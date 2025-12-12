---
name: admin-mcp
description: |
  Installs and configures MCP (Model Context Protocol) servers for Claude Desktop. Supports both PowerShell (Windows native) and Bash/WSL workflows. Covers installation workflows, claude_desktop_config.json management, MCP registry patterns, and the three CLI tools: Desktop Commander, Win-CLI, and Claude Code MCP.

  Use when: installing MCP servers, configuring Claude Desktop, choosing between MCP CLI tools, managing MCP registries, or troubleshooting "MCP server not starting", "tool not found", "spawn ENOENT" errors.
license: MIT
---

# MCP Server Management

**Status**: Production Ready  
**Last Updated**: 2025-12-12  
**Dependencies**: Node.js 18+, Claude Desktop, admin-windows skill

Central skill for installing, configuring, and troubleshooting MCP servers used by Claude Desktop on Windows/WSL.

## Navigation

Read these as needed (one level deep):
- Installation workflows and patterns: [references/INSTALLATION.md](references/INSTALLATION.md)
- Config file locations and structure: [references/CONFIGURATION.md](references/CONFIGURATION.md)
- Desktop Commander / Win‑CLI / Claude Code MCP: [references/CLI_TOOLS.md](references/CLI_TOOLS.md)
- Registry format and update script: [references/REGISTRY.md](references/REGISTRY.md)
- Diagnostics and common fixes: [references/TROUBLESHOOTING.md](references/TROUBLESHOOTING.md)

## Quick Start (10 minutes)

1. Verify prerequisites:
   - `node --version` → 18+
   - `npm --version`
   - Claude Desktop installed
   - WSL users: `jq` installed

2. Locate and backup Claude Desktop config:
   - Windows: `%APPDATA%/Claude/claude_desktop_config.json`
   - WSL path to Windows file:
     ```bash
     WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
     CONFIG_PATH="/mnt/c/Users/$WIN_USER/AppData/Roaming/Claude/claude_desktop_config.json"
     cp "$CONFIG_PATH" "${CONFIG_PATH}.backup.$(date +%Y%m%d-%H%M%S)"
     ```

3. Add your first server using the default NPX pattern:
   ```json
   {
     "mcpServers": {
       "filesystem": {
         "command": "npx",
         "args": ["-y", "@modelcontextprotocol/server-filesystem", "C:/Users/<YourUsername>/Documents"]
       }
     }
   }
   ```
   Full install methods and examples are in `references/INSTALLATION.md`.

4. Restart Claude Desktop and verify tools appear.

## Critical Rules

- Close Claude Desktop before editing config.
- Always take a timestamped backup first.
- Use absolute Windows paths inside `claude_desktop_config.json` even when editing from WSL.
- Prefer one install method per server (default NPX; global npm/local clone only when needed).
- Restart Claude Desktop after changes.
- Log installs using `log_admin` and optionally update your MCP registry.

## Bundled Resources

Scripts in `scripts/`:
- `add-mcp-server.ps1` – add a server entry to config.
- `backup-config.ps1` – backup config with rotation.
- `diagnose-mcp.ps1` – generate diagnostics report.

Templates in `templates/`:
- `claude-desktop-config.json`
- `mcp-registry.json`
- `win-cli-config.json`

## Official Docs

- MCP protocol: https://modelcontextprotocol.io/
- MCP servers: https://github.com/modelcontextprotocol/servers
- Claude Desktop: https://claude.ai/download
- Desktop Commander: https://github.com/anthropics/desktop-commander

## Package Versions (snapshot)

```json
{
  "dependencies": {
    "node": ">=18.0.0",
    "@modelcontextprotocol/server-filesystem": "^0.6.x",
    "@anthropic-ai/desktop-commander": "^0.1.x"
  }
}
```
