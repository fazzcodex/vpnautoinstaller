#!/bin/bash
# ============================================================
#   FazzPedia||Vpn - Xray User Management
#   VMess / VLess / Trojan
# ============================================================
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'
MYIP=$(curl -s ipinfo.io/ip)
XRAY_CONFIG="/etc/xray/config.json"

# ── Helper ───────────────────────────────────────────────────
new_uuid() { xray uuid 2>/dev/null || cat /proc/sys/kernel/random/uuid; }

add_client() {
    local proto="$1" uuid="$2" email="$3" exp="$4"
    local idx
    case "$proto" in
        vmess-tls)  idx=0 ;;
        vmess-ntls) idx=1 ;;
        vless-tls)  idx=2 ;;
        vless-ntls) idx=3 ;;
        trojan)     idx=4 ;;
    esac
    python3 - <<PYEOF
import json, sys
with open("$XRAY_CONFIG") as f: cfg = json.load(f)
inb = cfg["inbounds"][$idx]
client = {"id":"$uuid","email":"$email","alterId":0} if "$proto".startswith("vmess") else \
         {"id":"$uuid","email":"$email"}              if "$proto".startswith("vless") else \
         {"password":"$uuid","email":"$email"}
inb["settings"]["clients"].append(client)
with open("$XRAY_CONFIG","w") as f: json.dump(cfg, f, indent=2)
PYEOF
    # Save expiry
    echo "$email $exp $proto $uuid" >> /etc/fazzpedia/xray_accounts.conf
    systemctl restart xray 2>/dev/null
}

# ── VMess TLS ────────────────────────────────────────────────
addvmess() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}       FazzPedia||Vpn - Create VMess Account${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
read -p " Username        : " EMAIL
read -p " Expired (days)  : " DAYS
UUID=$(new_uuid)
EXPDATE=$(date -d "+${DAYS} days" +"%Y-%m-%d")

add_client "vmess-tls"  "$UUID" "${EMAIL}-tls"  "$EXPDATE"
add_client "vmess-ntls" "$UUID" "${EMAIL}-ntls" "$EXPDATE"

# Build vmess:// link (TLS)
VMESS_JSON=$(python3 -c "
import json, base64
d = {
    'v':'2','ps':'FazzPedia-VMess-TLS','add':'$MYIP',
    'port':'8443','id':'$UUID','aid':'0',
    'net':'ws','type':'none','host':'$MYIP',
    'path':'/vmess-tls','tls':'tls'
}
print(base64.b64encode(json.dumps(d).encode()).decode())
")

clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}         FazzPedia||Vpn - VMess Account Info${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${YELLOW}Username   :${NC} $EMAIL"
echo -e " ${YELLOW}UUID       :${NC} $UUID"
echo -e " ${YELLOW}Expired    :${NC} $EXPDATE ($DAYS days)"
echo ""
echo -e " ${WHITE}── VMess TLS (port 8443) ──${NC}"
echo -e " ${YELLOW}Host       :${NC} $MYIP"
echo -e " ${YELLOW}Port       :${NC} 8443"
echo -e " ${YELLOW}Network    :${NC} WebSocket"
echo -e " ${YELLOW}Path       :${NC} /vmess-tls"
echo -e " ${YELLOW}TLS        :${NC} Yes"
echo ""
echo -e " ${WHITE}── VMess Non-TLS (port 80) ──${NC}"
echo -e " ${YELLOW}Host       :${NC} $MYIP"
echo -e " ${YELLOW}Port       :${NC} 80"
echo -e " ${YELLOW}Path       :${NC} /vmess-ntls"
echo -e " ${YELLOW}TLS        :${NC} No"
echo ""
echo -e " ${WHITE}── Import Link ──${NC}"
echo -e " vmess://${VMESS_JSON}"
echo ""
echo -e "${CYAN}============================================================${NC}"
}

delvmess() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}       FazzPedia||Vpn - Delete VMess Account${NC}"
echo -e "${CYAN}============================================================${NC}"
read -p " Username : " EMAIL
python3 - <<PYEOF
import json
with open("$XRAY_CONFIG") as f: cfg = json.load(f)
for idx in [0,1]:
    cfg["inbounds"][idx]["settings"]["clients"] = [
        c for c in cfg["inbounds"][idx]["settings"]["clients"]
        if c.get("email","") not in ["${EMAIL}-tls","${EMAIL}-ntls"]
    ]
