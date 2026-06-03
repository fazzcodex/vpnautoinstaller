#!/bin/bash
# ============================================================
#   FazzPedia||Vpn - SSH & OpenVPN Installer
#   Support: Ubuntu 20.04 / 22.04 / 24.04
# ============================================================

RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
ORANGE='\033[0;33m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'
YELLOW='\033[1;33m'; WHITE='\033[1;37m'

MYIP=$(curl -s ipinfo.io/ip)
NET=$(ip -o -4 route show to default | awk '{print $5}')
source /etc/os-release
VER=$VERSION_ID

export DEBIAN_FRONTEND=noninteractive

echo -e "${YELLOW}[SSH-VPN] Installing SSH, Dropbear, OpenVPN, Stunnel5, Squid, BadVPN...${NC}"

# ============================================================
# 1. System Dependencies
# ============================================================
apt update -y
apt install -y openssh-server dropbear stunnel4 openvpn \
    squid3 fail2ban net-tools iptables python3 \
    python3-pip curl wget git unzip screen \
    build-essential libssl-dev libffi-dev \
    ca-certificates gnupg lsb-release

# ============================================================
# 2. OpenSSH Config
# ============================================================
cat > /etc/ssh/sshd_config <<EOF
Port 22
Port 443
AddressFamily inet
ListenAddress 0.0.0.0
PermitRootLogin yes
PasswordAuthentication yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UseDNS no
EOF

# Banner MOTD
cat > /etc/issue.net <<EOF
 ╔══════════════════════════════════════════╗
 ║         FazzPedia || Vpn Server          ║
 ║   Unauthorized access is prohibited!    ║
 ║     Telegram: t.me/fazzpediavpn            ║
 ╚══════════════════════════════════════════╝
EOF
echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
systemctl restart ssh

# ============================================================
# 3. Dropbear
# ============================================================
cat > /etc/default/dropbear <<EOF
NO_START=0
DROPBEAR_PORT=109
DROPBEAR_EXTRA_ARGS="-p 143"
DROPBEAR_BANNER="/etc/issue.net"
DROPBEAR_RECEIVE_WINDOW=65536
EOF
systemctl restart dropbear || service dropbear restart

# ============================================================
# 4. Stunnel5 (SSL Tunnel)
# ============================================================
mkdir -p /etc/stunnel
# Generate self-signed cert
openssl req -new -x509 -days 3650 -nodes \
    -out /etc/stunnel/stunnel.pem \
    -keyout /etc/stunnel/stunnel.pem \
    -subj "/C=ID/ST=Indonesia/L=Indonesia/O=FazzPedia/CN=FazzPedia-VPN"

cat > /etc/stunnel/stunnel.conf <<EOF
sslVersion = TLSv1.2
cert = /etc/stunnel/stunnel.pem
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
client = no

[dropbear-ssl]
accept = 445
connect = 127.0.0.1:109

[openssh-ssl]
accept = 777
connect = 127.0.0.1:22
EOF

cat > /etc/default/stunnel4 <<EOF
ENABLED=1
FILES="/etc/stunnel/*.conf"
OPTIONS=""
BANNER="/etc/issue.net"
EOF
systemctl enable stunnel4
systemctl restart stunnel4

# ============================================================
# 5. OpenVPN
# ============================================================
apt install -y openvpn easy-rsa

# Generate CA & Certs
mkdir -p /etc/openvpn/easy-rsa
cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/
cd /etc/openvpn/easy-rsa

cat > /etc/openvpn/easy-rsa/vars <<EOF
set_var EASYRSA_REQ_COUNTRY    "ID"
set_var EASYRSA_REQ_PROVINCE   "Indonesia"
set_var EASYRSA_REQ_CITY       "Indonesia"
set_var EASYRSA_REQ_ORG        "FazzPedia VPN"
set_var EASYRSA_REQ_EMAIL      "admin@fazzpedia.vpn"
set_var EASYRSA_REQ_OU         "FazzPedia"
set_var EASYRSA_CA_EXPIRE      3650
set_var EASYRSA_CERT_EXPIRE    3650
EOF

./easyrsa init-pki
echo "FazzPedia-CA" | ./easyrsa build-ca nopass
echo "FazzPedia-Server" | ./easyrsa gen-req server nopass
echo "yes" | ./easyrsa sign-req server server
./easyrsa gen-dh
openvpn --genkey secret /etc/openvpn/ta.key

cp pki/ca.crt /etc/openvpn/
cp pki/issued/server.crt /etc/openvpn/
cp pki/private/server.key /etc/openvpn/
cp pki/dh.pem /etc/openvpn/

# OpenVPN TCP 1194
cat > /etc/openvpn/server-tcp.conf <<EOF
port 1194
proto tcp
dev tun
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh.pem
tls-auth /etc/openvpn/ta.key 0
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist /var/log/openvpn/ipp-tcp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
cipher AES-256-GCM
auth SHA256
compress lz4-v2
push "compress lz4-v2"
max-clients 100
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn/openvpn-status-tcp.log
log /var/log/openvpn/openvpn-tcp.log
verb 3
EOF

