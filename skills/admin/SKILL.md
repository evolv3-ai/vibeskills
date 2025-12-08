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

Central entry point for all administration tasks. Detects your platform, routes to the right specialist skill, and maintains unified logging across all operations.

## Quick Start

### First-Run Detection

On first activation, if no configuration exists:

1. **Auto-detect environment**:
   ```bash
   # Platform detection
   if grep -q Microsoft /proc/version 2>/dev/null; then
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

### Loading Configuration

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

## Platform Detection

```bash
detect_platform() {
    # Check explicit override first
    if [[ -n "$ADMIN_PLATFORM" ]]; then
        echo "$ADMIN_PLATFORM"
        return
    fi

    # Auto-detect
    if grep -q Microsoft /proc/version 2>/dev/null; then
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
