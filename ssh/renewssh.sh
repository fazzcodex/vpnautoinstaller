#!/bin/bash
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${YELLOW}         Renew SSH Account${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -ne " Username       : "; read LOGIN
echo -ne " Tambah (hari)  : "; read DAYS
if ! id "$LOGIN" &>/dev/null; then
    echo -e "${RED}[!] User tidak ditemukan!${NC}"; exit 1
fi
CURR=$(chage -l "$LOGIN" | grep "Account expires" | cut -d: -f2 | xargs)
if [ "$CURR" == "never" ] || [ -z "$CURR" ]; then
    NEW=$(date -d "$DAYS days" +"%Y-%m-%d")
else
    NEW=$(date -d "$CURR + $DAYS days" +"%Y-%m-%d")
fi
usermod -e "$NEW" "$LOGIN"
echo -e "${GREEN}[✓] Akun $LOGIN diperpanjang hingga $NEW${NC}"
