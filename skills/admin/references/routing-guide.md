# Admin Routing Guide

Detailed routing rules for the admin orchestrator skill.

## Contents
- Routing Decision Flow
- Keyword → Skill Mapping
- Context Validation
- Handoff Protocol
- Skill Availability Check
- Examples

---

## Routing Decision Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                     ADMIN ROUTING ENGINE                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ Detect Platform │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
    ┌─────────┐        ┌─────────┐        ┌─────────┐
    │ Windows │        │   WSL   │        │  Linux  │
    │(non-WSL)│        │         │        │ /macOS  │
    └────┬────┘        └────┬────┘        └────┬────┘
         │                  │                  │
         ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                      TASK CLASSIFICATION                        │
└─────────────────────────────────────────────────────────────────┘
                              │
    ┌────────────┬────────────┼────────────┬────────────┐
    ▼            ▼            ▼            ▼            ▼
┌────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐
│ Server │ │ Windows  │ │WSL/Linux │ │   MCP    │ │ Profile │
│  Task  │ │  System  │ │  System  │ │   Task   │ │/Logging │
└───┬────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬────┘
    │           │            │            │            │
    ▼           ▼            ▼            ▼            ▼
┌────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐
│ admin- │ │  admin-  │ │  admin-  │ │  admin-  │ │  admin  │
│servers │ │ windows  │ │   wsl    │ │   mcp    │ │ (self)  │
└───┬────┘ └──────────┘ └──────────┘ └────┬─────┘ └─────────┘
    │                                      │
    ▼                                      │
┌────────────────┐                         │
│ Provider Task? │                         │
└───────┬────────┘                         │
        │ YES                              │
        ▼                                  │
┌────────────────┐                         │
│ admin-infra-*  │◄────────────────────────┘
│ (oci, hetzner, │    (MCP may need server)
│  vultr, etc.)  │
└───────┬────────┘
        │
        ▼
┌────────────────┐
│ App Deployment?│
└───────┬────────┘
        │ YES
        ▼
┌────────────────┐
│  admin-app-*   │
│(coolify, kasm) │
└────────────────┘
```

## Keyword → Skill Mapping

### Server Management

```yaml
keywords:
  - server, servers, provision, deploy, infrastructure
  - cloud, VPS, VM, instance, droplet, linode
  - inventory, "my servers", "server list"
route_to: admin-servers

sub_routing:
  - keywords: [oracle, oci, "oracle cloud", ARM64, "always free"]
    route_to: admin-infra-oci

  - keywords: [hetzner, hcloud, CAX, european]
    route_to: admin-infra-hetzner

  - keywords: [digitalocean, doctl, droplet]
    route_to: admin-infra-digitalocean

  - keywords: [vultr, "vultr-cli", "high frequency"]
    route_to: admin-infra-vultr

  - keywords: [linode, akamai, "linode-cli"]
    route_to: admin-infra-linode

  - keywords: [contabo, cntb, budget]
    route_to: admin-infra-contabo

  - keywords: [coolify, paas, "self-hosted heroku"]
    route_to: admin-app-coolify

  - keywords: [kasm, workspaces, vdi, "virtual desktop"]
    route_to: admin-app-kasm
```

### Windows Administration

```yaml
keywords:
  - powershell, pwsh, windows, winget, scoop, chocolatey
  - registry, "environment variable", PATH
  - ".wslconfig", "windows terminal"
  - "Get-", "Set-", "New-", "Remove-"  # PowerShell cmdlets
route_to: admin-windows
requires_context: windows

if_wrong_context: |
  This is a Windows task but you're in WSL/Linux.
  Please open a Windows terminal to proceed.

sub_routing:
  - keywords: [mcp, "model context protocol", "claude desktop", mcpServers]
    route_to: admin-mcp
```

### WSL/Linux Administration

```yaml
keywords:
  - wsl, ubuntu, apt, dpkg, linux, bash, zsh
  - docker, container, "docker-compose"
  - systemd, systemctl, journalctl
  - python, pip, uv, venv
  - node, npm, nvm
route_to: admin-wsl
requires_context: [wsl, linux, macos]

if_wrong_context: |
  This is a Linux/WSL task but you're in Windows.
  Please run: wsl -d Ubuntu-24.04
```

### Profile/Logging (handled by admin itself)

```yaml
keywords:
  - profile, "my tools", "installed tools"
  - log, logs, history, "what did I install"
  - sync, "cross-device", "my devices"
