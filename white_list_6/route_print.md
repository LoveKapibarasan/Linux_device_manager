# Windows

1. Interface List
```powershell
33...........................WireGuard Tunnel
7...00 09 0f aa 00 01 ......Fortinet SSL VPN Virtual Ethernet Adapter
5...a8 5e 45 2c c6 f7 ......Realtek PCIe GbE Family Controller
16...00 09 0f fe 00 01 ......Fortinet Virtual Ethernet Adapter (NDIS 6.30)
1...........................Software Loopback Interface 1
```

2. IPv4 Route Table
```powershell
Network Destination        Netmask          Gateway       Interface  Metric
0.0.0.0                     0.0.0.0        172.xx.xx.xx    172.xx.xx.xx   35
0.0.0.0                     0.0.0.0        On-link         10.0.0.2       0
10.0.0.0                     255.255.255.0  On-link         10.0.0.2       256
10.0.0.2                     255.255.255.255 On-link        10.0.0.2       256
```
* Metrics = Priority(Smaller is more important)
* gateway: Bridge
* Netmask: Range

**On Link**
* PC can directly reach.