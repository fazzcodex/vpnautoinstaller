#!/bin/bash
GREEN='\033[0;32m'; NC='\033[0m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'
MYIP=$(cat /etc/fazzpedia/myip 2>/dev/null || curl -s ipinfo.io/ip)
PSK=$(cat /etc/fazzpedia/l2tp_psk 2>/dev/null || echo "fazzpedia")
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${YELLOW}         Create L2TP Account${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -ne " Username      : "; read LOGIN
echo -ne " Password      : "; read PASS
echo -ne " Expired (hari): "; read DAYS
EXPIRED=$(date -d "$DAYS days" +"%Y-%m-%d")

# Tambah ke chap-secrets
echo "$LOGIN * $PASS *" >> /etc/ppp/chap-secrets
mkdir -p /etc/fazzpedia/l2tp
echo "$LOGIN|$PASS|$EXPIRED" >> /etc/fazzpedia/l2tp/users.db

clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${GREEN}         L2TP/IPSec Account Created!${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${WHITE}Username   : ${YELLOW}$LOGIN${NC}"
echo -e " ${WHITE}Password   : ${YELLOW}$PASS${NC}"
echo -e " ${WHITE}PSK        : ${YELLOW}$PSK${NC}"
echo -e " ${WHITE}Server IP  : ${YELLOW}$MYIP${NC}"
echo -e " ${WHITE}Expired    : ${YELLOW}$EXPIRED${NC}"
echo -e "${CYAN}──────────── Android Settings ───────────────${NC}"
echo -e " ${WHITE}Type       : ${YELLOW}L2TP/IPSec PSK${NC}"
echo -e " ${WHITE}Server     : ${YELLOW}$MYIP${NC}"
echo -e " ${WHITE}L2TP Key   : ${YELLOW}(kosong)${NC}"
echo -e " ${WHITE}IPSec Key  : ${YELLOW}$PSK${NC}"
echo -e "${CYAN}============================================================${NC}"
