# Device Profiles - v3.0

Device profiles provide **context-aware assistance** by tracking your installed tools, preferences, servers, and capabilities.

## Profile Location

```
$HOME/.admin/profiles/{HOSTNAME}.json
```

- **Windows**: `C:\Users\{username}\.admin\profiles\{COMPUTERNAME}.json`
- **WSL**: `/mnt/c/Users/{win_user}/.admin/profiles/{hostname}.json`
- **Linux/macOS**: `~/.admin/profiles/{hostname}.json`

## Schema Version

Current: **v3.0**

Schema file: `assets/profile-schema.json`

## Profile Structure

```json
{
  "schemaVersion": "3.0",
  "device": { },        // Hardware, OS, hostname
  "paths": { },         // Critical file locations
  "packageManagers": { }, // Available package managers
  "tools": { },         // Installed tools with full context
  "preferences": { },   // User choices - THE KEY INNOVATION
  "wsl": { },           // WSL config (Windows only)
  "docker": { },        // Docker setup
  "mcp": { },           // MCP server inventory
  "servers": [ ],       // Managed remote servers
  "deployments": { },   // .env.local file references
  "issues": { },        // Known problems
  "history": [ ],       // Action log
  "capabilities": { }   // Quick routing flags
}
```

## Key Sections

### preferences - Smart Adaptation

The `preferences` section enables the core value proposition: adapting instructions to your setup.

```json
"preferences": {
  "python": {
    "manager": "uv",
    "reason": "Fast, modern, replaces pip+venv+poetry"
  },
  "node": {
    "manager": "npm",
    "reason": "Default, bun for speed-critical scripts"
  },
  "packages": {
    "manager": "scoop",
    "reason": "Portable installs, good for dev tools"
  }
}
```

**Usage**: Before suggesting `pip install x`, check `profile.preferences.python.manager`. If it's `uv`, suggest `uv pip install x` instead.

### tools - Full Context

Each tool has rich metadata for AI guidance:

```json
"tools": {
  "uv": {
    "present": true,
    "version": "0.9.5",
    "installedVia": "cargo",
    "path": "C:/Users/Owner/.local/bin/uv.exe",
    "shimPath": null,
    "configPath": null,
    "lastChecked": "2025-12-14T00:00:00Z",
    "installStatus": "working",
    "notes": "PREFERRED Python package manager. Use instead of pip."
  }
}
```

**Key fields**:
- `path` / `shimPath`: Where to find the executable
- `installStatus`: `working`, `failed`, `pending`, `deprecated`
- `notes`: **AI guidance** - explicit instructions for this tool

### servers - Remote Management

```json
"servers": [
  {
    "id": "cool-two",
    "name": "COOL_TWO",
    "host": "85.239.242.228",
    "port": 22,
    "username": "root",
    "authMethod": "key",
    "keyPath": "C:/Users/Owner/.ssh/id_rsa_openssh",
    "provider": "contabo",
    "role": "coolify",
    "status": "active"
  }
]
```

**Usage**: Construct SSH commands from profile data instead of asking user every time.

### deployments - .env.local References

```json
"deployments": {
  "vibeskills-oci": {
    "envFile": "D:/vibeskills-demo/.env.local",
    "type": "coolify",
    "provider": "oci",
    "status": "active",
    "serverIds": ["cool-oci-1"]
  }
}
```

**Two-file architecture**: Profile stores device context, `.env.local` stores deployment secrets. Profile **references** env files to avoid duplication.

### capabilities - Quick Routing

```json
"capabilities": {
  "canRunPowershell": true,
  "canRunBash": true,
  "hasWsl": true,
  "hasDocker": true,
  "hasSsh": true,
  "mcpEnabled": true
}
```

**Usage**: Check capabilities before routing to specialist skills.

## Loading Profiles

### PowerShell

```powershell
. scripts/Load-Profile.ps1
Load-AdminProfile -Export
Show-AdminSummary

# Access data
$AdminProfile.preferences.python.manager  # "uv"
Get-AdminTool "docker"
Get-AdminServer -Role "coolify"
Get-AdminPreference "python"
Test-AdminCapability "hasWsl"
```

### Bash

```bash
source scripts/load-profile.sh
load_admin_profile
show_admin_summary

# Access data
get_preferred_manager python  # "uv"
get_admin_tool "docker"
get_admin_server role "coolify"
ssh_to_server "cool-two"
has_capability "hasWsl"
```

## Updating Profiles

After installing a tool:

```powershell
# PowerShell
$AdminProfile.tools["newtool"] = @{
    present = $true
    version = "1.0.0"
    installedVia = "scoop"
    path = "C:/Users/Owner/scoop/apps/newtool/current/newtool.exe"
    installStatus = "working"
    lastChecked = (Get-Date).ToString("o")
}
$AdminProfile | ConvertTo-Json -Depth 10 | Set-Content $AdminProfile.paths.deviceProfile
```

After encountering an issue:

```powershell
$AdminProfile.issues.current += @{
    id = "issue-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    tool = "python"
    issue = "Version conflict with system Python"
    priority = "high"
    status = "pending"
    created = (Get-Date).ToString("o")
}
```

## Migration

From older profile formats:

```powershell
# Preview
.\scripts\Migrate-Profile.ps1 -DryRun

# Execute
.\scripts\Migrate-Profile.ps1
```

## Best Practices

1. **Always load profile first** - Before any operation
2. **Check preferences** - Never assume pip/npm/etc.
3. **Use notes field** - Add AI guidance for tricky tools
4. **Track issues** - Avoid repeating failed approaches
5. **Keep history** - Log installations for debugging
6. **Reference env files** - Don't duplicate secrets in profile
