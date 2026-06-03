#!/bin/bash
# ============================================================
#   FazzPedia||Vpn - Main Menu Panel
#   Telegram : https://t.me/FazzCodex
# ============================================================
clear

RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
ORANGE='\033[0;33m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'
YELLOW='\033[1;33m'; WHITE='\033[1;37m'; BOLD='\033[1m'
PURPLE='\033[0;35m'

MYIP=$(curl -s ipinfo.io/ip 2>/dev/null || hostname -I | awk '{print $1}')
VER=$(cat /etc/fazzpedia/version 2>/dev/null || echo "2.0")
DOMAIN=$(cat /etc/fazzpedia/domain.conf 2>/dev/null || echo "$MYIP")
OS=$(lsb_release -d | awk -F'\t' '{print $2}')
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2+$4}')
RAM_USED=$(free -m | awk '/Mem/{print $3}')
RAM_TOTAL=$(free -m | awk '/Mem/{print $2}')
UPTIME=$(uptime -p)

echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${YELLOW}   ███████╗ █████╗ ███████╗███████╗                      ${CYAN}║${NC}"
echo -e "${CYAN}║${YELLOW}   ██╔════╝██╔══██╗╚══███╔╝╚══███╔╝                      ${CYAN}║${NC}"
echo -e "${CYAN}║${YELLOW}   █████╗  ███████║  ███╔╝   ███╔╝                       ${CYAN}║${NC}"
echo -e "${CYAN}║${YELLOW}   ██╔══╝  ██╔══██║ ███╔╝   ███╔╝                        ${CYAN}║${NC}"
echo -e "${CYAN}║${YELLOW}   ██║     ██║  ██║███████╗███████╗                       ${CYAN}║${NC}"
echo -e "${CYAN}║${YELLOW}   ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝  Vpn v${VER}        ${CYAN}║${NC}"
echo -e "${CYAN}║${GREEN}           Telegram : t.me/fazzpediavpn                      ${CYAN}║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${WHITE} IP     : ${YELLOW}${MYIP}${WHITE}   OS   : ${YELLOW}${OS}        ${CYAN}║${NC}"
echo -e "${CYAN}║${WHITE} CPU    : ${YELLOW}${CPU}%${WHITE}            RAM  : ${YELLOW}${RAM_USED}/${RAM_TOTAL} MB     ${CYAN}║${NC}"
echo -e "${CYAN}║${WHITE} Uptime : ${YELLOW}${UPTIME}                               ${CYAN}║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"
echo ""

echo -e " ${WHITE}SSH & OPENVPN${NC}"
echo -e " ${CYAN}─────────────────────────────────────────────────────${NC}"
echo -e "  ${GREEN}[1]${NC}  Create SSH & OpenVPN Account"
echo -e "  ${GREEN}[2]${NC}  Generate SSH Trial Account"
echo -e "  ${GREEN}[3]${NC}  Renew SSH Account"
echo -e "  ${GREEN}[4]${NC}  Check Active SSH Login"
echo -e "  ${GREEN}[5]${NC}  List SSH Member"
echo -e "  ${GREEN}[6]${NC}  Delete SSH Account"
echo -e "  ${GREEN}[7]${NC}  Delete All Expired SSH"
echo -e "  ${GREEN}[8]${NC}  Setup Auto-Kill Multi Login"
echo -e "  ${GREEN}[9]${NC}  Show Multi Login Violations"
echo -e "  ${GREEN}[10]${NC} Restart All Services"
echo ""

echo -e " ${WHITE}WIREGUARD${NC}"
echo -e " ${CYAN}─────────────────────────────────────────────────────${NC}"
echo -e "  ${GREEN}[11]${NC} Create Wireguard Account"
echo -e "  ${GREEN}[12]${NC} Delete Wireguard Account"
echo -e "  ${GREEN}[13]${NC} Renew Wireguard Account"
echo ""

echo -e " ${WHITE}SHADOWSOCKS-R${NC}"
echo -e " ${CYAN}─────────────────────────────────────────────────────${NC}"
echo -e "  ${GREEN}[14]${NC} Create Shadowsocks Account"
echo -e "  ${GREEN}[15]${NC} Delete Shadowsocks Account"
echo -e "  ${GREEN}[16]${NC} Renew Shadowsocks Account"
echo -e "  ${GREEN}[17]${NC} Check Shadowsocks Login"
echo ""