with open("$XRAY_CONFIG","w") as f: json.dump(cfg, f, indent=2)
PYEOF
sed -i "/${EMAIL}/d" /etc/fazzpedia/xray_accounts.conf
systemctl restart xray 2>/dev/null
echo -e "${GREEN}[OK] VMess user '$EMAIL' deleted.${NC}"
}

renewvmess() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}       FazzPedia||Vpn - Renew VMess Account${NC}"
echo -e "${CYAN}============================================================${NC}"
read -p " Username      : " EMAIL
read -p " Extend (days) : " DAYS
NEWDATE=$(date -d "+${DAYS} days" +"%Y-%m-%d")
sed -i "s/^${EMAIL}-tls .* vmess-tls/${EMAIL}-tls $NEWDATE vmess-tls/" /etc/fazzpedia/xray_accounts.conf
echo -e "${GREEN}[OK] VMess '$EMAIL' renewed until $NEWDATE${NC}"
}

cekvmess() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}       FazzPedia||Vpn - Check VMess Accounts${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
python3 - <<PYEOF
import json
with open("$XRAY_CONFIG") as f: cfg = json.load(f)
clients = cfg["inbounds"][0]["settings"]["clients"]
print(f"  {'EMAIL':<30} {'UUID':<38}")
print(f"  {'-'*30} {'-'*38}")
for c in clients:
    print(f"  {c.get('email',''):<30} {c.get('id',''):<38}")
PYEOF
echo ""
echo -e "${CYAN}============================================================${NC}"
}

# ── VLess ────────────────────────────────────────────────────
addvless() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}       FazzPedia||Vpn - Create VLess Account${NC}"
echo -e "${CYAN}============================================================${NC}"
read -p " Username        : " EMAIL
read -p " Expired (days)  : " DAYS
UUID=$(new_uuid)
EXPDATE=$(date -d "+${DAYS} days" +"%Y-%m-%d")

add_client "vless-tls"  "$UUID" "${EMAIL}-tls"  "$EXPDATE"
add_client "vless-ntls" "$UUID" "${EMAIL}-ntls" "$EXPDATE"

VLESS_LINK="vless://${UUID}@${MYIP}:8442?encryption=none&security=tls&type=ws&path=/vless-tls#FazzPedia-VLess-TLS"

clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}        FazzPedia||Vpn - VLess Account Info${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${YELLOW}Username   :${NC} $EMAIL"
echo -e " ${YELLOW}UUID       :${NC} $UUID"
echo -e " ${YELLOW}Expired    :${NC} $EXPDATE ($DAYS days)"
echo ""
echo -e " ${WHITE}── VLess TLS (port 8442) ──${NC}"
echo -e " ${YELLOW}Host       :${NC} $MYIP"
echo -e " ${YELLOW}Port       :${NC} 8442"
echo -e " ${YELLOW}Path       :${NC} /vless-tls"
echo -e " ${YELLOW}TLS        :${NC} Yes"
echo ""
echo -e " ${WHITE}── VLess Non-TLS (port 8441) ──${NC}"
echo -e " ${YELLOW}Host       :${NC} $MYIP"
echo -e " ${YELLOW}Port       :${NC} 8441"
echo -e " ${YELLOW}Path       :${NC} /vless-ntls"
echo -e " ${YELLOW}TLS        :${NC} No"
echo ""
echo -e " ${WHITE}── Import Link ──${NC}"
echo -e " ${VLESS_LINK}"
echo ""
echo -e "${CYAN}============================================================${NC}"
}

delvless() {
clear; read -p " Username : " EMAIL
python3 - <<PYEOF
import json
with open("$XRAY_CONFIG") as f: cfg = json.load(f)
for idx in [2,3]:
    cfg["inbounds"][idx]["settings"]["clients"] = [
        c for c in cfg["inbounds"][idx]["settings"]["clients"]
        if c.get("email","") not in ["${EMAIL}-tls","${EMAIL}-ntls"]
    ]
with open("$XRAY_CONFIG","w") as f: json.dump(cfg, f, indent=2)
PYEOF
sed -i "/${EMAIL}/d" /etc/fazzpedia/xray_accounts.conf
systemctl restart xray 2>/dev/null
echo -e "${GREEN}[OK] VLess user '$EMAIL' deleted.${NC}"
}

renewvless() {
read -p " Username      : " EMAIL; read -p " Extend (days) : " DAYS
NEWDATE=$(date -d "+${DAYS} days" +"%Y-%m-%d")
echo -e "${GREEN}[OK] VLess '$EMAIL' renewed until $NEWDATE${NC}"
}

