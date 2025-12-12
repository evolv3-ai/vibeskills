# Claude Desktop Configuration for MCP

## Contents
- Config locations
- Config structure
- Field reference
- Safe editing rules
- Minimal example
- Validation checks

---

## Config Locations

```
Windows: %APPDATA%/Claude/claude_desktop_config.json
macOS:   ~/Library/Application Support/Claude/claude_desktop_config.json
Linux:   ~/.config/Claude/claude_desktop_config.json
WSL:     /mnt/c/Users/<USERNAME>/AppData/Roaming/Claude/claude_desktop_config.json
```

PowerShell:
```powershell
$configPath = "$env:APPDATA/Claude/claude_desktop_config.json"
```

WSL/Bash:
```bash
WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
CONFIG_PATH="/mnt/c/Users/$WIN_USER/AppData/Roaming/Claude/claude_desktop_config.json"
```

---

## Config Structure

```json
{
  "mcpServers": {
    "server-name": {
      "command": "node",
      "args": ["path/to/server.js"],
      "env": {
        "ENV_VAR": "value"
      },
      "disabled": false
    }
  }
}
```

---

## Field Reference

| Field | Required | Description |
|-------|----------|-------------|
| `command` | Yes | Executable to run (node, npx, python, etc.) |
| `args` | Yes | Array of arguments passed to command |
| `env` | No | Environment variables for the server |
| `disabled` | No | Set `true` to disable without removing |

---

## Safe Editing Rules

- Close Claude Desktop before editing the config.
- Always create a timestamped backup first.
- Use absolute paths everywhere.
- From WSL, edit the Windows file but keep Windows paths (`C:/...`) inside JSON.
- Restart Claude Desktop after any change.

---

## Minimal Example

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

---

## Validation Checks

PowerShell:
```powershell
$config = Get-Content $configPath | ConvertFrom-Json
$config.mcpServers.Keys
```

WSL/Bash:
```bash
cat "$CONFIG_PATH" | jq '.mcpServers | keys'
```

If JSON parsing fails, restore the last backup.

