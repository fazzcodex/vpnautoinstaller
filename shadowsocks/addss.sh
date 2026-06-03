#!/bin/bash
# addss.sh
GREEN='\033[0;32m'; NC='\033[0m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'
MYIP=$(cat /etc/fazzpedia/myip 2>/dev/null || curl -s ipinfo.io/ip)
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${YELLOW}         Create Shadowsocks Account${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -ne " Remark        : "; read REMARK
echo -ne " Password      : "; read PASS
echo -ne " Expired (hari): "; read DAYS

# Cari port kosong mulai 1443
PORT=1443
while grep -q "\"$PORT\"" /etc/shadowsocks/config.json 2>/dev/null; do PORT=$((PORT+1)); done

EXPIRED=$(date -d "$DAYS days" +"%Y-%m-%d")
METHOD="aes-256-gcm"

# Tambah port ke config
python3 - <<PYEOF
import json
with open('/etc/shadowsocks/config.json') as f:
    cfg = json.load(f)
cfg['port_password']['$PORT'] = '$PASS'
with open('/etc/shadowsocks/config.json', 'w') as f:
    json.dump(cfg, f, indent=4)
PYEOF

mkdir -p /etc/shadowsocks/users
echo "$REMARK|$PORT|$PASS|$METHOD|$EXPIRED" >> /etc/shadowsocks/users/ss.db
systemctl restart shadowsocks

clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${GREEN}         Shadowsocks Account Created!${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${WHITE}Remark   : ${YELLOW}$REMARK${NC}"
echo -e " ${WHITE}Host     : ${YELLOW}$MYIP${NC}"
echo -e " ${WHITE}Port     : ${YELLOW}$PORT${NC}"
echo -e " ${WHITE}Password : ${YELLOW}$PASS${NC}"
echo -e " ${WHITE}Method   : ${YELLOW}$METHOD${NC}"
echo -e " ${WHITE}Expired  : ${YELLOW}$EXPIRED${NC}"
echo -e "${CYAN}============================================================${NC}"
