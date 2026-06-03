#!/bin/bash
# ============================================================
#   FazzPedia||Vpn - L2TP/IPSec Installer
#   Support: Ubuntu 20.04 / 22.04 / 24.04
# ============================================================

RED='\033[0;31m'; NC='\033[0m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MYIP=$(curl -s ipinfo.io/ip)
NET=$(ip -o -4 route show to default | awk '{print $5}')

echo -e "${YELLOW}[IPSEC] Installing L2TP/IPSec...${NC}"

apt install -y strongswan xl2tpd ppp

PSK="FazzPedia2024Secret"
echo "$PSK" > /etc/fazzpedia/ipsec_psk.conf

# IPSec config
cat > /etc/ipsec.conf <<EOF
config setup
    charondebug="ike 1, knl 1, cfg 0"
    uniqueids=no

conn %default
    ikelifetime=60m
    keylife=20m
    rekeymargin=3m
    keyingtries=1
    keyexchange=ikev1
    authby=secret

conn L2TP-PSK-noNAT
    rightsubnet=vhost:%priv
    also=L2TP-PSK

conn L2TP-PSK
    authby=secret
    pfs=no
    auto=add
    keyingtries=3
    dpddelay=30
    dpdtimeout=120
    dpdaction=clear
    rekey=no
    left=%defaultroute
    right=%any
    type=transport
    leftprotoport=17/1701
    rightprotoport=17/%any
    forceencaps=yes
EOF

cat > /etc/ipsec.secrets <<EOF
%any %any : PSK "${PSK}"
EOF

# xl2tpd config
cat > /etc/xl2tpd/xl2tpd.conf <<EOF
[global]
ipsec saref = yes

[lns default]
ip range = 192.168.98.10-192.168.98.254
local ip = 192.168.98.1
require chap = yes
refuse pap = yes
require authentication = yes
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF

cat > /etc/ppp/options.xl2tpd <<EOF
ipcp-accept-local
ipcp-accept-remote
ms-dns 8.8.8.8
ms-dns 8.8.4.4
noccp
auth
mtu 1280
mru 1280
proxyarp
lcp-echo-failure 4
lcp-echo-interval 30
connect-delay 5000
EOF

# NAT
iptables -t nat -A POSTROUTING -s 192.168.98.0/24 -o ${NET} -j MASQUERADE
iptables-save > /etc/iptables.rules

systemctl enable strongswan xl2tpd
systemctl restart strongswan xl2tpd

echo -e "${GREEN}[IPSEC] Done! PSK: ${PSK}, Port: 1701 (L2TP), 500/4500 (IPSec)${NC}"
