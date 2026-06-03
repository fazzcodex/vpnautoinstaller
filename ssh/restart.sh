#!/bin/bash
GREEN='\033[0;32m'; NC='\033[0m'; YELLOW='\033[1;33m'; RED='\033[0;31m'
echo -e "${YELLOW}Restarting all services...${NC}"
SERVICES=(ssh dropbear stunnel4 sslh squid openvpn@server-tcp openvpn@server-udp xray wg-quick@wg0 ws-nontls ws-tls fail2ban nginx)
for svc in "${SERVICES[@]}"; do
    systemctl restart "$svc" 2>/dev/null && echo -e "  ${GREEN}✓${NC} $svc" || echo -e "  ${RED}✗${NC} $svc"
done
for port in 7100 7200 7300; do
    systemctl restart "badvpn-${port}" 2>/dev/null
done
for port in 8181 8282 8383; do
    systemctl restart "ohp-${port}" 2>/dev/null
done
echo -e "${GREEN}Done!${NC}"
