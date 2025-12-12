# MCP Diagnostics and Troubleshooting

## Contents
- Run diagnostics script
- Manual information collection
- Common problems and fixes
- Known issues prevention
- Setup checklist

---

## Run Diagnostics Script (Preferred)

Use the bundled script to collect full context:

```powershell
# Full system diagnostic
./scripts/diagnose-mcp.ps1

# Diagnose specific server
./scripts/diagnose-mcp.ps1 -ServerName "server-name"

# Save report
./scripts/diagnose-mcp.ps1 -OutputFile "mcp-report.md"

# JSON report
./scripts/diagnose-mcp.ps1 -Json -OutputFile "mcp-report.json"
```

Include the report in bug tickets.

---

## Manual Information Collection

### 1. System Environment

PowerShell:
```powershell
$PSVersionTable | Format-List
node --version
(Get-Command node).Source
npm --version
npm root -g
```

WSL/Bash:
```bash
echo "Shell: $SHELL"
echo "Bash version: $BASH_VERSION"
node --version
which node
npm --version
npm root -g
```

### 2. Config Validity

PowerShell:
```powershell
$configPath = "$env:APPDATA/Claude/claude_desktop_config.json"
Test-Path $configPath
Get-Content $configPath | ConvertFrom-Json | ConvertTo-Json -Depth 10
```

WSL/Bash:
```bash
WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
CONFIG_PATH="/mnt/c/Users/$WIN_USER/AppData/Roaming/Claude/claude_desktop_config.json"
cat "$CONFIG_PATH" | jq .
```

### 3. PATH Analysis

PowerShell:
```powershell
$env:PATH -split ';' | Where-Object { $_ -like "*npm*" -or $_ -like "*node*" }
```

WSL/Bash:
```bash
echo "$PATH" | tr ':' '\n' | grep -E 'npm|node'
cmd.exe /c "echo %PATH%" 2>/dev/null | tr ';' '\n' | grep -iE 'npm|node'
```

### 4. Test a Server Manually

PowerShell:
```powershell
npx.cmd -y @modelcontextprotocol/server-filesystem --help
node "<MCP_ROOT>/server-name/dist/index.js" --help
```

WSL/Bash:
```bash
npx -y @modelcontextprotocol/server-filesystem --help
node "/mnt/c/mcp/server-name/dist/index.js" --help
```

### 5. Check Claude Logs

PowerShell:
```powershell
Get-ChildItem "$env:APPDATA/Claude/logs" -Recurse
Get-Content "$env:APPDATA/Claude/logs/main.log" -Tail 50
Select-String -Path "$env:APPDATA/Claude/logs/*.log" -Pattern "mcp|MCP|error|ENOENT"
```

WSL/Bash:
```bash
LOG_DIR="/mnt/c/Users/$WIN_USER/AppData/Roaming/Claude/logs"
tail -50 "$LOG_DIR/main.log"
grep -iE 'mcp|error|ENOENT' "$LOG_DIR"/*.log
```

---

## Common Problems and Fixes

### MCP Server Not Starting

Symptoms: tools missing or server disabled.

PowerShell checklist:
```powershell
$config = Get-Content "$env:APPDATA/Claude/claude_desktop_config.json" | ConvertFrom-Json
$config.mcpServers.'server-name'
node "<MCP_ROOT>/server/dist/index.js" --help
node --version
cd "$env:MCP_ROOT/server" && npm install
```

Common fixes:
- Ensure `command` and path args exist.
- Use forward slashes in config paths.
- Restart Claude Desktop completely.

### "spawn ENOENT"

Cause: command executable not found.

Fix:
```powershell
$nodePath = (Get-Command node).Source
Write-Host "Use this path: $nodePath"
```

### Environment Variables Missing

Cause: malformed `env` block.

Fix:
```json
{
  "mcpServers": {
    "server": {
      "command": "node",
      "args": ["server.js"],
      "env": { "API_KEY": "your-key-here" }
    }
  }
}
```

### Works in Terminal but Not in Claude

Cause: different PATH/environment.

Fix: use absolute paths:
```json
{
  "command": "C:/Program Files/nodejs/node.exe",
  "args": ["C:/Users/<YourUsername>/AppData/Roaming/npm/node_modules/@org/server/dist/index.js"]
}
```

### Config Corrupted

Recovery:
```powershell
$configPath = "$env:APPDATA/Claude/claude_desktop_config.json"
$backups = Get-ChildItem "$env:APPDATA/Claude/*.backup.*" | Sort-Object LastWriteTime -Descending
Copy-Item $backups[0].FullName $configPath
```

---

## Known Issues Prevention

- Don’t edit config while Claude Desktop is running.
- Prefer NPX for quick setup; prefer global installs for offline use.
- After cloning a repo: always run `npm install && npm run build`.
- Use `npx.cmd` on Windows to avoid `spawn npx ENOENT`.

---

## Complete Setup Checklist

- [ ] Node.js 18+ installed and in PATH
- [ ] Claude Desktop installed
- [ ] Config file exists and is backed up
- [ ] MCP server installed (default NPX)
- [ ] Server added to config with absolute Windows paths
- [ ] Claude Desktop restarted
- [ ] Server tools visible in Claude
- [ ] Registry updated (if using)

