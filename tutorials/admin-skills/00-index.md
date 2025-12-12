# Admin Skills Tutorials (Vibe Coder Members Area)

Welcome to the Admin Skills tutorial series. This suite gives you a portable, model‑friendly system for real‑world devops and system administration with Claude.

## Who this series is for

- Vibe coders shipping apps on their own infra.
- Builders who want repeatable, logged, cross‑device admin workflows.
- Anyone using Windows + WSL or multiple cloud providers.

## What you’ll learn

By the end, you’ll be able to:

- Use the `admin` orchestrator to route any ops task to the right specialist skill.
- Set up a shared `.admin` root so Windows and WSL stay in sync.
- Keep centralized logs and device profiles that act as your “ops memory”.
- Manage a multi‑provider server inventory in `.agent-devops.env`.
- Provision infra, deploy Coolify/KASM, and manage MCP servers safely.

## Prerequisites

- Claude Skills installed and enabled.
- This repo (or your fork) available locally.
- Skills symlinked/installed under your Claude skills directory, e.g. `~/.claude/skills/`.
- Basic comfort with either bash/zsh or PowerShell.

## Suite map

- `admin` — orchestrator (platform/shell detection, routing, logging, profiles).
- `admin-devops` — inventory and provisioning entry point.
- `admin-infra-*` — provider specialists: OCI, Hetzner, DigitalOcean, Vultr, Linode, Contabo.
- `admin-app-*` — app specialists: Coolify, KASM.
- `admin-windows` — Windows + PowerShell admin.
- `admin-wsl` — WSL-only Linux admin.
- `admin-unix` — native Linux/macOS admin (non-WSL).
- `admin-mcp` — MCP server management on Windows.

## Course order

1. `01-what-is-suite.md`
2. `02-install-first-run.md`
3. `03-routing.md`
4. `04-logging.md`
5. `05-device-profiles.md`
6. `06-admin-devops-inventory.md`
7. `07-admin-infra-pattern.md`
8. `08-admin-infra-oci.md`
9. `09-admin-app-coolify.md`
10. `10-admin-app-kasm.md`
11. `11-admin-windows-vs-wsl.md`
12. `12-admin-mcp-capstone.md`

## How to use these lessons

Each tutorial includes:

- A concrete outcome.
- A guided, copy‑paste‑ready prompt to run in Claude.
- What “good output” looks like.
- A short exercise to lock in the pattern.

If you get stuck, open the linked skill docs (e.g., `skills/admin/SKILL.md`) and compare your situation to the examples.
