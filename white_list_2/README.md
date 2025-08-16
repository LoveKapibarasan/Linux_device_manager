
```bash
sudo iptables  -F OUTPUT
sudo ip6tables -F OUTPUT
sudo iptables  -P OUTPUT ACCEPT
sudo ip6tables -P OUTPUT ACCEPT
```

```bash
#=== ipset 初期化 ===#
IPSET_NAME="DOH_BLOCK"

# ipset 自体の削除
ipset destroy "$IPSET_NAME" 2>/dev/null || true

#=== iptables 初期化 ===#
# OUTPUT チェーンから当該 DROP ルールを削除
while iptables -C OUTPUT -m set --match-set "$IPSET_NAME" dst -j DROP 2>/dev/null; do
    iptables -D OUTPUT -m set --match-set "$IPSET_NAME" dst -j DROP
done
```
