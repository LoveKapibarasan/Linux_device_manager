import subprocess
import socket
from urllib.parse import urlparse
from datetime import datetime
from white_list_extractor import extract_whitelist_domains

WHITELIST_FILE = "/opt/white_list/bookmarks.html"

START = 50

def apply_firewall_whitelist(bookmarks_file):
    domains = extract_whitelist_domains(bookmarks_file)

    # 初期化（IPv4 / IPv6）
    subprocess.run(["sudo", "iptables", "-F", "OUTPUT"])
    subprocess.run(["sudo", "ip6tables", "-F", "OUTPUT"])

    # ループバック許可
    subprocess.run(["sudo", "iptables", "-A", "OUTPUT", "-o", "lo", "-j", "ACCEPT"])
    subprocess.run(["sudo", "ip6tables", "-A", "OUTPUT", "-o", "lo", "-j", "ACCEPT"])

    # DNS許可 (IPv4 / IPv6)
    subprocess.run(["sudo", "iptables", "-A", "OUTPUT", "-p", "udp", "--dport", "53", "-j", "ACCEPT"])
    subprocess.run(["sudo", "ip6tables", "-A", "OUTPUT", "-p", "udp", "--dport", "53", "-j", "ACCEPT"])

    for domain in domains:
        try:
            parsed = urlparse(domain if "://" in domain else "http://" + domain)
            hostname = parsed.hostname
            if not hostname:
                continue

            # IPv4 & IPv6 取得
            for family in (socket.AF_INET, socket.AF_INET6):
                try:
                    infos = socket.getaddrinfo(hostname, None, family, socket.SOCK_STREAM)
                    for info in infos:
                        ip = info[4][0]
                        if family == socket.AF_INET:
                            subprocess.run(["sudo", "iptables", "-A", "OUTPUT", "-d", ip, "-j", "ACCEPT"])
                        else:
                            subprocess.run(["sudo", "ip6tables", "-A", "OUTPUT", "-d", ip, "-j", "ACCEPT"])
                        print(f"Allowed: {hostname} ({ip})")
                except socket.gaierror:
                    pass

        except Exception as e:
            print(f"Failed to resolve {domain}: {e}")

    # 最後にDROP設定
    subprocess.run(["sudo", "iptables", "-P", "OUTPUT", "DROP"])
    subprocess.run(["sudo", "ip6tables", "-P", "OUTPUT", "DROP"])

def block_time_check():
    minute = datetime.now().minute
    return minute < START

if __name__ == "__main__":
    if block_time_check():
        apply_firewall_whitelist(WHITELIST_FILE)
