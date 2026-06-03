#!/bin/bash
# ============================================================
#   FazzPedia||Vpn - Wireguard Installer
#   Support: Ubuntu 20.04 / 22.04 / 24.04
# ============================================================

RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'

MYIP=$(curl -s ipinfo.io/ip)
NET=$(ip -o -4 route show to default | awk '{print $5}')

echo -e "${YELLOW}[WIREGUARD] Installing Wireguard...${NC}"

apt install -y wireguard wireguard-tools qrencode

# Generate server keys
mkdir -p /etc/wireguard
wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key
SERVER_PRIV=$(cat /etc/wireguard/server_private.key)
SERVER_PUB=$(cat /etc/wireguard/server_public.key)

cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = ${SERVER_PRIV}
Address = 10.66.66.1/24
ListenPort = 7070
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ${NET} -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ${NET} -j MASQUERADE
EOF

echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

echo "$SERVER_PUB" > /etc/wireguard/server_public.key
echo -e "${GREEN}[WIREGUARD] Done! Server Public Key: ${SERVER_PUB}${NC}"
