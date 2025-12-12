# Tutorial 4 — Centralized Logging (Your Ops Memory)

## Outcome

You can read, interpret, and leverage centralized logs to stay consistent over time.

## What gets logged

Under `$ADMIN_LOG_PATH`:

- `operations.log`: all non‑install ops.
- `installations.log`: tool/package installs.
- `system-changes.log`: config or registry changes.
- `handoffs.log`: context switches required.
- `devices/<DEVICE_NAME>/history.log`: per‑device timeline.

The logs are shared across Windows + WSL when you use a shared `ADMIN_ROOT`.

## Log formats

Bash/zsh:

```bash
log_admin "SUCCESS" "installation" "Installed Docker" "version=24.x method=apt"
```

PowerShell:

```powershell
Log-Operation -Status "SUCCESS" -Operation "Install" -Details "Installed git via winget"
```

## How to use logs day‑to‑day

- Before changing something fragile, scan last relevant log lines.
- After any install or config change, log it.
- Use logs to generate a “what changed” summary for future you.

## Demo prompt

Paste:

```
Here are my last 20 admin log lines. Summarize what changed, what might break, and what I should verify next.
```

Expected behavior:

- Claude groups by category (installs, system changes, handoffs).
- It highlights any risky changes and suggested checks.

## Exercise

1. Do one small operation (edit `.zshrc`, update PATH, restart a service).
2. Make sure it is logged in `operations.log` or `system-changes.log`.
3. Ask Claude: “What should I do next to verify this change?”

Next: `05-device-profiles.md`.

