# MCP Server Installation

## Contents
- Prerequisites
- Recommended NPX install
- Global npm install
- Local clone install
- Python MCP servers
- Step‑by‑step workflow (PowerShell)
- Step‑by‑step workflow (WSL/Bash)
- WSL path conversion
- Common MCP servers

---

## Prerequisites

- Node.js 18+ in PATH (`node --version`)
- npm in PATH (`npm --version`)
- Claude Desktop installed and closed before edits
- WSL users: `jq` installed for JSON edits (`sudo apt install jq`)

---

## Recommended NPX Install (Default)

Use NPX when you want the latest version with minimal setup.

Example server entry:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "C:/Users/<YourUsername>/Documents"
      ]
    }
  }
}
```

Pros: no global install, auto‑updates.  
Cons: first run requires internet and can be slower.

---

## Global npm Install

Use global installs for faster startup or offline operation.

Install:

```powershell
npm install -g @modelcontextprotocol/server-filesystem
```

Config example:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "node",
      "args": [
        "C:/Users/<YourUsername>/AppData/Roaming/npm/node_modules/@modelcontextprotocol/server-filesystem/dist/index.js",
        "C:/Users/<YourUsername>/Documents"
      ]
    }
  }
}
```

Pros: faster startup, works offline.  
Cons: manual updates.

---

## Local Clone Install (Development/Customization)

Use this when you need to edit server source or pin a fork.

```powershell
cd $env:MCP_ROOT  # e.g., D:/mcp or C:/mcp
git clone https://github.com/org/mcp-server.git
cd mcp-server
npm install
npm run build
```

Config example:

```json
{
  "mcpServers": {
    "server-name": {
      "command": "node",
      "args": ["<MCP_ROOT>/mcp-server/dist/index.js"]
    }
  }
}
```

Pros: full control.  
Cons: manual updates and build steps required.

---

## Python MCP Servers

Example entry:

```json
{
  "mcpServers": {
    "python-server": {
      "command": "python",
      "args": ["-m", "mcp_server_package"],
      "env": {
        "PYTHONPATH": "<path/to/server>"
      }
    }
  }
}
```

---

## MCP Installation Workflow (PowerShell)

Copy this checklist and follow in order:

1. Check registry (optional): `Get-Content $env:MCP_REGISTRY | ConvertFrom-Json`
2. Backup config:
   ```powershell
   $configPath = "$env:APPDATA/Claude/claude_desktop_config.json"
   Copy-Item $configPath "$configPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
   ```
3. Install server (default NPX, use one method):
   ```powershell
   # Default: NPX
   # Alternative: npm install -g @org/mcp-server-name
   # Alternative: local clone in $env:MCP_ROOT
   ```
4. Add server to config (example for local clone):
   ```powershell
   $config = Get-Content $configPath | ConvertFrom-Json
   $config.mcpServers | Add-Member -NotePropertyName "server-name" -NotePropertyValue @{
       command = "node"
       args = @("$env:MCP_ROOT/mcp-server/dist/index.js")
   }
   $config | ConvertTo-Json -Depth 10 | Set-Content $configPath
   ```
5. Log install using `log_admin` (from `admin`).
6. Restart Claude Desktop.
7. Verify tools appear in Claude.

---

## MCP Installation Workflow (WSL/Bash)

1. Get Windows config path:
   ```bash
   WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
   CONFIG_PATH="/mnt/c/Users/$WIN_USER/AppData/Roaming/Claude/claude_desktop_config.json"
   ```
2. Backup config:
   ```bash
   cp "$CONFIG_PATH" "${CONFIG_PATH}.backup.$(date +%Y%m%d-%H%M%S)"
   ```
3. Install server (default NPX, use one method):
   ```bash
   # Default: NPX
   # Alternative: npm install -g @org/mcp-server-name
   # Alternative: local clone on Windows FS:
   MCP_ROOT="/mnt/c/mcp"
   cd "$MCP_ROOT" && git clone https://github.com/org/mcp-server.git
   ```
4. Add server to config with Windows paths:
   ```bash
   jq '.mcpServers["server-name"] = {
     "command": "node",
     "args": ["C:/mcp/mcp-server/dist/index.js"]
   }' "$CONFIG_PATH" > "${CONFIG_PATH}.tmp" && mv "${CONFIG_PATH}.tmp" "$CONFIG_PATH"
   ```
5. Log install using `log_admin`.
6. Restart Claude Desktop:
   ```bash
   powershell.exe -Command "Stop-Process -Name 'Claude' -ErrorAction SilentlyContinue; Start-Process 'C:/Users/$WIN_USER/AppData/Local/Programs/Claude/Claude.exe'"
   ```
7. Verify tools appear in Claude.

---

## WSL Path Conversion

Claude Desktop runs on Windows, so all config paths must be Windows paths:

| WSL Path | Windows Path (for config) |
|----------|---------------------------|
| `/mnt/c/Users/user/...` | `C:/Users/user/...` |
| `/mnt/d/mcp/...` | `D:/mcp/...` |
| `$HOME/.ssh/id_rsa` | N/A (use Windows path) |

---

## Common MCP Servers

### Official servers

| Server | Package | Purpose |
|--------|---------|---------|
| Filesystem | `@modelcontextprotocol/server-filesystem` | File system access |
| GitHub | `@modelcontextprotocol/server-github` | GitHub API integration |
| GitLab | `@modelcontextprotocol/server-gitlab` | GitLab integration |
| Slack | `@modelcontextprotocol/server-slack` | Slack integration |
| Google Drive | `@modelcontextprotocol/server-gdrive` | Drive access |
| PostgreSQL | `@modelcontextprotocol/server-postgres` | Database queries |
| SQLite | `@modelcontextprotocol/server-sqlite` | SQLite database |
| Puppeteer | `@modelcontextprotocol/server-puppeteer` | Browser automation |
| Brave Search | `@modelcontextprotocol/server-brave-search` | Web search |
| Fetch | `@modelcontextprotocol/server-fetch` | HTTP requests |
| Memory | `@modelcontextprotocol/server-memory` | Persistent memory |
| Sequential Thinking | `@modelcontextprotocol/server-sequential-thinking` | Step‑by‑step reasoning |

### Community servers

| Server | Package/Repo | Purpose |
|--------|--------------|---------|
| Desktop Commander | `@anthropic-ai/desktop-commander` | File ops + terminals |
| Context7 | `context7-mcp` | Library documentation |
| Obsidian | Various | Notes integration |
| Notion | Various | Notion integration |

