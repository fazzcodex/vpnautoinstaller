#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
GREEN='\033[0;32m'; NC='\033[0m'; YELLOW='\033[1;33m'; RED='\033[0;31m'
MYIP=$(cat /etc/fazzpedia/myip 2>/dev/null || curl -s ipinfo.io/ip)
echo -e "${YELLOW}[Xray] Installing...${NC}"

# Install Xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install 2>/dev/null
if ! command -v xray &>/dev/null; then
    wget -q https://github.com/XTLS/Xray-install/raw/main/install-release.sh -O /tmp/xray-install.sh
    bash /tmp/xray-install.sh install 2>/dev/null
fi

mkdir -p /etc/xray

# Generate UUID
UUID=$(cat /proc/sys/kernel/random/uuid)
echo "$UUID" > /etc/xray/uuid

# Domain
DOMAIN=$(cat /etc/xray/domain 2>/dev/null || echo "$MYIP")

# Generate self-signed cert jika belum ada
if [ ! -f /etc/xray/xray.crt ]; then
    openssl req -new -x509 -days 3650 -nodes \
        -subj "/C=ID/ST=Indonesia/L=Indonesia/O=FazzPedia/CN=${DOMAIN}" \
        -newkey rsa:2048 -keyout /etc/xray/xray.key -out /etc/xray/xray.crt 2>/dev/null
fi

# Xray config
cat > /etc/xray/config.json <<-EOF
{
  "log": {"loglevel": "warning"},
  "inbounds": [
    {
      "port": 8443,
      "protocol": "vmess",
      "settings": {"clients": [{"id": "${UUID}", "alterId": 0}]},
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {"certificates": [{"certificateFile": "/etc/xray/xray.crt", "keyFile": "/etc/xray/xray.key"}]},
        "wsSettings": {"path": "/vmess"}
      },
      "tag": "vmess-tls"
    },
    {
      "port": 80,
      "protocol": "vmess",
      "settings": {"clients": [{"id": "${UUID}", "alterId": 0}]},
      "streamSettings": {"network": "ws", "wsSettings": {"path": "/vmess"}},
      "tag": "vmess-ntls"
    },
    {
      "port": 8442,
      "protocol": "vless",
      "settings": {"clients": [{"id": "${UUID}"}], "decryption": "none"},
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {"certificates": [{"certificateFile": "/etc/xray/xray.crt", "keyFile": "/etc/xray/xray.key"}]},
        "wsSettings": {"path": "/vless"}
      },
      "tag": "vless-tls"
    },
    {
      "port": 8441,
      "protocol": "vless",
      "settings": {"clients": [{"id": "${UUID}"}], "decryption": "none"},
      "streamSettings": {"network": "ws", "wsSettings": {"path": "/vless"}},
      "tag": "vless-ntls"
    },
    {
      "port": 2083,
      "protocol": "trojan",
      "settings": {"clients": [{"password": "${UUID}"}]},
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {"certificates": [{"certificateFile": "/etc/xray/xray.crt", "keyFile": "/etc/xray/xray.key"}]},
        "wsSettings": {"path": "/trojan"}
      },
      "tag": "trojan"
    }
  ],
  "outbounds": [
    {"protocol": "freedom", "tag": "direct"},
    {"protocol": "blackhole", "tag": "blocked"}
  ]
}
EOF

systemctl enable xray
systemctl restart xray
echo -e "${GREEN}[Xray] Installation complete! UUID: ${UUID}${NC}"
