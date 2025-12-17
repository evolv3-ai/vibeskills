---
name: admin
description: |
  Context-aware development companion that knows your machine and adapts instructions accordingly.
  Central orchestrator for system administration - reads device profile, routes to specialists.

  Use when: installing tools, managing servers, setting up dev environments, coordinating any admin task.
  The skill adapts to YOUR preferences (uv over pip, scoop over winget, etc.)
license: MIT
---

# Admin - Context-Aware DevOps Companion

**Purpose**: Read your device profile, adapt instructions to your setup, route to specialist skills.

## Core Value

When a GitHub repo says `pip install package`, this skill knows you prefer `uv` and suggests `uv pip install package` instead.

## Profile Location

```
$HOME/.admin/profiles/{HOSTNAME}.json    # Schema v3.0
```

**Profile contains**: installed tools, paths, preferences, servers, deployments, capabilities.

---

## Quick Start: Load Profile First

### PowerShell (Windows)
```powershell
. scripts/Load-Profile.ps1
Load-AdminProfile -Export
Show-AdminSummary
```

### Bash (WSL/Linux/macOS)
```bash
source scripts/load-profile.sh
load_admin_profile
show_admin_summary
```

---

## The Key Innovation: Preferences

```json
"preferences": {
  "python": { "manager": "uv", "reason": "Fast, modern, replaces pip+venv" },
  "node": { "manager": "npm", "reason": "Default, bun for speed" },
  "packages": { "manager": "scoop", "reason": "Portable installs" }
}
```

**Always check preferences before suggesting commands.**

---

## Adaptation Examples

| User Wants | README Says | Profile Shows | You Suggest |
|------------|-------------|---------------|-------------|
| Install Python pkg | `pip install x` | `preferences.python.manager: "uv"` | `uv pip install x` |
| Install Node pkg | `npm install` | `preferences.node.manager: "pnpm"` | `pnpm install` |
| Install CLI tool | `brew install x` | `preferences.packages.manager: "scoop"` | `scoop install x` |

---

## Profile Sections Quick Reference

| Section | What It Contains | When To Use |
|---------|------------------|-------------|
| `device` | OS, hostname, hardware | Platform detection |
| `paths` | Critical locations | Finding configs, skills, keys |
| `tools` | Installed tools + paths | Check before install |
| `preferences` | User choices | **Adapt commands** |
| `servers` | Managed servers | SSH, deployments |
| `deployments` | .env.local references | Load provider configs |
| `capabilities` | Quick flags | Route decisions |
| `issues` | Known problems | Avoid repeating fixes |
| `mcp` | MCP server configs | MCP troubleshooting |
| `wsl` | WSL config (Windows) | Cross-platform |

---

## Routing Rules

| Task Type | Route To | Requires |
|-----------|----------|----------|
| Server provisioning | `admin-devops` | - |
| OCI infrastructure | `admin-infra-oci` | OCI CLI configured |
| Hetzner infrastructure | `admin-infra-hetzner` | Hetzner token |
| Other clouds | `admin-infra-{provider}` | Provider credentials |
| Coolify installation | `admin-app-coolify` | Server access |
| KASM installation | `admin-app-kasm` | Server access |
| Windows system admin | `admin-windows` | Windows platform |
| WSL administration | `admin-wsl` | WSL present |
| Linux/macOS admin | `admin-unix` | Non-Windows |
| MCP servers | `admin-mcp` | - |

---

## Tool Installation Workflow

1. **Check if installed**: `profile.tools.{name}.present`
2. **If installed, check status**: `profile.tools.{name}.installStatus`
3. **If not installed**:
   - Check preferred manager: `profile.preferences.packages.manager`
   - Construct install command for that manager
4. **After install**:
   - Update `profile.tools.{name}` with version, path
   - Add entry to `profile.history`

---

## Server Operations Workflow

1. **List servers**: `profile.servers[]`
2. **Get SSH details**: `profile.servers[id].{username, host, keyPath, port}`
3. **Construct command**:
   ```bash
   ssh -i {keyPath} -p {port} {username}@{host}
   ```

---

## Deployment Workflow

1. **Find deployment**: `profile.deployments.{name}`
2. **Load env file**: `profile.deployments.{name}.envFile`
3. **Get provider**: `profile.deployments.{name}.provider`
4. **Get linked servers**: `profile.deployments.{name}.serverIds`

---

## Capability Checks

```javascript
// Before running PowerShell commands
if (!profile.capabilities.canRunPowershell) { /* route to bash */ }

// Before using Docker
if (!profile.capabilities.hasDocker) { /* offer to install */ }

// Before WSL operations
if (!profile.capabilities.hasWsl) { /* Windows-only alternative */ }
```

---

## References

- `references/device-profiles.md` - Profile management details
- `references/routing-guide.md` - Detailed routing logic
- `references/logging.md` - Centralized logging
- `references/first-run-setup.md` - Initial setup flow
- `references/cross-platform.md` - Windows ↔ WSL coordination

## Scripts

| Script | Purpose |
|--------|---------|
| `Load-Profile.ps1` | PowerShell profile loader |
| `load-profile.sh` | Bash profile loader |

## Templates

| File | Purpose |
|------|---------|
| `templates/profile-v3-example.json` | Complete profile example |
| `templates/env-template.env` | Universal deployment config |

## Related Skills

| Skill | Purpose |
|-------|---------|
| `admin-devops` | Server inventory & provisioning |
| `admin-infra-*` | Cloud provider provisioning |
| `admin-app-*` | Application deployment |
| `admin-windows` | Windows administration |
| `admin-wsl` | WSL administration |
| `admin-unix` | Linux/macOS administration |
| `admin-mcp` | MCP server management |
