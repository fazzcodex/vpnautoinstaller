#!/bin/bash
# ============================================================
#   FazzPedia||Vpn - Add SSH Account
# ============================================================
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'

MYIP=$(curl -s ipinfo.io/ip)

addssh() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}          FazzPedia||Vpn - Create SSH Account${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
read -p " Username        : " USER
read -p " Password        : " PASS
read -p " Expired (days)  : " DAYS
read -p " Max Login       : " MAXLOGIN

if id "$USER" &>/dev/null; then
    echo -e "${RED}[ERROR] User '$USER' already exists!${NC}"
    return
fi

EXPDATE=$(date -d "+${DAYS} days" +"%Y-%m-%d")
useradd -e "$EXPDATE" -s /bin/false -M "$USER"
echo "$USER:$PASS" | chpasswd

# Save maxlogin limit
echo "$USER $MAXLOGIN" >> /etc/fazzpedia/ssh_limits.conf

clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}       FazzPedia||Vpn - SSH Account Created${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo -e " ${YELLOW}Username   :${NC} $USER"
echo -e " ${YELLOW}Password   :${NC} $PASS"
echo -e " ${YELLOW}Expired    :${NC} $EXPDATE ($DAYS days)"
echo -e " ${YELLOW}Max Login  :${NC} $MAXLOGIN"
echo ""
echo -e " ${WHITE}── Connection Info ──${NC}"
echo -e " ${YELLOW}Host/IP    :${NC} $MYIP"
echo -e " ${YELLOW}SSH Port   :${NC} 22, 443"
echo -e " ${YELLOW}Dropbear   :${NC} 109, 143"
echo -e " ${YELLOW}SSL/Stunnel:${NC} 445, 777"
echo -e " ${YELLOW}WS Non-TLS :${NC} 8880"
echo -e " ${YELLOW}OHP SSH    :${NC} 8181"
echo -e " ${YELLOW}OHP DB     :${NC} 8282"
echo -e "${CYAN}============================================================${NC}"
echo ""
}

delssh() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}          FazzPedia||Vpn - Delete SSH Account${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
read -p " Username : " USER
if ! id "$USER" &>/dev/null; then
    echo -e "${RED}[ERROR] User '$USER' not found!${NC}"
    return
fi
userdel -r "$USER" 2>/dev/null
sed -i "/^$USER /d" /etc/fazzpedia/ssh_limits.conf
echo -e "${GREEN}[OK] User '$USER' deleted.${NC}"
}

renewssh() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}         FazzPedia||Vpn - Renew SSH Account${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
read -p " Username       : " USER
read -p " Extend (days)  : " DAYS
if ! id "$USER" &>/dev/null; then
    echo -e "${RED}[ERROR] User '$USER' not found!${NC}"
    return
fi
CURRENT=$(chage -l "$USER" | grep "Account expires" | awk -F': ' '{print $2}')
if [[ "$CURRENT" == "never" ]] || [[ -z "$CURRENT" ]]; then
    NEWDATE=$(date -d "+${DAYS} days" +"%Y-%m-%d")
else
    NEWDATE=$(date -d "$CURRENT +${DAYS} days" +"%Y-%m-%d")
fi
chage -E "$NEWDATE" "$USER"
echo -e "${GREEN}[OK] User '$USER' renewed until $NEWDATE${NC}"
}

cekssh() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}         FazzPedia||Vpn - Check SSH Login${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
echo -e " ${WHITE}Active SSH Sessions:${NC}"
echo ""
who | awk '{print " User: "$1"\t IP: "$5"\t Time: "$3" "$4}'
echo ""
echo -e " ${YELLOW}Total users online: $(who | wc -l)${NC}"
echo ""
echo -e "${CYAN}============================================================${NC}"
}

member() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}         FazzPedia||Vpn - SSH Member List${NC}"
echo -e "${CYAN}============================================================${NC}"
printf " %-20s %-15s %-12s\n" "USERNAME" "EXPIRED" "STATUS"
echo -e " ------------------------------------------------------------"
while IFS=: read -r user _ uid _ _ _ shell; do
    if [[ "$uid" -ge 1000 ]] && [[ "$shell" == "/bin/false" ]]; then
        EXP=$(chage -l "$user" 2>/dev/null | grep "Account expires" | awk -F': ' '{print $2}')
        TODAY=$(date +%s)
        if [[ "$EXP" == "never" ]]; then
            STATUS="${GREEN}Active${NC}"
        else
            EXP_TS=$(date -d "$EXP" +%s 2>/dev/null)
            if [[ "$TODAY" -gt "$EXP_TS" ]]; then
                STATUS="${RED}Expired${NC}"
            else
                STATUS="${GREEN}Active${NC}"
            fi
        fi
        printf " %-20s %-15s " "$user" "$EXP"
        echo -e "$STATUS"
    fi