# OpenVPN UDP 2200
cat > /etc/openvpn/server-udp.conf <<EOF
port 2200
proto udp
dev tun1
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh.pem
tls-auth /etc/openvpn/ta.key 0
server 10.9.0.0 255.255.255.0
ifconfig-pool-persist /var/log/openvpn/ipp-udp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
cipher AES-256-GCM
auth SHA256
compress lz4-v2
push "compress lz4-v2"
max-clients 100
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn/openvpn-status-udp.log
log /var/log/openvpn/openvpn-udp.log
verb 3
EOF

mkdir -p /var/log/openvpn
systemctl enable openvpn@server-tcp
systemctl enable openvpn@server-udp
systemctl start openvpn@server-tcp
systemctl start openvpn@server-udp

# ============================================================
# 6. IPTables NAT for OpenVPN
# ============================================================
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sysctl -p

iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o ${NET} -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o ${NET} -j MASQUERADE
iptables-save > /etc/iptables.rules

cat > /etc/network/if-pre-up.d/iptables <<EOF
#!/bin/sh
iptables-restore < /etc/iptables.rules
EOF
chmod +x /etc/network/if-pre-up.d/iptables

# ============================================================
# 7. Squid Proxy
# ============================================================
cat > /etc/squid/squid.conf <<EOF
acl localhost src 127.0.0.1/32
acl to_localhost dst 127.0.0.0/8
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT
http_access allow manager localhost
http_access deny manager
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow localhost
http_access allow all
http_port 3128
http_port 8080
coredump_dir /var/spool/squid
header_access Via deny all
header_access X-Forwarded-For deny all
header_access From deny all
header_access Link deny all
forwarded_for off
request_header_access Allow allow all
request_header_access Authorization allow all
request_header_access WWW-Authenticate allow all
request_header_access Proxy-Authorization allow all
request_header_access Proxy-Authenticate allow all
request_header_access Cache-Control allow all
request_header_access Content-Encoding allow all
request_header_access Content-Length allow all
request_header_access Content-Type allow all
request_header_access Date allow all
request_header_access Expires allow all
request_header_access Host allow all
request_header_access If-Modified-Since allow all
request_header_access Last-Modified allow all
request_header_access Location allow all
request_header_access Pragma allow all
request_header_access Accept allow all
request_header_access Accept-Charset allow all
request_header_access Accept-Encoding allow all
request_header_access Accept-Language allow all
request_header_access Content-Language allow all
request_header_access Mime-Version allow all
request_header_access Retry-After allow all
request_header_access Title allow all
request_header_access Connection allow all
request_header_access Proxy-Connection allow all
request_header_access User-Agent allow all
request_header_access Cookie allow all
request_header_access All deny all
EOF
systemctl restart squid || systemctl restart squid3

# ============================================================
# 8. BBR Congestion Control
# ============================================================
if [ "$(uname -r | cut -d'.' -f1)" -ge 4 ]; then
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p
    echo -e "${GREEN}[OK] BBR enabled${NC}"
fi

# ============================================================
# 9. Fail2Ban
# ============================================================
cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
bantime  = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port    = 22,443
EOF
systemctl restart fail2ban

# ============================================================
# 10. BadVPN UDPGW
# ============================================================
wget -q "https://github.com/ambrop72/badvpn/releases/latest/download/badvpn-udpgw" \
    -O /usr/local/bin/badvpn-udpgw 2>/dev/null || \
    apt install -y badvpn 2>/dev/null

chmod +x /usr/local/bin/badvpn-udpgw 2>/dev/null

for PORT in 7100 7200 7300; do
cat > /etc/systemd/system/badvpn-${PORT}.service <<EOF
[Unit]
Description=BadVPN UDPGW Port ${PORT}
After=network.target
[Service]
ExecStart=/usr/local/bin/badvpn-udpgw --listen-addr 127.0.0.1:${PORT} --max-clients 500
Restart=always
[Install]
WantedBy=multi-user.target
EOF
systemctl enable badvpn-${PORT}
systemctl start badvpn-${PORT}
done

# ============================================================
# 11. Auto-delete expired SSH accounts (cron)
# ============================================================
cat > /etc/cron.daily/fazzpedia-cleanup <<'EOF'
#!/bin/bash
TODAY=$(date +%Y-%m-%d)
while IFS=: read -r user pass uid gid info home shell; do
    if [[ "$uid" -ge 1000 ]] && [[ "$shell" != "/sbin/nologin" ]]; then
        EXP=$(chage -l "$user" 2>/dev/null | grep "Account expires" | awk -F': ' '{print $2}')
        if [[ "$EXP" != "never" ]] && [[ ! -z "$EXP" ]]; then
            EXP_DATE=$(date -d "$EXP" +%Y-%m-%d 2>/dev/null)
            if [[ "$TODAY" > "$EXP_DATE" ]]; then
                userdel -r "$user" 2>/dev/null
            fi
        fi
    fi
done < /etc/passwd
EOF
chmod +x /etc/cron.daily/fazzpedia-cleanup

# Auto reboot at 05:00 WIB (UTC+7 = 22:00 UTC)
(crontab -l 2>/dev/null; echo "0 22 * * * /sbin/reboot") | crontab -

echo -e "${GREEN}[SSH-VPN] Installation complete!${NC}"
