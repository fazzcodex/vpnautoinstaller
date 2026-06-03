#!/bin/bash
# restore.sh
GREEN='\033[0;32m'; NC='\033[0m'; YELLOW='\033[1;33m'; RED='\033[0;31m'
BACKUP_DIR="/root/fazzpedia-backup"
echo -e "${YELLOW}Available backups:${NC}"
ls -lt "$BACKUP_DIR"/*.tar.gz 2>/dev/null | awk '{print NR".", $NF}'
echo -ne " Masukkan nama file backup : "; read BFILE
[ ! -f "$BFILE" ] && [ -f "$BACKUP_DIR/$BFILE" ] && BFILE="$BACKUP_DIR/$BFILE"
if [ ! -f "$BFILE" ]; then echo -e "${RED}File tidak ditemukan!${NC}"; exit 1; fi
echo -e "${YELLOW}[Restore] Restoring from $BFILE...${NC}"
tar -xzf "$BFILE" -C / 2>/dev/null
systemctl restart xray ssh dropbear stunnel4 sslh wg-quick@wg0 2>/dev/null
echo -e "${GREEN}[✓] Restore selesai!${NC}"
