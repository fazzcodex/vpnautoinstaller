#!/bin/bash
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
echo -ne " Username to kick : "; read LOGIN
pkill -u "$LOGIN" 2>/dev/null && echo -e "${GREEN}[✓] User $LOGIN kicked!${NC}" || echo -e "${RED}[!] User not found or not logged in.${NC}"
