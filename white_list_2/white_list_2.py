#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
完全版: BlockListを常時最優先に評価し、Whitelistはサブドメイン含め許可。
- dnsmasq と ipset 連携で A/AAAA 解決時に自動で WHITELIST/BLOCKLIST に積む
- OUTPUTチェーンの先頭に BlockList DROP を明示的に挿入（-I 1）
- QUIC(UDP/443) も BlockList で落ちる。Whitelist側は 80/443(TCP) と 443(UDP) を許可
- 平日/週末のブロック時間帯に合わせて、全体のデフォルトDROPを切り替え

前提:
- dnsmasq が導入済み
- systemd-resolved を利用し、lo に 127.0.0.1/::1 を向ける（本スクリプトで設定）
- white_list_extractor.extract_url(csv_path) が1列目のドメインを返す

配置例:
  スクリプト: /opt/white_list/white_list_2.py
  allow CSV : /opt/white_list/white_list.csv
  block CSV : /opt/white_list/block_list.csv
  dnsmasq設定: /etc/dnsmasq.d/whitelist.conf （本スクリプトが生成）
"""

import subprocess
import time
from datetime import datetime
from white_list_extractor import extract_url
from typing import Iterable

WHITE_CSV = "/opt/white_list/white_list.csv"
BLOCK_CSV = "/opt/white_list/block_list.csv"

DNSMASQ_CONF   = "/etc/dnsmasq.d/whitelist.conf"
CHECK_INTERVAL = 5  # seconds

# Weekday settings (minutes in each hour)
WEEKDAY_START = 55
WEEKDAY_END   = 59

# Weekend settings
WEEKEND_START = 30
WEEKEND_END   = 59

# --------------------------- Helpers ---------------------------

def _run(cmd: list[str], **kw) -> subprocess.CompletedProcess:
    """Run a command; do not raise on failure by default."""
    kw.setdefault("check", False)
    return subprocess.run(cmd, **kw)

# ---------------- dnsmasq/ipset sync ----------------

def write_dnsmasq_config(allow_domains: Iterable[str], block_domains: Iterable[str]) -> None:
    """
    Generate /etc/dnsmasq.d/whitelist.conf with ipset lines so that
    *.domain gets added into WHITELIST4/6 and BLOCKLIST4/6 automatically
    on DNS resolution. Avoid duplicates.
    """
    lines = [
        "listen-address=127.0.0.1,::1",
        "bind-interfaces",
    ]

    seen = set()
    for d in allow_domains:
        d = (d or '').strip().lower()
        if not d or d in seen:
            continue
        seen.add(d)
        lines.append(f"ipset=/{d}/WHITELIST4,WHITELIST6")

    seen_block = set()
    for d in block_domains:
        d = (d or '').strip().lower()
        if not d or d in seen_block:
            continue
        seen_block.add(d)
        lines.append(f"ipset=/{d}/BLOCKLIST4,BLOCKLIST6")

    content = "\n".join(lines) + "\n"
    with open(DNSMASQ_CONF, "w") as f:
        f.write(content)

    # Reload dnsmasq and point systemd-resolved to it
    _run(["sudo", "systemctl", "restart", "dnsmasq"])
    _run(["sudo", "resolvectl", "dns", "lo", "127.0.0.1", "::1"])
    _run(["sudo", "resolvectl", "flush-caches"])

# ---------------- Firewall rules ----------------

def apply_firewall_base() -> None:
    """
    Build OUTPUT policy for allowlist browsing, with BlockList taking precedence.
    This function prepares whitelist sets and base ACCEPTs; the BlockList DROP
    insertion itself happens in apply_block_list() which always inserts at the
    very top so it wins over ACCEPTs below.
    """
    # ipset create (exist OK). Whitelist expires to auto-refresh via DNS.
    _run(["sudo", "ipset", "create", "WHITELIST4", "hash:ip", "timeout", "3600", "-exist"])
    _run(["sudo", "ipset", "create", "WHITELIST6", "hash:ip", "family", "inet6", "timeout", "3600", "-exist"])

    # Flush OUTPUT to reconstruct; policy will be set at the end.
    _run(["sudo", "iptables",  "-F", "OUTPUT"])
    _run(["sudo", "ip6tables", "-F", "OUTPUT"])

    # (1) Loopback first
    _run(["sudo", "iptables",  "-A", "OUTPUT", "-o", "lo", "-j", "ACCEPT"])
    _run(["sudo", "ip6tables", "-A", "OUTPUT", "-o", "lo", "-j", "ACCEPT"])

    # (2) DNS via dnsmasq (both UDP/TCP 53)
    for proto in ("udp", "tcp"):
        _run(["sudo", "iptables",  "-A", "OUTPUT", "-p", proto, "--dport", "53", "-j", "ACCEPT"])
        _run(["sudo", "ip6tables", "-A", "OUTPUT", "-p", proto, "--dport", "53", "-j", "ACCEPT"])

    # (3) PMTU/ICMP
    _run(["sudo", "iptables",  "-A", "OUTPUT", "-p", "icmp",   "-j", "ACCEPT"])
    _run(["sudo", "ip6tables", "-A", "OUTPUT", "-p", "icmpv6", "-j", "ACCEPT"])

    # (4) Web via WHITELIST ipset only
    _run(["sudo", "iptables",  "-A", "OUTPUT", "-p", "tcp", "-m", "multiport", "--dports", "80,443",
          "-m", "set", "--match-set", "WHITELIST4", "dst", "-j", "ACCEPT"])
    _run(["sudo", "ip6tables", "-A", "OUTPUT", "-p", "tcp", "-m", "multiport", "--dports", "80,443",
          "-m", "set", "--match-set", "WHITELIST6", "dst", "-j", "ACCEPT"])

    # (5) HTTP/3 (QUIC) also allowed for whitelisted IPs only
    _run(["sudo", "iptables",  "-A", "OUTPUT", "-p", "udp", "--dport", "443",
          "-m", "set", "--match-set", "WHITELIST4", "dst", "-j", "ACCEPT"])
    _run(["sudo", "ip6tables", "-A", "OUTPUT", "-p", "udp", "--dport", "443",
          "-m", "set", "--match-set", "WHITELIST6", "dst", "-j", "ACCEPT"])

    # (6) 既存接続: これは BlockList DROP をチェーン先頭に入れた後でも下に置く
    _run(["sudo", "iptables",  "-A", "OUTPUT", "-m", "conntrack", "--ctstate", "ESTABLISHED,RELATED", "-j", "ACCEPT"])
    _run(["sudo", "ip6tables", "-A", "OUTPUT", "-m", "conntrack", "--ctstate", "ESTABLISHED,RELATED", "-j", "ACCEPT"])

    # Default DROP at the end
    _run(["sudo", "iptables",  "-P", "OUTPUT", "DROP"])
    _run(["sudo", "ip6tables", "-P", "OUTPUT", "DROP"])


def clear_firewall() -> None:
    """Allow all (flush OUTPUT and set default ACCEPT)."""
    _run(["sudo", "iptables",  "-F", "OUTPUT"])
    _run(["sudo", "ip6tables", "-F", "OUTPUT"])
    _run(["sudo", "iptables",  "-P", "OUTPUT", "ACCEPT"])
    _run(["sudo", "ip6tables", "-P", "OUTPUT", "ACCEPT"])


def apply_block_list(domains: Iterable[str]) -> None:
    """
    Ensure BlockList ipsets exist and DROP rules are at the absolute top of OUTPUT.
    Also load current A/AAAA once (dnsmasq will auto-add on future resolutions).
    """
    # Create ipsets for blocked domains
    _run(["sudo", "ipset", "create", "BLOCKLIST4", "hash:ip", "-exist"])
    _run(["sudo", "ipset", "create", "BLOCKLIST6", "hash:ip", "family", "inet6", "-exist"])

    # Prime ipsets once using dig (best-effort; dnsmasq will keep them fresh)
    for d in domains:
        d = (d or '').strip().lower()
        if not d:
            continue
        res4 = subprocess.run(["dig", "+short", "A", d], capture_output=True, text=True)
        for ip in res4.stdout.splitlines():
            if ip:
                _run(["sudo", "ipset", "add", "BLOCKLIST4", ip, "-exist"])
        res6 = subprocess.run(["dig", "+short", "AAAA", d], capture_output=True, text=True)
        for ip in res6.stdout.splitlines():
            if ip:
                _run(["sudo", "ipset", "add", "BLOCKLIST6", ip, "-exist"])

    # Remove any existing DROP rules (if present)
    _run(["sudo", "iptables",  "-D", "OUTPUT", "-m", "set", "--match-set", "BLOCKLIST4", "dst", "-j", "DROP"])  # may fail; ignore
    _run(["sudo", "ip6tables", "-D", "OUTPUT", "-m", "set", "--match-set", "BLOCKLIST6", "dst", "-j", "DROP"])  # may fail; ignore

    # Insert BlockList DROP at the very top so it wins over any ACCEPT rules below
    _run(["sudo", "iptables",  "-I", "OUTPUT", "1", "-m", "set", "--match-set", "BLOCKLIST4", "dst", "-j", "DROP"])
    _run(["sudo", "ip6tables", "-I", "OUTPUT", "1", "-m", "set", "--match-set", "BLOCKLIST6", "dst", "-j", "DROP"])

# ---------------- Time window logic ----------------

def block_time_check() -> bool:
    """
    Check if the current minute is within the blocking window,
    with START/END decided dynamically based on weekday/weekend.
    Returns True if blocking window is active (enforce firewall), else False.
    """
    now = datetime.now()
    today = now.weekday()   # 0=Mon, 6=Sun
    current_hour = now.hour
    if today < 5 and 9 < current_hour < 17:
        start = WEEKDAY_START
        end = WEEKDAY_END
    else:
        start = WEEKEND_START
        end = WEEKEND_END
    minute = now.minute
    return start <= minute <= end

# ---------------- Main ----------------

if __name__ == "__main__":
    last_state = None

    # Load domain lists and sync dnsmasq/ipset mappings once at startup
    white_list_domains = extract_url(WHITE_CSV)
    black_list_domains = extract_url(BLOCK_CSV)
    write_dnsmasq_config(white_list_domains, black_list_domains)

    # Always ensure BlockList DROP is present
    apply_block_list(black_list_domains)

    while True:
        state = block_time_check()
        if state != last_state:
            if state:
                # Enforce default-DROP allowlist policy
                apply_firewall_base()
            else:
                # Allow all
                clear_firewall()
            # After base changes, re-insert BlockList DROP at top
            apply_block_list(black_list_domains)
            last_state = state
        time.sleep(CHECK_INTERVAL)