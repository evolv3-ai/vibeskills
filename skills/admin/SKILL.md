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

**Purpose**: Central entry point for administration tasks. Detects platform + shell, validates context, routes to the right specialist skill, and maintains shared logs and device profiles.

## Navigation

Longer material is split into references (one level deep):
- Shell + platform detection: `references/shell-detection.md`
- First‑run setup and config loading: `references/first-run-setup.md`
- Routing rules and context handoff: `references/routing-guide.md`
- Centralized logging: `references/logging.md`
- Device profiles (installed tools, servers): `references/device-profiles.md`
- Cross‑platform coordination (Windows ↔ WSL): `references/cross-platform.md`
- PowerShell command cheatsheet: `references/powershell-commands.md`

## Core Rules

1. **Detect both platform and shell first**. `ADMIN_PLATFORM` and `ADMIN_SHELL` are separate; shell syntax wins over platform.
2. **Use shell‑appropriate syntax** regardless of host OS (Git Bash on Windows counts as bash).
3. **Validate context before routing**. If a task requires another context, log a handoff and stop.
4. **Handle profile/logging tasks directly** in `admin`; do not route these.
5. **Prefer forward‑slash Windows paths** in examples (`C:/Users/...`) to avoid shell ambiguity.

## Quick Start

1. Ensure `ADMIN_ROOT` exists. On Windows+WSL machines, this points to the Windows filesystem so logs/profiles are shared.
2. Load config from `.env.local` (project) or `$ADMIN_ROOT/.env` (global).
3. Determine `ADMIN_PLATFORM` and `ADMIN_SHELL` using helpers in `references/shell-detection.md`.
4. Route to a specialist skill using the routing summary below (details in `references/routing-guide.md`).

## Routing Summary

- **Server / infrastructure / provisioning** → `admin-devops`  
  May further route to `admin-infra-*` (OCI, Hetzner, DigitalOcean, Vultr, Linode, Contabo) or `admin-app-*` (Coolify, KASM).
- **Windows system administration** (PowerShell, winget/scoop, registry, `.wslconfig`, Windows Terminal) → `admin-windows`  
  Requires Windows context.
- **MCP / Claude Desktop config on Windows** → `admin-mcp`  
  Requires Windows context.
- **WSL administration** (Ubuntu in WSL, Docker Desktop integration, WSL profile) → `admin-wsl`  
  Requires WSL context.
- **Linux/macOS administration** (apt on Linux, brew on macOS, unix services) → `admin-unix`  
  Requires Linux/macOS context (non-WSL).
- **Profiles, logs, cross‑platform coordination** → handled here in `admin`.

## Key Environment Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `DEVICE_NAME` | Device identifier | `$(hostname)` / `$COMPUTERNAME` |
| `ADMIN_USER` | Primary admin username | `$(whoami)` / `$USERNAME` |
| `ADMIN_ROOT` | Shared admin directory | Windows: `C:/Users/<USERNAME>/.admin` • WSL: `/mnt/c/Users/<WIN_USER>/.admin` • Linux/macOS: `~/.admin` |
| `ADMIN_LOG_PATH` | Log directory | `$ADMIN_ROOT/logs` |
| `ADMIN_PROFILE_PATH` | Profiles directory | `$ADMIN_ROOT/profiles` |
| `ADMIN_PLATFORM` | Override auto‑detection | Auto‑detected |
| `ADMIN_SHELL` | Override shell detection | Auto‑detected |
| `WSL_DISTRO` | Target WSL distro | `Ubuntu-24.04` |

Full variable list: `assets/env-spec.txt` and `.env.template`.

## Logging Integration

- Bash mode uses `log_admin` (see `references/logging.md`).
- PowerShell mode uses `Log-Operation` (see `references/logging.md`).
- Always log handoffs (`LogType=handoff`) when a task requires switching contexts.

## Device Profiles

Profiles track installed tools, package managers, and managed servers per device. Use:
- `update_profile()` to create/locate the current device profile.
- `log_tool_install()` after installing tools to update `installedTools`.

Details and canonical functions: `references/device-profiles.md`.

## Related Skills

| Skill | Purpose |
|-------|---------|
| `admin-devops` | Server inventory & provisioning |
| `admin-infra-oci` | Oracle Cloud Infrastructure |
| `admin-infra-hetzner` | Hetzner Cloud |
| `admin-infra-digitalocean` | DigitalOcean |
| `admin-infra-vultr` | Vultr |
| `admin-infra-linode` | Linode/Akamai |
| `admin-infra-contabo` | Contabo |
| `admin-app-coolify` | Coolify PaaS deployments |
| `admin-app-kasm` | KASM Workspaces deployments |
| `admin-windows` | Windows administration |
| `admin-wsl` | WSL administration (WSL-only) |
| `admin-unix` | Linux/macOS administration (non-WSL) |
| `admin-mcp` | MCP server management |

## Common Error Patterns

- **Wrong context**: Task requires a different platform/shell. Follow handoff instructions logged in `handoffs.log`.
- **Missing config**: Create `.env.local` or run setup flow in `references/first-run-setup.md`.
- **Sub‑skill not installed**: Install with `./scripts/install-skill.sh <skill-name>`.

## Bundled Resources

- `assets/env-spec.txt` - Canonical environment variable specification
- `assets/profile-schema.json` - JSON Schema for device profiles
- `templates/profile.json` - Empty profile template
- `references/*` - Detailed behavior and workflows
