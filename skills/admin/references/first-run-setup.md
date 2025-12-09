# First-Run Setup Guide

When the admin skill activates and no configuration exists, guide the user through setup.

## Detection

### Bash Mode

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

### PowerShell Mode

```powershell
function Test-AdminConfig {
    # Check project-local config
    if (Test-Path '.env.local') { return $true }

    # Check global config
    $globalEnv = Join-Path $env:USERPROFILE '.admin\.env'
    if (Test-Path $globalEnv) { return $true }

    return $false
}
```

## Setup Flow

### Step 1: Detect Environment

Automatically detect without user input:

```bash
# Platform (case-insensitive grep for WSL)
if grep -qi microsoft /proc/version 2>/dev/null; then
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

Generate the configuration file.

**IMPORTANT**: Always use absolute paths, never tilde (~). Tilde only expands when sourced, not when parsed.

#### Bash Mode

```bash
create_config() {
    # Always expand to absolute path
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
ADMIN_SHELL=${detected_shell:-bash}

# Paths (ALWAYS use absolute paths, never ~)
ADMIN_ROOT=$config_dir
ADMIN_LOG_PATH=$config_dir/logs
ADMIN_PROFILE_PATH=$config_dir/profiles

# Platform-specific (WSL)
WSL_DISTRO=${WSL_DISTRO:-Ubuntu-24.04}
WSL_ADMIN_PATH=${WSL_ADMIN_PATH:-$HOME/dev/wsl-admin}

# Sync (optional)
ADMIN_SYNC_ENABLED=${sync_enabled:-false}
${sync_path:+ADMIN_SYNC_PATH=$sync_path}
EOF

    echo "Configuration saved to: $config_file"
}
```

#### PowerShell Mode

```powershell
function New-AdminConfig {
    # Always use absolute paths
    $configDir = if ($env:ADMIN_ROOT) { $env:ADMIN_ROOT } else { Join-Path $env:USERPROFILE '.admin' }
    $configFile = Join-Path $configDir '.env'

    # Create directories
    @('logs', 'profiles', 'config') | ForEach-Object {
        New-Item -ItemType Directory -Force -Path (Join-Path $configDir $_) | Out-Null
    }
    New-Item -ItemType Directory -Force -Path (Join-Path $configDir "logs\devices\$env:COMPUTERNAME") | Out-Null

    # Generate config content
    $config = @"
# Admin Skills Configuration
# Generated: $(Get-Date -Format 'o')

# Core Identity
DEVICE_NAME=$env:COMPUTERNAME
ADMIN_USER=$env:USERNAME
ADMIN_PLATFORM=windows
ADMIN_SHELL=powershell

# Paths (absolute paths only)
ADMIN_ROOT=$configDir
ADMIN_LOG_PATH=$configDir\logs
ADMIN_PROFILE_PATH=$configDir\profiles

# Sync (optional)
ADMIN_SYNC_ENABLED=false
"@

    Set-Content -Path $configFile -Value $config
    Write-Output "Configuration saved to: $configFile"
}
```

### Step 4: Create Initial Profile

Generate device profile.

#### Bash Mode

```bash
create_profile() {
    local profile_dir="${ADMIN_PROFILE_PATH:-$HOME/.admin/profiles}"
    local device="${DEVICE_NAME:-$(hostname)}"
    local profile_file="$profile_dir/$device.json"

    mkdir -p "$profile_dir"

    cat > "$profile_file" << EOF
{
  "schemaVersion": "2.0",
  "deviceInfo": {
    "name": "$device",
    "platform": "${ADMIN_PLATFORM:-$(detect_platform)}",
    "shell": "${ADMIN_SHELL:-bash}",
    "hostname": "$(hostname)",
    "user": "${ADMIN_USER:-$(whoami)}",
    "adminRoot": "${ADMIN_ROOT:-$HOME/.admin}",
    "lastUpdated": "$(date -Iseconds)"
  },
  "packageManagers": {},
  "installedTools": {},
  "installationHistory": [],
  "systemInfo": {},
  "paths": {},
  "managedServers": [],
  "cloudProviders": {},
  "syncSettings": {
    "enabled": ${ADMIN_SYNC_ENABLED:-false}
  },
  "customMetadata": {}
}
EOF

    echo "Profile created: $profile_file"
}
```

#### PowerShell Mode

```powershell
function New-AdminProfile {
    $profileDir = if ($env:ADMIN_PROFILE_PATH) { $env:ADMIN_PROFILE_PATH } else { Join-Path $env:USERPROFILE '.admin\profiles' }
    $device = if ($env:DEVICE_NAME) { $env:DEVICE_NAME } else { $env:COMPUTERNAME }
    $profileFile = Join-Path $profileDir "$device.json"
    $adminRoot = if ($env:ADMIN_ROOT) { $env:ADMIN_ROOT } else { Join-Path $env:USERPROFILE '.admin' }

    New-Item -ItemType Directory -Force -Path $profileDir | Out-Null

    $profile = @{
        schemaVersion = "2.0"
        deviceInfo = @{
            name = $device
            platform = "windows"
            shell = "powershell"
            hostname = $env:COMPUTERNAME
            user = $env:USERNAME
            adminRoot = $adminRoot
            lastUpdated = (Get-Date -Format 'o')
        }
        packageManagers = @{}
        installedTools = @{}
        installationHistory = @()
        systemInfo = @{}
        paths = @{}
        managedServers = @()
        cloudProviders = @{}
        syncSettings = @{
            enabled = $false
        }
        customMetadata = @{}
    }

    $profile | ConvertTo-Json -Depth 10 | Set-Content $profileFile
    Write-Output "Profile created: $profileFile"
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

**Bash:**
```bash
# Check config locations
ls -la ~/.admin/.env
ls -la .env.local

# Verify syntax
bash -n ~/.admin/.env
```

**PowerShell:**
```powershell
# Check config locations
Test-Path "$env:USERPROFILE\.admin\.env"
Test-Path ".env.local"

# View config content
Get-Content "$env:USERPROFILE\.admin\.env"
```

### Permission Issues

**Bash:**
```bash
# Fix ownership
chown -R $(whoami) ~/.admin

# Fix permissions
chmod 700 ~/.admin
chmod 600 ~/.admin/.env
chmod 755 ~/.admin/logs ~/.admin/profiles
```

**PowerShell:**
```powershell
# Check access
$adminPath = "$env:USERPROFILE\.admin"
Get-Acl $adminPath | Format-List

# Grant full control to current user (if needed)
$acl = Get-Acl $adminPath
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $env:USERNAME, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
)
$acl.SetAccessRule($rule)
Set-Acl $adminPath $acl
```

### Reset Configuration

**Bash:**
```bash
# Backup and reset
mv ~/.admin ~/.admin.backup.$(date +%Y%m%d)

# Re-run setup
# (admin skill will detect missing config and run setup)
```

**PowerShell:**
```powershell
# Backup and reset
$backupName = ".admin.backup.$(Get-Date -Format 'yyyyMMdd')"
Move-Item "$env:USERPROFILE\.admin" "$env:USERPROFILE\$backupName"

# Re-run setup
# (admin skill will detect missing config and run setup)
```

### Windows-Specific Issues

**PowerShell Version Too Old:**
```powershell
# Check version (need 7.x, not 5.1)
$PSVersionTable.PSVersion

# If 5.1, install PowerShell 7
winget install Microsoft.PowerShell

# Then run from pwsh.exe, not powershell.exe
```

**Environment Variables Not Found:**
```powershell
# Verify essential variables exist
$env:USERPROFILE   # Should be C:\Users\YourName
$env:COMPUTERNAME  # Should be your PC name
$env:USERNAME      # Should be your username

# If empty, you may be in a restricted environment
```

**Path Issues:**
```powershell
# Always use Join-Path, never string concatenation
# Wrong:
$path = "$env:USERPROFILE\.admin\logs"  # May fail with special chars

# Correct:
$path = Join-Path $env:USERPROFILE '.admin' 'logs'
```

**Execution Policy:**
```powershell
# Check policy
Get-ExecutionPolicy

# If Restricted, allow local scripts
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```
