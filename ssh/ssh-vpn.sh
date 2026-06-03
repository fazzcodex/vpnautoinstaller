#!/bin/bash
# ============================================================
#   FazzPedia||Vpn - SSH & OpenVPN Installer
#   Support: Ubuntu 20.04 / 22.04 / 24.04
# ============================================================
export DEBIAN_FRONTEND=noninteractive
RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; YELLOW='\033[1;33m'; WHITE='\033[1;37m'

MYIP=$(curl -s ipinfo.io/ip 2>/dev/null || wget -qO- ipinfo.io/ip)
NET=$(ip -o -4 route show to default | awk '{print $5}')
source /etc/os-release
VER=$VERSION_ID

echo -e "${YELLOW}[SSH-VPN] Starting installation...${NC}"

# ============================================================
# 1. Install semua dependencies
# ============================================================
apt-get update -y
apt-get install -y --no-install-recommends \
    openssh-server dropbear stunnel4 squid \
    openvpn easy-rsa net-tools iptables \
    curl wget git unzip screen nano \
    build-essential libssl-dev ca-certificates \
    gnupg lsb-release fail2ban iptables-persistent \
    netfilter-persistent cron vnstat python3 \
    python3-pip bc jq sslh ruby cmake

pip3 install websockets 2>/dev/null

# ============================================================
# 2. SSH Config — port 22, 2253 (443 untuk SSLH)
# ============================================================
echo -e "${YELLOW}[SSH] Configuring SSH...${NC}"
sed -i 's/^#\?Port .*//' /etc/ssh/sshd_config
sed -i '/^$/d' /etc/ssh/sshd_config
cat >> /etc/ssh/sshd_config <<-END
Port 22
Port 2253
END
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh

# ============================================================
# 3. Dropbear — port 109, 143
# ============================================================
echo -e "${YELLOW}[Dropbear] Configuring...${NC}"
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear 2>/dev/null
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/g' /etc/default/dropbear 2>/dev/null
sed -i 's/DROPBEAR_EXTRA_ARGS=.*/DROPBEAR_EXTRA_ARGS="-p 109 -p 143"/g' /etc/default/dropbear 2>/dev/null
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
systemctl restart dropbear 2>/dev/null || /etc/init.d/dropbear restart 2>/dev/null

# ============================================================
# 4. Squid Proxy — port 3128, 8080
# ============================================================
echo -e "${YELLOW}[Squid] Configuring...${NC}"
cat > /etc/squid/squid.conf <<-END
http_port 3128
http_port 8080
acl localhost src 127.0.0.1/32
acl to_localhost dst 127.0.0.0/8
acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 1025-65535
acl CONNECT method CONNECT
http_access allow all
visible_hostname FazzPedia-VPN
END
systemctl restart squid

# ============================================================
# 5. Buat SSL Certificate (self-signed)
# ============================================================
echo -e "${YELLOW}[SSL] Generating certificate...${NC}"
mkdir -p /etc/xray
if [ ! -f /etc/xray/xray.key ]; then
    openssl req -new -x509 -days 3650 -nodes \
        -subj "/C=ID/ST=Indonesia/L=Indonesia/O=FazzPedia/CN=FazzPedia-VPN" \
        -newkey rsa:2048 \
        -keyout /etc/xray/xray.key \
        -out /etc/xray/xray.crt 2>/dev/null
    chmod 644 /etc/xray/xray.crt /etc/xray/xray.key
fi

# Stunnel4 pakai format gabungan
cat /etc/xray/xray.key /etc/xray/xray.crt > /etc/stunnel/stunnel.pem
chmod 600 /etc/stunnel/stunnel.pem

# ============================================================
# 6. Stunnel4 — port 445 (dropbear), 777 (ssh), 990 (ovpn)
# ============================================================
echo -e "${YELLOW}[Stunnel] Configuring...${NC}"
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear-ssl]
accept = 445
connect = 127.0.0.1:109

[openssh-ssl]
accept = 777
connect = 127.0.0.1:22

[openvpn-ssl]
accept = 990
connect = 127.0.0.1:1194
END

sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4 2>/dev/null
systemctl enable stunnel4
systemctl restart stunnel4

# ============================================================
# 7. WebSocket SSH — port 8880 (non-TLS)
# ============================================================
echo -e "${YELLOW}[WebSocket] Setting up...${NC}"
cat > /usr/local/bin/ws-ssh.py <<-'PYEOF'
#!/usr/bin/env python3
import asyncio, websockets, socket, ssl, os

async def handle(ws):
    ssh = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        ssh.connect(('127.0.0.1', 22))
        ssh.setblocking(False)
    except Exception as e:
        await ws.close()
        return
    loop = asyncio.get_event_loop()
    async def ws2ssh():
        try:
            async for msg in ws:
                data = msg if isinstance(msg, bytes) else msg.encode()
                await loop.sock_sendall(ssh, data)
        except: pass
    async def ssh2ws():
        try:
            while True:
                data = await loop.sock_recv(ssh, 4096)
                if not data: break
                await ws.send(data)
        except: pass
    done, pending = await asyncio.wait(
        [asyncio.ensure_future(ws2ssh()), asyncio.ensure_future(ssh2ws())],
        return_when=asyncio.FIRST_COMPLETED
    )
    for t in pending: t.cancel()
    ssh.close()

