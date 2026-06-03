#!/bin/bash
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'
MYIP=$(cat /etc/fazzpedia/myip 2>/dev/null || curl -s ipinfo.io/ip)
DAYS=1
LOGIN="trial$(date +%s | tail -c 5)"
PASS=$(openssl rand -base64 6 | tr -dc 'a-zA-Z0-9' | head -c 8)
useradd -e "$(date -d "$DAYS days" +"%Y-%m-%d")" -s /bin/false -M "$LOGIN"
echo -e "$PASS\n$PASS" | passwd "$LOGIN" &>/dev/null
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${GREEN}         Trial SSH Account (1 Hari)${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${WHITE}Username   : ${YELLOW}$LOGIN${NC}"
echo -e " ${WHITE}Password   : ${YELLOW}$PASS${NC}"
echo -e " ${WHITE}Expired    : ${YELLOW}$(date -d "$DAYS days" +"%Y-%m-%d")${NC}"
echo -e " ${WHITE}Host       : ${YELLOW}$MYIP${NC}"
echo -e " ${WHITE}Port SSH   : ${YELLOW}22, 2253${NC}"
echo -e " ${WHITE}Port SSL   : ${YELLOW}443, 445, 777${NC}"
echo -e " ${WHITE}WebSocket  : ${YELLOW}8880${NC}"
echo -e "${CYAN}============================================================${NC}"
