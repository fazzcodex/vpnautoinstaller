#!/bin/bash
# ============================================================
#   FazzPedia||Vpn - Shadowsocks-R Installer
#   Support: Ubuntu 20.04 / 22.04 / 24.04
# ============================================================

RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'

echo -e "${YELLOW}[SHADOWSOCKS] Installing Shadowsocks-R...${NC}"

apt install -y python3 python3-pip shadowsocks-libev

# Shadowsocks config
mkdir -p /etc/shadowsocks
cat > /etc/shadowsocks/config.json <<EOF
{
    "server": "0.0.0.0",
    "port_password": {
        "1443": "fazzpedia2024",
        "1444": "fazzpedia2024",
        "1445": "fazzpedia2024"
    },
    "timeout": 300,
    "method": "aes-256-gcm",
    "fast_open": true,
    "mode": "tcp_and_udp"
}
EOF

# Systemd service
cat > /etc/systemd/system/shadowsocks-fazzpedia.service <<EOF
[Unit]
Description=FazzPedia Shadowsocks Service
After=network.target
[Service]
Type=forking
ExecStart=/usr/bin/ss-server -c /etc/shadowsocks/config.json -u -d start
ExecStop=/usr/bin/ss-server -c /etc/shadowsocks/config.json -d stop
Restart=always
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable shadowsocks-fazzpedia
systemctl start shadowsocks-fazzpedia

echo -e "${GREEN}[SHADOWSOCKS] Done! Port: 1443-1445, Method: aes-256-gcm${NC}"
