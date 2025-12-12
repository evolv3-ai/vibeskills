# Unix Admin (macOS + Linux)

Administers native macOS and Linux systems with shell-first commands, centralized logging, and portable examples.

## Contents

- Auto-Trigger Keywords
- What This Skill Does
- When to Use This Skill
- What This Skill Avoids
- References

---

## Auto-Trigger Keywords

- macos, osx, darwin, homebrew, brew
- linux, ubuntu, debian, apt, apt-get
- systemctl, journalctl, service status
- shell, bash, zsh, permissions, chmod, chown
- "command not found", "permission denied", "service failed"

## What This Skill Does

- Provides macOS Homebrew workflows and Linux apt workflows.
- Uses centralized logging patterns from `admin`.
- Avoids WSL- or Windows-specific assumptions.

## When to Use This Skill

Use when the current platform is:

- `macos` (Darwin)
- `linux` (native Linux, not WSL)

If you are in WSL, use `admin-wsl` instead.

## What This Skill Avoids

- Windows tasks (use `admin-windows`)
- WSL tasks (use `admin-wsl`)
- MCP/Claude Desktop config (use `admin-mcp`)

## References

- `SKILL.md`
- `references/OPERATIONS.md`

