#!/bin/bash
# ram.sh
while true; do
    clear
    echo -e "\033[1;36m===== RAM Usage Monitor =====\033[0m"
    free -m | awk 'NR==2{printf " Used: %s MB / Total: %s MB (%.1f%%)\n", $3,$2,$3*100/$2}'
    echo -e " Press Ctrl+C to exit"
    echo ""
    ps aux --sort=-%mem | head -10
    sleep 3
done
