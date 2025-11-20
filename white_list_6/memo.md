

curl ifconfig.me




```bash
sudo wg-quick down "$interface"
sudo wg-quick up "$interface"
```


```bash
sudo iptables -L FORWARD -n
# -L: Rule List
# -n: Do not resolve domain
sudo iptables -t nat -L POSTROUTING -n
# -t: Nat
```

**Ip Address Routes**

```bash
# Interface List
ip a
# IP Routes
sudo ip route show
```

**Check Own IP**

```bash
curl ifconfig.me
```

> Server IP address will be shown.


### Notes

* 10.0.0.x is problematic for AWS .


* Edit server's /etc/wireguard/server.conf 
```
[Peer]
PublicKey = xxxxxxxxxxxx
AllowedIPs = 10.10.0.2/32
# Change Server.conf here
Endpoint = IP:Port
```

* `eth0` → `ens5`: ens5 is newer name convention.