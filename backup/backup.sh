#!/bin/bash
# ============================================================
#   FazzPedia||Vpn - Backup & Restore
# ============================================================
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'

BACKUP_DIR="/etc/fazzpedia/backup"
DATE=$(date +%Y%m%d-%H%M%S)

backup() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}          FazzPedia||Vpn - Backup Server Data${NC}"
echo -e "${CYAN}============================================================${NC}"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/fazzpedia-backup-$DATE.tar.gz"
echo -e "${YELLOW}[+] Creating backup...${NC}"
tar -czf "$BACKUP_FILE" \
    /etc/fazzpedia/ \
    /etc/ssh/sshd_config \
    /etc/default/dropbear \
    /etc/stunnel/ \
    /etc/squid/squid.conf \
    /etc/openvpn/ \
    /etc/xray/config.json \
    /etc/xray/cert/ \
    /etc/wireguard/ \
    /etc/shadowsocks/ \
    /etc/ppp/chap-secrets \
    /etc/ipsec.conf \
    /etc/ipsec.secrets \
    2>/dev/null
echo -e "${GREEN}[OK] Backup saved: $BACKUP_FILE${NC}"
echo -e " ${YELLOW}Size: $(du -sh $BACKUP_FILE | awk '{print $1}')${NC}"
echo -e "${CYAN}============================================================${NC}"
}

restore() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}         FazzPedia||Vpn - Restore Server Data${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e "${YELLOW}Available backups:${NC}"
ls -lh "$BACKUP_DIR"/*.tar.gz 2>/dev/null || { echo "No backup found."; return; }
echo ""
read -p " Enter backup filename: " FILE
if [ -f "$BACKUP_DIR/$FILE" ]; then
    tar -xzf "$BACKUP_DIR/$FILE" -C /
    echo -e "${GREEN}[OK] Restored from $FILE${NC}"
    bash /etc/fazzpedia/system/restart.sh
else
    echo -e "${RED}[ERROR] File not found.${NC}"
fi
}

autobackup() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}       FazzPedia||Vpn - Auto Backup Setup${NC}"
echo -e "${CYAN}============================================================${NC}"
read -p " Enable auto backup daily? [y/n]: " CONFIRM
if [[ "$CONFIRM" == "y" ]]; then
    (crontab -l 2>/dev/null; echo "0 3 * * * /bin/bash /etc/fazzpedia/backup/backup.sh auto") | crontab -
    echo -e "${GREEN}[OK] Auto backup enabled at 03:00 WIB daily.${NC}"
fi
}

case "$1" in
    restore)    restore ;;
    autobackup) autobackup ;;
    *)          backup ;;
esac
