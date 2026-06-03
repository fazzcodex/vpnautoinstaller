#!/bin/bash
# startup.sh - dijalankan saat boot via systemd fazzpedia.service
sleep 5
SERVICES=(ssh dropbear stunnel4 sslh squid openvpn@server-tcp openvpn@server-udp xray ws-nontls ws-tls fail2ban nginx)
for svc in "${SERVICES[@]}"; do
    systemctl is-enabled "$svc" &>/dev/null && systemctl start "$svc" 2>/dev/null
done
# Wireguard
systemctl start wg-quick@wg0 2>/dev/null
# BadVPN
for port in 7100 7200 7300; do
    systemctl start badvpn-${port} 2>/dev/null
done
# OHP
for port in 8181 8282 8383; do
    systemctl start ohp-${port} 2>/dev/null
done
# L2TP
systemctl start strongswan xl2tpd 2>/dev/null
echo "FazzPedia startup complete: $(date)" >> /var/log/fazzpedia-startup.log
