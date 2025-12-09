---
name: admin
description: |
  Central orchestrator for system administration. Detects context (Windows/WSL/Linux/macOS),
  routes to specialist skills, provides centralized logging and device profiles.

  Use when: managing servers, administering Windows or Linux systems, tracking installed tools,
  coordinating cross-platform tasks, or troubleshooting any admin-related issues.
license: MIT
---

# Admin - System Administration Orchestrator

Central entry point for all administration tasks. Detects your platform and shell, routes to the right specialist skill, and maintains unified logging across all operations.

## Environment Detection (CRITICAL - Do This First)

Before running ANY commands, determine BOTH the platform AND the shell. These are separate concepts:

- **ADMIN_PLATFORM**: The operating system (windows, wsl, linux, macos)
- **ADMIN_SHELL**: The command interpreter (bash, powershell, zsh, cmd)

### Why Both Matter

| Scenario | ADMIN_PLATFORM | ADMIN_SHELL | Command Syntax | Available Tools |
|----------|----------------|-------------|----------------|-----------------|
| WSL Ubuntu | wsl | bash | Bash | apt, docker |
| Windows PowerShell | windows | powershell | PowerShell | winget, scoop |
| Windows Git Bash | windows | bash | Bash | winget (via cmd) |
| macOS Terminal | macos | zsh | Bash-like | brew |
| Linux | linux | bash | Bash | apt, dnf, etc. |

### Detecting Shell (ADMIN_SHELL)

**Quick test to determine shell:**
- Try: `echo $BASH_VERSION`
- If it returns a version → `ADMIN_SHELL=bash`
- If it fails or returns empty on Windows → `ADMIN_SHELL=powershell`

#### Bash Detection
```bash
# If this works, you're in bash/zsh
if [[ -n "$BASH_VERSION" ]]; then
    ADMIN_SHELL="bash"
elif [[ -n "$ZSH_VERSION" ]]; then
    ADMIN_SHELL="zsh"
fi
```

#### PowerShell Detection
```powershell
# If this works, you're in PowerShell
if ($PSVersionTable) {
    $ADMIN_SHELL = "powershell"
}
```

### Detecting Platform (ADMIN_PLATFORM)

#### From Bash
```bash
if grep -qi microsoft /proc/version 2>/dev/null; then
    ADMIN_PLATFORM="wsl"
elif [[ "$OS" == "Windows_NT" ]]; then
    ADMIN_PLATFORM="windows"  # Git Bash on Windows
elif [[ "$(uname -s)" == "Darwin" ]]; then
    ADMIN_PLATFORM="macos"
else
    ADMIN_PLATFORM="linux"
fi
```

#### From PowerShell
```powershell
$ADMIN_PLATFORM = "windows"  # PowerShell only runs on Windows (or cross-platform pwsh)
```

### Shell Mode Reference

