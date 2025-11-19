import socket
import time

PORT = 5356

# TCP
tcp_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
tcp_sock.bind(("127.0.0.1", PORT))
tcp_sock.listen()
print("TCP bind succeeded")

# UDP
udp_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
udp_sock.bind(("127.0.0.1", PORT))
print("UDP bind succeeded")

# 永久ループでソケットを維持
try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    tcp_sock.close()
    udp_sock.close()
    print("Sockets closed")
