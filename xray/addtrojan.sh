#!/bin/bash
GREEN='\033[0;32m'; NC='\033[0m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'
MYIP=$(cat /etc/fazzpedia/myip 2>/dev/null || curl -s ipinfo.io/ip)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "$MYIP")
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${YELLOW}         Create Trojan Account${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -ne " Nama/Remark   : "; read REMARK
echo -ne " Password      : "; read PASS
echo -ne " Expired (hari): "; read DAYS
EXPIRED=$(date -d "$DAYS days" +"%Y-%m-%d")
CONFIG="/etc/xray/config.json"
jq --arg pw "$PASS" --arg email "$REMARK" \
  '(.inbounds[] | select(.tag == "trojan") | .settings.clients) += [{"password": $pw, "email": $email}]' \
  "$CONFIG" > /tmp/xray_tmp.json && mv /tmp/xray_tmp.json "$CONFIG"
mkdir -p /etc/xray/users
echo "$REMARK|$PASS|$EXPIRED|trojan" >> /etc/xray/users/trojan.db
systemctl restart xray
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${GREEN}         Akun Trojan Berhasil Dibuat!${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${WHITE}Remark   : ${YELLOW}$REMARK${NC}"
echo -e " ${WHITE}Password : ${YELLOW}$PASS${NC}"
echo -e " ${WHITE}Expired  : ${YELLOW}$EXPIRED${NC}"
echo -e " ${WHITE}Host     : ${YELLOW}$DOMAIN${NC}"
echo -e " ${WHITE}Port     : ${YELLOW}2083${NC}"
echo -e " ${WHITE}Path     : ${YELLOW}/trojan${NC}"
echo -e " ${WHITE}TLS      : ${YELLOW}TLS${NC}"
echo -e "${CYAN}============================================================${NC}"
