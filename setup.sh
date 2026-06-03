#!/bin/bash
# ============================================================
#   FazzPedia||Vpn - Auto Installer
#   Telegram : https://t.me/FazzCodex
#   Support  : Ubuntu 20.04 / 22.04 / 24.04
# ============================================================
if [ "${EUID}" -ne 0 ]; then echo "Run as root!"; exit 1; fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then echo "OpenVZ not supported"; exit 1; fi

RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'

REPO="https://raw.githubusercontent.com/fazzcodex/vpnautoinstaller/main"
MYIP=$(curl -s ipinfo.io/ip 2>/dev/null || wget -qO- ipinfo.io/ip)
clear

banner() {
echo -e "${CYAN}============================================================${NC}"
echo -e "${YELLOW}   ███████╗ █████╗ ███████╗███████╗${NC}"
echo -e "${YELLOW}   ██╔════╝██╔══██╗╚══███╔╝╚══███╔╝${NC}"
echo -e "${YELLOW}   █████╗  ███████║  ███╔╝   ███╔╝ ${NC}"
echo -e "${YELLOW}   ██╔══╝  ██╔══██║ ███╔╝   ███╔╝  ${NC}"
echo -e "${YELLOW}   ██║     ██║  ██║███████╗███████╗ ${NC}"
echo -e "${YELLOW}   ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝ Vpn v2.0${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${GREEN}Telegram : https://t.me/fazzpediavpn${NC}"
echo -e " ${GREEN}IP VPS   : ${MYIP}${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
}

banner

if [ -f "/etc/fazzpedia/installed" ]; then
    echo -e "${RED}Script Already Installed!${NC}"; exit 0
fi

source /etc/os-release
VER=$VERSION_ID
case $VER in
    20.04|22.04|24.04) echo -e "${GREEN}[OK] Ubuntu ${VER} supported!${NC}" ;;
    *) echo -e "${RED}[ERROR] Ubuntu ${VER} not supported.${NC}"; exit 1 ;;
esac

mkdir -p /etc/fazzpedia /var/lib/crot
echo "IP=${MYIP}" > /var/lib/crot/ipvps.conf

# ── Download semua file dari GitHub ──────────────────────────
echo -e "${YELLOW}[1/8] Downloading scripts...${NC}"
dl() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname $dst)"
    wget -q --tries=3 -O "$dst" "${REPO}/${src}" && chmod +x "$dst" && echo -e "  ${GREEN}✓${NC} $src" || echo -e "  ${RED}✗${NC} $src GAGAL"
}

dl "ssh/ssh-vpn.sh"        "/etc/fazzpedia/ssh/ssh-vpn.sh"
dl "ssh/addssh.sh"         "/usr/bin/addssh"
dl "ssh/delssh.sh"         "/usr/bin/delssh"
dl "ssh/renewssh.sh"       "/usr/bin/renewssh"
dl "ssh/cekssh.sh"         "/usr/bin/cekssh"
dl "ssh/trialssh.sh"       "/usr/bin/trialssh"
dl "ssh/member.sh"         "/usr/bin/member"
dl "ssh/delexp.sh"         "/usr/bin/delexp"
dl "ssh/restart.sh"        "/usr/bin/restart"
dl "ssh/info.sh"           "/usr/bin/info"
dl "ssh/ram.sh"            "/usr/bin/ram"
dl "ssh/autokill.sh"       "/usr/bin/autokill"
dl "ssh/tendang.sh"        "/usr/bin/tendang"
dl "ssh/changeport.sh"     "/usr/bin/changeport"
dl "xray/xray.sh"          "/etc/fazzpedia/xray/xray.sh"
dl "xray/addvmess.sh"      "/usr/bin/addvmess"
dl "xray/delvmess.sh"      "/usr/bin/delvmess"
dl "xray/renewvmess.sh"    "/usr/bin/renewvmess"
dl "xray/cekvmess.sh"      "/usr/bin/cekvmess"
dl "xray/addvless.sh"      "/usr/bin/addvless"
dl "xray/delvless.sh"      "/usr/bin/delvless"
dl "xray/renewvless.sh"    "/usr/bin/renewvless"
dl "xray/cekvless.sh"      "/usr/bin/cekvless"
dl "xray/addtrojan.sh"     "/usr/bin/addtrojan"
dl "xray/deltrojan.sh"     "/usr/bin/deltrojan"
dl "xray/renewtrojan.sh"   "/usr/bin/renewtrojan"
dl "xray/cektrojan.sh"     "/usr/bin/cektrojan"
dl "wireguard/wireguard.sh"   "/etc/fazzpedia/wireguard/wireguard.sh"
dl "wireguard/addwg.sh"       "/usr/bin/addwg"
dl "wireguard/delwg.sh"       "/usr/bin/delwg"
dl "wireguard/renewwg.sh"     "/usr/bin/renewwg"
dl "shadowsocks/shadowsocks.sh" "/etc/fazzpedia/shadowsocks/shadowsocks.sh"
dl "shadowsocks/addss.sh"     "/usr/bin/addss"
dl "shadowsocks/delss.sh"     "/usr/bin/delss"
dl "shadowsocks/renewss.sh"   "/usr/bin/renewss"
dl "shadowsocks/cekss.sh"     "/usr/bin/cekss"
dl "sstp/sstp.sh"             "/etc/fazzpedia/sstp/sstp.sh"
dl "sstp/addsstp.sh"          "/usr/bin/addsstp"
dl "sstp/delsstp.sh"          "/usr/bin/delsstp"
dl "sstp/renewsstp.sh"        "/usr/bin/renewsstp"
dl "ipsec/ipsec.sh"           "/etc/fazzpedia/ipsec/ipsec.sh"
dl "ipsec/addl2tp.sh"         "/usr/bin/addl2tp"
dl "ipsec/dell2tp.sh"         "/usr/bin/dell2tp"
dl "ipsec/renewl2tp.sh"       "/usr/bin/renewl2tp"
dl "websocket/websocket.sh"   "/etc/fazzpedia/websocket/websocket.sh"
dl "system/setdomain.sh"      "/usr/bin/setdomain"
dl "system/info.sh"           "/usr/bin/sysinfo"
dl "backup/backup.sh"         "/usr/bin/backup"
dl "backup/restore.sh"        "/usr/bin/restore"
dl "menu.sh"                  "/usr/bin/menu"
dl "menu.sh"                  "/usr/bin/fazzpedia"

