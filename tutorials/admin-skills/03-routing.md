# Tutorial 3 — How `admin` Routes Tasks

## Outcome

You can reliably trigger the right admin specialist and understand handoffs.

## The two detections that matter

`admin` detects:

- `ADMIN_PLATFORM`: windows, wsl, linux, macos.
- `ADMIN_SHELL`: powershell, bash, zsh.

Rule: **shell syntax wins over platform** (Git Bash on Windows counts as bash).

## Routing summary

From `skills/admin/SKILL.md`:

- Server/infrastructure/provisioning → `admin-devops`
  - then provider tasks → `admin-infra-*`
  - app deployment tasks → `admin-app-*`
- Windows system tasks → `admin-windows`
  - MCP tasks on Windows → `admin-mcp`
- WSL tasks → `admin-wsl`
- Native Linux/macOS tasks → `admin-unix`
- Logs/profiles/cross‑platform coordination → handled by `admin` itself

## Context validation and handoffs

If you ask for a Windows task while in WSL, `admin` must:

1. Log a handoff to `handoffs.log`.
2. Tell you to open a Windows terminal.
3. Stop instead of guessing Linux commands.

Same for Linux tasks asked from Windows.

## Demo prompt

Paste:

```
I’m in WSL right now. I need to increase WSL memory to 24GB by editing `.wslconfig`. What do you do? Include any handoff logging you would perform.
```

Expected behavior:

- Claude says this is a Windows task.
- It routes to `admin-windows`.
- It writes a HANDOFF log line and gives you Windows‑side steps.

## Exercise

Trigger two routes:

1. Ask in WSL: “Install Node LTS using winget.”  
2. Ask in Windows PowerShell: “Install PostgreSQL via apt.”

In each case, confirm you got a handoff and that it landed in `handoffs.log`.

Next: `04-logging.md`.
