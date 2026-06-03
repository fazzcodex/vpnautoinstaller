#!/bin/bash
# ============================================================
#   FazzPedia||Vpn - WebSocket & OHP Installer
#   Support: Ubuntu 20.04 / 22.04 / 24.04
# ============================================================

RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'

echo -e "${YELLOW}[WEBSOCKET] Installing WebSocket Server...${NC}"

apt install -y python3 python3-pip nginx

pip3 install websockets 2>/dev/null

# ============================================================
# Python WebSocket server (SSH over WS)
# ============================================================
cat > /usr/local/bin/ws-fazzpedia.py <<'PYEOF'
#!/usr/bin/env python3
import asyncio, websockets, socket, threading

LISTEN_PORT_TLS  = 443
LISTEN_PORT_NTLS = 8880
SSH_HOST = "127.0.0.1"
SSH_PORT = 22

async def relay(ws, target_host, target_port):
    try:
        reader, writer = await asyncio.open_connection(target_host, target_port)
    except Exception:
        return
    async def ws_to_tcp():
        try:
            async for msg in ws:
                writer.write(msg if isinstance(msg, bytes) else msg.encode())
                await writer.drain()
        except Exception:
            pass
        finally:
            writer.close()
    async def tcp_to_ws():
        try:
            while True:
                data = await reader.read(4096)
                if not data:
                    break
                await ws.send(data)
        except Exception:
            pass
    await asyncio.gather(ws_to_tcp(), tcp_to_ws())

async def handler(ws, path):
    await relay(ws, SSH_HOST, SSH_PORT)

async def main():
    server_ntls = await websockets.serve(handler, "0.0.0.0", LISTEN_PORT_NTLS)
    print(f"FazzPedia WS (Non-TLS) listening on :{LISTEN_PORT_NTLS}")
    await server_ntls.wait_closed()

asyncio.run(main())
PYEOF
chmod +x /usr/local/bin/ws-fazzpedia.py

# Systemd for WS Non-TLS (8880)
cat > /etc/systemd/system/ws-fazzpedia.service <<EOF
[Unit]
Description=FazzPedia WebSocket Server
After=network.target
[Service]
ExecStart=/usr/bin/python3 /usr/local/bin/ws-fazzpedia.py
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ws-fazzpedia
systemctl start ws-fazzpedia

# ============================================================
# Nginx WebSocket TLS Proxy (port 443 WS → port 22)
# ============================================================
cat > /etc/nginx/conf.d/fazzpedia-ws.conf <<EOF
server {
    listen 89;
    server_name _;
    root /var/www/html;
    index index.html;
    location / {
        try_files \$uri \$uri/ =404;
    }
}

map \$http_upgrade \$connection_upgrade {
    default upgrade;
    '' close;
}

server {
    listen 2086;
    server_name _;
    location /ws-ovpn {
        proxy_pass http://127.0.0.1:1194;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header Host \$host;
    }
}
EOF

nginx -t && systemctl restart nginx

echo -e "${GREEN}[WEBSOCKET] Done! WS Non-TLS: 8880, WS OpenVPN: 2086${NC}"

# ============================================================
# OHP Server (Overhead Protocol HTTP)
# ============================================================
echo -e "${YELLOW}[OHP] Installing OHP Server...${NC}"

# OHP binary install (Go-based)
wget -q "https://github.com/lfasmpao/open-http-puncher/releases/latest/download/ohpserver-linux64" \
    -O /usr/local/bin/ohpserver 2>/dev/null

if [ ! -f /usr/local/bin/ohpserver ] || [ ! -s /usr/local/bin/ohpserver ]; then
    # Fallback: build simple OHP with Python
    cat > /usr/local/bin/ohpserver.py <<'OHPEOF'
#!/usr/bin/env python3
import socket, threading, sys

def handle(client, target_host, target_port):
    try:
        srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        srv.connect((target_host, target_port))
        client.send(b"HTTP/1.0 200 Connection established\r\n\r\n")
        def relay(src, dst):
            try:
                while True:
                    data = src.recv(4096)
                    if not data:
                        break
                    dst.sendall(data)
            except:
                pass
        t1 = threading.Thread(target=relay, args=(client, srv))
        t2 = threading.Thread(target=relay, args=(srv, client))
        t1.start(); t2.start()
        t1.join(); t2.join()
    except:
        pass
    finally:
        client.close()

def serve(listen_port, target_host, target_port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(('0.0.0.0', listen_port))
    s.listen(50)
    print(f"OHP listening :{listen_port} -> {target_host}:{target_port}")
    while True:
        client, _ = s.accept()
        threading.Thread(target=handle, args=(client, target_host, target_port)).start()

if __name__ == '__main__':
    lport = int(sys.argv[1]) if len(sys.argv) > 1 else 8181
    thost = sys.argv[2] if len(sys.argv) > 2 else "127.0.0.1"
    tport = int(sys.argv[3]) if len(sys.argv) > 3 else 22
    serve(lport, thost, tport)
OHPEOF
    chmod +x /usr/local/bin/ohpserver.py
    OHP_CMD="/usr/bin/python3 /usr/local/bin/ohpserver.py"
else
    chmod +x /usr/local/bin/ohpserver
    OHP_CMD="/usr/local/bin/ohpserver"
fi

# OHP for SSH port 8181
cat > /etc/systemd/system/ohp-ssh.service <<EOF
[Unit]
Description=FazzPedia OHP SSH
After=network.target
[Service]
ExecStart=${OHP_CMD} 8181 127.0.0.1 22
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF

# OHP for Dropbear port 8282
cat > /etc/systemd/system/ohp-dropbear.service <<EOF
[Unit]
Description=FazzPedia OHP Dropbear
After=network.target
[Service]
ExecStart=${OHP_CMD} 8282 127.0.0.1 109
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF

# OHP for OpenVPN port 8383
cat > /etc/systemd/system/ohp-ovpn.service <<EOF
[Unit]
Description=FazzPedia OHP OpenVPN
After=network.target
[Service]
ExecStart=${OHP_CMD} 8383 127.0.0.1 1194
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
for svc in ohp-ssh ohp-dropbear ohp-ovpn; do
    systemctl enable $svc
    systemctl start $svc
done

echo -e "${GREEN}[OHP] Done! OHP-SSH:8181, OHP-Dropbear:8282, OHP-OpenVPN:8383${NC}"
