#!/usr/bin/env bash
sudo pacman -S bpftrace audit
sudo systemctl enable --now auditd

sudo bpftrace -e 'uprobe:/usr/lib/libc.so.6:getaddrinfo { printf("Host query: %s\n", str(arg0)); }'


# If some process calls, getaddrinfo("google.com", ...);
# Hook the first argument