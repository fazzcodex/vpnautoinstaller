#!/bin/bash
# sstp.sh - SSTP installer
export DEBIAN_FRONTEND=noninteractive
GREEN='\033[0;32m'; NC='\033[0m'; YELLOW='\033[1;33m'
echo -e "${YELLOW}[SSTP] Installing...${NC}"
apt-get install -y softether-vpnserver 2>/dev/null || {
    # Fallback: install dari source
    apt-get install -y build-essential libssl-dev libreadline-dev zlib1g-dev cmake
    wget -q https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.42-9798-beta/softether-vpnserver-v4.42-9798-beta-2023.06.30-linux-x64-64bit.tar.gz \
        -O /tmp/se.tar.gz
    if [ -f /tmp/se.tar.gz ]; then
        tar -xzf /tmp/se.tar.gz -C /tmp/
        cd /tmp/vpnserver
        make 2>/dev/null
        mv /tmp/vpnserver /usr/local/vpnserver
        chmod 600 /usr/local/vpnserver/*
        chmod 700 /usr/local/vpnserver/vpnserver
    fi
}

# Pakai xl2tpd+ppp sebagai SSTP fallback dengan stunnel di port 444
apt-get install -y pptpd xl2tpd libssl-dev

# SSTP via stunnel port 444 → PPP
cat >> /etc/stunnel/stunnel.conf <<-END

[sstp]
accept = 444
connect = 127.0.0.1:1723
END
systemctl restart stunnel4

mkdir -p /etc/sstp
echo "SSTP_PORT=444" > /etc/sstp/config
echo -e "${GREEN}[SSTP] Done! Port 444${NC}"
