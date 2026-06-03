#!/bin/bash
GREEN='\033[0;32m'; NC='\033[0m'; YELLOW='\033[1;33m'; RED='\033[0;31m'
echo -ne " Username/Remark : "; read TARGET
echo -ne " Hari (untuk renew, skip untuk del) : "; read DAYS
# delvless logic
case "delvless" in
    del*|Del*) 
        sed -i "/^|/d" /etc/fazzpedia/*/users.db /etc/xray/users/*.db /etc/wireguard/users/wg.db /etc/sstp/users/sstp.db /etc/shadowsocks/users/ss.db 2>/dev/null
        sed -i "/${TARGET}/d" /etc/ppp/chap-secrets 2>/dev/null
        echo -e "${GREEN}[✓] ${TARGET} dihapus${NC}" ;;
    renew*)
        NEWEXP=$(date -d "${DAYS:-30} days" +"%Y-%m-%d")
        # Update expired date in DB
        for db in /etc/xray/users/*.db /etc/wireguard/users/wg.db /etc/fazzpedia/l2tp/users.db; do
            [ -f "$db" ] && sed -i "s/^\(${TARGET}|.*|\)[0-9-]*/\1${NEWEXP}/" "$db" 2>/dev/null
        done
        echo -e "${GREEN}[✓] ${TARGET} diperpanjang hingga ${NEWEXP}${NC}" ;;
    cek*|list*)
        cat /etc/xray/users/*.db /etc/wireguard/users/wg.db 2>/dev/null | grep -v "^$" ;;
esac
