#!/bin/bash
apt update -y && apt install -y git python3 iproute2
rm -rf /opt/mtp
git clone -b stable https://github.com/alexbers/mtprotoproxy.git /opt/mtp

cat << 'EOF' > /opt/mtp/config.py
PORT = 8443
USERS = {"tg": "24a8ff74c95e9cc64ded28d2107e8306"}
MODES = {"classic": False, "secure": False, "tls": True}
TLS_DOMAIN = "www.microsoft.com"
AD_TAG = "61b82566cdc6a422993e81666858ede7"
EOF

pkill -9 python3 2>/dev/null
nohup python3 /opt/mtp/mtprotoproxy.py >/dev/null 2>&1 &

IFACE=$(ip -o -4 route show to default | awk '{print $5}')
tc qdisc replace dev $IFACE root tbf rate 20mbit burst 128kbit latency 400ms

IP=$(curl -s ifconfig.me)
echo "=========================================="
echo "PROXY READY! Copy your link:"
echo "tg://proxy?server=$IP&port=8443&secret=ee24a8ff74c95e9cc64ded28d2107e83067777772e6d6963726f736f66742e636f6d"
echo "=========================================="
