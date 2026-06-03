#!/bin/bash
# cekssh.sh - Check active SSH login
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${YELLOW}         Active SSH Login${NC}"
echo -e "${CYAN}============================================================${NC}"
COUNT=0
while IFS= read -r line; do
    USER=$(echo "$line" | awk '{print $1}')
    IP=$(echo "$line" | awk '{print $3}' | cut -d: -f1 | tr -d '()')
    [ -n "$USER" ] && [ "$USER" != "USER" ] && {
        echo -e " ${WHITE}$USER ${YELLOW}→ ${GREEN}$IP${NC}"
        COUNT=$((COUNT+1))
    }
done < <(who)
echo -e "${CYAN}============================================================${NC}"
echo -e " Total login: ${YELLOW}$COUNT${NC}"
echo -e "${CYAN}============================================================${NC}"
