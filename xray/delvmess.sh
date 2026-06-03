#!/bin/bash
# delvmess.sh
GREEN='\033[0;32m'; NC='\033[0m'; RED='\033[0;31m'; YELLOW='\033[1;33m'
echo -ne " UUID atau Remark yang dihapus : "; read TARGET
sed -i "/$TARGET/d" /etc/xray/users/vmess.db 2>/dev/null
CONFIG="/etc/xray/config.json"
jq --arg t "$TARGET" \
  '(.inbounds[] | select(.tag | startswith("vmess")) | .settings.clients) |= map(select(.id != $t and .email != $t))' \
  "$CONFIG" > /tmp/xray_tmp.json && mv /tmp/xray_tmp.json "$CONFIG"
systemctl restart xray
echo -e "${GREEN}[✓] VMess user $TARGET dihapus${NC}"