cekvless() {
clear; echo -e "${CYAN}VLess Accounts:${NC}"
python3 - <<PYEOF
import json
with open("$XRAY_CONFIG") as f: cfg = json.load(f)
for c in cfg["inbounds"][2]["settings"]["clients"]:
    print(f"  {c.get('email',''):<30} {c.get('id','')}")
PYEOF
}

# ── Trojan ───────────────────────────────────────────────────
addtrojan() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}       FazzPedia||Vpn - Create Trojan Account${NC}"
echo -e "${CYAN}============================================================${NC}"
read -p " Username        : " EMAIL
read -p " Password        : " TPASS
read -p " Expired (days)  : " DAYS
EXPDATE=$(date -d "+${DAYS} days" +"%Y-%m-%d")

python3 - <<PYEOF
import json
with open("$XRAY_CONFIG") as f: cfg = json.load(f)
cfg["inbounds"][4]["settings"]["clients"].append({"password":"$TPASS","email":"$EMAIL"})
with open("$XRAY_CONFIG","w") as f: json.dump(cfg, f, indent=2)
PYEOF
echo "$EMAIL $EXPDATE trojan $TPASS" >> /etc/fazzpedia/xray_accounts.conf
systemctl restart xray 2>/dev/null

TROJAN_LINK="trojan://${TPASS}@${MYIP}:2083?security=tls&type=tcp#FazzPedia-Trojan"

clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}        FazzPedia||Vpn - Trojan Account Info${NC}"
echo -e "${CYAN}============================================================${NC}"
echo -e " ${YELLOW}Username   :${NC} $EMAIL"
echo -e " ${YELLOW}Password   :${NC} $TPASS"
echo -e " ${YELLOW}Expired    :${NC} $EXPDATE"
echo -e " ${YELLOW}Host/IP    :${NC} $MYIP"
echo -e " ${YELLOW}Port       :${NC} 2083"
echo -e " ${YELLOW}TLS        :${NC} Yes"
echo ""
echo -e " ${WHITE}── Import Link ──${NC}"
echo -e " ${TROJAN_LINK}"
echo ""
echo -e "${CYAN}============================================================${NC}"
}

deltrojan() {
read -p " Username : " EMAIL
python3 - <<PYEOF
import json
with open("$XRAY_CONFIG") as f: cfg = json.load(f)
cfg["inbounds"][4]["settings"]["clients"] = [
    c for c in cfg["inbounds"][4]["settings"]["clients"] if c.get("email","") != "$EMAIL"
]
with open("$XRAY_CONFIG","w") as f: json.dump(cfg, f, indent=2)
PYEOF
sed -i "/${EMAIL}/d" /etc/fazzpedia/xray_accounts.conf
systemctl restart xray 2>/dev/null
echo -e "${GREEN}[OK] Trojan user '$EMAIL' deleted.${NC}"
}

renewtrojan() {
read -p " Username      : " EMAIL; read -p " Extend (days) : " DAYS
NEWDATE=$(date -d "+${DAYS} days" +"%Y-%m-%d")
echo -e "${GREEN}[OK] Trojan '$EMAIL' renewed until $NEWDATE${NC}"
}

cektrojan() {
clear; echo -e "${CYAN}Trojan Accounts:${NC}"
python3 - <<PYEOF
import json
with open("$XRAY_CONFIG") as f: cfg = json.load(f)
for c in cfg["inbounds"][4]["settings"]["clients"]:
    print(f"  {c.get('email',''):<30} pass={c.get('password','')}")
PYEOF
}

certv2ray() {
echo -e "${YELLOW}[INFO] Regenerating Xray TLS certificate...${NC}"
MYIP=$(curl -s ipinfo.io/ip)
openssl req -new -x509 -days 3650 -nodes \
    -out /etc/xray/cert/xray.crt \
    -keyout /etc/xray/cert/xray.key \
    -subj "/C=ID/ST=Indonesia/L=Jakarta/O=FazzPedia/CN=${MYIP}"
systemctl restart xray
echo -e "${GREEN}[OK] Certificate renewed.${NC}"
}

case "$1" in
    del-vmess)    delvmess ;;
    renew-vmess)  renewvmess ;;
    cek-vmess)    cekvmess ;;
    add-vless)    addvless ;;
    del-vless)    delvless ;;
    renew-vless)  renewvless ;;
    cek-vless)    cekvless ;;
    add-trojan)   addtrojan ;;
    del-trojan)   deltrojan ;;
    renew-trojan) renewtrojan ;;
    cek-trojan)   cektrojan ;;
    cert)         certv2ray ;;
    *)            addvmess ;;
esac
