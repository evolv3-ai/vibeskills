# Admin - System Administration Orchestrator

Central entry point for all system administration tasks. Detects platform context, routes to specialist skills, and maintains unified logging.

## Contents

- Auto-Trigger Keywords
- Features
- Sub-Skills
- Quick Start
- Related Skills

---

## Auto-Trigger Keywords

### Primary (always trigger admin)

- admin, administration, system admin, sysadmin
- devops, ops, operations
- manage system, system management
- device profile, my setup, my tools, installed tools
- admin log, admin history, what did I install

### Server Keywords (routes to admin-servers)

- server, servers, provision, deploy
- cloud, infrastructure, VPS, VM, instance
- inventory, my servers, server list
- OCI, oracle cloud, hetzner, digitalocean, vultr, linode, contabo
- always free tier, ARM64 server, budget VPS

### Windows Keywords (routes to admin-windows)

- windows, powershell, pwsh, PowerShell 7
- winget, scoop, chocolatey
- windows admin, windows setup
- registry, environment variable windows, PATH windows
- .wslconfig, windows terminal, wt
- Get-Content, Set-Content, New-Item (PowerShell cmdlets)
- $env:USERPROFILE, $env:COMPUTERNAME

### WSL/Linux Keywords (routes to admin-wsl)

- wsl, ubuntu, linux, bash, zsh
- apt, dpkg, snap
- docker, container, docker-compose
- systemd, systemctl, journalctl
- python, pip, uv, venv
- node, npm, nvm, pnpm

### MCP Keywords (routes via admin-windows)

- mcp, model context protocol
- claude desktop, mcpServers
- mcp server, mcp install

### Application Keywords (routes via admin-servers)

- coolify, self-hosted, paas, self-hosted heroku
- kasm, workspaces, vdi, virtual desktop

### Cross-Platform Keywords

- sync, cross-device, my devices
- both windows and, windows and wsl
- cross-platform, on both systems

## Features

- **Shell Detection**: Auto-detects PowerShell, Bash, Zsh and uses correct syntax
- **Platform Detection**: Auto-detects Windows, WSL, Linux, macOS
- **Smart Routing**: Delegates to specialist skills based on task type
- **Centralized Logging**: Unified log format across all admin operations
- **Device Profiles**: Track installed tools per device
- **Cross-Platform Coordination**: Handles Windows ↔ WSL handoffs with clear instructions

## Sub-Skills

| Skill | Domain |
|-------|--------|
| admin-servers | Server inventory & provisioning |
| admin-infra-* | Cloud providers (OCI, Hetzner, DO, Vultr, Linode, Contabo) |
| admin-app-* | Applications (Coolify, KASM) |
| admin-windows | Windows administration |
| admin-wsl | WSL/Linux administration |
| admin-mcp | MCP server management |

## Quick Start

**Bash/WSL/Linux:**
```bash
# First run creates ~/.admin/ structure
mkdir -p ~/.admin/{logs,profiles,config}

# View logs
cat ~/.admin/logs/operations.log

# View device profile
cat ~/.admin/profiles/$(hostname).json
```

**PowerShell (Windows):**
```powershell
# First run creates %USERPROFILE%\.admin\ structure
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.admin\logs","$env:USERPROFILE\.admin\profiles","$env:USERPROFILE\.admin\config"

# View logs
Get-Content "$env:USERPROFILE\.admin\logs\operations.log"

# View device profile
Get-Content "$env:USERPROFILE\.admin\profiles\$env:COMPUTERNAME.json"
```

## Related Skills

- admin-servers - Server inventory and provisioning
- admin-windows - Windows-specific administration
- admin-wsl - WSL/Linux-specific administration
