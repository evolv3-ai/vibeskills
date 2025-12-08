#!/bin/bash

# KASM API Wrapper Functions
# Provides high-level functions for interacting with KASM Workspaces API
# Based on specification: post-installation-interview-spec.md (lines 674-711)

# Load MCP variables
KASM_API_URL="${KASM_API_URL:-https://localhost/api}"
KASM_API_CONFIG="${KASM_API_CONFIG:-/opt/kasm/current/conf/app/api.app.config.yaml}"

# Function to get KASM API credentials from installation
get_kasm_api_creds() {
    if [[ ! -f "$KASM_API_CONFIG" ]]; then
        echo "ERROR: KASM API config not found at $KASM_API_CONFIG" >&2
        return 1
    fi

    # Extract API credentials from config
    KASM_API_KEY=$(sudo grep "api_key:" "$KASM_API_CONFIG" | head -1 | awk '{print $2}' | tr -d '"' | tr -d "'")
    KASM_API_SECRET=$(sudo grep "api_key_secret:" "$KASM_API_CONFIG" | head -1 | awk '{print $2}' | tr -d '"' | tr -d "'")

    if [[ -z "$KASM_API_KEY" ]] || [[ -z "$KASM_API_SECRET" ]]; then
        echo "ERROR: Failed to extract KASM API credentials" >&2
        return 1
    fi

    export KASM_API_KEY
    export KASM_API_SECRET
    return 0
}

# Function to make authenticated API request
kasm_api_request() {
    local method="$1"
    local endpoint="$2"
    local data="$3"

    if [[ -z "$KASM_API_KEY" ]] || [[ -z "$KASM_API_SECRET" ]]; then
        get_kasm_api_creds || return 1
    fi

    local response
    if [[ "$method" == "GET" ]]; then
        response=$(curl -s -k -X GET \
            "$KASM_API_URL$endpoint" \
            -H "Content-Type: application/json" \
            -u "$KASM_API_KEY:$KASM_API_SECRET")
    else
        response=$(curl -s -k -X "$method" \
            "$KASM_API_URL$endpoint" \
            -H "Content-Type: application/json" \
            -u "$KASM_API_KEY:$KASM_API_SECRET" \
            -d "$data")
    fi

    echo "$response"
}

# Function to get workspace list
get_workspaces() {
    kasm_api_request "POST" "/api/public/get_workspaces" '{}'
}

# Function to get specific workspace by ID
get_workspace() {
    local workspace_id="$1"
    kasm_api_request "POST" "/api/public/get_workspace" "{\"workspace_id\": \"$workspace_id\"}"
}

# Function to update workspace configuration
update_workspace_config() {
    local workspace_id="$1"
    local config_json="$2"

    kasm_api_request "POST" "/api/public/update_workspace" \
        "{\"workspace_id\": \"$workspace_id\", \"config\": $config_json}"
}

# Function to update workspace docker run config
update_workspace_docker_run_config() {
    local workspace_id="$1"
    local docker_run_config="$2"

    kasm_api_request "POST" "/api/public/update_workspace" \
        "{\"workspace_id\": \"$workspace_id\", \"docker_run_config\": $docker_run_config}"
}

# Function to update workspace docker exec config
update_workspace_docker_exec_config() {
    local workspace_id="$1"
    local docker_exec_config="$2"

    kasm_api_request "POST" "/api/public/update_workspace" \
        "{\"workspace_id\": \"$workspace_id\", \"docker_exec_config\": $docker_exec_config}"
}

# Function to create storage mapping
create_storage_mapping() {
    local mapping_json="$1"

    kasm_api_request "POST" "/api/public/create_storage_mapping" "$mapping_json"
}

# Function to get storage mappings
get_storage_mappings() {
    kasm_api_request "POST" "/api/public/get_storage_mappings" '{}'
}

# Function to delete storage mapping
delete_storage_mapping() {
    local mapping_id="$1"

    kasm_api_request "POST" "/api/public/delete_storage_mapping" \
        "{\"storage_mapping_id\": \"$mapping_id\"}"
}

# Function to create user
create_user() {
    local username="$1"
    local password="$2"
    local email="${3:-$username@kasm.local}"

    kasm_api_request "POST" "/api/public/create_user" \
        "{\"username\": \"$username\", \"password\": \"$password\", \"email\": \"$email\"}"
}

# Function to get users
get_users() {
    kasm_api_request "POST" "/api/public/get_users" '{}'
}

# Function to get server info
get_server_info() {
    kasm_api_request "POST" "/api/public/get_server_info" '{}'
}

# Function to test API connection
test_api_connection() {
    local response
    response=$(get_server_info)

    if echo "$response" | grep -q '"success".*true'; then
        echo "SUCCESS: KASM API connection established"
        return 0
    else
        echo "ERROR: KASM API connection failed"
        echo "Response: $response"
        return 1
    fi
}

# Function to apply volume mapping to workspace
apply_volume_mapping() {
    local workspace_id="$1"
    local host_path="$2"
    local container_path="$3"
    local mode="${4:-rw}"
    local uid="${5:-1000}"
    local gid="${6:-1000}"

    local volume_config=$(cat <<EOF
{
    "volume_mappings": {
        "$host_path": {
            "bind": "$container_path",
            "mode": "$mode",
            "uid": $uid,
            "gid": $gid,
            "required": true,
            "skip_check": false
        }
    }
}
EOF
)

    update_workspace_config "$workspace_id" "$volume_config"
}

# Function to apply persistent profile configuration
apply_persistent_profile() {
    local workspace_id="$1"
    local profile_path="$2"
    local quota_gb="${3:-10}"

    local profile_config=$(cat <<EOF
{
    "persistent_profile_path": "$profile_path",
    "persistent_profile_config": {
        "quota_gb": $quota_gb,
        "permissions": {
            "uid": 1000,
            "gid": 1000,
            "mode": "0755"
        }
    }
}
EOF
)

    update_workspace_config "$workspace_id" "$profile_config"
}

# Export functions
export -f get_kasm_api_creds
export -f kasm_api_request
export -f get_workspaces
export -f get_workspace
export -f update_workspace_config
export -f update_workspace_docker_run_config
export -f update_workspace_docker_exec_config
export -f create_storage_mapping
export -f get_storage_mappings
export -f delete_storage_mapping
export -f create_user
export -f get_users
export -f get_server_info
export -f test_api_connection
export -f apply_volume_mapping
export -f apply_persistent_profile
