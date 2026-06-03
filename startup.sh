#!/bin/bash
# FazzPedia startup — restart all services on boot
for svc in ssh dropbear stunnel4 openvpn@server-tcp openvpn@server-udp squid xray wg-quick@wg0 ws-fazzpedia ohp-ssh ohp-dropbear ohp-ovpn badvpn-7100 badvpn-7200 badvpn-7300; do
    systemctl start $svc 2>/dev/null
done
