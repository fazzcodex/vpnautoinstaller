#!/bin/bash
# addvmess.sh
GREEN='\033[0;32m'; NC='\033[0m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'
MYIP=$(cat /etc/fazzpedia/myip 2>/dev/null || curl -s ipinfo.io/ip)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "$MYIP")
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${YELLOW}         Create VMess Account${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -ne " Nama/Remark   : "; read REMARK
echo -ne " Expired (hari): "; read DAYS
UUID=$(cat /proc/sys/kernel/random/uuid)
EXPIRED=$(date -d "$DAYS days" +"%Y-%m-%d")

# Tambah ke xray config
CONFIG="/etc/xray/config.json"
jq --arg uuid "$UUID" --arg email "$REMARK" \
  '(.inbounds[] | select(.tag | startswith("vmess")) | .settings.clients) += [{"id": $uuid, "alterId": 0, "email": $email}]' \
  "$CONFIG" > /tmp/xray_tmp.json && mv /tmp/xray_tmp.json "$CONFIG"

# Simpan data user
mkdir -p /etc/xray/users
echo "$REMARK|$UUID|$EXPIRED|vmess" >> /etc/xray/users/vmess.db
systemctl restart xray

clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${GREEN}         Akun VMess Berhasil Dibuat!${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${WHITE}Remark     : ${YELLOW}$REMARK${NC}"
echo -e " ${WHITE}UUID       : ${YELLOW}$UUID${NC}"
echo -e " ${WHITE}Expired    : ${YELLOW}$EXPIRED${NC}"
echo -e "${CYAN}──────────────── VMess TLS ──────────────────${NC}"
echo -e " ${WHITE}Host       : ${YELLOW}$DOMAIN${NC}"
echo -e " ${WHITE}Port       : ${YELLOW}8443${NC}"
echo -e " ${WHITE}Network    : ${YELLOW}WebSocket${NC}"
echo -e " ${WHITE}Path       : ${YELLOW}/vmess${NC}"
echo -e " ${WHITE}TLS        : ${YELLOW}TLS${NC}"
echo -e "${CYAN}──────────────── VMess Non-TLS ──────────────${NC}"
echo -e " ${WHITE}Host       : ${YELLOW}$MYIP${NC}"
echo -e " ${WHITE}Port       : ${YELLOW}80${NC}"
echo -e " ${WHITE}Network    : ${YELLOW}WebSocket${NC}"
echo -e " ${WHITE}Path       : ${YELLOW}/vmess${NC}"
echo -e " ${WHITE}TLS        : ${YELLOW}None${NC}"
echo -e "${CYAN}============================================================${NC}"
