#!/bin/bash
# addvless.sh
GREEN='\033[0;32m'; NC='\033[0m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'
MYIP=$(cat /etc/fazzpedia/myip 2>/dev/null || curl -s ipinfo.io/ip)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "$MYIP")
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${YELLOW}         Create VLess Account${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -ne " Nama/Remark   : "; read REMARK
echo -ne " Expired (hari): "; read DAYS
UUID=$(cat /proc/sys/kernel/random/uuid)
EXPIRED=$(date -d "$DAYS days" +"%Y-%m-%d")
CONFIG="/etc/xray/config.json"
jq --arg uuid "$UUID" --arg email "$REMARK" \
  '(.inbounds[] | select(.tag | startswith("vless")) | .settings.clients) += [{"id": $uuid, "email": $email}]' \
  "$CONFIG" > /tmp/xray_tmp.json && mv /tmp/xray_tmp.json "$CONFIG"
mkdir -p /etc/xray/users
echo "$REMARK|$UUID|$EXPIRED|vless" >> /etc/xray/users/vmess.db
systemctl restart xray
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${GREEN}         Akun VLess Berhasil Dibuat!${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${WHITE}Remark  : ${YELLOW}$REMARK${NC}"
echo -e " ${WHITE}UUID    : ${YELLOW}$UUID${NC}"
echo -e " ${WHITE}Expired : ${YELLOW}$EXPIRED${NC}"
echo -e "${CYAN}──────────────── VLess TLS ──────────────────${NC}"
echo -e " ${WHITE}Host : ${YELLOW}$DOMAIN${NC}  Port: ${YELLOW}8442${NC}  Path: ${YELLOW}/vless${NC}  TLS: ${YELLOW}TLS${NC}"
echo -e "${CYAN}──────────────── VLess Non-TLS ──────────────${NC}"
echo -e " ${WHITE}Host : ${YELLOW}$MYIP${NC}  Port: ${YELLOW}8441${NC}  Path: ${YELLOW}/vless${NC}  TLS: ${YELLOW}None${NC}"
echo -e "${CYAN}============================================================${NC}"
