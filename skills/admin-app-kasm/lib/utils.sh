#!/bin/bash

# Common Utility Functions
# Shared utilities for KASM post-installation wizard modules
# Based on specification: post-installation-interview-spec.md

# Load MCP variables
STATE_FILE="${KASM_WIZARD_STATE_FILE:-/opt/kasm-sync/configs/interview-state.json}"

# Function to check if script is run as root
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        echo "ERROR: This script should NOT be run as root" >&2
        echo "Please run as a regular user with sudo privileges if needed" >&2
        return 1
    fi
    return 0
}

# Function to check if running with sudo privileges
check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        echo "ERROR: This script requires sudo privileges" >&2
        echo "Please run with sudo or configure passwordless sudo" >&2
        return 1
    fi
    return 0
}

# Function to check if directory exists and is writable
check_directory() {
    local dir="$1"
    local create_if_missing="${2:-false}"

    if [[ ! -d "$dir" ]]; then
        if [[ "$create_if_missing" == "true" ]]; then
            sudo mkdir -p "$dir" || return 1
            return 0
        else
            echo "ERROR: Directory does not exist: $dir" >&2
            return 1
        fi
    fi

    if [[ ! -w "$dir" ]] && ! sudo test -w "$dir"; then
        echo "ERROR: Directory is not writable: $dir" >&2
        return 1
    fi

    return 0
}

# Function to check if command exists
command_exists() {
    local cmd="$1"
    command -v "$cmd" >/dev/null 2>&1
}

# Function to check required commands
check_required_commands() {
    local missing_cmds=()

    for cmd in "$@"; do
        if ! command_exists "$cmd"; then
            missing_cmds+=("$cmd")
        fi
    done

    if [ ${#missing_cmds[@]} -gt 0 ]; then
        echo "ERROR: Missing required commands: ${missing_cmds[*]}" >&2
        return 1
    fi

    return 0
}

# Function to backup a file
backup_file() {
    local file="$1"
    local backup_suffix="${2:-.backup.$(date +%Y%m%d_%H%M%S)}"

    if [[ -f "$file" ]]; then
        sudo cp "$file" "${file}${backup_suffix}"
        echo "Backed up: $file -> ${file}${backup_suffix}"
        return 0
    fi

    return 1
}

# Function to load interview state
load_state() {
    if [[ -f "$STATE_FILE" ]]; then
        cat "$STATE_FILE"
    else
        echo "{}"
    fi
}

# Function to save interview state
save_state() {
    local state_json="$1"
    local state_dir=$(dirname "$STATE_FILE")

    # Create state directory if it doesn't exist
    sudo mkdir -p "$state_dir"

    # Save state
    echo "$state_json" | sudo tee "$STATE_FILE" > /dev/null

    echo "State saved to: $STATE_FILE"
}

# Function to get module status from state
get_module_status() {
    local module_name="$1"
    local state=$(load_state)

    echo "$state" | jq -r ".modules.\"$module_name\".status // \"pending\""
}

# Function to update module status
update_module_status() {
    local module_name="$1"
    local status="$2"
    local config="${3:-{}}"
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

    local state=$(load_state)

    # Update state using jq
    state=$(echo "$state" | jq \
        --arg module "$module_name" \
        --arg status "$status" \
        --arg timestamp "$timestamp" \
        --argjson config "$config" \
        '.modules[$module] = {
            status: $status,
            updated_at: $timestamp,
            config: $config
        }')

    save_state "$state"
}

# Function to initialize state file
init_state() {
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

    local initial_state=$(cat <<EOF
{
    "interview_state": {
        "version": "1.0",
        "started": "$timestamp",
        "last_updated": "$timestamp",
        "modules": {}
    }
}
EOF
)

    save_state "$initial_state"
}

# Function to validate JSON
validate_json() {
    local json="$1"

    if echo "$json" | jq empty 2>/dev/null; then
        return 0
    else
        echo "ERROR: Invalid JSON" >&2
        return 1
    fi
}

# Function to create directory with proper permissions
create_directory() {
    local dir="$1"
    local owner="${2:-1000:1000}"
    local perms="${3:-755}"

    sudo mkdir -p "$dir"
    sudo chown "$owner" "$dir"
    sudo chmod "$perms" "$dir"

    echo "Created directory: $dir (owner: $owner, perms: $perms)"
}

# Function to test directory write access
test_directory_write() {
    local dir="$1"
    local test_file="$dir/.write_test_$$"

    if touch "$test_file" 2>/dev/null; then
        rm -f "$test_file"
        return 0
    elif sudo touch "$test_file" 2>/dev/null; then
        sudo rm -f "$test_file"
        return 0
    else
        return 1
    fi
}

# Function to check disk space
check_disk_space() {
    local path="$1"
    local required_mb="$2"

    local available_mb=$(df -m "$path" | tail -1 | awk '{print $4}')

    if [ "$available_mb" -lt "$required_mb" ]; then
        echo "ERROR: Insufficient disk space. Required: ${required_mb}MB, Available: ${available_mb}MB" >&2
        return 1
    fi

    echo "Disk space OK: ${available_mb}MB available"
    return 0
}

# Function to retry a command
retry_command() {
    local max_attempts="$1"
    local delay="$2"
    shift 2
    local cmd=("$@")

    local attempt=1
    while [ $attempt -le $max_attempts ]; do
        if "${cmd[@]}"; then
            return 0
        else
            if [ $attempt -lt $max_attempts ]; then
                echo "Attempt $attempt failed. Retrying in ${delay}s..." >&2
                sleep "$delay"
            fi
        fi
        ((attempt++))
    done

    echo "All $max_attempts attempts failed" >&2
    return 1
}

# Function to log message to file and stdout
log_message() {
    local level="$1"
    local message="$2"
    local log_file="${3:-/var/log/kasm-wizard.log}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$timestamp] [$level] $message" | sudo tee -a "$log_file" >/dev/null
    echo "[$timestamp] [$level] $message"
}

# Function to generate random string
generate_random_string() {
    local length="${1:-32}"
    tr -dc 'A-Za-z0-9' < /dev/urandom | head -c "$length"
}

# Function to check if port is in use
check_port_in_use() {
    local port="$1"

    if sudo netstat -tlnp 2>/dev/null | grep -q ":$port "; then
        return 0
    else
        return 1
    fi
}

# Function to get system info
get_system_info() {
    local cpu_cores=$(nproc)
    local total_mem=$(free -m | awk 'NR==2{print $2}')
    local available_mem=$(free -m | awk 'NR==2{print $7}')
    local os_version=$(lsb_release -ds 2>/dev/null || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)

    cat <<EOF
{
    "cpu_cores": $cpu_cores,
    "total_memory_mb": $total_mem,
    "available_memory_mb": $available_mem,
    "os_version": "$os_version"
}
EOF
}

# Export functions
export -f check_not_root
export -f check_sudo
export -f check_directory
export -f command_exists
export -f check_required_commands
export -f backup_file
export -f load_state
export -f save_state
export -f get_module_status
export -f update_module_status
export -f init_state
export -f validate_json
export -f create_directory
export -f test_directory_write
export -f check_disk_space
export -f retry_command
export -f log_message
export -f generate_random_string
export -f check_port_in_use
export -f get_system_info
