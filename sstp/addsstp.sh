#!/bin/bash
# ============================================================
#   FazzPedia||Vpn - SSTP User Management
# ============================================================
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'
MYIP=$(curl -s ipinfo.io/ip)

addsstp() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}        FazzPedia||Vpn - Create SSTP Account${NC}"
echo -e "${CYAN}============================================================${NC}"
read -p " Username        : " USER
read -p " Password        : " PASS
read -p " Expired (days)  : " DAYS
EXPDATE=$(date -d "+${DAYS} days" +"%Y-%m-%d")
echo "${USER} * ${PASS} *" >> /etc/ppp/chap-secrets
echo "$USER $EXPDATE sstp" >> /etc/fazzpedia/sstp_accounts.conf
systemctl restart sstp-fazzpedia 2>/dev/null
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}        FazzPedia||Vpn - SSTP Account Info${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${YELLOW}Username   :${NC} $USER"
echo -e " ${YELLOW}Password   :${NC} $PASS"
echo -e " ${YELLOW}Expired    :${NC} $EXPDATE"
echo -e " ${YELLOW}Host/IP    :${NC} $MYIP"
echo -e " ${YELLOW}Port       :${NC} 444"
echo -e " ${YELLOW}Protocol   :${NC} SSTP (Microsoft)"
echo -e "${CYAN}============================================================${NC}"
}

delsstp() {
read -p " Username : " USER
sed -i "/^${USER} \*/d" /etc/ppp/chap-secrets
sed -i "/^${USER} /d" /etc/fazzpedia/sstp_accounts.conf
echo -e "${GREEN}[OK] SSTP user '$USER' deleted.${NC}"
}

renewsstp() {
read -p " Username      : " USER
read -p " Extend (days) : " DAYS
NEWDATE=$(date -d "+${DAYS} days" +"%Y-%m-%d")
sed -i "s/^${USER} [0-9-]* sstp/${USER} ${NEWDATE} sstp/" /etc/fazzpedia/sstp_accounts.conf
echo -e "${GREEN}[OK] SSTP '$USER' renewed until ${NEWDATE}${NC}"
}

ceksstp() {
clear
echo -e "${CYAN}SSTP Accounts:${NC}"
printf " %-20s %-15s\n" "USERNAME" "EXPIRED"
while read user exp proto; do
    printf " %-20s %-15s\n" "$user" "$exp"
done < /etc/fazzpedia/sstp_accounts.conf 2>/dev/null
}

case "$1" in
    del)   delsstp ;;
    renew) renewsstp ;;
    cek)   ceksstp ;;
    *)     addsstp ;;
esac
