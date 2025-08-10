import subprocess
import socket
import time
from urllib.parse import urlparse
from datetime import datetime
from white_list_extractor import extract_whitelist_domains

WHITELIST_FILE = "/opt/white_list/bookmarks.html"
START = 10    # 開始分
END = 59      # 終了分
CHECK_INTERVAL = 60  # 秒ごとにチェック

def apply_firewall_whitelist(bookmarks_file):
    domains = extract_whitelist_domains(bookmarks_file)

    subprocess.run(["sudo", "iptables", "-F", "OUTPUT"])
    subprocess.run(["sudo", "ip6tables", "-F", "OUTPUT"])

    subprocess.run(["sudo", "iptables", "-A", "OUTPUT", "-o", "lo", "-j", "ACCEPT"])
    subprocess.run(["sudo", "ip6tables", "-A", "OUTPUT", "-o", "lo", "-j", "ACCEPT"])

    subprocess.run(["sudo", "iptables", "-A", "OUTPUT", "-p", "udp", "--dport", "53", "-j", "ACCEPT"])
    subprocess.run(["sudo", "ip6tables", "-A", "OUTPUT", "-p", "udp", "--dport", "53", "-j", "ACCEPT"])

    for domain in domains:
        try:
            parsed = urlparse(domain if "://" in domain else "http://" + domain)
            hostname = parsed.hostname
            if not hostname:
                continue

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

    subprocess.run(["sudo", "iptables", "-P", "OUTPUT", "DROP"])
    subprocess.run(["sudo", "ip6tables", "-P", "OUTPUT", "DROP"])
    print("Firewall whitelist applied.")

def clear_firewall():
    subprocess.run(["sudo", "iptables", "-F", "OUTPUT"])
    subprocess.run(["sudo", "ip6tables", "-F", "OUTPUT"])
    subprocess.run(["sudo", "iptables", "-P", "OUTPUT", "ACCEPT"])
    subprocess.run(["sudo", "ip6tables", "-P", "OUTPUT", "ACCEPT"])
    print("Firewall cleared.")

def block_time_check():
    minute = datetime.now().minute
    return  START <= minute <= END

if __name__ == "__main__":
    last_state = None
    while True:
        state = block_time_check()
        if state != last_state:
            if state:
                apply_firewall_whitelist(WHITELIST_FILE)
            else:
                clear_firewall()
            last_state = state
        time.sleep(CHECK_INTERVAL)
