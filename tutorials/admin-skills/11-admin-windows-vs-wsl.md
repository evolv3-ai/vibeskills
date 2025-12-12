# Tutorial 11 — Windows vs WSL vs Unix Admin

## Outcome

You consistently use the right OS specialist and avoid cross‑shell mistakes.

## `admin-windows` covers

- PowerShell 7.x only.
- winget/scoop/choco/npm global installs.
- Persistent PATH via registry.
- Windows Terminal and `.wslconfig`.

Overview: `skills/admin-windows/SKILL.md`.

## `admin-wsl` covers (WSL-only)

- bash/zsh syntax.
- apt, Docker, uv/venv.
- systemd services.
- WSL profile and shared `.admin` root.

Overview: `skills/admin-wsl/SKILL.md`.

## `admin-unix` covers (native Linux/macOS)

- Native Linux (non-WSL): apt + systemd patterns.
- macOS: Homebrew patterns (including Apple Silicon PATH notes).
- Shell-first admin tasks that are not Windows and not WSL.

Overview: `skills/admin-unix/SKILL.md`.

## Common handoff boundaries

Always defer to Windows:

- `.wslconfig` edits.
- Windows package installs.
- MCP/Claude Desktop config.
- Registry changes.

Always defer to WSL/Linux:

- apt installs.
- Docker containers in WSL.
- Linux service management.

Always defer to native Linux/macOS:

- “On my Mac…” or “on my Ubuntu laptop (not WSL)…” tasks.
- Homebrew installs and troubleshooting.
- Linux apt/systemd work on native Linux machines.

## Demo prompt

Paste from Windows PowerShell:

```
Install Node LTS using winget, ensure npm global bin paths are persistent, and log the operation.
```

Then paste from WSL:

```
Install uv via the recommended method, confirm it’s on PATH, and log the operation.
```

Expected behavior:

- Each specialist uses correct shell syntax.
- If you ask the wrong one, it handoffs instead of guessing.

## Exercise

Try to trick it:

1. From WSL, ask to “install PowerShell via winget.”
2. From Windows, ask to “install postgresql via apt.”

Confirm you get HANDOFF entries both times.

Next: `12-admin-mcp-capstone.md`.
