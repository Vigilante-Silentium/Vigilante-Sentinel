#!/bin/bash

# ==============================================================================
# VigilanteSilentiumShield - Judicium in Silentio, Scutum in Umbra
# ==============================================================================
#
# SYSTEM: VIGILANTE SENTINEL
# ROLE: INTEGRITY MONITOR & ANTI-FORENSICS CLEANER
# OS: PARROT OS / KALI LINUX
#
# ==============================================================================

# COLORS
R='\033[0;31m'
G='\033[0;32m'
B='\033[0;34m'
Y='\033[1;33m'
NC='\033[0m'
DB_FILE=".fim_hash.db"

banner() {
    clear
    echo -e "${B}======================================================"
    echo -e "   VIGILANTE SENTINEL - BLUE TEAM PROTOCOL"
    echo -e "   Judicium in Silentio, Scutum in Umbra"
    echo -e "======================================================${NC}"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${R}[!] ERROR: ACCESS DENIED. ROOT REQUIRED.${NC}"
        exit
    fi
}

# [MODULE 1] FILE INTEGRITY MONITOR (FIM)
fim_module() {
    echo -e "${Y}[*] INITIATING INTEGRITY CHECK...${NC}"
    FILES=("/etc/passwd" "/etc/shadow" "/etc/hosts" "$0")

    if [ ! -f "$DB_FILE" ]; then
        echo -e "${B}[i] Creating Baseline...${NC}"
        touch "$DB_FILE"
        for f in "${FILES[@]}"; do
            sha256sum "$f" >> "$DB_FILE" 2>/dev/null
        done
        echo -e "${G}[+] Baseline Established.${NC}"
    else
        echo -e "${B}[i] Verifying Hashes...${NC}"
        sha256sum -c "$DB_FILE" 2>/dev/null > /tmp/fim_res
        if grep -q "FAILED" /tmp/fim_res; then
            echo -e "${R}[!!!] ALERT: SYSTEM MODIFICATION DETECTED [!!!]${NC}"
            grep "FAILED" /tmp/fim_res
        else
            echo -e "${G}[+] System Integrity: SECURE.${NC}"
        fi
        rm /tmp/fim_res
    fi
}

# [MODULE 2] LOG ANALYSIS
log_module() {
    echo -e "\n${Y}[*] SCANNING AUTH LOGS...${NC}"
    LOG="/var/log/auth.log"
    if [ -f "$LOG" ]; then
        FAILS=$(grep -c "Failed password" "$LOG")
        SUDO=$(grep -c "sudo" "$LOG")
        echo -e "   > Failed Logins: $FAILS"
        echo -e "   > Sudo Events  : $SUDO"
    else
        echo -e "${R}[!] Log file not found.${NC}"
    fi
}

# [MODULE 3] JUDICIUM CLEANER (Anti-Forensics)
clean_module() {
    echo -e "\n${Y}[*] POST-OPERATION CLEANUP PROTOCOL${NC}"
    echo -n "   > Execute Cleaning? (y/n): "
    read confirm
    if [ "$confirm" == "y" ]; then
        echo -e "${B}   [+] Clearing APT Cache...${NC}"
        apt-get clean > /dev/null 2>&1
        
        echo -e "${B}   [+] Sanitizing Logs (Truncate)...${NC}"
        truncate -s 0 /var/log/syslog 2>/dev/null
        truncate -s 0 /var/log/auth.log 2>/dev/null
        
        echo -e "${B}   [+] Wiping Bash History...${NC}"
        history -c
        cat /dev/null > ~/.bash_history
        
        echo -e "${G}[V] TRACES ELIMINATED.${NC}"
    else
        echo -e "${B}[i] Aborted.${NC}"
    fi
}

# MAIN EXECUTION
check_root
banner
fim_module
log_module
clean_module
