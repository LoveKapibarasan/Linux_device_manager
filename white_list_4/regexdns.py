#!/usr/bin/env python3
from dnslib.server import DNSServer, BaseResolver
from dnslib import DNSRecord, RCODE
import re, socket, sys, time, os, signal

WHITELIST_FILE = "white-list.csv"
ALLOW = []

def load_whitelist():
    global ALLOW
    rules = []
    try:
        with open(WHITELIST_FILE, "r") as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith("#"):
                    continue
                try:
                    rules.append(re.compile(line, re.IGNORECASE))
                except re.error as e:
                    print(f"[ERROR] invalid regex '{line}': {e}")
        ALLOW = rules
        print(f"[INFO] Loaded {len(ALLOW)} whitelist rules")
    except FileNotFoundError:
        print(f"[WARN] No whitelist file at {WHITELIST_FILE}")
        ALLOW = []

def is_allowed(qname: str) -> bool:
    return any(r.match(qname) for r in ALLOW)

class RegexProxy(BaseResolver):
    def __init__(self, forward_host="127.0.0.1", forward_port=5353):
        self.forward_host = forward_host
        self.forward_port = forward_port

    def resolve(self, request, handler):
        qname = str(request.q.qname).rstrip(".")
        load_whitelist()  # reload each query (can optimize later)
        if not is_allowed(qname):
            print(f"[BLOCK] {qname}")
            reply = request.reply()
            reply.header.rcode = RCODE.NXDOMAIN
            return reply
        print(f"[ALLOW] {qname}")
        # forward
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.sendto(request.pack(), (self.forward_host, self.forward_port))
        data, _ = sock.recvfrom(4096)
        return DNSRecord.parse(data)

def kill_port_53():
    # Kill anything listening on 53
    os.system("fuser -k 53/udp || true")
    os.system("fuser -k 53/tcp || true")

if __name__ == "__main__":
    kill_port_53()
    load_whitelist()
    resolver = RegexProxy()
    server = DNSServer(resolver, port=53, address="127.0.0.1", tcp=True)
    print("[INFO] Regex DNS proxy running on :53 → forward to :5353")
    server.start()
