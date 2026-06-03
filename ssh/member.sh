#!/bin/bash
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${YELLOW}         List SSH Member${NC}"
echo -e "${CYAN}============================================================${NC}"
printf " %-20s %-15s %-5s\n" "USERNAME" "EXPIRED" "STATUS"
echo -e "${CYAN}------------------------------------------------------------${NC}"
TODAY=$(date +%s)
while IFS=: read -r user _ uid _ _ _ shell; do
    [ "$uid" -ge 1000 ] 2>/dev/null || continue
    [ "$shell" = "/bin/false" ] || [ "$shell" = "/usr/sbin/nologin" ] || continue
    EXP=$(chage -l "$user" 2>/dev/null | grep "Account expires" | cut -d: -f2 | xargs)
    if [ "$EXP" = "never" ] || [ -z "$EXP" ]; then
        STATUS="${GREEN}Active${NC}"; EXP="Never"
    else
        EXP_S=$(date -d "$EXP" +%s 2>/dev/null || echo 0)
        [ "$TODAY" -gt "$EXP_S" ] && STATUS="${RED}Expired${NC}" || STATUS="${GREEN}Active${NC}"
    fi
    printf " %-20s %-15s " "$user" "$EXP"
    echo -e "$STATUS"
done < /etc/passwd
echo -e "${CYAN}============================================================${NC}"
