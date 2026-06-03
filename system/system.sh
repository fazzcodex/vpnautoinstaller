#!/bin/bash
# ============================================================
#   FazzPedia||Vpn - System Information
# ============================================================
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'

info() {
clear
MYIP=$(curl -s ipinfo.io/ip 2>/dev/null)
OS=$(lsb_release -d | awk -F'\t' '{print $2}')
KERNEL=$(uname -r)
CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -1 | awk -F': ' '{print $2}')
CPU_CORES=$(nproc)
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.1f", $2+$4}')
RAM_USED=$(free -m | awk '/Mem/{print $3}')
RAM_TOTAL=$(free -m | awk '/Mem/{print $2}')
DISK_USED=$(df -h / | awk 'NR==2{print $3}')
DISK_TOTAL=$(df -h / | awk 'NR==2{print $2}')
UPTIME=$(uptime -p)
LOAD=$(uptime | awk -F'load average: ' '{print $2}')

echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}         FazzPedia||Vpn - System Information${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo -e " ${YELLOW}── Server ──${NC}"
echo -e " ${WHITE}IP Address  :${NC} $MYIP"
echo -e " ${WHITE}OS          :${NC} $OS"
echo -e " ${WHITE}Kernel      :${NC} $KERNEL"
echo -e " ${WHITE}Uptime      :${NC} $UPTIME"
echo -e " ${WHITE}Load        :${NC} $LOAD"
echo ""
echo -e " ${YELLOW}── Resources ──${NC}"
echo -e " ${WHITE}CPU         :${NC} $CPU_MODEL ($CPU_CORES cores)"
echo -e " ${WHITE}CPU Usage   :${NC} ${CPU_USAGE}%"
echo -e " ${WHITE}RAM         :${NC} ${RAM_USED}/${RAM_TOTAL} MB"
echo -e " ${WHITE}Disk        :${NC} ${DISK_USED}/${DISK_TOTAL}"
echo ""
echo -e " ${YELLOW}── Services ──${NC}"
services=("ssh:SSH" "dropbear:Dropbear" "stunnel4:Stunnel5"
          "openvpn@server-tcp:OpenVPN TCP" "openvpn@server-udp:OpenVPN UDP"
          "squid:Squid Proxy" "xray:Xray Core"
          "wg-quick@wg0:Wireguard"
          "ws-fazzpedia:WebSocket"
          "ohp-ssh:OHP SSH" "ohp-dropbear:OHP Dropbear")
for entry in "${services[@]}"; do
    svc="${entry%%:*}"; label="${entry##*:}"
    STATUS=$(systemctl is-active "$svc" 2>/dev/null)
    if [ "$STATUS" == "active" ]; then
        printf " ${WHITE}%-22s${NC}: ${GREEN}[RUNNING]${NC}\n" "$label"
    else
        printf " ${WHITE}%-22s${NC}: ${RED}[STOPPED]${NC}\n" "$label"
    fi
done
echo ""
echo -e " ${YELLOW}── Ports ──${NC}"
echo -e " ${WHITE}SSH         :${NC} 22, 443"
echo -e " ${WHITE}Dropbear    :${NC} 109, 143"
echo -e " ${WHITE}Stunnel5    :${NC} 445, 777"
echo -e " ${WHITE}OpenVPN     :${NC} TCP 1194, UDP 2200"
echo -e " ${WHITE}Squid       :${NC} 3128, 8080"
echo -e " ${WHITE}BadVPN      :${NC} 7100, 7200, 7300"
echo -e " ${WHITE}Wireguard   :${NC} 7070"
echo -e " ${WHITE}L2TP/IPSec  :${NC} 1701"
echo -e " ${WHITE}SSTP        :${NC} 444"
echo -e " ${WHITE}VMess TLS   :${NC} 8443"
echo -e " ${WHITE}VMess NTLS  :${NC} 80"
echo -e " ${WHITE}VLess TLS   :${NC} 8442"
echo -e " ${WHITE}VLess NTLS  :${NC} 8441"
echo -e " ${WHITE}Trojan      :${NC} 2083"
echo -e " ${WHITE}WS NTLS     :${NC} 8880"
echo -e " ${WHITE}OHP SSH     :${NC} 8181"
echo -e " ${WHITE}OHP DB      :${NC} 8282"
echo -e " ${WHITE}OHP OVPN    :${NC} 8383"
echo ""
echo -e "${CYAN}============================================================${NC}"
}