echo -e " ${WHITE}SSTP${NC}"
echo -e " ${CYAN}─────────────────────────────────────────────────────${NC}"
echo -e "  ${GREEN}[18]${NC} Create SSTP Account"
echo -e "  ${GREEN}[19]${NC} Delete SSTP Account"
echo -e "  ${GREEN}[20]${NC} Renew SSTP Account"
echo -e "  ${GREEN}[21]${NC} Check SSTP Login"
echo ""

echo -e " ${WHITE}L2TP / IPSEC${NC}"
echo -e " ${CYAN}─────────────────────────────────────────────────────${NC}"
echo -e "  ${GREEN}[22]${NC} Create L2TP Account"
echo -e "  ${GREEN}[23]${NC} Delete L2TP Account"
echo -e "  ${GREEN}[24]${NC} Renew L2TP Account"
echo ""

echo -e " ${WHITE}XRAY / VMESS${NC}"
echo -e " ${CYAN}─────────────────────────────────────────────────────${NC}"
echo -e "  ${GREEN}[25]${NC} Create VMess Account (TLS + Non-TLS)"
echo -e "  ${GREEN}[26]${NC} Delete VMess Account"
echo -e "  ${GREEN}[27]${NC} Renew VMess Account"
echo -e "  ${GREEN}[28]${NC} Check VMess Accounts"
echo -e "  ${GREEN}[29]${NC} Renew Xray Certificate"
echo ""

echo -e " ${WHITE}XRAY / VLESS${NC}"
echo -e " ${CYAN}─────────────────────────────────────────────────────${NC}"
echo -e "  ${GREEN}[30]${NC} Create VLess Account (TLS + Non-TLS)"
echo -e "  ${GREEN}[31]${NC} Delete VLess Account"
echo -e "  ${GREEN}[32]${NC} Renew VLess Account"
echo -e "  ${GREEN}[33]${NC} Check VLess Accounts"
echo ""

echo -e " ${WHITE}XRAY / TROJAN${NC}"
echo -e " ${CYAN}─────────────────────────────────────────────────────${NC}"
echo -e "  ${GREEN}[34]${NC} Create Trojan Account"
echo -e "  ${GREEN}[35]${NC} Delete Trojan Account"
echo -e "  ${GREEN}[36]${NC} Renew Trojan Account"
echo -e "  ${GREEN}[37]${NC} Check Trojan Accounts"
echo ""

echo -e " ${WHITE}SYSTEM & TOOLS${NC}"
echo -e " ${CYAN}─────────────────────────────────────────────────────${NC}"
echo -e "  ${GREEN}[38]${NC} Set Domain / Subdomain"
echo -e "  ${GREEN}[39]${NC} Change Service Port"
echo -e "  ${GREEN}[40]${NC} Backup Server Data"
echo -e "  ${GREEN}[41]${NC} Restore Server Data"
echo -e "  ${GREEN}[42]${NC} Setup Auto Backup"
echo -e "  ${GREEN}[43]${NC} Limit Bandwidth Speed"
echo -e "  ${GREEN}[44]${NC} RAM Usage Monitor"
echo -e "  ${GREEN}[45]${NC} Speedtest VPS"
echo -e "  ${GREEN}[46]${NC} System Information"
echo -e "  ${GREEN}[47]${NC} Reboot VPS"
echo -e "  ${GREEN}[48]${NC} Update FazzPedia Script"
echo -e "  ${GREEN}[00]${NC} About FazzPedia"
echo ""
echo -e " ${CYAN}─────────────────────────────────────────────────────${NC}"
echo ""
read -p " Select [0-48] : " MENU
echo ""

