import re
import os
import socket
import threading
from datetime import datetime
from functools import lru_cache

from dnslib.server import DNSServer, BaseResolver
from dnslib import DNSRecord, RCODE


SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

WHITELIST_FILE = os.path.join(SCRIPT_DIR ,"white-list.csv")

LOG_FILE = os.path.join(os.path.expanduser("~"), "regexdns.log")

def notify(content):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    message = f"[{timestamp}] {content}"

    print(message, flush=True)

    try:
        with open(LOG_FILE, "a") as f:
            f.write(message + "\n")
    except Exception as e:
        print(f"Failed to write log: {e}")

def load_whitelist():
    patterns = []
    with open(WHITELIST_FILE, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            patterns.append(line)
    notify(f"[INFO] Loaded {len(patterns)} whitelist patterns")
    return patterns

class RegexProxy(BaseResolver):
    def __init__(self, forward_host="8.8.8.8", forward_port=53):
        patterns = load_whitelist()
        self.regex = re.compile("(" + ")|(".join(patterns) + ")", re.IGNORECASE) if patterns else None
        self.forward = (forward_host, forward_port)

    @lru_cache(maxsize=50000)
    def _is_allowed_cached(self, qname):
        if not self.regex:
            return False
        return self.regex.search(qname) is not None

    def _is_allowed(self, qname):
        return self._is_allowed_cached(qname)

    def resolve(self, request, handler):
        qname = str(request.q.qname).rstrip(".")

        if not self._is_allowed(qname):
            notify(f"[BLOCK] {qname}")
            reply = request.reply()
            reply.header.rcode = RCODE.NXDOMAIN
            return reply

        notify(f"[ALLOW] {qname}")

        # Forward to upstream (local dnsmasq/unbound)
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.settimeout(2)
        sock.connect(self.forward)
        sock.sendall(request.pack())
        data = sock.recv(4096)
        try:
            sock.sendto(request.pack(), self.forward)
            data, _ = sock.recvfrom(4096)
            return DNSRecord.parse(data)
        except:
            reply = request.reply()
            reply.header.rcode = RCODE.SERVFAIL
            return reply

if __name__ == "__main__":
    resolver = RegexProxy()
    notify("[INFO] RegexProxy running on 127.0.0.1:53 --> 127.0.0.1:5354")

    try:
        server = DNSServer(
            resolver,
            port=53,
            address="0.0.0.0",
            tcp=True,
        )
        server.start_thread()
        print("Server thread started")

        # ★DNSを止めない永続ループ
        stopper = threading.Event()
        stopper.wait()

    except Exception as e:
        print("Failed to start server:", e)
