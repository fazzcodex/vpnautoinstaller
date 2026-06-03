#!/bin/bash
GREEN='\033[0;32m'; NC='\033[0m'; YELLOW='\033[1;33m'
echo -ne " Max login per user [default 2] : "; read MAX
MAX=${MAX:-2}
cat > /usr/local/bin/autokill-ssh.sh <<-KILL
#!/bin/bash
who | awk '{print \$1}' | sort | uniq -c | while read count user; do
    if [ "\$count" -gt ${MAX} ]; then
        pkill -u "\$user"
    fi
done
KILL
chmod +x /usr/local/bin/autokill-ssh.sh
# Add to cron every minute
(crontab -l 2>/dev/null | grep -v autokill-ssh; echo "* * * * * root /usr/local/bin/autokill-ssh.sh") | crontab -
echo -e "${GREEN}[✓] Autokill aktif — max $MAX login per user${NC}"