case $MENU in
# ── SSH & OpenVPN ──────────────────────────────────────────
1)  bash /etc/fazzpedia/ssh/addssh.sh ;;
2)  bash /etc/fazzpedia/ssh/addssh.sh trial ;;
3)  bash /etc/fazzpedia/ssh/addssh.sh renew ;;
4)  bash /etc/fazzpedia/ssh/addssh.sh cek ;;
5)  bash /etc/fazzpedia/ssh/addssh.sh member ;;
6)  bash /etc/fazzpedia/ssh/addssh.sh del ;;
7)  bash /etc/fazzpedia/ssh/addssh.sh delexp ;;
8)  bash /etc/fazzpedia/ssh/addssh.sh autokill ;;
9)  bash /etc/fazzpedia/ssh/addssh.sh ceklim ;;
10) bash /etc/fazzpedia/system/restart.sh ;;
# ── Wireguard ─────────────────────────────────────────────
11) bash /etc/fazzpedia/wireguard/addwg.sh ;;
12) bash /etc/fazzpedia/wireguard/addwg.sh del ;;
13) bash /etc/fazzpedia/wireguard/addwg.sh renew ;;
# ── Shadowsocks ───────────────────────────────────────────
14) bash /etc/fazzpedia/shadowsocks/addss.sh ;;
15) bash /etc/fazzpedia/shadowsocks/addss.sh del ;;
16) bash /etc/fazzpedia/shadowsocks/addss.sh renew ;;
17) bash /etc/fazzpedia/shadowsocks/addss.sh cek ;;
# ── SSTP ──────────────────────────────────────────────────
18) bash /etc/fazzpedia/sstp/addsstp.sh ;;
19) bash /etc/fazzpedia/sstp/addsstp.sh del ;;
20) bash /etc/fazzpedia/sstp/addsstp.sh renew ;;
21) bash /etc/fazzpedia/sstp/addsstp.sh cek ;;
# ── L2TP ──────────────────────────────────────────────────
22) bash /etc/fazzpedia/ipsec/addl2tp.sh ;;
23) bash /etc/fazzpedia/ipsec/addl2tp.sh del ;;
24) bash /etc/fazzpedia/ipsec/addl2tp.sh renew ;;
# ── VMess ─────────────────────────────────────────────────
25) bash /etc/fazzpedia/xray/addvmess.sh ;;
26) bash /etc/fazzpedia/xray/addvmess.sh del-vmess ;;
27) bash /etc/fazzpedia/xray/addvmess.sh renew-vmess ;;
28) bash /etc/fazzpedia/xray/addvmess.sh cek-vmess ;;
29) bash /etc/fazzpedia/xray/addvmess.sh cert ;;
# ── VLess ─────────────────────────────────────────────────
30) bash /etc/fazzpedia/xray/addvmess.sh add-vless ;;
31) bash /etc/fazzpedia/xray/addvmess.sh del-vless ;;
32) bash /etc/fazzpedia/xray/addvmess.sh renew-vless ;;
33) bash /etc/fazzpedia/xray/addvmess.sh cek-vless ;;
# ── Trojan ────────────────────────────────────────────────
34) bash /etc/fazzpedia/xray/addvmess.sh add-trojan ;;
35) bash /etc/fazzpedia/xray/addvmess.sh del-trojan ;;
36) bash /etc/fazzpedia/xray/addvmess.sh renew-trojan ;;
37) bash /etc/fazzpedia/xray/addvmess.sh cek-trojan ;;
# ── System ────────────────────────────────────────────────
38) bash /etc/fazzpedia/system/setdomain.sh ;;
39) bash /etc/fazzpedia/system/changeport.sh ;;
40) bash /etc/fazzpedia/backup/backup.sh ;;
41) bash /etc/fazzpedia/backup/restore.sh ;;
42) bash /etc/fazzpedia/backup/autobackup.sh ;;
43) bash /etc/fazzpedia/system/limitspeed.sh ;;
44) bash /etc/fazzpedia/system/ram.sh ;;
45) bash /etc/fazzpedia/system/speedtest.sh ;;
46) bash /etc/fazzpedia/system/info.sh ;;
47) echo -e "${YELLOW}Rebooting...${NC}"; sleep 2; reboot ;;
48) bash /etc/fazzpedia/system/update.sh ;;
00|0) bash /etc/fazzpedia/system/about.sh ;;
*) clear; menu ;;
esac
