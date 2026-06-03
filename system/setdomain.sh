#!/bin/bash
GREEN='\033[0;32m'; NC='\033[0m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${YELLOW}         Set Domain / Subdomain${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -ne " Masukkan domain/subdomain : "; read DOMAIN
[ -z "$DOMAIN" ] && echo "Domain kosong!" && exit 1

echo "$DOMAIN" > /etc/xray/domain
echo -e "${YELLOW}[~] Mengupdate config Xray...${NC}"

# Update xray config jika ada
if [ -f /etc/xray/config.json ]; then
    OLDDOMAIN=$(cat /etc/xray/domain.old 2>/dev/null || echo "")
    [ -n "$OLDDOMAIN" ] && sed -i "s/${OLDDOMAIN}/${DOMAIN}/g" /etc/xray/config.json
fi
echo "$DOMAIN" > /etc/xray/domain.old

systemctl restart xray 2>/dev/null
echo -e "${GREEN}[✓] Domain berhasil diset ke: $DOMAIN${NC}"
echo -e "${YELLOW}[!] Pastikan domain sudah diarahkan ke IP: $(cat /etc/fazzpedia/myip)${NC}"
