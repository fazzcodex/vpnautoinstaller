#!/bin/bash
# update.sh
GREEN='\033[0;32m'; NC='\033[0m'; YELLOW='\033[1;33m'
REPO="https://raw.githubusercontent.com/fazzcodex/vpnautoinstaller/main"
echo -e "${YELLOW}[Update] Downloading latest menu...${NC}"
wget -q "$REPO/menu.sh" -O /usr/bin/menu && chmod +x /usr/bin/menu
wget -q "$REPO/menu.sh" -O /usr/bin/fazzpedia && chmod +x /usr/bin/fazzpedia
echo -e "${GREEN}[✓] Update selesai!${NC}"
