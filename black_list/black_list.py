import csv
import socket
import subprocess

CSV_FILE = "blacklist.csv"
HOSTS_FILE = "/etc/hosts"

def load_blacklist(path):
    with open(path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        return [row["address"].strip() for row in reader if row["address"].strip()]

def resolve_to_ip(address):
    try:
        ip = socket.gethostbyname(address)
        print(f"[RESOLVE] {address} -> {ip}")
        return ip
    except socket.gaierror:
        print(f"[WARN] {address} を解決できませんでした")
        return None

def redirect_to_loopback(ip):
    cmd = ["sudo", "iptables", "-t", "nat", "-A", "OUTPUT", "-d", ip,
           "-j", "DNAT", "--to-destination", "127.0.0.1"]
    subprocess.run(cmd, check=True)
    print(f"[REDIRECT] {ip} -> 127.0.0.1")

def append_hosts(domains):
    with open(HOSTS_FILE, "a", encoding="utf-8") as f:
        for d in domains:
            line = f"127.0.0.1 {d}\n"
            f.write(line)
            print(f"[HOSTS] {line.strip()}")

if __name__ == "__main__":
    domains = load_blacklist(CSV_FILE)
    for addr in domains:
        ip = resolve_to_ip(addr)
        if ip:
            redirect_to_loopback(ip)
    append_hosts(domains)
