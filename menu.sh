#!/bin/bash
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'
MYIP=$(cat /etc/fazzpedia/myip 2>/dev/null || curl -s ipinfo.io/ip)
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
RAM=$(free -m | awk 'NR==2{printf "%s/%s MB", $3,$2}')
DISK=$(df -h / | awk 'NR==2{printf "%s/%s", $3,$2}')
UPTIME=$(uptime -p | sed 's/up //')

svc() { systemctl is-active --quiet "$1" && echo -e "${GREEN}[RUNNING]${NC}" || echo -e "${RED}[STOPPED]${NC}"; }

clear
echo -e "${CYAN}==========================================================${NC}"
echo -e "${YELLOW}   ███████╗ █████╗ ███████╗███████╗${NC}"
echo -e "${YELLOW}   ██╔════╝██╔══██╗╚══███╔╝╚══███╔╝${NC}"
echo -e "${YELLOW}   █████╗  ███████║  ███╔╝   ███╔╝ ${NC}"
echo -e "${YELLOW}   ██╔══╝  ██╔══██║ ███╔╝   ███╔╝  ${NC}"
echo -e "${YELLOW}   ██║     ██║  ██║███████╗███████╗ Vpn v2.0${NC}"
echo -e "${CYAN}   Telegram : t.me/fazzpediavpn${NC}"
echo -e "${CYAN}==========================================================${NC}"
echo -e " ${WHITE}IP     : ${YELLOW}${MYIP}${WHITE}   OS   : ${YELLOW}$(lsb_release -ds 2>/dev/null)${NC}"
echo -e " ${WHITE}CPU    : ${YELLOW}${CPU}%${WHITE}          RAM  : ${YELLOW}${RAM}${NC}"
echo -e " ${WHITE}Uptime : ${YELLOW}${UPTIME}${NC}"
echo -e "${CYAN}==========================================================${NC}"
echo -e " ${WHITE}SSH            :$(svc ssh)   Dropbear    :$(svc dropbear)${NC}"
echo -e " ${WHITE}SSLH (443)     :$(svc sslh)   Stunnel4    :$(svc stunnel4)${NC}"
echo -e " ${WHITE}OpenVPN TCP    :$(svc openvpn@server-tcp)   OpenVPN UDP :$(svc openvpn@server-udp)${NC}"
echo -e " ${WHITE}Xray           :$(svc xray)   Wireguard   :$(svc wg-quick@wg0)${NC}"
echo -e " ${WHITE}WebSocket      :$(svc ws-nontls)   Squid       :$(svc squid)${NC}"
echo -e "${CYAN}==========================================================${NC}"
echo -e " ${YELLOW}SSH & OPENVPN${NC}"
echo -e " ${WHITE}[1]  Create SSH & OpenVPN Account${NC}"
echo -e " ${WHITE}[2]  Trial SSH Account${NC}"
echo -e " ${WHITE}[3]  Renew SSH Account${NC}"
echo -e " ${WHITE}[4]  Check Active SSH Login${NC}"
echo -e " ${WHITE}[5]  List SSH Member${NC}"
echo -e " ${WHITE}[6]  Delete SSH Account${NC}"
echo -e " ${WHITE}[7]  Delete All Expired SSH${NC}"
echo -e " ${WHITE}[8]  Setup Auto-Kill Multi Login${NC}"
echo -e " ${WHITE}[9]  Kick SSH User${NC}"
echo -e " ${WHITE}[10] Restart All Services${NC}"
echo -e " ${YELLOW}WIREGUARD${NC}"
echo -e " ${WHITE}[11] Create Wireguard Account${NC}"
echo -e " ${WHITE}[12] Delete Wireguard Account${NC}"
echo -e " ${WHITE}[13] Renew Wireguard Account${NC}"
echo -e " ${YELLOW}SHADOWSOCKS-R${NC}"
echo -e " ${WHITE}[14] Create Shadowsocks Account${NC}"
echo -e " ${WHITE}[15] Delete Shadowsocks Account${NC}"
echo -e " ${WHITE}[16] Renew Shadowsocks Account${NC}"
echo -e " ${WHITE}[17] Check Shadowsocks Login${NC}"
echo -e " ${YELLOW}SSTP${NC}"
echo -e " ${WHITE}[18] Create SSTP Account${NC}"
echo -e " ${WHITE}[19] Delete SSTP Account${NC}"
echo -e " ${WHITE}[20] Renew SSTP Account${NC}"
echo -e " ${YELLOW}L2TP / IPSEC${NC}"
echo -e " ${WHITE}[21] Create L2TP Account${NC}"
echo -e " ${WHITE}[22] Delete L2TP Account${NC}"
echo -e " ${WHITE}[23] Renew L2TP Account${NC}"
echo -e " ${YELLOW}XRAY / VMESS${NC}"
echo -e " ${WHITE}[24] Create VMess Account${NC}"
echo -e " ${WHITE}[25] Delete VMess Account${NC}"
echo -e " ${WHITE}[26] Renew VMess Account${NC}"
echo -e " ${WHITE}[27] Check VMess Accounts${NC}"
echo -e " ${YELLOW}XRAY / VLESS${NC}"
echo -e " ${WHITE}[28] Create VLess Account${NC}"
echo -e " ${WHITE}[29] Delete VLess Account${NC}"
echo -e " ${WHITE}[30] Renew VLess Account${NC}"
echo -e " ${WHITE}[31] Check VLess Accounts${NC}"
echo -e " ${YELLOW}XRAY / TROJAN${NC}"
echo -e " ${WHITE}[32] Create Trojan Account${NC}"
echo -e " ${WHITE}[33] Delete Trojan Account${NC}"
echo -e " ${WHITE}[34] Renew Trojan Account${NC}"
echo -e " ${WHITE}[35] Check Trojan Accounts${NC}"
echo -e " ${YELLOW}SYSTEM & TOOLS${NC}"
echo -e " ${WHITE}[36] Set Domain / Subdomain${NC}"
echo -e " ${WHITE}[37] Change Service Port${NC}"
echo -e " ${WHITE}[38] Backup Server Data${NC}"
echo -e " ${WHITE}[39] Restore Server Data${NC}"
echo -e " ${WHITE}[40] RAM Usage Monitor${NC}"
echo -e " ${WHITE}[41] Speedtest VPS${NC}"
echo -e " ${WHITE}[42] System Information${NC}"
echo -e " ${WHITE}[43] Reboot VPS${NC}"
echo -e " ${WHITE}[44] Update FazzPedia Script${NC}"
echo -e " ${WHITE}[00] About FazzPedia${NC}"
echo -e "${CYAN}==========================================================${NC}"
echo -ne " ${YELLOW}Select [0-44] : ${NC}"
read CHOICE

