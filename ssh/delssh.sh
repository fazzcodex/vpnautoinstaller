#!/bin/bash
# delssh.sh
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${YELLOW}         Delete SSH Account${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -ne " Username : "; read LOGIN
if ! id "$LOGIN" &>/dev/null; then
    echo -e "${RED}[!] User tidak ditemukan!${NC}"; exit 1
fi
userdel --force "$LOGIN" 2>/dev/null
echo -e "${GREEN}[✓] User $LOGIN berhasil dihapus!${NC}"
