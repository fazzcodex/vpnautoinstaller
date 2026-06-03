#!/bin/bash
# wireguard.sh - installer
export DEBIAN_FRONTEND=noninteractive
GREEN='\033[0;32m'; NC='\033[0m'; YELLOW='\033[1;33m'
echo -e "${YELLOW}[Wireguard] Installing...${NC}"
apt-get install -y wireguard wireguard-tools
modprobe wireguard 2>/dev/null

mkdir -p /etc/wireguard
WG_KEY=$(wg genkey)
WG_PUB=$(echo "$WG_KEY" | wg pubkey)
echo "$WG_KEY" > /etc/wireguard/server_private.key
echo "$WG_PUB" > /etc/wireguard/server_public.key
chmod 600 /etc/wireguard/server_private.key

NET=$(ip -o -4 route show to default | awk '{print $5}')
cat > /etc/wireguard/wg0.conf <<-END
[Interface]
Address = 10.7.0.1/24
ListenPort = 7070
PrivateKey = ${WG_KEY}
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ${NET} -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ${NET} -j MASQUERADE
END

systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0
echo -e "${GREEN}[Wireguard] Done! Port 7070${NC}"
