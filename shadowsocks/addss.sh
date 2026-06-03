#!/bin/bash
# ============================================================
#   FazzPedia||Vpn - Shadowsocks User Management
# ============================================================
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'
MYIP=$(curl -s ipinfo.io/ip)
SS_CONFIG="/etc/shadowsocks/config.json"

addss() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}      FazzPedia||Vpn - Create Shadowsocks Account${NC}"
echo -e "${CYAN}============================================================${NC}"
read -p " Password        : " PASS
read -p " Port (1443-1543): " PORT
read -p " Expired (days)  : " DAYS
EXPDATE=$(date -d "+${DAYS} days" +"%Y-%m-%d")

python3 - <<PYEOF
import json
with open("$SS_CONFIG") as f: cfg = json.load(f)
cfg["port_password"]["$PORT"] = "$PASS"
with open("$SS_CONFIG","w") as f: json.dump(cfg, f, indent=4)
PYEOF
systemctl restart shadowsocks-fazzpedia 2>/dev/null
echo "$PORT $EXPDATE $PASS" >> /etc/fazzpedia/ss_accounts.conf

clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}      FazzPedia||Vpn - Shadowsocks Account Info${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${YELLOW}Password   :${NC} $PASS"
echo -e " ${YELLOW}Port       :${NC} $PORT"
echo -e " ${YELLOW}Expired    :${NC} $EXPDATE"
echo -e " ${YELLOW}Host/IP    :${NC} $MYIP"
echo -e " ${YELLOW}Method     :${NC} aes-256-gcm"
echo -e " ${YELLOW}Protocol   :${NC} Shadowsocks"
echo -e "${CYAN}============================================================${NC}"
}

delss() {
read -p " Port to delete : " PORT
python3 - <<PYEOF
import json
with open("$SS_CONFIG") as f: cfg = json.load(f)
cfg["port_password"].pop("$PORT", None)
with open("$SS_CONFIG","w") as f: json.dump(cfg, f, indent=4)
PYEOF
sed -i "/^${PORT} /d" /etc/fazzpedia/ss_accounts.conf
systemctl restart shadowsocks-fazzpedia 2>/dev/null
echo -e "${GREEN}[OK] Shadowsocks port $PORT deleted.${NC}"
}

renewss() {
read -p " Port          : " PORT
read -p " Extend (days) : " DAYS
NEWDATE=$(date -d "+${DAYS} days" +"%Y-%m-%d")
sed -i "s/^${PORT} [0-9-]* /${PORT} ${NEWDATE} /" /etc/fazzpedia/ss_accounts.conf
echo -e "${GREEN}[OK] Shadowsocks port $PORT renewed until ${NEWDATE}${NC}"
}

cekss() {
clear
echo -e "${CYAN}Shadowsocks Accounts:${NC}"
python3 - <<PYEOF
import json
with open("$SS_CONFIG") as f: cfg = json.load(f)
print(f"  {'PORT':<10} {'PASSWORD':<30}")
print(f"  {'-'*10} {'-'*30}")
for port, pw in cfg["port_password"].items():
    print(f"  {port:<10} {pw:<30}")
PYEOF
}

case "$1" in
    del)   delss ;;
    renew) renewss ;;
    cek)   cekss ;;
    *)     addss ;;
esac
