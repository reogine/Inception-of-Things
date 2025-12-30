#!/bin/bash

# Colors
RESET='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'

# Logger function
log() {
    local level=$1
    local message=$2
    local color=$3
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    echo -e "${color}[${timestamp}] [${level}] ${message}${RESET}"
}

# Log levels
info() {
    log "INFO" "$1" "${BLUE}"
}

success() {
    log "SUCCESS" "$1" "${GREEN}"
}

warn() {
    log "WARN" "$1" "${YELLOW}"
}

error() {
    log "ERROR" "$1" "${RED}" >&2
}

title() {
    local message="$1"
    local len=$((${#message} + 3))
    local line=$(printf '%*s' "$len" '' | sed "s/ /─/g")
    echo -e "\n${BOLD}${message}${RESET}"
    echo -e "${line}"
    echo ""
}

frame() {
    local message="$1"
    local padding="  "
    local len=${#message}
    local line_len=$((len + 4))
    
    local line=$(printf '%*s' "$line_len" '' | sed "s/ /═/g")
    
    echo -e "${BOLD}${CYAN}╔${line}╗${RESET}"
    echo -e "${BOLD}${CYAN}║${padding}${RESET}${message}${BOLD}${CYAN}${padding}║${RESET}"
    echo -e "${BOLD}${CYAN}╚${line}╝${RESET}"
}

services_table() {
    local args=()
    local start=false
    local end=false

    for arg in "$@"; do
        case "$arg" in
            --start) start=true ;;
            --end) end=true ;;
            *) args+=("$arg") ;;
        esac
    done
    
    set -- "${args[@]}"
    local name="${1:-}"
    local url="${2:-}"
    local user="${3:-}"
    local pass="${4:-}"
    
    local width=60
    local line_content=$(printf '%*s' "$((width - 2))" '' | sed "s/ /═/g")
    local sep_content=$(printf '%*s' "$((width - 2))" '' | sed "s/ /─/g")

    # Helper for rows
    print_row() {
        local label="$1"
        local value="$2"
        local color="$3"
        if [ -z "$value" ]; then return; fi
        
        local text_len=$((${#label} + 2 + ${#value}))
        local padding=$((width - text_len - 4))
        if [ $padding -lt 0 ]; then padding=0; fi
        local pad_str=$(printf '%*s' "$padding" '')
        echo -e "${BOLD}${CYAN}║ ${color}${label}: ${RESET}${value}${pad_str}${BOLD}${CYAN} ║${RESET}"
    }
    
    # Helper for headers
    print_header() {
        local title="$1"
        local padding=$((width - ${#title} - 4))
        local pad_str=$(printf '%*s' "$padding" '')
        echo -e "${BOLD}${CYAN}║ ${BOLD}${title}${pad_str}${BOLD}${CYAN} ║${RESET}"
    }

    if [ "$start" = true ]; then
        echo -e "${BOLD}${CYAN}╔${line_content}╗${RESET}"
        local title="SERVICES"
        local padding=$(( (width - 2 - ${#title}) / 2 ))
        local pad_str=$(printf '%*s' "$padding" '')
        echo -e "${BOLD}${CYAN}║${pad_str}${BOLD}${title}${RESET}${BOLD}${CYAN}${pad_str}║${RESET}"
    elif [ -n "$name" ]; then
        echo -e "${BOLD}${CYAN}╟${sep_content}╢${RESET}"
    fi

    if [ -n "$name" ]; then
        print_header "$name"
        print_row "URL" "$url" "${BLUE}"
        print_row "User" "$user" "${YELLOW}"
        print_row "Pass" "$pass" "${GREEN}"
    fi

    if [ "$end" = true ]; then
        echo -e "${BOLD}${CYAN}╚${line_content}╝${RESET}"
    fi
}




