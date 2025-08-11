# /opt/white_list/white_list_2.py
import subprocess
import time
from datetime import datetime
from white_list_extractor import extract_whitelist_domains

WHITELIST_FILE = "/opt/white_list/bookmarks.html"
DNSMASQ_CONF   = "/etc/dnsmasq.d/whitelist.conf"
CHECK_INTERVAL = 5  # seconds

# Weekday settings
WEEKDAY_START = 00
WEEKDAY_END = 55

# Weekend settings
WEEKEND_START = 30
WEEKEND_END = 59

today = datetime.now().weekday()
current_hour = datetime.now().hour
# weekday() returns 0=Monday ... 6=Sunday

if today < 5 and 9 < current_hour < 17:  # Monday–Friday
    START = WEEKDAY_START
    END = WEEKDAY_END
else:  # Saturday–Sunday
    START = WEEKEND_START
    END = WEEKEND_END


def write_dnsmasq_whitelist(domains):
    """
    Generate /etc/dnsmasq.d/whitelist.conf with ipset lines so that
    *.domain gets added into WHITELIST4/6 automatically on DNS resolve.
    """
    lines = [
        "listen-address=127.0.0.1,::1",
        "bind-interfaces",
    ]

    seen = set()
    for d in domains:
        d = d.strip().lower()
        if not d or d in seen:
            continue
        seen.add(d)
        # 同一サイト全サブドメインを対象にする
        lines.append(f"ipset=/{d}/WHITELIST4,WHITELIST6")

    content = "\n".join(lines) + "\n"
    with open(DNSMASQ_CONF, "w") as f:
        f.write(content)

    # 反映
    subprocess.run(["sudo", "systemctl", "restart", "dnsmasq"], check=False)
    # systemd-resolved を併用しているなら DNS を dnsmasq に向ける
    subprocess.run(["sudo", "resolvectl", "dns", "lo", "127.0.0.1", "::1"], check=False)
    subprocess.run(["sudo", "resolvectl", "flush-caches"], check=False)

def apply_firewall_base():
    # ipset 作成（存在すれば -exist でOK）
    subprocess.run(["sudo", "ipset", "create", "WHITELIST4", "hash:ip", "timeout", "3600", "-exist"])
    subprocess.run(["sudo", "ipset", "create", "WHITELIST6", "hash:ip", "family", "inet6", "timeout", "3600", "-exist"])

    # OUTPUT 再構成
    subprocess.run(["sudo", "iptables",  "-F", "OUTPUT"])
    subprocess.run(["sudo", "ip6tables", "-F", "OUTPUT"])

    # 既存接続の継続・localhost
    subprocess.run(["sudo", "iptables",  "-A", "OUTPUT", "-m", "conntrack", "--ctstate", "ESTABLISHED,RELATED", "-j", "ACCEPT"])
    subprocess.run(["sudo", "ip6tables", "-A", "OUTPUT", "-m", "conntrack", "--ctstate", "ESTABLISHED,RELATED", "-j", "ACCEPT"])
    subprocess.run(["sudo", "iptables",  "-A", "OUTPUT", "-o", "lo", "-j", "ACCEPT"])
    subprocess.run(["sudo", "ip6tables", "-A", "OUTPUT", "-o", "lo", "-j", "ACCEPT"])

    # DNS を TCP/UDP 両方許可（dnsmasq 利用）
    for proto in ("udp", "tcp"):
        subprocess.run(["sudo", "iptables",  "-A", "OUTPUT", "-p", proto, "--dport", "53", "-j", "ACCEPT"])
        subprocess.run(["sudo", "ip6tables", "-A", "OUTPUT", "-p", proto, "--dport", "53", "-j", "ACCEPT"])

    # PMTU など
    subprocess.run(["sudo", "iptables",  "-A", "OUTPUT", "-p", "icmp",   "-j", "ACCEPT"])
    subprocess.run(["sudo", "ip6tables", "-A", "OUTPUT", "-p", "icmpv6", "-j", "ACCEPT"])

    # Web は ipset（同一サイトのみ）に宛先が入っている場合だけ許可
    subprocess.run(["sudo", "iptables",  "-A", "OUTPUT", "-p", "tcp", "-m", "multiport", "--dports", "80,443",
                    "-m", "set", "--match-set", "WHITELIST4", "dst", "-j", "ACCEPT"])
    subprocess.run(["sudo", "ip6tables", "-A", "OUTPUT", "-p", "tcp", "-m", "multiport", "--dports", "80,443",
                    "-m", "set", "--match-set", "WHITELIST6", "dst", "-j", "ACCEPT"])

    # （任意）HTTP/3(QUIC) を許可
    subprocess.run(["sudo", "iptables",  "-A", "OUTPUT", "-p", "udp", "--dport", "443",
                    "-m", "set", "--match-set", "WHITELIST4", "dst", "-j", "ACCEPT"])
    subprocess.run(["sudo", "ip6tables", "-A", "OUTPUT", "-p", "udp", "--dport", "443",
                    "-m", "set", "--match-set", "WHITELIST6", "dst", "-j", "ACCEPT"])

    # 最後にデフォルト DROP
    subprocess.run(["sudo", "iptables",  "-P", "OUTPUT", "DROP"])
    subprocess.run(["sudo", "ip6tables", "-P", "OUTPUT", "DROP"])

def clear_firewall():
    subprocess.run(["sudo", "iptables",  "-F", "OUTPUT"])
    subprocess.run(["sudo", "ip6tables", "-F", "OUTPUT"])
    subprocess.run(["sudo", "iptables",  "-P", "OUTPUT", "ACCEPT"])
    subprocess.run(["sudo", "ip6tables", "-P", "OUTPUT", "ACCEPT"])

def block_time_check():
    minute = datetime.now().minute
    return START <= minute <= END

if __name__ == "__main__":
    last_state = None

    # 起動時に一度、dnsmasq の allowlist を同期
    domains = extract_whitelist_domains(WHITELIST_FILE)
    write_dnsmasq_whitelist(domains)

    while True:
        state = block_time_check()
        if state != last_state:
            if state:
                # ルール適用
                apply_firewall_base()
            else:
                # 全許可に戻す
                clear_firewall()
            last_state = state
        time.sleep(CHECK_INTERVAL)
