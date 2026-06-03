#!/bin/bash
CYAN='\033[0;36m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'; NC='\033[0m'
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${YELLOW}         List VMess Accounts${NC}"
echo -e "${CYAN}============================================================${NC}"
if [ ! -f /etc/xray/users/vmess.db ]; then echo "Tidak ada akun."; exit; fi
printf " %-20s %-38s %-12s\n" "REMARK" "UUID" "EXPIRED"
echo -e "${CYAN}------------------------------------------------------------${NC}"
while IFS='|' read -r remark uuid expired type; do
    [ "$type" = "vmess" ] || continue
    TODAY=$(date +%s); EXP_S=$(date -d "$expired" +%s 2>/dev/null || echo 0)
    [ "$TODAY" -gt "$EXP_S" ] && STATUS="\033[0;31mExpired\033[0m" || STATUS="\033[0;32mActive\033[0m"
    printf " %-20s %-38s %-12s " "$remark" "$uuid" "$expired"
    echo -e "$STATUS"
done < /etc/xray/users/vmess.db
echo -e "${CYAN}============================================================${NC}"