restart_all() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}        FazzPedia||Vpn - Restart All Services${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
services=(ssh dropbear stunnel4 "openvpn@server-tcp" "openvpn@server-udp"
          squid xray "wg-quick@wg0" ws-fazzpedia
          ohp-ssh ohp-dropbear ohp-ovpn
          badvpn-7100 badvpn-7200 badvpn-7300
          strongswan xl2tpd)
for svc in "${services[@]}"; do
    systemctl restart "$svc" 2>/dev/null && \
        echo -e " ${GREEN}[OK]${NC} Restarted: $svc" || \
        echo -e " ${RED}[--]${NC} Not found: $svc"
done
echo ""
echo -e "${GREEN}All services restarted.${NC}"
echo -e "${CYAN}============================================================${NC}"
}

ram_monitor() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}          FazzPedia||Vpn - RAM Monitor${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
free -h
echo ""
echo -e " ${YELLOW}Top 10 Memory Consumers:${NC}"
ps aux --sort=-%mem | awk 'NR<=11 {printf " %-25s %s%%\n", $11, $4}'
echo ""
echo -e "${CYAN}============================================================${NC}"
}

speedtest_run() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}          FazzPedia||Vpn - Speedtest VPS${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo -e "${YELLOW}Running speedtest...${NC}"
if command -v speedtest-cli &>/dev/null; then
    speedtest-cli --simple
elif command -v python3 &>/dev/null; then
    pip3 install speedtest-cli -q
    speedtest-cli --simple
else
    # Simple wget-based test
    echo -e "${YELLOW}Download test (100MB from Cachefly):${NC}"
    wget -O /dev/null https://cachefly.cachefly.net/100mb.test 2>&1 | \
        grep -E "MB/s|Kbytes"
fi
echo ""
echo -e "${CYAN}============================================================${NC}"
}

about_script() {
clear
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${YELLOW}         FazzPedia || Vpn - Auto Installer v2.0         ${CYAN}║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${WHITE}                                                          ${CYAN}║${NC}"
echo -e "${CYAN}║${WHITE}  Developer  : FazzCodex                                  ${CYAN}║${NC}"
echo -e "${CYAN}║${WHITE}  Telegram   : https://t.me/FazzCodex                     ${CYAN}║${NC}"
echo -e "${CYAN}║${WHITE}  Version    : 2.0                                         ${CYAN}║${NC}"
echo -e "${CYAN}║${WHITE}  OS Support : Ubuntu 20.04 / 22.04 / 24.04               ${CYAN}║${NC}"
echo -e "${CYAN}║${WHITE}                                                          ${CYAN}║${NC}"
echo -e "${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║${YELLOW}  Features:                                               ${CYAN}║${NC}"
echo -e "${CYAN}║${GREEN}  ✓ SSH/OpenVPN  ✓ Dropbear   ✓ Stunnel5 (SSL)           ${CYAN}║${NC}"
echo -e "${CYAN}║${GREEN}  ✓ Wireguard    ✓ Xray VMess ✓ Xray VLess               ${CYAN}║${NC}"
echo -e "${CYAN}║${GREEN}  ✓ Trojan       ✓ SSTP       ✓ L2TP/IPSec               ${CYAN}║${NC}"
echo -e "${CYAN}║${GREEN}  ✓ ShadowsocksR ✓ WebSocket  ✓ OHP Server                ${CYAN}║${NC}"
echo -e "${CYAN}║${GREEN}  ✓ Squid Proxy  ✓ BadVPN     ✓ BBR                      ${CYAN}║${NC}"
echo -e "${CYAN}║${GREEN}  ✓ Auto-Backup  ✓ Auto-Kill  ✓ Fail2Ban                 ${CYAN}║${NC}"
echo -e "${CYAN}║${WHITE}                                                          ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
}

