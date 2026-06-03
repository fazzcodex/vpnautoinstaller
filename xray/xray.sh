#!/bin/bash
# ============================================================
#   FazzPedia||Vpn - Xray Installer (VMess/VLess/Trojan)
#   Support: Ubuntu 20.04 / 22.04 / 24.04
# ============================================================

RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; WHITE='\033[1;37m'

MYIP=$(curl -s ipinfo.io/ip)
source /etc/os-release
VER=$VERSION_ID

echo -e "${YELLOW}[XRAY] Installing Xray Core...${NC}"

apt install -y curl wget unzip nginx

# ============================================================
# Install Xray Core (latest)
# ============================================================
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# ============================================================
# Generate UUID
# ============================================================
UUID=$(xray uuid)
echo "$UUID" > /etc/xray/uuid.conf

# ============================================================
# Self-Signed Cert for TLS
# ============================================================
mkdir -p /etc/xray/cert
openssl req -new -x509 -days 3650 -nodes \
    -out /etc/xray/cert/xray.crt \
    -keyout /etc/xray/cert/xray.key \
    -subj "/C=ID/ST=Indonesia/L=Jakarta/O=FazzPedia/CN=${MYIP}"

# ============================================================
# Xray Config
# ============================================================
cat > /etc/xray/config.json <<EOF
{
  "log": {
    "loglevel": "warning",
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log"
  },
  "inbounds": [
    {
      "port": 8443,
      "protocol": "vmess",
      "tag": "vmess-tls",
      "settings": {
        "clients": [],
        "disableInsecureEncryption": false
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/etc/xray/cert/xray.crt",
              "keyFile": "/etc/xray/cert/xray.key"
            }
          ]
        },
        "wsSettings": {
          "path": "/vmess-tls",
          "headers": {}
        }
      }
    },
    {
      "port": 80,
      "protocol": "vmess",
      "tag": "vmess-ntls",
      "settings": {
        "clients": [],
        "disableInsecureEncryption": false
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/vmess-ntls",
          "headers": {}
        }
      }
    },
    {
      "port": 8442,
      "protocol": "vless",
      "tag": "vless-tls",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/etc/xray/cert/xray.crt",
              "keyFile": "/etc/xray/cert/xray.key"
            }
          ]
        },
        "wsSettings": {
          "path": "/vless-tls",
          "headers": {}
        }
      }
    },
    {
      "port": 8441,
      "protocol": "vless",
      "tag": "vless-ntls",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/vless-ntls",
          "headers": {}
        }
      }
    },
    {
      "port": 2083,
      "protocol": "trojan",
      "tag": "trojan",
      "settings": {
        "clients": [],
        "fallbacks": []
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            {
              "certificateFile": "/etc/xray/cert/xray.crt",
              "keyFile": "/etc/xray/cert/xray.key"
            }
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": ["geoip:private"],
        "outboundTag": "blocked"
      }
    ]
  }
}
EOF

mkdir -p /var/log/xray
systemctl enable xray
systemctl restart xray

echo -e "${GREEN}[XRAY] Installation complete! UUID: ${UUID}${NC}"
