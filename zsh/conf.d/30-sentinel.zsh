# ==============================================================================
# 🛡️ lagOS Core Subsystem: Sentinel Infrastructure Auditor
# ==============================================================================

function sentinel() {
    local DEV_USER="$USER"
    
    # ANSI Color Codes
    local B='\033[1;34m' # Info
    local G='\033[0;32m' # Success
    local R='\033[0;31m' # Fail
    local Y='\033[1;33m' # Action
    local NC='\033[0m'   # No Color

    echo -e "${B}===[ 🛡️  SENTINEL SYSTEM CHECK | User: ${DEV_USER} ]===${NC}"

    # 1. SECURITY POLICY
    printf "🔐 Security: "
    if [[ -d ~/.ssh ]]; then
        chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_ed25519* 2>/dev/null
        echo -e "${G}POLICY_ENFORCED${NC}"
    else
        echo -e "${R}DIR_MISSING${NC}"
    fi
    
    # 2. VIRTUALIZATION (Deterministic Logic Gate)
    printf "🌐 Virtual:  "
    if systemctl is-active --quiet libvirtd; then
        echo -e "${G}KVM_ACTIVE${NC}"
    else
        echo -e "${Y}STARTING_LIBVIRTD...${NC}"
        sudo systemctl start libvirtd && echo -e "    ↳ ${G}Daemon spawned successfully.${NC}"
    fi

    # 3. RUNTIME INVENTORY
    printf "🐍 Python:   "
    command -v python3 &>/dev/null && echo -e "${G}$(python3 --version | awk '{print $2}')${NC}" || echo -e "${R}NOT_FOUND${NC}"

    printf "☕ Java:     "
    command -v java &>/dev/null && echo -e "${G}$(java -version 2>&1 | awk -F '\"' '/version/ {print $2}')${NC}" || echo -e "${R}NOT_FOUND${NC}"
    
    printf "🔷 .NET:     "
    command -v dotnet &>/dev/null && echo -e "${G}$(dotnet --version)${NC}" || echo -e "${R}NOT_FOUND${NC}"

    # 4. FAST RUNTIMES (Inline Output)
    printf "⚡ Runtimes: "
    command -v bun &>/dev/null && echo -ne "${G}Bun($(bun --version))${NC} | " || echo -ne "${R}NO_BUN${NC} | "
    command -v go &>/dev/null && echo -e "${G}Go($(go version | awk '{print $3}' | sed 's/go//'))${NC}" || echo -e "${R}NO_GO${NC}"

    # 5. GIT IDENTITY
    printf "🐙 Git Auth: "
    echo -e "${G}$(git config --global user.name)${NC}"

    echo -e "${B}=================================================${NC}"
}
