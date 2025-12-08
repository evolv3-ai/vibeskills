# First-Run Setup Guide

When the admin skill activates and no configuration exists, guide the user through setup.

## Detection

Check for existing configuration:

```bash
config_exists() {
    # Check project-local config
    [[ -f ".env.local" ]] && return 0

    # Check global config
    [[ -f "$HOME/.admin/.env" ]] && return 0

    # Check if admin directory exists with config
    [[ -f "${ADMIN_ROOT:-$HOME/.admin}/config/.env" ]] && return 0

    return 1
}
```

## Setup Flow

### Step 1: Detect Environment

Automatically detect without user input:

```bash
# Platform
if grep -q Microsoft /proc/version 2>/dev/null; then
    detected_platform="wsl"
elif [[ "$OS" == "Windows_NT" ]]; then
    detected_platform="windows"
elif [[ "$(uname -s)" == "Darwin" ]]; then
    detected_platform="macos"
else
    detected_platform="linux"
fi

# Hostname
detected_hostname=$(hostname)

# Username
detected_user=$(whoami)
```

Display to user:
```
Detected Environment:
  Platform: wsl
  Hostname: WOPR3
  User: wsladmin
```

### Step 2: Prompt for Configuration

Ask user for optional customizations:

```
Configuration Options:

1. Device name (default: WOPR3)
   > [press Enter for default or type custom name]

2. Admin directory (default: ~/.admin)
   > [press Enter for default or type custom path]

3. Enable cross-device sync? (y/N)
   > [if yes, ask for sync path]
```

### Step 3: Create Configuration

Generate the configuration file:

```bash
create_config() {
    local config_dir="${ADMIN_ROOT:-$HOME/.admin}"
    local config_file="$config_dir/.env"

    mkdir -p "$config_dir"/{logs,profiles,config}

    cat > "$config_file" << EOF
# Admin Skills Configuration
# Generated: $(date -Iseconds)

# Core Identity
DEVICE_NAME=${device_name:-$(hostname)}
ADMIN_USER=${admin_user:-$(whoami)}
ADMIN_PLATFORM=${detected_platform}

# Paths
ADMIN_ROOT=$config_dir
ADMIN_LOG_PATH=$config_dir/logs
ADMIN_PROFILE_PATH=$config_dir/profiles

# Platform-specific (WSL)
WSL_DISTRO=${WSL_DISTRO:-Ubuntu-24.04}
WSL_ADMIN_PATH=${WSL_ADMIN_PATH:-~/dev/wsl-admin}

# Sync (optional)
ADMIN_SYNC_ENABLED=${sync_enabled:-false}
${sync_path:+ADMIN_SYNC_PATH=$sync_path}
EOF

    echo "Configuration saved to: $config_file"
}
```

### Step 4: Create Initial Profile

Generate empty device profile:

```bash
create_profile() {
    local profile_dir="${ADMIN_PROFILE_PATH:-$HOME/.admin/profiles}"
    local device="${DEVICE_NAME:-$(hostname)}"
    local profile_file="$profile_dir/$device.json"

    mkdir -p "$profile_dir"

    cat > "$profile_file" << EOF
{
  "deviceInfo": {
    "name": "$device",
    "platform": "${ADMIN_PLATFORM:-$(detect_platform)}",
    "hostname": "$(hostname)",
    "user": "${ADMIN_USER:-$(whoami)}",
    "lastUpdated": "$(date -Iseconds)"
  },
  "installedTools": {},
  "managedServers": [],
  "cloudProviders": {},
  "syncSettings": {
    "enabled": ${ADMIN_SYNC_ENABLED:-false}
  }
}
EOF

    echo "Profile created: $profile_file"
}
```

### Step 5: Verify Setup

Test the configuration:

```bash
verify_setup() {
    local errors=0

    # Check directories
    for dir in "$ADMIN_ROOT" "$ADMIN_LOG_PATH" "$ADMIN_PROFILE_PATH"; do
        if [[ ! -d "$dir" ]]; then
            echo "ERROR: Directory missing: $dir"
            ((errors++))
        fi
    done

    # Check write permissions
    if ! touch "$ADMIN_LOG_PATH/.test" 2>/dev/null; then
        echo "ERROR: Cannot write to log directory"
        ((errors++))
    else
        rm -f "$ADMIN_LOG_PATH/.test"
    fi

    # Check profile exists
    local profile="${ADMIN_PROFILE_PATH}/${DEVICE_NAME}.json"
    if [[ ! -f "$profile" ]]; then
        echo "ERROR: Profile not created: $profile"
        ((errors++))
    fi

    if [[ $errors -eq 0 ]]; then
        echo "Setup verified successfully!"
        return 0
    else
        echo "Setup completed with $errors error(s)"
        return 1
    fi
}
```

### Step 6: Display Summary

Show user what was created:

```
═══════════════════════════════════════════════════════════════════
   ADMIN SETUP COMPLETE
═══════════════════════════════════════════════════════════════════

Device: WOPR3 (wsl)
User: wsladmin

Directories Created:
  ~/.admin/
  ~/.admin/logs/
  ~/.admin/profiles/

Files Created:
  ~/.admin/.env (configuration)
  ~/.admin/profiles/WOPR3.json (device profile)

───────────────────────────────────────────────────────────────────
NEXT STEPS
───────────────────────────────────────────────────────────────────

• To manage servers: "provision a server" or "list my servers"
• To manage this PC: "install [package]" or "update system"
• To manage WSL: Already in WSL - use apt, docker, etc.
• To view logs: cat ~/.admin/logs/operations.log
• To view profile: cat ~/.admin/profiles/WOPR3.json

═══════════════════════════════════════════════════════════════════
```

## Subsequent Runs

After initial setup, admin loads configuration silently:

```bash
load_config() {
    # Source config in priority order
    if [[ -f ".env.local" ]]; then
        source .env.local
    elif [[ -f "$HOME/.admin/.env" ]]; then
        source "$HOME/.admin/.env"
    fi

    # Apply defaults for any unset values
    DEVICE_NAME="${DEVICE_NAME:-$(hostname)}"
    ADMIN_USER="${ADMIN_USER:-$(whoami)}"
    ADMIN_ROOT="${ADMIN_ROOT:-$HOME/.admin}"
    ADMIN_LOG_PATH="${ADMIN_LOG_PATH:-$ADMIN_ROOT/logs}"
    ADMIN_PROFILE_PATH="${ADMIN_PROFILE_PATH:-$ADMIN_ROOT/profiles}"

    # Auto-detect platform if not set
    if [[ -z "$ADMIN_PLATFORM" ]]; then
        ADMIN_PLATFORM=$(detect_platform)
    fi
}
```

## Troubleshooting

### Config Not Loading

```bash
# Check config locations
ls -la ~/.admin/.env
ls -la .env.local

# Verify syntax
bash -n ~/.admin/.env
```

### Permission Issues

```bash
# Fix ownership
chown -R $(whoami) ~/.admin

# Fix permissions
chmod 700 ~/.admin
chmod 600 ~/.admin/.env
chmod 755 ~/.admin/logs ~/.admin/profiles
```

### Reset Configuration

```bash
# Backup and reset
mv ~/.admin ~/.admin.backup.$(date +%Y%m%d)

# Re-run setup
# (admin skill will detect missing config and run setup)
```
