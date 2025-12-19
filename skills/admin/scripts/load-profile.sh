#!/usr/bin/env bash
# =============================================================================
# Admin Suite Profile Loader - Bash version for WSL/Unix
# =============================================================================
# Usage:
#   source load-profile.sh                    # Load default profile
#   source load-profile.sh vibeskills-oci    # Load profile + deployment
#   load_admin_profile                        # After sourcing, use functions
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Detect environment and set correct ADMIN_ROOT
detect_admin_root() {
    if grep -qi microsoft /proc/version 2>/dev/null; then
        # WSL - profile lives on Windows side
        local win_user
        win_user=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
        echo "/mnt/c/Users/$win_user/.admin"
    else
        # Native Linux/macOS - use home directory
        echo "${HOME}/.admin"
    fi
}

# Default paths - auto-detect based on environment
ADMIN_ROOT="${ADMIN_ROOT:-$(detect_admin_root)}"
HOSTNAME=$(hostname)
DEFAULT_PROFILE="${ADMIN_ROOT}/profiles/${HOSTNAME}.json"

# Global variables
export ADMIN_PROFILE_PATH=""
export ADMIN_PROFILE_JSON=""
export ADMIN_DEVICE_NAME=""
export ADMIN_PLATFORM=""

log_info() { echo -e "${CYAN}[INFO]${NC} $1"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Show detected environment (useful for debugging)
show_environment() {
    echo ""
    echo -e "${CYAN}=== Environment Detection ===${NC}"
    if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "Type:        WSL (Windows Subsystem for Linux)"
        local win_user
        win_user=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
        echo "Win User:    $win_user"
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        echo "Type:        macOS"
    else
        echo "Type:        Native Linux"
    fi
    echo "Hostname:    $(hostname)"
    echo "ADMIN_ROOT:  $ADMIN_ROOT"
    echo "Profile:     $DEFAULT_PROFILE"
    echo "Exists:      $(test -f "$DEFAULT_PROFILE" && echo 'YES' || echo 'NO')"
    echo ""
}

check_dependencies() {
    if ! command -v jq &> /dev/null; then
        log_error "jq is required but not installed"
        log_info "Install with: sudo apt install jq"
        return 1
    fi
}

load_admin_profile() {
    local profile_path="${1:-$DEFAULT_PROFILE}"
    
    check_dependencies || return 1
    
    if [[ ! -f "$profile_path" ]]; then
        log_error "Profile not found: $profile_path"
        log_warn "ADMIN_ROOT is: $ADMIN_ROOT"
        if grep -qi microsoft /proc/version 2>/dev/null; then
            log_warn "Running in WSL - profile should be on Windows side"
            log_warn "Expected: /mnt/c/Users/{WIN_USER}/.admin/profiles/$(hostname).json"
            log_warn "Create profile from Windows: Initialize-AdminProfile.ps1"
        else
            log_warn "Create profile with: Initialize-AdminProfile.ps1 (Windows)"
        fi
        return 1
    fi
    
    log_info "Loading profile: $profile_path"
    
    if ! jq empty "$profile_path" 2>/dev/null; then
        log_error "Invalid JSON in profile"
        return 1
    fi
    
    ADMIN_PROFILE_PATH="$profile_path"
    ADMIN_PROFILE_JSON=$(cat "$profile_path")
    ADMIN_DEVICE_NAME=$(echo "$ADMIN_PROFILE_JSON" | jq -r '.device.name')
    ADMIN_PLATFORM=$(echo "$ADMIN_PROFILE_JSON" | jq -r '.device.platform')
    
    local schema_version=$(echo "$ADMIN_PROFILE_JSON" | jq -r '.schemaVersion')
    if [[ "$schema_version" != "3.0" ]]; then
        log_warn "Profile schema version $schema_version - expected 3.0"
    fi
    
    local tool_count=$(echo "$ADMIN_PROFILE_JSON" | jq '.tools | length')
    local server_count=$(echo "$ADMIN_PROFILE_JSON" | jq '.servers | length')
    
    log_ok "Device: $ADMIN_DEVICE_NAME ($ADMIN_PLATFORM)"
    log_info "Tools: $tool_count registered"
    log_info "Servers: $server_count managed"
    
    return 0
}

load_deployment() {
    local deployment_name="$1"
    
    if [[ -z "$ADMIN_PROFILE_JSON" ]]; then
        log_error "Profile not loaded. Run load_admin_profile first"
        return 1
    fi
    
    local env_file=$(echo "$ADMIN_PROFILE_JSON" | jq -r ".deployments[\"$deployment_name\"].envFile // empty")
    
    if [[ -z "$env_file" ]]; then
        log_error "Deployment '$deployment_name' not found or has no envFile"
        log_warn "Available deployments:"
        echo "$ADMIN_PROFILE_JSON" | jq -r '.deployments | keys[]' | sed 's/^/  - /'
        return 1
    fi
    
    # Convert Windows paths to WSL if needed
    if [[ "$env_file" == *":"* ]]; then
        local drive=$(echo "$env_file" | cut -c1 | tr '[:upper:]' '[:lower:]')
        local path=$(echo "$env_file" | cut -c3- | sed 's|\\|/|g')
        env_file="/mnt/$drive$path"
    fi
    
    if [[ ! -f "$env_file" ]]; then
        log_error "Env file not found: $env_file"
        return 1
    fi
    
    log_info "Loading deployment: $deployment_name"
    load_env_file "$env_file"
}

load_env_file() {
    local env_path="$1"
    local export_vars="${2:-true}"
    
    if [[ ! -f "$env_path" ]]; then
        log_error "Env file not found: $env_path"
        return 1
    fi
    
    log_info "Parsing: $env_path"
    
    local count=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        
        if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            value="${value#\"}"; value="${value%\"}"
            value="${value#\'}"; value="${value%\'}"
            
            if [[ "$export_vars" == "true" ]]; then
                export "$key=$value"
            fi
            ((count++))
        fi
    done < "$env_path"
    
    log_ok "Loaded $count variables"
}

get_admin_tool() {
    local tool_name="$1"
    if [[ -z "$ADMIN_PROFILE_JSON" ]]; then log_error "Profile not loaded"; return 1; fi
    echo "$ADMIN_PROFILE_JSON" | jq ".tools[\"$tool_name\"]"
}

get_tool_path() {
    local tool_name="$1"
    echo "$ADMIN_PROFILE_JSON" | jq -r ".tools[\"$tool_name\"].path // empty"
}

is_tool_working() {
    local tool_name="$1"
    local status=$(echo "$ADMIN_PROFILE_JSON" | jq -r ".tools[\"$tool_name\"].installStatus // empty")
    [[ "$status" == "working" ]]
}

get_admin_server() {
    local filter_type="$1"
    local filter_value="$2"
    
    if [[ -z "$ADMIN_PROFILE_JSON" ]]; then log_error "Profile not loaded"; return 1; fi
    
    case "$filter_type" in
        id) echo "$ADMIN_PROFILE_JSON" | jq ".servers[] | select(.id == \"$filter_value\")" ;;
        role) echo "$ADMIN_PROFILE_JSON" | jq ".servers[] | select(.role == \"$filter_value\")" ;;
        provider) echo "$ADMIN_PROFILE_JSON" | jq ".servers[] | select(.provider == \"$filter_value\")" ;;
        *) echo "$ADMIN_PROFILE_JSON" | jq '.servers[]' ;;
    esac
}

