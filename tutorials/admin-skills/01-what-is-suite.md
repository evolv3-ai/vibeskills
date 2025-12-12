# Tutorial 1 — The Admin Skills Suite: What It Is

## Outcome

You understand what the admin skills are, why they exist, and which problems each one handles.

## The big idea

The suite is designed like a real ops team:

- `admin` is your dispatcher and shared memory.
- Specialist skills handle fragile domains (cloud providers, Windows, WSL, apps, MCP).

This keeps `SKILL.md` files concise and makes Claude’s context usage predictable.

## What’s in the suite

**Orchestrator**

- `admin`: detects platform and shell, validates context, routes tasks, writes logs, updates device profiles.

**Inventory and provisioning**

- `admin-devops`: keeps a `.agent-devops.env` inventory and coordinates provisioning across providers and apps.

**Cloud providers**

- `admin-infra-oci`
- `admin-infra-hetzner`
- `admin-infra-digitalocean`
- `admin-infra-vultr`
- `admin-infra-linode`
- `admin-infra-contabo`

All provider skills follow the same high‑level workflow; only the CLI/API details change.

**Apps**

- `admin-app-coolify`: install and run Coolify PaaS.
- `admin-app-kasm`: install and run KASM Workspaces (VDI).

**OS specialists**

- `admin-windows`: Windows 11 + PowerShell 7.x, winget/scoop, registry PATH, Windows‑side handoffs.
- `admin-wsl`: WSL-only Ubuntu admin (apt, Docker Desktop integration, uv, systemd).
- `admin-unix`: native Linux/macOS admin (Linux apt + systemd; macOS Homebrew).

**MCP**

- `admin-mcp`: install/configure MCP servers in Claude Desktop on Windows.

## When to start with `admin`

Default: always start with `admin` unless you’re already in a specialist flow.

Examples:

- “Provision a server on OCI.” → `admin` routes to `admin-devops` → `admin-infra-oci`.
- “Fix winget not found in PATH.” → `admin` routes to `admin-windows`.
- “Docker socket missing in WSL.” → `admin` routes to `admin-wsl`.
- “brew install jq on my Mac.” → `admin` routes to `admin-unix`.

## Demo prompt

Paste this into Claude:

```
I’m learning the admin skills suite. For each task below, tell me which skill should handle it and why:

1) Install uv in WSL and add it to PATH
2) Provision a cheap ARM VPS on OCI Always Free
3) Deploy Coolify on that server and set up HTTPS
4) Fix "Get-Content not recognized" error on Windows
5) Add an MCP server to Claude Desktop
```

Expected behavior: Claude explains routing, notes context requirements (Windows vs WSL), and points you to the right specialist skill.

## Exercise

Write 5 tasks from your own work. For each one:

1. Guess which skill triggers.
2. Ask Claude using `admin`.
3. Compare your guess to the routing.

Next: `02-install-first-run.md`.
