#!/bin/bash
# ============================================================
#   FazzPedia||Vpn - Wireguard User Management
# ============================================================
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'
MYIP=$(curl -s ipinfo.io/ip)
SERVER_PUB=$(cat /etc/wireguard/server_public.key)

addwg() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}      FazzPedia||Vpn - Create Wireguard Account${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
read -p " Username        : " USERNAME
read -p " Expired (days)  : " DAYS
EXPDATE=$(date -d "+${DAYS} days" +"%Y-%m-%d")

# Generate client keys
CLIENT_PRIV=$(wg genkey)
CLIENT_PUB=$(echo "$CLIENT_PRIV" | wg pubkey)
CLIENT_PSK=$(wg genpsk)

# Get next available IP
LAST_IP=$(grep "AllowedIPs" /etc/wireguard/wg0.conf | tail -1 | grep -oP '10\.66\.66\.\K\d+' | tail -1)
if [ -z "$LAST_IP" ]; then LAST_IP=1; fi
CLIENT_IP="10.66.66.$((LAST_IP + 1))"

# Add peer to server config
cat >> /etc/wireguard/wg0.conf <<EOF

# Client: ${USERNAME} | Exp: ${EXPDATE}
[Peer]
PublicKey = ${CLIENT_PUB}
PresharedKey = ${CLIENT_PSK}
AllowedIPs = ${CLIENT_IP}/32
EOF

# Create client config
mkdir -p /etc/wireguard/clients
cat > /etc/wireguard/clients/${USERNAME}.conf <<EOF
[Interface]
PrivateKey = ${CLIENT_PRIV}
Address = ${CLIENT_IP}/24
DNS = 8.8.8.8, 8.8.4.4

[Peer]
PublicKey = ${SERVER_PUB}
PresharedKey = ${CLIENT_PSK}
Endpoint = ${MYIP}:7070
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

wg addconf wg0 <(echo "[Peer]
PublicKey = ${CLIENT_PUB}
PresharedKey = ${CLIENT_PSK}
AllowedIPs = ${CLIENT_IP}/32") 2>/dev/null || systemctl restart wg-quick@wg0

echo "$USERNAME $EXPDATE $CLIENT_PUB" >> /etc/fazzpedia/wg_accounts.conf

clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}      FazzPedia||Vpn - Wireguard Account Info${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${YELLOW}Username   :${NC} $USERNAME"
echo -e " ${YELLOW}IP Client  :${NC} $CLIENT_IP"
echo -e " ${YELLOW}Expired    :${NC} $EXPDATE"
echo -e " ${YELLOW}Server     :${NC} $MYIP:7070"
echo ""
echo -e " ${WHITE}Client Config saved to: /etc/wireguard/clients/${USERNAME}.conf${NC}"
echo ""
if command -v qrencode &>/dev/null; then
    echo -e " ${WHITE}QR Code:${NC}"
    qrencode -t ansiutf8 < /etc/wireguard/clients/${USERNAME}.conf
fi
echo -e "${CYAN}============================================================${NC}"
}

delwg() {
clear
read -p " Username : " USERNAME
CLIENT_PUB=$(grep -A3 "Client: ${USERNAME}" /etc/wireguard/wg0.conf | grep "PublicKey" | awk '{print $3}')
if [ ! -z "$CLIENT_PUB" ]; then
    wg set wg0 peer "$CLIENT_PUB" remove 2>/dev/null
    # Remove from config
    python3 - <<PYEOF
import re
with open("/etc/wireguard/wg0.conf") as f: content = f.read()
pattern = r'\n# Client: ${USERNAME}.*?(?=\n# Client:|\Z)'
content = re.sub(pattern, '', content, flags=re.DOTALL)
with open("/etc/wireguard/wg0.conf","w") as f: f.write(content)
PYEOF
fi
rm -f /etc/wireguard/clients/${USERNAME}.conf
sed -i "/^${USERNAME} /d" /etc/fazzpedia/wg_accounts.conf
echo -e "${GREEN}[OK] Wireguard user '${USERNAME}' deleted.${NC}"
}

renewwg() {
read -p " Username      : " USERNAME
read -p " Extend (days) : " DAYS
NEWDATE=$(date -d "+${DAYS} days" +"%Y-%m-%d")
sed -i "s/^${USERNAME} [0-9-]* /${USERNAME} ${NEWDATE} /" /etc/fazzpedia/wg_accounts.conf
echo -e "${GREEN}[OK] Wireguard '${USERNAME}' renewed until ${NEWDATE}${NC}"
}

case "$1" in
    del)   delwg ;;
    renew) renewwg ;;
    *)     addwg ;;
esac