done < /etc/passwd
echo ""
echo -e "${CYAN}============================================================${NC}"
}

delexp() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}      FazzPedia||Vpn - Delete Expired SSH Accounts${NC}"
echo -e "${CYAN}============================================================${NC}"
TODAY=$(date +%s)
COUNT=0
while IFS=: read -r user _ uid _ _ _ shell; do
    if [[ "$uid" -ge 1000 ]] && [[ "$shell" == "/bin/false" ]]; then
        EXP=$(chage -l "$user" 2>/dev/null | grep "Account expires" | awk -F': ' '{print $2}')
        if [[ "$EXP" != "never" ]] && [[ ! -z "$EXP" ]]; then
            EXP_TS=$(date -d "$EXP" +%s 2>/dev/null)
            if [[ "$TODAY" -gt "$EXP_TS" ]]; then
                userdel -r "$user" 2>/dev/null
                echo -e " ${RED}Deleted:${NC} $user (expired: $EXP)"
                ((COUNT++))
            fi
        fi
    fi
done < /etc/passwd
echo ""
echo -e " ${YELLOW}Total deleted: $COUNT accounts${NC}"
echo -e "${CYAN}============================================================${NC}"
}

trialssh() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}       FazzPedia||Vpn - Create Trial SSH Account${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
TRIAL_USER="trial$(shuf -i 1000-9999 -n 1)"
TRIAL_PASS="fazzpedia$(shuf -i 100-999 -n 1)"
EXPDATE=$(date -d "+1 days" +"%Y-%m-%d")
useradd -e "$EXPDATE" -s /bin/false -M "$TRIAL_USER"
echo "$TRIAL_USER:$TRIAL_PASS" | chpasswd
echo -e " ${YELLOW}Username   :${NC} $TRIAL_USER"
echo -e " ${YELLOW}Password   :${NC} $TRIAL_PASS"
echo -e " ${YELLOW}Expired    :${NC} $EXPDATE (1 day trial)"
echo -e " ${YELLOW}Host/IP    :${NC} $MYIP"
echo -e " ${YELLOW}SSH Port   :${NC} 22, 443"
echo ""
echo -e "${CYAN}============================================================${NC}"
}

autokill() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}        FazzPedia||Vpn - Setup Auto-Kill SSH${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
read -p " Enable auto-kill multi-login? [y/n]: " CONFIRM
if [[ "$CONFIRM" == "y" ]]; then
    cat > /etc/cron.d/fazzpedia-autokill <<'EOF'
*/5 * * * * root /bin/bash /etc/fazzpedia/autokill.sh
EOF
    cat > /etc/fazzpedia/autokill.sh <<'AKEOF'
#!/bin/bash
while read user limit; do
    ACTIVE=$(who | grep "^$user " | wc -l)
    if [[ "$ACTIVE" -gt "$limit" ]]; then
        who | grep "^$user " | awk '{print $2}' | while read tty; do
            pkill -t "$tty" -u "$user" 2>/dev/null
        done
    fi
done < /etc/fazzpedia/ssh_limits.conf
AKEOF
    chmod +x /etc/fazzpedia/autokill.sh
    echo -e "${GREEN}[OK] Auto-kill enabled (checks every 5 minutes)${NC}"
fi
}

ceklim() {
clear
echo -e "${CYAN}============================================================${NC}"
echo -e "${WHITE}      FazzPedia||Vpn - Multi-Login Violators${NC}"
echo -e "${CYAN}============================================================${NC}"
echo ""
while read user limit; do
    ACTIVE=$(who | grep "^$user " | wc -l)
    if [[ "$ACTIVE" -gt "$limit" ]]; then
        echo -e " ${RED}VIOLATION${NC} - User: $user | Active: $ACTIVE | Limit: $limit"
    fi
done < /etc/fazzpedia/ssh_limits.conf 2>/dev/null
echo ""
echo -e "${CYAN}============================================================${NC}"
}

# Run the function passed as argument or show addssh by default
case "$1" in
    del) delssh ;;
    renew) renewssh ;;
    cek) cekssh ;;
    member) member ;;
    delexp) delexp ;;
    trial) trialssh ;;
    autokill) autokill ;;
    ceklim) ceklim ;;
    *) addssh ;;
esac
