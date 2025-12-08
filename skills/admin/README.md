# Admin - System Administration Orchestrator

Central entry point for all system administration tasks. Detects platform context, routes to specialist skills, and maintains unified logging.

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

- windows, powershell, pwsh
- winget, scoop, chocolatey
- windows admin, windows setup
- registry, environment variable windows, PATH windows
- .wslconfig, windows terminal, wt

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

- **Platform Detection**: Auto-detects Windows, WSL, Linux, macOS
- **Smart Routing**: Delegates to specialist skills based on task type
- **Centralized Logging**: Unified log format across all admin operations
- **Device Profiles**: Track installed tools per device
- **Cross-Platform Coordination**: Handles Windows ↔ WSL handoffs

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

```bash
# First run creates ~/.admin/ structure
# Configuration: ~/.admin/.env or project .env.local

# View logs
cat ~/.admin/logs/operations.log

# View device profile
cat ~/.admin/profiles/$(hostname).json
```

## Related Skills

- admin-servers - Server inventory and provisioning
- admin-windows - Windows-specific administration
- admin-wsl - WSL/Linux-specific administration