async def main():
    async with websockets.serve(handle, '0.0.0.0', 8880, ping_interval=None):
        await asyncio.Future()

asyncio.run(main())
PYEOF
chmod +x /usr/local/bin/ws-ssh.py

cat > /etc/systemd/system/ws-nontls.service <<-END
[Unit]
Description=WebSocket SSH Non-TLS (8880)
After=network.target
[Service]
ExecStart=/usr/bin/python3 /usr/local/bin/ws-ssh.py
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
END
systemctl daemon-reload
systemctl enable ws-nontls
systemctl start ws-nontls

# ============================================================
# 8. SSLH — port 443 multiplexer (SSH+SSL+WS+OpenVPN)
# ============================================================
echo -e "${YELLOW}[SSLH] Configuring port 443 multiplexer...${NC}"
cat > /etc/default/sslh <<-END
RUN=yes
DAEMON=/usr/sbin/sslh
DAEMON_OPTS="--user sslh --listen 0.0.0.0:443 --ssl 127.0.0.1:777 --ssh 127.0.0.1:109 --openvpn 127.0.0.1:1194 --http 127.0.0.1:8880 --pidfile /var/run/sslh/sslh.pid -n"
END

# Pastikan sslh tidak pakai systemd socket activation
if [ -f /lib/systemd/system/sslh.service ]; then
    sed -i 's/sslh-select/sslh/g' /lib/systemd/system/sslh.service
    sed -i '/EnvironmentFile/a ExecStart=' /lib/systemd/system/sslh.service 2>/dev/null
fi
systemctl daemon-reload
systemctl enable sslh
systemctl restart sslh

# ============================================================
# 9. OpenVPN
# ============================================================
echo -e "${YELLOW}[OpenVPN] Installing...${NC}"
apt-get install -y openvpn easy-rsa

mkdir -p /etc/openvpn/easy-rsa
cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/ 2>/dev/null
cd /etc/openvpn/easy-rsa

# Generate keys
./easyrsa init-pki 2>/dev/null
echo "FazzPedia" | ./easyrsa build-ca nopass 2>/dev/null
echo "server" | ./easyrsa gen-req server nopass 2>/dev/null
echo "yes" | ./easyrsa sign-req server server 2>/dev/null
./easyrsa gen-dh 2>/dev/null
openvpn --genkey --secret /etc/openvpn/ta.key 2>/dev/null

cp pki/ca.crt /etc/openvpn/
cp pki/issued/server.crt /etc/openvpn/
cp pki/private/server.key /etc/openvpn/
cp pki/dh.pem /etc/openvpn/dh2048.pem 2>/dev/null || cp pki/dh.pem /etc/openvpn/ 2>/dev/null

# OpenVPN TCP config
cat > /etc/openvpn/server-tcp.conf <<-END
port 1194
proto tcp
dev tun
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh2048.pem
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
duplicate-cn
keepalive 10 120
comp-lzo
persist-key
persist-tun
status /var/log/openvpn-status.log
log /var/log/openvpn.log
verb 3
END

# OpenVPN UDP config
cat > /etc/openvpn/server-udp.conf <<-END
port 2200
proto udp
dev tun1
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh2048.pem
server 10.9.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
duplicate-cn
keepalive 10 120
comp-lzo
persist-key
persist-tun
verb 3
END

systemctl enable openvpn@server-tcp openvpn@server-udp
systemctl restart openvpn@server-tcp openvpn@server-udp

cd /root

# ============================================================
# 10. BadVPN UDPGW
# ============================================================
echo -e "${YELLOW}[BadVPN] Installing...${NC}"
apt-get install -y cmake make build-essential
wget -q https://github.com/ambrop72/badvpn/archive/refs/heads/master.zip -O /tmp/badvpn.zip
if [ -f /tmp/badvpn.zip ]; then
    unzip -q /tmp/badvpn.zip -d /tmp/
    cd /tmp/badvpn-master
    mkdir -p build && cd build
    cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 2>/dev/null
    make 2>/dev/null
    cp udpgw/badvpn-udpgw /usr/local/bin/ 2>/dev/null
    cd /root
    rm -rf /tmp/badvpn-master /tmp/badvpn.zip
fi

# BadVPN service
for PORT in 7100 7200 7300; do
cat > /etc/systemd/system/badvpn-${PORT}.service <<-END
[Unit]
Description=BadVPN UDPGW Port ${PORT}
After=network.target
[Service]
ExecStart=/usr/local/bin/badvpn-udpgw --listen-addr 127.0.0.1:${PORT} --max-clients 500
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
END
systemctl daemon-reload
systemctl enable badvpn-${PORT}
systemctl start badvpn-${PORT}
done

# ============================================================
# 11. OHP Server (SSH, Dropbear, OpenVPN)
# ============================================================
echo -e "${YELLOW}[OHP] Setting up...${NC}"
# Install python-based OHP
pip3 install aiohttp 2>/dev/null
cat > /usr/local/bin/ohpserver.py <<-'OHPEOF'
#!/usr/bin/env python3
import asyncio, aiohttp.web, socket

