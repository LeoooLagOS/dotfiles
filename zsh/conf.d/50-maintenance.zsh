# ==============================================================================
# 🧰 lagOS Maintenance Layer: System Update & Cleanup
# ==============================================================================

function system_update_sync() {
    local B='\033[1;34m' G='\033[0;32m' R='\033[0;31m' Y='\033[1;33m' NC='\033[0m'
    local LOG_PREFIX="[SYSTEM-SYNC]"
    local START_TIME=$(date +%s)
    
    # Internal Logging Helpers
    log_info()    { echo -e "${B}${LOG_PREFIX}${NC} $1"; }
    log_success() { echo -e "${G}${LOG_PREFIX} SUCCESS:${NC} $1"; }
    log_warn()    { echo -e "${Y}${LOG_PREFIX} WARNING:${NC} $1"; }
    log_error()   { echo -e "${R}${LOG_PREFIX} ERROR:${NC} $1"; }

    echo -e "${B}🔍 Analyzing System State & Calculating Transaction...${NC}"

    # 1. PRE-FLIGHT: Refresh administrative credentials for the analysis
    sudo -v || return 1

    # 2. PLAN PHASE: Capture metadata via Dry-Runs
    log_info "Calculating DNF infrastructure changes..."
    local DNF_SUMMARY=$(sudo dnf upgrade --refresh --assumeno 2>/dev/null | grep -E "Transaction Summary|Install|Upgrade|Remove|Total download size|Is this ok")
    
    log_info "Calculating Flatpak application changes..."
    local FP_SUMMARY=$(flatpak update --dry-run 2>/dev/null | grep -E "Total download|Install|Update")

    # 3. PRESENT THE DEPLOYMENT PLAN
    echo -e "\n${B}📋 DEPLOYMENT PLAN${NC}"
    echo -e "-------------------------------------------------"
    
    if [[ -n "$DNF_SUMMARY" && ! "$DNF_SUMMARY" =~ "Nothing to do" ]]; then
        echo -e "${Y}[DNF System Packages]${NC}"
        echo "$DNF_SUMMARY" | grep -v "Is this ok" | sed 's/^/  /'
    else
        echo -e "${G}  DNF: System is already up to date.${NC}"
    fi

    echo ""

    if [[ -n "$FP_SUMMARY" ]]; then
        echo -e "${Y}[Flatpak Applications]${NC}"
        echo "$FP_SUMMARY" | sed 's/^/  /'
    else
        echo -e "${G}  Flatpak: All applications are up to date.${NC}"
    fi
    echo -e "-------------------------------------------------"

    # 4. SHORT-CIRCUIT: Skip transaction if the system is current
    if [[ "$DNF_SUMMARY" =~ "Nothing to do" && -z "$FP_SUMMARY" ]]; then
        log_success "System state is already optimized."
        echo -ne "${Y}❓ Run maintenance cleanup anyway? [y/N]: ${NC}"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            [[ -n "$(whence sys-clean)" ]] && sys-clean || log_error "sys-clean function not found."
        fi
        return 0
    fi

    # 5. THE GATEKEEPER
    echo -ne "${Y}❓ Proceed with the deployment? [y/N]: ${NC}"
    read -r response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        log_warn "Deployment aborted by user."
        return 0
    fi

    # 6. EXECUTION PHASE
    echo -e "\n${B}🚀 Executing Transaction...${NC}"
    
    # Fire-and-forget background sudo keep-alive (Disowned to hide PID)
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &!

    # Execute system package upgrades
    sudo dnf upgrade -y
    
    # Execute application-layer updates
    flatpak update -y

    # Post-deployment cleanup logic
    if whence sys-clean >/dev/null; then
        log_info "Initializing post-deployment cleanup..."
        sys-clean
    fi

    local END_TIME=$(date +%s)
    echo -e "\n${G}✨ SYSTEM SYNCHRONIZED SUCCESSFULLY ($((END_TIME - START_TIME))s)${NC}"
}

sys-clean() {
    local B='\033[1;34m' G='\033[0;32m' NC='\033[0m'
    
    echo -e "${B}🧹 Cleaning DNF (Fedora Package Manager)...${NC}"
    sudo dnf autoremove -y && sudo dnf clean all

    echo -e "${B}📦 Cleaning Unused Flatpak Runtimes...${NC}"
    flatpak uninstall --unused -y

    echo -e "${B}📔 Vacuuming System Logs (older than 2 weeks)...${NC}"
    sudo journalctl --vacuum-time=2weeks

    echo -e "${B}🗑️  Clearing user cache...${NC}"
    if [[ -d "$HOME/.cache/thumbnails" ]]; then
        find "$HOME/.cache/thumbnails" -mindepth 1 -delete 2>/dev/null
        echo -e "${G}✨ Thumbnail cache purged.${NC}"
    fi
    
    # Packet Tracer specific maintenance
    if [[ -d "$HOME/pt/logs" ]]; then
        echo -e "${B}🚀 Purging Packet Tracer debug logs...${NC}"
        find "$HOME/pt/logs" -type f -name "*.log" -delete 2>/dev/null
        echo -e "${G}✨ PT logs cleared.${NC}"
    fi

    echo -e "\n${G}✅ System Janitor: Sanitation Complete.${NC}"
}