| ADMIN_SHELL | Command Syntax | Path Variables | Path Separator |
|-------------|----------------|----------------|----------------|
| **bash** | `mkdir -p`, `$HOME` | `$HOME`, `$USER` | `/` |
| **zsh** | Same as bash | `$HOME`, `$USER` | `/` |
| **powershell** | `New-Item`, `$env:VAR` | `$env:USERPROFILE` | `\` |

**IMPORTANT**: Use the syntax for your detected ADMIN_SHELL, regardless of ADMIN_PLATFORM.

Example: Git Bash on Windows uses Bash syntax, even though platform is "windows".

---

## Quick Start

### First-Run Detection

On first activation, if no configuration exists:

#### Bash Mode (WSL/Linux/macOS)

1. **Auto-detect environment**:
   ```bash
   # Platform detection (case-insensitive grep for WSL)
   if grep -qi microsoft /proc/version 2>/dev/null; then
       ADMIN_PLATFORM="wsl"
   elif [[ "$OS" == "Windows_NT" ]]; then
       ADMIN_PLATFORM="windows"
   elif [[ "$(uname -s)" == "Darwin" ]]; then
       ADMIN_PLATFORM="macos"
   else
       ADMIN_PLATFORM="linux"
   fi
   ```

2. **Create default configuration**:
   ```bash
   DEVICE_NAME="${DEVICE_NAME:-$(hostname)}"
   ADMIN_USER="${ADMIN_USER:-$(whoami)}"
   ADMIN_ROOT="${ADMIN_ROOT:-$HOME/.admin}"
   mkdir -p "$ADMIN_ROOT"/{logs,profiles,config}
   ```

3. **Guide user through setup** (see `references/first-run-setup.md`)

#### PowerShell Mode (Windows Native)

1. **Auto-detect environment**:
   ```powershell
   # Platform is always Windows in PowerShell mode
   $ADMIN_PLATFORM = "windows"
   ```

2. **Create default configuration**:
   ```powershell
   $DEVICE_NAME = if ($env:DEVICE_NAME) { $env:DEVICE_NAME } else { $env:COMPUTERNAME }
   $ADMIN_USER = if ($env:ADMIN_USER) { $env:ADMIN_USER } else { $env:USERNAME }
   $ADMIN_ROOT = if ($env:ADMIN_ROOT) { $env:ADMIN_ROOT } else { Join-Path $env:USERPROFILE '.admin' }

   # Create directories
   @('logs', 'profiles', 'config') | ForEach-Object {
       New-Item -ItemType Directory -Force -Path (Join-Path $ADMIN_ROOT $_) | Out-Null
   }
   New-Item -ItemType Directory -Force -Path (Join-Path $ADMIN_ROOT "logs\devices\$DEVICE_NAME") | Out-Null
   ```

3. **Guide user through setup** (see `references/first-run-setup.md`)

### Loading Configuration

#### Bash Mode

```bash
# Load config with fallback chain
if [[ -f ".env.local" ]]; then
    source .env.local
elif [[ -f "$HOME/.admin/.env" ]]; then
    source "$HOME/.admin/.env"
fi

# Apply defaults
DEVICE_NAME="${DEVICE_NAME:-$(hostname)}"
ADMIN_USER="${ADMIN_USER:-$(whoami)}"
ADMIN_ROOT="${ADMIN_ROOT:-$HOME/.admin}"
ADMIN_LOG_PATH="${ADMIN_LOG_PATH:-$ADMIN_ROOT/logs}"
ADMIN_PROFILE_PATH="${ADMIN_PROFILE_PATH:-$ADMIN_ROOT/profiles}"
```

#### PowerShell Mode

```powershell
# Load config with fallback chain
$envFile = $null
if (Test-Path '.env.local') {
    $envFile = '.env.local'
} elseif (Test-Path (Join-Path $env:USERPROFILE '.admin\.env')) {
    $envFile = Join-Path $env:USERPROFILE '.admin\.env'
}

if ($envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^([^#][^=]*)=(.*)$') {
            [Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim(), 'Process')
        }
    }
}

# Apply defaults
$DEVICE_NAME = if ($env:DEVICE_NAME) { $env:DEVICE_NAME } else { $env:COMPUTERNAME }
$ADMIN_USER = if ($env:ADMIN_USER) { $env:ADMIN_USER } else { $env:USERNAME }
$ADMIN_ROOT = if ($env:ADMIN_ROOT) { $env:ADMIN_ROOT } else { Join-Path $env:USERPROFILE '.admin' }
$ADMIN_LOG_PATH = if ($env:ADMIN_LOG_PATH) { $env:ADMIN_LOG_PATH } else { Join-Path $ADMIN_ROOT 'logs' }
$ADMIN_PROFILE_PATH = if ($env:ADMIN_PROFILE_PATH) { $env:ADMIN_PROFILE_PATH } else { Join-Path $ADMIN_ROOT 'profiles' }
```

## Platform Detection

### Bash Mode

```bash
detect_platform() {
    # Check explicit override first
    if [[ -n "$ADMIN_PLATFORM" ]]; then
        echo "$ADMIN_PLATFORM"
        return
    fi

    # Auto-detect (case-insensitive grep for WSL)
    if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
    elif [[ "$OS" == "Windows_NT" ]]; then
        echo "windows"
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        echo "macos"
    else
        echo "linux"
    fi
}
```

### PowerShell Mode

```powershell
function Get-AdminPlatform {
    # Check explicit override first
    if ($env:ADMIN_PLATFORM) {
        return $env:ADMIN_PLATFORM
    }

    # In PowerShell, we're always on Windows
    return "windows"
}

