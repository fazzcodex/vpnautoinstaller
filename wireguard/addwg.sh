#!/bin/bash
# addwg.sh
GREEN='\033[0;32m'; NC='\033[0m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'
MYIP=$(cat /etc/fazzpedia/myip 2>/dev/null || curl -s ipinfo.io/ip)
SERVER_PUB=$(cat /etc/wireguard/server_public.key)
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${YELLOW}         Create Wireguard Account${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -ne " Nama/Remark   : "; read REMARK
echo -ne " Expired (hari): "; read DAYS

# Hitung IP client berikutnya
LAST=$(grep -c "^#" /etc/wireguard/wg0.conf 2>/dev/null || echo 0)
CLIENT_IP="10.7.0.$((LAST+2))"

CLIENT_KEY=$(wg genkey)
CLIENT_PUB=$(echo "$CLIENT_KEY" | wg pubkey)
EXPIRED=$(date -d "$DAYS days" +"%Y-%m-%d")

# Tambah ke server config
cat >> /etc/wireguard/wg0.conf <<-END

# $REMARK | $EXPIRED
[Peer]
PublicKey = ${CLIENT_PUB}
AllowedIPs = ${CLIENT_IP}/32
END

# Client config
CLIENT_CONF="/tmp/wg-${REMARK}.conf"
cat > "$CLIENT_CONF" <<-END
[Interface]
PrivateKey = ${CLIENT_KEY}
Address = ${CLIENT_IP}/24
DNS = 8.8.8.8

[Peer]
PublicKey = ${SERVER_PUB}
Endpoint = ${MYIP}:7070
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
END

# Simpan data
mkdir -p /etc/wireguard/users
echo "$REMARK|$CLIENT_PUB|$CLIENT_IP|$EXPIRED" >> /etc/wireguard/users/wg.db

systemctl restart wg-quick@wg0

clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${GREEN}         Wireguard Account Created!${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${WHITE}Remark     : ${YELLOW}$REMARK${NC}"
echo -e " ${WHITE}Client IP  : ${YELLOW}$CLIENT_IP${NC}"
echo -e " ${WHITE}Server     : ${YELLOW}$MYIP:7070${NC}"
echo -e " ${WHITE}Expired    : ${YELLOW}$EXPIRED${NC}"
echo -e "${CYAN}────────── Client Config ────────────────────${NC}"
cat "$CLIENT_CONF"
echo -e "${CYAN}============================================================${NC}"
echo -e " Config saved to: ${YELLOW}$CLIENT_CONF${NC}"
