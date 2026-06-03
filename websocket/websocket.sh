#!/bin/bash
# websocket.sh - WebSocket SSH installer (ws-nontls sudah di ssh-vpn.sh, ini tambah ws-tls)
export DEBIAN_FRONTEND=noninteractive
GREEN='\033[0;32m'; NC='\033[0m'; YELLOW='\033[1;33m'
echo -e "${YELLOW}[WebSocket] Setting up WS-TLS...${NC}"
pip3 install websockets 2>/dev/null

# ws-tls (port 443 lewat SSLH, juga bisa akses langsung port 8443-ws)
cat > /usr/local/bin/ws-ssh-tls.py <<-'PYEOF'
#!/usr/bin/env python3
import asyncio, websockets, socket, ssl

async def handle(ws):
    ssh = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        ssh.connect(('127.0.0.1', 22))
        ssh.setblocking(False)
    except:
        await ws.close(); return
    loop = asyncio.get_event_loop()
    async def ws2ssh():
        try:
            async for msg in ws:
                await loop.sock_sendall(ssh, msg if isinstance(msg, bytes) else msg.encode())
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
        return_when=asyncio.FIRST_COMPLETED)
    for t in pending: t.cancel()
    ssh.close()

async def main():
    ssl_ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    ssl_ctx.load_cert_chain('/etc/xray/xray.crt', '/etc/xray/xray.key')
    async with websockets.serve(handle, '0.0.0.0', 8081, ssl=ssl_ctx, ping_interval=None):
        await asyncio.Future()

asyncio.run(main())
PYEOF
chmod +x /usr/local/bin/ws-ssh-tls.py

cat > /etc/systemd/system/ws-tls.service <<-END
[Unit]
Description=WebSocket SSH TLS (8081)
After=network.target
[Service]
ExecStart=/usr/bin/python3 /usr/local/bin/ws-ssh-tls.py
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
END
systemctl daemon-reload
systemctl enable ws-tls ws-nontls
systemctl restart ws-tls ws-nontls
echo -e "${GREEN}[WebSocket] Done! WS Non-TLS:8880, WS-TLS:8081${NC}"