# Usage: $platform = Get-AdminPlatform
```

## Routing Logic

### Decision Tree

```
START
│
├─ SERVER task? (provision, deploy, cloud, infrastructure)
│  └─ YES → admin-servers
│     └─ May route to: admin-infra-* or admin-app-*
│
├─ WINDOWS SYSTEM task? (powershell, winget, registry, .wslconfig)
│  ├─ In WSL context? → Log handoff, instruct to use Windows terminal
│  └─ In Windows → admin-windows
│     └─ MCP-related? → admin-mcp
│
├─ WSL/LINUX task? (apt, docker, bash, systemd)
│  ├─ In Windows (non-WSL)? → Log handoff, instruct to enter WSL
│  └─ In WSL/Linux → admin-wsl
│
└─ PROFILE/LOGGING task?
   └─ Handle directly (don't route)
```

### Keyword Routing

| Keywords | Route To | Context Required |
|----------|----------|------------------|
| server, provision, deploy, cloud, VPS | admin-servers | Any |
| oracle, oci, ARM64, always free | admin-infra-oci | Any |
| hetzner, hcloud, CAX | admin-infra-hetzner | Any |
| digitalocean, doctl, droplet | admin-infra-digitalocean | Any |
| vultr, high frequency | admin-infra-vultr | Any |
| linode, akamai | admin-infra-linode | Any |
| contabo, budget | admin-infra-contabo | Any |
| coolify, paas, self-hosted | admin-app-coolify | Any |
| kasm, vdi, virtual desktop | admin-app-kasm | Any |
| powershell, winget, scoop, registry | admin-windows | Windows |
| mcp, claude desktop, mcpServers | admin-mcp | Windows |
| wsl, ubuntu, apt, docker, systemd | admin-wsl | WSL/Linux |
| profile, my tools, logs, sync | self (admin) | Any |

### Context Validation

Before routing, validate context compatibility:

#### Bash Mode

```bash
validate_context() {
    local task_type="$1"
    local current_platform=$(detect_platform)

    case "$task_type" in
        windows)
            if [[ "$current_platform" == "wsl" || "$current_platform" == "linux" ]]; then
                log_admin "HANDOFF" "handoff" "Windows task requested from $current_platform" \
                    "Open Windows terminal to proceed"
                return 1
            fi
            ;;
        wsl|linux)
            if [[ "$current_platform" == "windows" ]]; then
                log_admin "HANDOFF" "handoff" "WSL/Linux task requested from Windows" \
                    "Run: wsl -d ${WSL_DISTRO:-Ubuntu-24.04}"
                return 1
            fi
            ;;
    esac
    return 0
}
```

#### PowerShell Mode

```powershell
function Test-AdminContext {
    param([string]$TaskType)

    $platform = Get-AdminPlatform

    switch ($TaskType) {
        'wsl' {
            if ($platform -eq 'windows') {
                Log-Admin -Level "HANDOFF" -Category "handoff" `
                    -Message "WSL/Linux task requested from Windows" `
                    -Details "Run: wsl -d $($env:WSL_DISTRO ?? 'Ubuntu-24.04')"
                return $false
            }
        }
        'windows' {
            # Already in Windows - no handoff needed
            return $true
        }
    }
    return $true
}
```

## Centralized Logging

### Log Structure

```
$ADMIN_LOG_PATH/
├── operations.log        # General operations
├── installations.log     # Software installations
├── system-changes.log    # Configuration changes
├── handoffs.log          # Cross-platform handoffs
└── devices/
    └── $DEVICE_NAME/
        └── history.log   # All logs for this device
