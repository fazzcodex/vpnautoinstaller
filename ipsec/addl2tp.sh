#!/bin/bash
# ============================================================
#   FazzPedia||Vpn - L2TP/IPSec User Management
# ============================================================
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'
MYIP=$(curl -s ipinfo.io/ip)
PSK=$(cat /etc/fazzpedia/ipsec_psk.conf 2>/dev/null || echo "FazzPedia2024Secret")

addl2tp() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}       FazzPedia||Vpn - Create L2TP/IPSec Account${NC}"
echo -e "${CYAN}============================================================${NC}"
read -p " Username        : " USER
read -p " Password        : " PASS
read -p " Expired (days)  : " DAYS
EXPDATE=$(date -d "+${DAYS} days" +"%Y-%m-%d")
echo "${USER} l2tpd ${PASS} *" >> /etc/ppp/chap-secrets
echo "$USER $EXPDATE l2tp" >> /etc/fazzpedia/l2tp_accounts.conf
systemctl restart xl2tpd 2>/dev/null
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}       FazzPedia||Vpn - L2TP/IPSec Account Info${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${YELLOW}Username   :${NC} $USER"
echo -e " ${YELLOW}Password   :${NC} $PASS"
echo -e " ${YELLOW}Expired    :${NC} $EXPDATE"
echo -e " ${YELLOW}Host/IP    :${NC} $MYIP"
echo -e " ${YELLOW}PSK/Secret :${NC} $PSK"
echo -e " ${YELLOW}Port       :${NC} 1701 (L2TP)"
echo -e "${CYAN}============================================================${NC}"
}

dell2tp() {
read -p " Username : " USER
sed -i "/^${USER} l2tpd/d" /etc/ppp/chap-secrets
sed -i "/^${USER} /d" /etc/fazzpedia/l2tp_accounts.conf
echo -e "${GREEN}[OK] L2TP user '$USER' deleted.${NC}"
}

renewl2tp() {
read -p " Username      : " USER
read -p " Extend (days) : " DAYS
NEWDATE=$(date -d "+${DAYS} days" +"%Y-%m-%d")
sed -i "s/^${USER} [0-9-]* l2tp/${USER} ${NEWDATE} l2tp/" /etc/fazzpedia/l2tp_accounts.conf
echo -e "${GREEN}[OK] L2TP '$USER' renewed until ${NEWDATE}${NC}"
}

case "$1" in
    del)   dell2tp ;;
    renew) renewl2tp ;;
    *)     addl2tp ;;
esac
