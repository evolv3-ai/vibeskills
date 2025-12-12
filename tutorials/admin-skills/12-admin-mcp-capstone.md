# Tutorial 12 — MCP on Windows + Capstone

## Outcome

You can add MCP servers safely and run an end‑to‑end ops workflow using the whole suite.

## MCP basics (`admin-mcp`)

MCP servers for Claude Desktop are Windows‑side tasks. The skill handles:

- Installation (npx/npm/clone).
- Updating `claude_desktop_config.json`.
- Tracking installed servers in a registry.
- Diagnostics via `scripts/diagnose-mcp.ps1`.

Overview: `skills/admin-mcp/SKILL.md`.

## Demo prompt (MCP)

Paste in Windows PowerShell:

```
Install an MCP server of my choice, add it to Claude Desktop config, and record it in the MCP registry. Ask me which server and any paths you need.
```

Expected behavior:

- Claude confirms Windows context.
- It edits config with forward‑slash paths.
- It runs or suggests the diagnostic script if something fails.

## Capstone workflow

Paste:

```
End-to-end admin run:
1) Provision an OCI Always Free ARM server.
2) Add it to `.agent-devops.env` as COOLIFY01.
3) Install Coolify on it and secure HTTPS.
4) Deploy a demo app.
5) Update my device profile and summarize my last 20 logs.

Ask me for missing details at each step and log every major operation.
```

Expected behavior:

- Claude routes correctly at each step.
- It performs handoffs if context shifts are required.
- You end with a clean inventory entry, profile update, and log summary.

## Exercise

Run the capstone on your infra. If you stop early, still do:

- Step 1 and 2 for a new server.
- Ask for a “next‑steps plan” to finish later.

You’re done with the series.