get_admin_preference() {
    local category="$1"
    echo "$ADMIN_PROFILE_JSON" | jq -r ".preferences[\"$category\"]"
}

get_preferred_manager() {
    local category="$1"
    echo "$ADMIN_PROFILE_JSON" | jq -r ".preferences[\"$category\"].manager // empty"
}

has_capability() {
    local capability="$1"
    local value=$(echo "$ADMIN_PROFILE_JSON" | jq -r ".capabilities[\"$capability\"] // false")
    [[ "$value" == "true" ]]
}

show_admin_summary() {
    if [[ -z "$ADMIN_PROFILE_JSON" ]]; then log_error "Profile not loaded"; return 1; fi
    
    echo ""
    echo -e "${CYAN}=== Admin Profile Summary ===${NC}"
    echo "Device:     $ADMIN_DEVICE_NAME ($ADMIN_PLATFORM)"
    echo "User:       $(echo "$ADMIN_PROFILE_JSON" | jq -r '.device.user')"
    echo "Shell:      $(echo "$ADMIN_PROFILE_JSON" | jq -r '.preferences.shell.preferred')"
    echo ""
    
    echo -e "${YELLOW}Preferences:${NC}"
    echo "  Python:   $(get_preferred_manager python)"
    echo "  Node:     $(get_preferred_manager node)"
    echo "  Packages: $(get_preferred_manager packages)"
    echo ""
    
    echo -e "${YELLOW}Capabilities:${NC}"
    local caps=""
    has_capability "hasWsl" && caps+="WSL "
    has_capability "hasDocker" && caps+="Docker "
    has_capability "mcpEnabled" && caps+="MCP "
    has_capability "canAccessDropbox" && caps+="Dropbox "
    echo "  $caps"
    echo ""
    
    echo -e "${YELLOW}Servers:${NC}"
    echo "$ADMIN_PROFILE_JSON" | jq -r '.servers[] | "  \(if .status == "active" then "✓" else "○" end) \(.name) (\(.role)) - \(.host)"'
    echo ""
    
    echo -e "${YELLOW}Deployments:${NC}"
    echo "$ADMIN_PROFILE_JSON" | jq -r '.deployments | to_entries[] | "  \(if .value.envFile then "✓" else "○" end) \(.key) (\(.value.type)/\(.value.provider)) - \(.value.status)"'
    echo ""
}

ssh_to_server() {
    local server_id="$1"
    shift
    
    local server=$(get_admin_server id "$server_id")
    
    if [[ -z "$server" || "$server" == "null" ]]; then
        log_error "Server not found: $server_id"
        return 1
    fi
    
    local host=$(echo "$server" | jq -r '.host')
    local user=$(echo "$server" | jq -r '.username')
    local port=$(echo "$server" | jq -r '.port // 22')
    local key=$(echo "$server" | jq -r '.keyPath // empty')
    
    if [[ -n "$key" && "$key" == *":"* ]]; then
        local drive=$(echo "$key" | cut -c1 | tr '[:upper:]' '[:lower:]')
        local path=$(echo "$key" | cut -c3- | sed 's|\\|/|g')
        key="/mnt/$drive$path"
    fi
    
    log_info "Connecting to $user@$host:$port"
    
    if [[ -n "$key" && -f "$key" ]]; then
        ssh -i "$key" -p "$port" "$user@$host" "$@"
    else
        ssh -p "$port" "$user@$host" "$@"
    fi
}

py() {
    local manager=$(get_preferred_manager python)
    case "$manager" in
        uv) uv "$@" ;;
        pip) pip "$@" ;;
        conda) conda "$@" ;;
        poetry) poetry "$@" ;;
        *) python "$@" ;;
    esac
}

if [[ "${1:-}" ]]; then
    load_admin_profile
    load_deployment "$1"
    show_admin_summary
fi