case $CHOICE in
    1)  addssh ;;
    2)  trialssh ;;
    3)  renewssh ;;
    4)  cekssh ;;
    5)  member ;;
    6)  delssh ;;
    7)  delexp ;;
    8)  autokill ;;
    9)  tendang ;;
    10) restart ;;
    11) addwg ;;
    12) delwg ;;
    13) renewwg ;;
    14) addss ;;
    15) delss ;;
    16) renewss ;;
    17) cekss ;;
    18) addsstp ;;
    19) delsstp ;;
    20) renewsstp ;;
    21) addl2tp ;;
    22) dell2tp ;;
    23) renewl2tp ;;
    24) addvmess ;;
    25) delvmess ;;
    26) renewvmess ;;
    27) cekvmess ;;
    28) addvless ;;
    29) delvless ;;
    30) renewvless ;;
    31) cekvless ;;
    32) addtrojan ;;
    33) deltrojan ;;
    34) renewtrojan ;;
    35) cektrojan ;;
    36) setdomain ;;
    37) changeport ;;
    38) backup ;;
    39) restore ;;
    40) ram ;;
    41) speedtest /usr/bin/speedtest_cli.py 2>/dev/null || python3 -c "import urllib.request; exec(urllib.request.urlopen('https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py').read())" ;;
    42) sysinfo ;;
    43) reboot ;;
    44) bash /etc/fazzpedia/system/update.sh ;;
    00|0) cat /etc/fazzpedia/about 2>/dev/null || echo "FazzPedia||Vpn v2.0 - t.me/fazzpediavpn" ;;
    *) echo -e "${RED}Pilihan tidak valid!${NC}" ;;
esac
