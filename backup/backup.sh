#!/bin/bash
# backup.sh
GREEN='\033[0;32m'; NC='\033[0m'; YELLOW='\033[1;33m'
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/root/fazzpedia-backup"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/backup_${DATE}.tar.gz"
echo -e "${YELLOW}[Backup] Creating backup...${NC}"
tar -czf "$BACKUP_FILE" \
    /etc/fazzpedia \
    /etc/xray \
    /etc/wireguard \
    /etc/shadowsocks \
    /etc/ppp/chap-secrets \
    /etc/ipsec.secrets \
    /etc/stunnel/stunnel.conf \
    /var/lib/crot \
    2>/dev/null
echo -e "${GREEN}[✓] Backup saved: $BACKUP_FILE${NC}"
ls -lh "$BACKUP_FILE"
