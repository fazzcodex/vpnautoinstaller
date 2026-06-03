#!/bin/bash
# delexp.sh - delete expired SSH accounts
TODAY=$(date +%s)
DELETED=0
while IFS=: read -r user _ uid _ _ _ shell; do
    [ "$uid" -ge 1000 ] 2>/dev/null || continue
    [ "$shell" = "/bin/false" ] || [ "$shell" = "/usr/sbin/nologin" ] || continue
    EXP=$(chage -l "$user" 2>/dev/null | grep "Account expires" | cut -d: -f2 | xargs)
    [ "$EXP" = "never" ] || [ -z "$EXP" ] && continue
    EXP_S=$(date -d "$EXP" +%s 2>/dev/null || echo 0)
    if [ "$TODAY" -gt "$EXP_S" ]; then
        pkill -u "$user" 2>/dev/null
        userdel --force "$user" 2>/dev/null
        DELETED=$((DELETED+1))
        echo "[delexp] Deleted expired user: $user"
    fi
done < /etc/passwd
echo "[delexp] Total deleted: $DELETED"
