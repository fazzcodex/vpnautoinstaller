#!/bin/bash
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'

MYIP=$(cat /etc/fazzpedia/myip 2>/dev/null || curl -s ipinfo.io/ip)
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "$MYIP")
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${YELLOW}         Create SSH & OpenVPN Account${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -ne " Username    : "; read LOGIN
echo -ne " Password    : "; read PASS
echo -ne " Expired (hari): "; read DAYS
echo -e "${CYAN}============================================================${NC}"

if id "$LOGIN" &>/dev/null; then
    echo -e "${RED}[!] Username sudah ada!${NC}"; exit 1
fi

useradd -e "$(date -d "$DAYS days" +"%Y-%m-%d")" -s /bin/false -M "$LOGIN"
echo -e "$PASS\n$PASS" | passwd "$LOGIN" &>/dev/null

CREATED=$(date +"%Y-%m-%d")
EXPIRED=$(date -d "$DAYS days" +"%Y-%m-%d")

clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${GREEN}         Akun SSH & OpenVPN Berhasil Dibuat!${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${WHITE}Username   : ${YELLOW}$LOGIN${NC}"
echo -e " ${WHITE}Password   : ${YELLOW}$PASS${NC}"
echo -e " ${WHITE}Created    : ${YELLOW}$CREATED${NC}"
echo -e " ${WHITE}Expired    : ${YELLOW}$EXPIRED${NC}"
echo -e "${CYAN}──────────────── Host & Port ────────────────${NC}"
echo -e " ${WHITE}IP/Host    : ${YELLOW}$MYIP${NC}"
echo -e " ${WHITE}Domain     : ${YELLOW}$DOMAIN${NC}"
echo -e "${CYAN}──────────────── SSH ────────────────────────${NC}"
echo -e " ${WHITE}OpenSSH    : ${YELLOW}22, 2253${NC}"
echo -e " ${WHITE}Dropbear   : ${YELLOW}109, 143${NC}"
echo -e " ${WHITE}SSL/TLS    : ${YELLOW}443, 445, 777${NC}"
echo -e "${CYAN}──────────────── WebSocket ──────────────────${NC}"
echo -e " ${WHITE}WS TLS     : ${YELLOW}443${NC}"
echo -e " ${WHITE}WS Non-TLS : ${YELLOW}8880${NC}"
echo -e "${CYAN}──────────────── OpenVPN ────────────────────${NC}"
echo -e " ${WHITE}OVPN TCP   : ${YELLOW}1194${NC}"
echo -e " ${WHITE}OVPN UDP   : ${YELLOW}2200${NC}"
echo -e " ${WHITE}OVPN SSL   : ${YELLOW}990${NC}"
echo -e " ${WHITE}OVPN TCP   : ${YELLOW}http://$MYIP:89/tcp.ovpn${NC}"
echo -e " ${WHITE}OVPN UDP   : ${YELLOW}http://$MYIP:89/udp.ovpn${NC}"
echo -e "${CYAN}──────────────── Payload ────────────────────${NC}"
echo -e " ${WHITE}WS TLS     : ${YELLOW}GET wss://bug.com/ HTTP/1.1[crlf]Host: [host][crlf]Upgrade: websocket[crlf][crlf]${NC}"
echo -e " ${WHITE}WS Non-TLS : ${YELLOW}GET / HTTP/1.1[crlf]Host: [host][crlf]Upgrade: websocket[crlf][crlf]${NC}"
echo -e "${CYAN}──────────────── BadVPN ─────────────────────${NC}"
echo -e " ${WHITE}BadVPN     : ${YELLOW}7100, 7200, 7300${NC}"
echo -e "${CYAN}──────────────── OHP ────────────────────────${NC}"
echo -e " ${WHITE}OHP SSH    : ${YELLOW}8181${NC}"
echo -e " ${WHITE}OHP DB     : ${YELLOW}8282${NC}"
echo -e " ${WHITE}OHP OVPN   : ${YELLOW}8383${NC}"
echo -e "${CYAN}============================================================${NC}"
