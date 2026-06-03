#!/bin/bash
# addsstp.sh
GREEN='\033[0;32m'; NC='\033[0m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'
MYIP=$(cat /etc/fazzpedia/myip 2>/dev/null || curl -s ipinfo.io/ip)
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${YELLOW}         Create SSTP Account${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -ne " Username      : "; read LOGIN
echo -ne " Password      : "; read PASS
echo -ne " Expired (hari): "; read DAYS
EXPIRED=$(date -d "$DAYS days" +"%Y-%m-%d")
# SSTP pakai PPP auth
echo "$LOGIN * $PASS *" >> /etc/ppp/chap-secrets
mkdir -p /etc/sstp/users
echo "$LOGIN|$PASS|$EXPIRED" >> /etc/sstp/users/sstp.db
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${GREEN}         SSTP Account Created!${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${WHITE}Username : ${YELLOW}$LOGIN${NC}"
echo -e " ${WHITE}Password : ${YELLOW}$PASS${NC}"
echo -e " ${WHITE}Server   : ${YELLOW}$MYIP${NC}"
echo -e " ${WHITE}Port     : ${YELLOW}444${NC}"
echo -e " ${WHITE}Expired  : ${YELLOW}$EXPIRED${NC}"
echo -e "${CYAN}============================================================${NC}"
