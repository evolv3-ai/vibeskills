---
name: admin-unix
description: |
  Administers macOS and Linux systems with shell-first commands. Covers Homebrew (macOS), apt (Linux),
  core filesystem/process/service operations, and centralized logging integration.

  Use when: managing packages on macOS/Linux, troubleshooting Unix tooling issues, administering services,
  or performing system maintenance outside of Windows/WSL contexts.

  Keywords: macos, linux, unix, homebrew, brew, apt, systemctl, journalctl, shell, bash, zsh
license: MIT
---

# Unix Admin (macOS + Linux)

**Purpose**: Administer native macOS and Linux systems using shell-first commands, consistent logging, and portable paths. This skill is intentionally separate from `admin-wsl` (WSL-only).

## Navigation

- Operations and troubleshooting: `references/OPERATIONS.md`

## Scope

### Handles

- macOS and Linux administration
- Package management:
  - macOS: Homebrew (`brew`)
  - Linux: apt (`apt`)
- Services/logs:
  - Linux: systemd (`systemctl`, `journalctl`)
  - macOS: Homebrew services (`brew services`) where applicable

### Does Not Handle

- WSL-specific administration (use `admin-wsl`)
- Windows administration (use `admin-windows`)
- MCP / Claude Desktop Windows config (use `admin-mcp`)

## Quick Start

### 1. Confirm platform and shell

```bash
uname -s
echo "$SHELL"
```

Expected:

- macOS: `Darwin`
- Linux: `Linux`

### 2. Load admin config (optional but recommended)

Prefer project-local `.env.local`, otherwise `$ADMIN_ROOT/.env`.

```bash
if [[ -f ".env.local" ]]; then
  source ".env.local"
elif [[ -n "${ADMIN_ROOT:-}" && -f "$ADMIN_ROOT/.env" ]]; then
  source "$ADMIN_ROOT/.env"
fi
```

### 3. Log the session start

Central logging lives in the `admin` skill (`admin/references/logging.md`).

```bash
log_admin "INFO" "operation" "Session started" "platform=$(uname -s) user=$USER"
```

## Critical Rules

- Prefer shell-appropriate syntax and safe quoting.
- Use forward slashes in all path examples.
- Avoid WSL-only paths like `/mnt/c/...` unless you are explicitly in WSL (that belongs to `admin-wsl`).
- Keep SKILL.md concise; load details from `references/`.

## Related Skills

- `admin`: orchestrator and centralized logging/profiles
- `admin-wsl`: WSL2 Ubuntu administration (WSL-only)
- `admin-windows`: Windows administration
- `admin-devops`: server inventory and provisioning

