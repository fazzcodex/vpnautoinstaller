#!/bin/bash
# ipsec.sh - L2TP/IPSec installer
export DEBIAN_FRONTEND=noninteractive
GREEN='\033[0;32m'; NC='\033[0m'; YELLOW='\033[1;33m'
MYIP=$(cat /etc/fazzpedia/myip 2>/dev/null || curl -s ipinfo.io/ip)
echo -e "${YELLOW}[L2TP/IPSec] Installing...${NC}"

apt-get install -y strongswan xl2tpd ppp

# IPSec config
cat > /etc/ipsec.conf <<-END
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

conn L2TP-PSK-NAT
    rightsubnet=vhost:%priv
    also=L2TP-PSK-noNAT

conn L2TP-PSK-noNAT
    authby=secret
    pfs=no
    auto=add
    keyingtries=3
    rekey=no
    ikelifetime=8h
    keylife=1h
    type=transport
    left=%defaultroute
    leftid=${MYIP}
    leftprotoport=17/1701
    right=%any
    rightprotoport=17/%any
    dpddelay=40
    dpdtimeout=130
    dpdaction=clear
END

PSK=$(openssl rand -base64 16)
echo ": PSK \"${PSK}\"" > /etc/ipsec.secrets
echo "$PSK" > /etc/fazzpedia/l2tp_psk
chmod 600 /etc/ipsec.secrets

# xl2tpd config
cat > /etc/xl2tpd/xl2tpd.conf <<-END
[global]
ipsec saref = yes
saref refinfo = 30

[lns default]
ip range = 192.168.42.10-192.168.42.250
local ip = 192.168.42.1
require chap = yes
refuse pap = yes
require authentication = yes
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
END

cat > /etc/ppp/options.xl2tpd <<-END
ipcp-accept-local
ipcp-accept-remote
ms-dns 8.8.8.8
ms-dns 8.8.4.4
noccp
auth
hide-password
idle 1800
mtu 1460
mru 1460
lock
connect-delay 5000
END

systemctl enable strongswan xl2tpd
systemctl restart strongswan xl2tpd
echo -e "${GREEN}[L2TP/IPSec] Done! PSK: $PSK | Port 1701${NC}"