def make_handler(target_port):
    async def handler(req):
        reader, writer = await asyncio.open_connection('127.0.0.1', target_port)
        async def pipe(r, w):
            try:
                while True:
                    d = await r.read(4096)
                    if not d: break
                    w.write(d)
                    await w.drain()
            except: pass
            finally: w.close()
        data = await req.read()
        if data: writer.write(data)
        return aiohttp.web.Response(body=b'HTTP/1.1 200 Connection established\r\n\r\n')
    return handler

for port, target in [(8181, 22), (8282, 109), (8383, 1194)]:
    pass # placeholder — implemented as separate services below
OHPEOF

for item in "8181:22" "8282:109" "8383:1194"; do
    OHP_PORT="${item%%:*}"
    TARGET="${item##*:}"
    cat > /usr/local/bin/ohp-${OHP_PORT}.py <<-OHPEOF
#!/usr/bin/env python3
import socket, threading

def handle(client):
    try:
        srv = socket.socket()
        srv.connect(('127.0.0.1', ${TARGET}))
        def pipe(src, dst):
            try:
                while True:
                    d = src.recv(4096)
                    if not d: break
                    dst.sendall(d)
            except: pass
            finally:
                src.close(); dst.close()
        threading.Thread(target=pipe, args=(client, srv), daemon=True).start()
        threading.Thread(target=pipe, args=(srv, client), daemon=True).start()
    except: client.close()

srv = socket.socket()
srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
srv.bind(('0.0.0.0', ${OHP_PORT}))
srv.listen(100)
print(f'OHP listening on ${OHP_PORT} -> ${TARGET}')
while True:
    c, _ = srv.accept()
    threading.Thread(target=handle, args=(c,), daemon=True).start()
OHPEOF
    chmod +x /usr/local/bin/ohp-${OHP_PORT}.py
    cat > /etc/systemd/system/ohp-${OHP_PORT}.service <<-END
[Unit]
Description=OHP Port ${OHP_PORT}
After=network.target
[Service]
ExecStart=/usr/bin/python3 /usr/local/bin/ohp-${OHP_PORT}.py
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
END
    systemctl daemon-reload
    systemctl enable ohp-${OHP_PORT}
    systemctl start ohp-${OHP_PORT}
done

# ============================================================
# 12. Fail2Ban
# ============================================================
systemctl enable fail2ban
systemctl restart fail2ban

# ============================================================
# 13. IPTables
# ============================================================
echo -e "${YELLOW}[IPTables] Setting up...${NC}"
iptables -A INPUT -m string --algo bm --string "BitTorrent" -j DROP
iptables -A INPUT -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A INPUT -m string --algo bm --string "peer_id=" -j DROP
iptables -A INPUT -m string --algo bm --string ".torrent" -j DROP
iptables -A INPUT -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A INPUT -m string --algo bm --string "torrent" -j DROP
iptables -A INPUT -m string --algo bm --string "info_hash" -j DROP
iptables-save > /etc/iptables.up.rules
netfilter-persistent save 2>/dev/null

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# NAT untuk VPN
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o $NET -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o $NET -j MASQUERADE
iptables-save > /etc/iptables.up.rules
netfilter-persistent save 2>/dev/null

# ============================================================
# 14. Nginx untuk download OVPN config
# ============================================================
apt-get install -y nginx
mkdir -p /home/vps/public_html
cat > /etc/nginx/sites-available/default <<-END
server {
    listen 89;
    root /home/vps/public_html;
    autoindex on;
}
END
systemctl restart nginx

# Generate client OVPN files
cat > /home/vps/public_html/tcp.ovpn <<-END
client
dev tun
proto tcp
remote ${MYIP} 1194
resolv-retry infinite
nobind
persist-key
persist-tun
comp-lzo
verb 3
<ca>
$(cat /etc/openvpn/ca.crt)
</ca>
END

cp /home/vps/public_html/tcp.ovpn /home/vps/public_html/udp.ovpn
sed -i 's/proto tcp/proto udp/' /home/vps/public_html/udp.ovpn
sed -i 's/remote .* 1194/remote '"${MYIP}"' 2200/' /home/vps/public_html/udp.ovpn

# ============================================================
# 15. BBR
# ============================================================
echo -e "${YELLOW}[BBR] Enabling...${NC}"
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p 2>/dev/null

# ============================================================
# 16. Auto crontab
# ============================================================
echo -e "${YELLOW}[Cron] Setting up...${NC}"
(crontab -l 2>/dev/null; echo "0 22 * * * root reboot # fazzpedia auto-reboot") | crontab -
(crontab -l 2>/dev/null; echo "0 1 * * * root delexp # fazzpedia del-expired") | crontab -

# Simpan IP
echo "${MYIP}" > /etc/fazzpedia/myip
echo "${MYIP}" > /var/lib/crot/ipvps.conf 2>/dev/null

echo -e "${GREEN}[SSH-VPN] Installation complete!${NC}"