```

### Log Format

```
ISO8601 [DEVICE][PLATFORM] LEVEL: message | details
```

Example:
```
2025-12-08T14:30:00-05:00 [WOPR3][wsl] SUCCESS: Package installed | apt install postgresql-client
2025-12-08T14:31:00-05:00 [WOPR3][wsl] HANDOFF: Windows task required | task=update .wslconfig
```

### Bash Logging Function

```bash
log_admin() {
    local level="$1"      # INFO|SUCCESS|ERROR|WARN|HANDOFF
    local category="$2"   # operation|installation|system-change|handoff
    local message="$3"
    local details="${4:-}"

    local timestamp=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)
    local device="${DEVICE_NAME:-$(hostname)}"
    local platform="${ADMIN_PLATFORM:-$(detect_platform)}"
    local log_dir="${ADMIN_LOG_PATH:-$HOME/.admin/logs}"

    local log_line="$timestamp [$device][$platform] $level: $message"
    [[ -n "$details" ]] && log_line="$log_line | $details"

    mkdir -p "$log_dir/devices/$device" 2>/dev/null

    echo "$log_line" >> "$log_dir/${category}s.log"
    echo "$log_line" >> "$log_dir/devices/$device/history.log"

    [[ "$level" == "ERROR" ]] && echo "ERROR: $message" >&2
}
```

### PowerShell Logging Function

```powershell
function Log-Admin {
    param(
        [ValidateSet("INFO","SUCCESS","ERROR","WARN","HANDOFF")]
        [string]$Level,
        [ValidateSet("operation","installation","system-change","handoff")]
        [string]$Category,
        [string]$Message,
        [string]$Details = ""
    )

    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"
    $device = if ($env:DEVICE_NAME) { $env:DEVICE_NAME } else { $env:COMPUTERNAME }
    $platform = if ($env:ADMIN_PLATFORM) { $env:ADMIN_PLATFORM } else { "windows" }
    $logDir = if ($env:ADMIN_LOG_PATH) { $env:ADMIN_LOG_PATH } else { "$env:USERPROFILE\.admin\logs" }

    $logLine = "$timestamp [$device][$platform] ${Level}: $Message"
    if ($Details) { $logLine += " | $Details" }

    New-Item -ItemType Directory -Force -Path "$logDir\devices\$device" | Out-Null

    Add-Content -Path "$logDir\${Category}s.log" -Value $logLine
    Add-Content -Path "$logDir\devices\$device\history.log" -Value $logLine

    if ($Level -eq "ERROR") { Write-Error $Message }
}
```

## Device Profiles

### Profile Location

```
$ADMIN_PROFILE_PATH/$DEVICE_NAME.json
```

### Profile Schema

See `assets/profile-schema.json` for full JSON Schema.

Key sections:
- `deviceInfo`: name, platform, hostname, user, lastUpdated
- `installedTools`: tool name → version, installedVia, path, lastChecked
- `managedServers`: array of server IDs from admin-servers inventory

### Profile Operations

**Create/Update Profile**:
```bash
update_profile() {
    local profile_path="${ADMIN_PROFILE_PATH:-$HOME/.admin/profiles}/${DEVICE_NAME:-$(hostname)}.json"
    mkdir -p "$(dirname "$profile_path")"

    # Create if doesn't exist
    if [[ ! -f "$profile_path" ]]; then
        cat > "$profile_path" << EOF
{
  "deviceInfo": {
    "name": "${DEVICE_NAME:-$(hostname)}",
    "platform": "$(detect_platform)",
    "hostname": "$(hostname)",
    "user": "${ADMIN_USER:-$(whoami)}",
    "lastUpdated": "$(date -Iseconds)"
  },
  "installedTools": {},
  "managedServers": []
}
EOF
    fi

    echo "$profile_path"
}
```

**Log Tool Installation**:
```bash
log_tool_install() {
    local tool="$1"
    local version="$2"
    local method="$3"  # apt, brew, winget, npm, etc.

    local profile_path=$(update_profile)

    # Update installedTools section (requires jq)
    if command -v jq &>/dev/null; then
        jq --arg tool "$tool" \
           --arg ver "$version" \
           --arg method "$method" \
           --arg ts "$(date -Iseconds)" \
           '.installedTools[$tool] = {version: $ver, installedVia: $method, lastChecked: $ts}' \
           "$profile_path" > "${profile_path}.tmp" && mv "${profile_path}.tmp" "$profile_path"
    fi

    log_admin "SUCCESS" "installation" "Installed $tool" "version=$version method=$method"
}
```

## Cross-Platform Coordination

### Handoff Tags

When a task requires switching contexts:

- `[REQUIRES-WINADMIN]` - Must be done in Windows terminal
- `[REQUIRES-WSL-ADMIN]` - Must be done in WSL/Linux

### Path Conversion

| Context | Windows Path | WSL Path |
|---------|--------------|----------|
| Windows user home | `C:\Users\$USERNAME` | `/mnt/c/Users/$USERNAME` |
| WSL home from Windows | `\\wsl$\$DISTRO\home\$USER` | `~` or `/home/$USER` |
| Shared admin root | `$WIN_USER_HOME\.admin` | `$HOME/.admin` |

### Common Cross-Platform Tasks

| Task | Windows Handles | WSL Handles |
|------|-----------------|-------------|
| .wslconfig | ✓ | Read-only |
| Docker Desktop | ✓ (installer) | ✓ (CLI) |
| SSH keys | Both | Both |
| Git config | Both | Both |
| Claude Desktop MCP | ✓ | - |

## Sub-Skills Reference

| Skill | Purpose | Invoked When |
|-------|---------|--------------|
| admin-servers | Server inventory & provisioning | "provision server", "my servers" |
| admin-infra-oci | Oracle Cloud Infrastructure | "oracle", "oci", "always free" |
| admin-infra-hetzner | Hetzner Cloud | "hetzner", "hcloud", "CAX" |
| admin-infra-digitalocean | DigitalOcean | "digitalocean", "droplet" |
| admin-infra-vultr | Vultr | "vultr" |
| admin-infra-linode | Linode/Akamai | "linode", "akamai" |
| admin-infra-contabo | Contabo | "contabo", "budget vps" |
| admin-app-coolify | Coolify PaaS | "coolify", "self-hosted paas" |
| admin-app-kasm | KASM Workspaces | "kasm", "vdi", "workspaces" |
| admin-windows | Windows administration | "powershell", "winget", "registry" |
| admin-wsl | WSL/Linux administration | "apt", "docker", "systemd" |
| admin-mcp | MCP server management | "mcp", "claude desktop" |

## Configuration Reference

See `.env.template` for all available variables.

### Required Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `DEVICE_NAME` | Unique device identifier | `$(hostname)` |
| `ADMIN_USER` | Primary admin username | `$(whoami)` |
| `ADMIN_ROOT` | Central admin directory | `~/.admin` |

### Optional Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `ADMIN_PLATFORM` | Override auto-detection | Auto-detected |
| `ADMIN_LOG_PATH` | Log directory | `$ADMIN_ROOT/logs` |
| `ADMIN_PROFILE_PATH` | Profiles directory | `$ADMIN_ROOT/profiles` |
| `ADMIN_SYNC_ENABLED` | Enable cross-device sync | `false` |
| `ADMIN_SYNC_PATH` | Synced folder (Dropbox, etc.) | - |

## Error Patterns

### 1. Skill Not Found

**Error**: Sub-skill not installed
**Solution**:
```bash
./scripts/install-skill.sh admin-servers
```

### 2. Wrong Context

**Error**: Windows task from WSL (or vice versa)
**Solution**: Follow handoff instructions in log

### 3. Missing Configuration

**Error**: Required variable not set
**Solution**: Copy `.env.template` to `.env.local` and fill values

### 4. Permission Denied on Logs

**Error**: Cannot write to log directory
**Solution**:
```bash
mkdir -p "${ADMIN_LOG_PATH:-$HOME/.admin/logs}"
chmod 755 "${ADMIN_LOG_PATH:-$HOME/.admin/logs}"
```

## Bundled Resources

- `assets/env-spec.txt` - Canonical environment variable specification
- `assets/profile-schema.json` - JSON Schema for device profiles
- `references/routing-guide.md` - Detailed routing rules
- `references/first-run-setup.md` - New user setup guide
- `templates/profile.json` - Empty profile template
