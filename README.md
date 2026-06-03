# FazzPedia||Vpn Auto Installer v2.0
**Telegram:** https://t.me/FazzCodex  
**Support:** Ubuntu 20.04 / 22.04 / 24.04 (64-bit)

## Cara Install
```bash
wget -O setup.sh https://raw.githubusercontent.com/FazzCodex/fazzpedia-vpn/main/setup.sh
chmod +x setup.sh
./setup.sh
```
Atau jika file sudah ada di VPS:
```bash
bash setup.sh
```

## Fitur Lengkap
| Protokol         | Port          |
|-----------------|---------------|
| SSH             | 22, 443       |
| Dropbear        | 109, 143      |
| Stunnel5 SSL    | 445, 777      |
| OpenVPN TCP     | 1194          |
| OpenVPN UDP     | 2200          |
| Squid Proxy     | 3128, 8080    |
| BadVPN UDPGW    | 7100-7300     |
| Wireguard       | 7070          |
| L2TP/IPSec      | 1701          |
| SSTP            | 444           |
| ShadowsocksR    | 1443-1543     |
| Xray VMess TLS  | 8443          |
| Xray VMess NTLS | 80            |
| Xray VLess TLS  | 8442          |
| Xray VLess NTLS | 8441          |
| Xray Trojan     | 2083          |
| WebSocket NTLS  | 8880          |
| WS OpenVPN      | 2086          |
| OHP SSH         | 8181          |
| OHP Dropbear    | 8282          |
| OHP OpenVPN     | 8383          |

## Perintah Menu
```bash
menu
# atau
fazzpedia
```

## Struktur Script
```
fazzpedia/
├── setup.sh              ← Installer utama
├── startup.sh            ← Auto-start on boot
├── menu.sh               ← Panel menu
├── ssh/
│   ├── ssh-vpn.sh        ← Install SSH, Dropbear, OpenVPN, Stunnel, Squid, BadVPN
│   └── addssh.sh         ← Kelola akun SSH (add/del/renew/cek/trial)
├── xray/
│   ├── xray.sh           ← Install Xray core
│   └── addvmess.sh       ← Kelola VMess, VLess, Trojan
├── wireguard/
│   ├── wireguard.sh      ← Install Wireguard
│   └── addwg.sh          ← Kelola akun Wireguard + QR Code
├── shadowsocks/
│   ├── shadowsocks.sh    ← Install Shadowsocks-libev
│   └── addss.sh          ← Kelola port Shadowsocks
├── sstp/
│   ├── sstp.sh           ← Install SSTP (accel-ppp)
│   └── addsstp.sh        ← Kelola akun SSTP
├── ipsec/
│   ├── ipsec.sh          ← Install L2TP/IPSec
│   └── addl2tp.sh        ← Kelola akun L2TP
├── websocket/
│   └── websocket.sh      ← Install WebSocket + OHP Server
├── backup/
│   ├── backup.sh         ← Backup/Restore/AutoBackup
│   ├── restore.sh
│   └── autobackup.sh
└── system/
    ├── system.sh         ← Info, restart, speedtest, RAM, dll
    ├── restart.sh
    ├── info.sh
    ├── ram.sh
    ├── speedtest.sh
    ├── setdomain.sh
    ├── changeport.sh
    └── limitspeed.sh
```

## Catatan
- Pastikan VPS fresh install Ubuntu 20/22/24
- Jalankan sebagai root
- OpenVZ **tidak** didukung (gunakan KVM/XEN)
- Setelah install, ketik `menu` untuk membuka panel