setdomain() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}       FazzPedia||Vpn - Set Domain / Subdomain${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
read -p " Enter your domain/subdomain (e.g. vpn.domain.com): " DOMAIN
echo "$DOMAIN" > /etc/fazzpedia/domain.conf
# Update nginx if available
if command -v nginx &>/dev/null; then
    sed -i "s/server_name .*/server_name ${DOMAIN};/" /etc/nginx/conf.d/fazzpedia-ws.conf
    nginx -t && systemctl reload nginx
fi
echo -e "${GREEN}[OK] Domain set to: $DOMAIN${NC}"
}

changeport() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}         FazzPedia||Vpn - Change Service Port${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo -e " ${YELLOW}Available services:${NC}"
echo -e "  [1] SSH Port (current: 22, 443)"
echo -e "  [2] Dropbear Port (current: 109, 143)"
echo -e "  [3] Stunnel5 Port"
echo -e "  [4] Squid Proxy Port"
echo ""
read -p " Select service [1-4]: " SVC
case $SVC in
1)
    read -p " New SSH Port: " P1
    sed -i "s/^Port .*//" /etc/ssh/sshd_config
    sed -i "1iPort ${P1}" /etc/ssh/sshd_config
    systemctl restart ssh
    echo -e "${GREEN}[OK] SSH port changed to ${P1}${NC}"
    ;;
2)
    read -p " New Dropbear Port: " P2
    sed -i "s/DROPBEAR_PORT=.*/DROPBEAR_PORT=${P2}/" /etc/default/dropbear
    systemctl restart dropbear
    echo -e "${GREEN}[OK] Dropbear port changed to ${P2}${NC}"
    ;;
3)
    read -p " New Stunnel Port: " P3
    sed -i "s/accept = .*/accept = ${P3}/" /etc/stunnel/stunnel.conf
    systemctl restart stunnel4
    echo -e "${GREEN}[OK] Stunnel port changed to ${P3}${NC}"
    ;;
4)
    read -p " New Squid Port: " P4
    sed -i "s/^http_port .*/http_port ${P4}/" /etc/squid/squid.conf
    systemctl restart squid
    echo -e "${GREEN}[OK] Squid port changed to ${P4}${NC}"
    ;;
esac
}

limitspeed() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}       FazzPedia||Vpn - Limit Bandwidth Speed${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
NET=$(ip -o -4 route show to default | awk '{print $5}')
echo -e " ${YELLOW}Interface: ${NET}${NC}"
echo ""
read -p " Enable speed limit? [y/n]: " CONFIRM
if [[ "$CONFIRM" == "y" ]]; then
    read -p " Download limit (e.g. 100mbit): " DL
    read -p " Upload limit (e.g. 100mbit): " UL
    tc qdisc del dev ${NET} root 2>/dev/null
    tc qdisc add dev ${NET} root handle 1: htb default 10
    tc class add dev ${NET} parent 1: classid 1:10 htb rate ${DL} burst 15k
    echo -e "${GREEN}[OK] Speed limited to DL:${DL} UL:${UL}${NC}"
else
    tc qdisc del dev ${NET} root 2>/dev/null
    echo -e "${GREEN}[OK] Speed limit removed.${NC}"
fi
}

update_script() {
echo -e "${YELLOW}[UPDATE] Checking for FazzPedia updates...${NC}"
echo -e "${YELLOW}[INFO] To update, re-run: bash setup.sh${NC}"
echo -e "${GREEN}Current version: $(cat /etc/fazzpedia/version)${NC}"
}

case "$1" in
    info)      info ;;
    restart)   restart_all ;;
    ram)       ram_monitor ;;
    speedtest) speedtest_run ;;
    about)     about_script ;;
    domain)    setdomain ;;
    port)      changeport ;;
    speed)     limitspeed ;;
    update)    update_script ;;
    *)         info ;;
esac
