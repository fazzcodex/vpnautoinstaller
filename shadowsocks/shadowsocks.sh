#!/bin/bash
# shadowsocks.sh - ShadowsocksR installer
export DEBIAN_FRONTEND=noninteractive
GREEN='\033[0;32m'; NC='\033[0m'; YELLOW='\033[1;33m'
echo -e "${YELLOW}[ShadowsocksR] Installing...${NC}"
apt-get install -y python3 python3-pip
pip3 install shadowsocks 2>/dev/null

# Pakai shadowsocks-libev sebagai alternatif
apt-get install -y shadowsocks-libev
mkdir -p /etc/shadowsocks

cat > /etc/shadowsocks/config.json <<-END
{
    "server": "0.0.0.0",
    "port_password": {
        "1443": "fazzpedia2024",
        "1444": "fazzpedia2024",
        "1445": "fazzpedia2024"
    },
    "timeout": 300,
    "method": "aes-256-gcm",
    "fast_open": false
}
END

cat > /etc/systemd/system/shadowsocks.service <<-END
[Unit]
Description=ShadowsocksR Server
After=network.target
[Service]
ExecStart=/usr/bin/ss-server -c /etc/shadowsocks/config.json
Restart=always
[Install]
WantedBy=multi-user.target
END
systemctl daemon-reload
systemctl enable shadowsocks
systemctl restart shadowsocks
echo -e "${GREEN}[ShadowsocksR] Done! Port 1443-1543${NC}"
