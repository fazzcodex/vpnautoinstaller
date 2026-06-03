#!/bin/bash
# ============================================================
#   FazzPedia||Vpn - SSTP Installer
#   Support: Ubuntu 20.04 / 22.04 / 24.04
# ============================================================

RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MYIP=$(curl -s ipinfo.io/ip)
NET=$(ip -o -4 route show to default | awk '{print $5}')

echo -e "${YELLOW}[SSTP] Installing SSTP via accel-ppp...${NC}"

apt install -y accel-ppp || {
    echo -e "${YELLOW}[SSTP] Installing from source...${NC}"
    apt install -y build-essential cmake libssl-dev libpcre3-dev \
        libnetfilter-queue-dev libsnappy-dev
}

mkdir -p /etc/accel-ppp

cat > /etc/accel-ppp/accel-ppp.conf <<EOF
[modules]
log_file
sstp

[core]
thread-count=4

[common]
single-session=replace

[sstp]
listen=0.0.0.0:444
ssl-pemfile=/etc/stunnel/stunnel.pem
timeout=60

[ip-pool]
gw-ip-address=192.168.99.1
192.168.99.0/24

[dns]
dns1=8.8.8.8
dns2=8.8.4.4

[log]
log-file=/var/log/accel-ppp/accel-ppp.log
log-emerg=/var/log/accel-ppp/emerg.log
log-fail-file=/var/log/accel-ppp/auth-failed.log
copy=1

[chap-secrets]
gw-ip-address=192.168.99.1
chap-secrets=/etc/ppp/chap-secrets
EOF

mkdir -p /var/log/accel-ppp

cat > /etc/systemd/system/sstp-fazzpedia.service <<EOF
[Unit]
Description=FazzPedia SSTP Service
After=network.target
[Service]
ExecStart=/usr/sbin/accel-pppd -c /etc/accel-ppp/accel-ppp.conf -p /var/run/accel-ppp.pid -d
Type=forking
PIDFile=/var/run/accel-ppp.pid
Restart=always
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable sstp-fazzpedia
systemctl start sstp-fazzpedia 2>/dev/null || true

echo -e "${GREEN}[SSTP] Done! Port: 444${NC}"