# ── Install Services ─────────────────────────────────────────
echo -e "${YELLOW}[2/8] Installing SSH & OpenVPN...${NC}"
bash /etc/fazzpedia/ssh/ssh-vpn.sh

echo -e "${YELLOW}[3/8] Installing Xray...${NC}"
bash /etc/fazzpedia/xray/xray.sh

echo -e "${YELLOW}[4/8] Installing Wireguard...${NC}"
bash /etc/fazzpedia/wireguard/wireguard.sh

echo -e "${YELLOW}[5/8] Installing Shadowsocks-R...${NC}"
bash /etc/fazzpedia/shadowsocks/shadowsocks.sh

echo -e "${YELLOW}[6/8] Installing SSTP...${NC}"
bash /etc/fazzpedia/sstp/sstp.sh

echo -e "${YELLOW}[7/8] Installing L2TP/IPSec...${NC}"
bash /etc/fazzpedia/ipsec/ipsec.sh

echo -e "${YELLOW}[8/8] Installing WebSocket & finishing...${NC}"
bash /etc/fazzpedia/websocket/websocket.sh

# ── Systemd startup service ───────────────────────────────────
cat > /etc/systemd/system/fazzpedia.service <<-EOF
[Unit]
Description=FazzPedia VPN Startup
After=network.target
[Service]
Type=oneshot
ExecStart=/bin/bash /etc/fazzpedia/startup.sh
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable fazzpedia

# ── Auto menu saat login ──────────────────────────────────────
grep -q "fazzpedia-automenu" /root/.bashrc || cat >> /root/.bashrc <<-'BASHRC'

# fazzpedia-automenu
if [ -f /etc/fazzpedia/installed ] && [ -t 1 ]; then
    menu
fi
BASHRC

touch /etc/fazzpedia/installed
echo "2.0" > /etc/fazzpedia/version
history -c
rm -f /root/setup.sh

clear; banner
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}   INSTALASI SELESAI — FazzPedia||Vpn v2.0${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${GREEN}OpenSSH        : 22, 2253${NC}"
echo -e " ${GREEN}Dropbear       : 109, 143${NC}"
echo -e " ${GREEN}SSLH Mux       : 443 (SSH+WS+OpenVPN)${NC}"
echo -e " ${GREEN}Stunnel SSL    : 445, 777, 990${NC}"
echo -e " ${GREEN}WebSocket      : 8880 (non-TLS)${NC}"
echo -e " ${GREEN}OpenVPN TCP    : 1194${NC}"
echo -e " ${GREEN}OpenVPN UDP    : 2200${NC}"
echo -e " ${GREEN}Squid          : 3128, 8080${NC}"
echo -e " ${GREEN}BadVPN         : 7100, 7200, 7300${NC}"
echo -e " ${GREEN}Wireguard      : 7070${NC}"
echo -e " ${GREEN}L2TP/IPSec     : 1701${NC}"
echo -e " ${GREEN}SSTP           : 444${NC}"
echo -e " ${GREEN}Shadowsocks-R  : 1443-1543${NC}"
echo -e " ${GREEN}Xray VMess TLS : 8443${NC}"
echo -e " ${GREEN}Xray VMess NTLS: 80${NC}"
echo -e " ${GREEN}Xray VLess TLS : 8442${NC}"
echo -e " ${GREEN}Xray VLess NTLS: 8441${NC}"
echo -e " ${GREEN}Xray Trojan    : 2083${NC}"
echo -e " ${GREEN}OHP SSH        : 8181${NC}"
echo -e " ${GREEN}OHP Dropbear   : 8282${NC}"
echo -e " ${GREEN}OHP OpenVPN    : 8383${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${YELLOW}Ketik 'menu' untuk membuka panel FazzPedia${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo -e "${YELLOW}VPS reboot dalam 15 detik...${NC}"
sleep 15
reboot