route_to: self
```

### Cross-Platform

```yaml
keywords:
  - "both windows and", "windows and wsl"
  - cross-platform, "on both"
route_to: self
note: Admin coordinates calling multiple sub-skills
```

## Context Validation

Before routing to a skill, validate the context is appropriate:

```bash
validate_context() {
    local target_skill="$1"
    local current_platform=$(detect_platform)

    case "$target_skill" in
        admin-windows|admin-mcp)
            if [[ "$current_platform" != "windows" ]]; then
                echo "HANDOFF: Open Windows terminal for this task"
                return 1
            fi
            ;;
        admin-wsl)
            if [[ "$current_platform" == "windows" ]]; then
                echo "HANDOFF: Run 'wsl -d ${WSL_DISTRO:-Ubuntu-24.04}' first"
                return 1
            fi
            ;;
        admin-servers|admin-infra-*|admin-app-*)
            # These work from any context
            return 0
            ;;
    esac
    return 0
}
```

### PowerShell Mode

```powershell
function Test-AdminContext {
    param([string]$TargetSkill)

    $platform = Get-AdminPlatform
    $wslDistro = if ($env:WSL_DISTRO) { $env:WSL_DISTRO } else { "Ubuntu-24.04" }

    switch -Wildcard ($TargetSkill) {
        'admin-windows' {
            if ($platform -ne 'windows') {
                Log-Operation -Status "HANDOFF" -Operation "Cross-Platform" `
                    -Details "Windows task requested from $platform. Open a Windows terminal to proceed." `
                    -LogType "handoff"
                return $false
            }
        }
        'admin-mcp' {
            if ($platform -ne 'windows') {
                Log-Operation -Status "HANDOFF" -Operation "Cross-Platform" `
                    -Details "MCP/Windows task requested from $platform. Open a Windows terminal to proceed." `
                    -LogType "handoff"
                return $false
            }
        }
        'admin-wsl' {
            if ($platform -eq 'windows') {
                Log-Operation -Status "HANDOFF" -Operation "Cross-Platform" `
                    -Details "WSL/Linux task requested from Windows. Run: wsl -d $wslDistro" `
                    -LogType "handoff"
                return $false
            }
        }
        'admin-servers' { return $true }
        'admin-infra-*' { return $true }
        'admin-app-*' { return $true }
        default { return $true }
    }

    return $true
}
```

## Handoff Protocol

When a task requires a different context:

1. **Log the handoff**:
   ```bash
   log_admin "HANDOFF" "handoff" "Task requires $target_context" "current=$current_platform"
   ```

2. **Provide clear instructions**:
   - For Windows: "Open Windows Terminal or PowerShell"
   - For WSL: "Run `wsl -d Ubuntu-24.04`"

3. **Tag for tracking**:
   - `[REQUIRES-WINADMIN]` - Must be done in Windows
   - `[REQUIRES-WSL-ADMIN]` - Must be done in WSL/Linux

## Skill Availability Check

Before routing, verify the target skill is installed:

```bash
check_skill_available() {
    local skill_name="$1"
    local skill_path="$HOME/.claude/skills/$skill_name"

    if [[ ! -d "$skill_path" ]]; then
        echo "Skill '$skill_name' not installed."
        echo "Install with: ./scripts/install-skill.sh $skill_name"
        return 1
    fi
    return 0
}
```

## Examples

### Example 1: "Install Docker"

1. Detect platform: WSL
2. Keywords: "install", "docker"
3. Match: admin-wsl
4. Context check: WSL context valid for admin-wsl
5. Route to: admin-wsl

### Example 2: "Update .wslconfig memory"

1. Detect platform: WSL
2. Keywords: ".wslconfig"
3. Match: admin-windows (Windows file)
4. Context check: FAIL - WSL context, need Windows
5. Log handoff: "Open Windows terminal to edit .wslconfig"
6. Tag: `[REQUIRES-WINADMIN]`

### Example 3: "Provision OCI server"

1. Detect platform: WSL
2. Keywords: "provision", "OCI", "server"
3. Match: admin-servers → admin-infra-oci
4. Context check: Pass (servers work from any context)
5. Route to: admin-servers (which routes to admin-infra-oci)

### Example 4: "What tools do I have installed?"

1. Detect platform: WSL
2. Keywords: "tools", "installed"
3. Match: admin (self) - profile query
4. Action: Read device profile, display installed tools
