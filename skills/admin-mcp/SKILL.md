---
name: admin-mcp
description: |
  Install and configure MCP (Model Context Protocol) servers for Claude Desktop on Windows. Covers installation workflows, claude_desktop_config.json management, MCP registry patterns, and the three CLI tools: Desktop Commander, Win-CLI, and Claude Code MCP.

  Use when: installing MCP servers, configuring Claude Desktop, choosing between MCP CLI tools, managing MCP registries, or troubleshooting "MCP server not starting", "tool not found", "spawn ENOENT" errors.
license: MIT
---

# MCP Server Management

**Status**: Production Ready
**Last Updated**: 2025-12-06
**Dependencies**: Node.js 18+, Claude Desktop, admin-windows skill
**Latest Versions**: Claude Desktop 0.7.x, Node.js 22.x

---

## Quick Start (10 Minutes)

### 1. Verify Prerequisites

```powershell
# Check Node.js (required for most MCP servers)
node --version   # Should be 18+

# Check npm
npm --version

# Verify Claude Desktop installed
Test-Path "$env:APPDATA\Claude\claude_desktop_config.json"
```

### 2. Locate Config File

```powershell
# Claude Desktop config location
$configPath = "$env:APPDATA\Claude\claude_desktop_config.json"

# Read current config
Get-Content $configPath | ConvertFrom-Json | ConvertTo-Json -Depth 10
```

### 3. Install Your First MCP Server

```powershell
# Example: Install filesystem MCP server
npm install -g @modelcontextprotocol/server-filesystem

# Add to Claude Desktop config (see Configuration section)
```

---

## Critical Rules

### Always Do

- Backup `claude_desktop_config.json` before editing
- Use absolute paths for all executables and arguments
- Restart Claude Desktop after config changes
- Test MCP servers in isolation before adding to config
- Log all MCP installations to your registry

### Never Do

- Use relative paths in MCP server configurations
- Edit config while Claude Desktop is running (can corrupt)
- Install MCP servers without verifying Node.js compatibility
- Mix npx and global npm installations for same server
- Forget to escape backslashes in JSON (`\\` not `\`)

---

## Claude Desktop Configuration

### Config File Location

```
Windows: %APPDATA%\Claude\claude_desktop_config.json
macOS:   ~/Library/Application Support/Claude/claude_desktop_config.json
Linux:   ~/.config/Claude/claude_desktop_config.json
```

PowerShell:
```powershell
$configPath = "$env:APPDATA\Claude\claude_desktop_config.json"
```

### Config File Structure

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

### Configuration Fields

| Field | Required | Description |
|-------|----------|-------------|
| `command` | Yes | Executable to run (node, npx, python, etc.) |
| `args` | Yes | Array of arguments passed to command |
| `env` | No | Environment variables for the server |
| `disabled` | No | Set `true` to disable without removing |

---

## MCP Server Installation Patterns

### Pattern 1: NPX (Recommended for Quick Setup)

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "C:/Users/Owner/Documents"
      ]
    }
  }
}
```

**Pros**: Always uses latest version, no global install needed
**Cons**: Slower startup, requires internet on first run

### Pattern 2: Global NPM Install

```powershell
# Install globally
npm install -g @modelcontextprotocol/server-filesystem
```

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "node",
      "args": [
        "C:/Users/Owner/AppData/Roaming/npm/node_modules/@modelcontextprotocol/server-filesystem/dist/index.js",
        "C:/Users/Owner/Documents"
      ]
    }
  }
}
```

**Pros**: Faster startup, works offline
**Cons**: Manual updates needed

### Pattern 3: Local Clone (For Development/Customization)

```powershell
# Clone to MCP directory
cd D:/mcp
git clone https://github.com/org/mcp-server-name.git
cd mcp-server-name
npm install
npm run build
```

```json
{
  "mcpServers": {
    "server-name": {
      "command": "node",
      "args": ["D:/mcp/mcp-server-name/dist/index.js"]
    }
  }
}
```

**Pros**: Full control, can modify source
**Cons**: Manual updates, more disk space

### Pattern 4: Python MCP Server

```json
{
  "mcpServers": {
    "python-server": {
      "command": "python",
      "args": ["-m", "mcp_server_package"],
      "env": {
        "PYTHONPATH": "D:/path/to/server"
      }
    }
  }
}
```

---

## The Three MCP CLI Tools

Windows systems commonly use three MCP servers for CLI operations:

### 1. Desktop Commander (Primary for Local Work)

**Package**: `@anthropic-ai/desktop-commander`
**Best For**: File operations, code editing, persistent sessions

```json
{
  "mcpServers": {
    "desktop-commander": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/desktop-commander"]
    }
  }
}
```

**Tools Provided**:
- `read_file` - Read file contents
- `write_file` - Write/create files
- `edit_block` - Surgical code edits with diff
- `list_directory` - List directory contents
- `search_files` - Search for files by pattern
- `get_file_info` - File metadata
- `start_process` - Start persistent process
- `interact_with_process` - Send input to process
- `read_process_output` - Get process output
- `get_config` / `set_config_value` - Configure server

**Key Features**:
- Persistent process sessions (maintains state)
- Better PATH handling
- Diff-based code editing
- Interactive REPL support

### 2. Win-CLI (SSH and Multi-Shell)

**Best For**: SSH operations, remote servers, multiple shell types

```json
{
  "mcpServers": {
    "win-cli": {
      "command": "node",
      "args": [
        "D:/mcp/win-cli-mcp-server/dist/index.js",
        "--config",
        "D:/mcp/win-cli-mcp-server/config.json"
      ]
    }
  }
}
```

**Tools Provided**:
- `execute_command` - Run shell command
- `ssh_execute` - Run command on remote server
- `ssh_connect` - Connect to SSH server
- `list_ssh_connections` - List configured SSH connections

**Key Features**:
- Multiple shell support (PowerShell, CMD, Git Bash)
- Pre-configured SSH connections
- Isolated shell sessions

**Win-CLI Config** (`config.json`):
```json
{
  "shells": {
    "powershell": {
      "enabled": true,
      "command": "C:\\Program Files\\PowerShell\\7\\pwsh.exe",
      "args": ["-Command"]
    },
    "cmd": {
      "enabled": true,
      "command": "cmd.exe",
      "args": ["/c"]
    }
  },
  "ssh": {
    "connections": [
      {
        "id": "server-1",
        "host": "192.168.1.100",
        "username": "admin",
        "privateKeyPath": "C:/Users/Owner/.ssh/id_rsa"
      }
    ]
  },
  "security": {
    "allowedPaths": ["D:/", "C:/Users/Owner"],
    "blockedCommands": ["format", "shutdown", "rm -rf /"],
    "commandTimeout": 60
  }
}
```

### 3. Claude Code MCP (Complex Multi-File Tasks)

**Package**: `@anthropic-ai/claude-code-mcp`
**Best For**: Complex refactoring, git workflows, multi-file edits

```json
{
  "mcpServers": {
    "claude-code-mcp": {
      "command": "node",
      "args": ["D:/mcp/claude-code-mcp/dist/index.js"],
      "env": {
        "CLAUDE_CLI_PATH": "C:/Users/Owner/AppData/Roaming/npm/claude.cmd"
      }
    }
  }
}
```

**Tools Provided**:
- `claude_code` - Execute Claude Code CLI with prompt

**Key Features**:
- Wraps official Claude Code CLI
- Auto-bypasses permissions for automation
- Best for complex multi-file operations

**When to Use**:
```javascript
// Complex refactoring
claude_code({
  prompt: "Refactor all API calls to use async/await",
  workFolder: "D:/project"
})

// Git workflows
claude_code({
  prompt: "Stage changes, commit with message, push to develop",
  workFolder: "D:/project"
})
```

### Tool Selection Guide

| Task | Recommended Tool | Reason |
|------|-----------------|--------|
| Read/write files | Desktop Commander | Native file tools |
| Edit code blocks | Desktop Commander | Diff-based editing |
| Run local commands | Desktop Commander | Better PATH handling |
| SSH to remote server | Win-CLI | SSH support |
| Use specific shell | Win-CLI | Multi-shell support |
| Complex refactoring | Claude Code MCP | Multi-file awareness |
| Git operations | Claude Code MCP | Git workflow support |
| Interactive REPL | Desktop Commander | Persistent sessions |

---

## MCP Installation Workflow

### Step-by-Step Process

```powershell
# 1. Check if server exists in registry (if using registry)
$registry = Get-Content $env:MCP_REGISTRY | ConvertFrom-Json
$registry.mcpServers.'server-name'

# 2. Backup current config
$configPath = "$env:APPDATA\Claude\claude_desktop_config.json"
Copy-Item $configPath "$configPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"

# 3. Install server (choose method)
# Option A: NPX (no install needed)
# Option B: Global npm
npm install -g @org/mcp-server-name
# Option C: Local clone
cd D:/mcp && git clone https://github.com/org/mcp-server.git

# 4. Read current config
$config = Get-Content $configPath | ConvertFrom-Json

# 5. Add server to config
$config.mcpServers | Add-Member -NotePropertyName "server-name" -NotePropertyValue @{
    command = "node"
    args = @("D:/mcp/mcp-server/dist/index.js")
}

# 6. Save config
$config | ConvertTo-Json -Depth 10 | Set-Content $configPath

# 7. Update registry (if using)
# Add entry to mcp-registry.json

# 8. Log installation
Log-Operation -Status "SUCCESS" -Operation "MCP Install" -Details "Installed server-name" -LogType "installation"

# 9. Restart Claude Desktop
Stop-Process -Name "Claude" -ErrorAction SilentlyContinue
Start-Process "$env:LOCALAPPDATA\Programs\Claude\Claude.exe"

# 10. Test server
# Open Claude Desktop and verify server tools are available
```

---

## MCP Registry Pattern

Maintain a central registry of installed MCP servers:

### Registry Schema

```json
{
  "lastUpdated": "2025-12-06T12:00:00Z",
  "mcpServers": {
    "desktop-commander": {
      "installed": true,
      "installDate": "2025-10-01",
      "installMethod": "npx",
      "version": "latest",
      "purpose": "File operations and persistent sessions",
      "configPath": null,
      "notes": "Primary tool for local file operations"
    },
    "win-cli": {
      "installed": true,
      "installDate": "2025-10-01",
      "installMethod": "local-clone",
      "version": "1.0.0",
      "purpose": "SSH and multi-shell support",
      "configPath": "D:/mcp/win-cli-mcp-server/config.json",
      "notes": "Deprecated upstream, using local fork"
    },
    "filesystem": {
      "installed": true,
      "installDate": "2025-10-15",
      "installMethod": "npm-global",
      "version": "0.6.2",
      "purpose": "Filesystem access for specific directories",
      "configPath": null,
      "notes": "Limited to Documents folder"
    }
  }
}
```

### Registry Update Script

```powershell
function Update-McpRegistry {
    param(
        [string]$ServerName,
        [string]$InstallMethod,
        [string]$Version,
        [string]$Purpose,
        [string]$ConfigPath,
        [string]$Notes
    )

    $registryPath = $env:MCP_REGISTRY
    $registry = Get-Content $registryPath | ConvertFrom-Json

    $entry = @{
        installed = $true
        installDate = (Get-Date -Format "yyyy-MM-dd")
        installMethod = $InstallMethod
        version = $Version
        purpose = $Purpose
        configPath = $ConfigPath
        notes = $Notes
    }

    if ($registry.mcpServers.PSObject.Properties.Name -contains $ServerName) {
        $registry.mcpServers.$ServerName = $entry
    } else {
        $registry.mcpServers | Add-Member -NotePropertyName $ServerName -NotePropertyValue $entry
    }

    $registry.lastUpdated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    $registry | ConvertTo-Json -Depth 10 | Set-Content $registryPath

    Write-Host "Updated registry: $ServerName" -ForegroundColor Green
}
```

---

## Common MCP Servers

### Official Anthropic Servers

| Server | Package | Purpose |
|--------|---------|---------|
| Filesystem | `@modelcontextprotocol/server-filesystem` | File system access |
| GitHub | `@modelcontextprotocol/server-github` | GitHub API integration |
| GitLab | `@modelcontextprotocol/server-gitlab` | GitLab API integration |
| Slack | `@modelcontextprotocol/server-slack` | Slack integration |
| Google Drive | `@modelcontextprotocol/server-gdrive` | Google Drive access |
| PostgreSQL | `@modelcontextprotocol/server-postgres` | Database queries |
| SQLite | `@modelcontextprotocol/server-sqlite` | SQLite database |
| Puppeteer | `@modelcontextprotocol/server-puppeteer` | Browser automation |
| Brave Search | `@modelcontextprotocol/server-brave-search` | Web search |
| Fetch | `@modelcontextprotocol/server-fetch` | HTTP requests |
| Memory | `@modelcontextprotocol/server-memory` | Persistent memory |
| Sequential Thinking | `@modelcontextprotocol/server-sequential-thinking` | Step-by-step reasoning |

### Community Servers

| Server | Package/Repo | Purpose |
|--------|--------------|---------|
| Desktop Commander | `@anthropic-ai/desktop-commander` | File ops + terminals |
| Context7 | `context7-mcp` | Library documentation |
| Obsidian | Various | Note integration |
| Notion | Various | Notion integration |

---

## Comprehensive Diagnostics

When MCP servers fail, collect comprehensive diagnostic information using the bundled script:

### Run Full Diagnostics

```powershell
# Full system diagnostic
.\scripts\diagnose-mcp.ps1

# Diagnose specific server
.\scripts\diagnose-mcp.ps1 -ServerName "desktop-commander"

# Save report to file
.\scripts\diagnose-mcp.ps1 -OutputFile "mcp-report.md"

# JSON output for automation
.\scripts\diagnose-mcp.ps1 -Json -OutputFile "mcp-report.json"
```

### What the Diagnostic Collects

| Category | Information |
|----------|-------------|
| **System** | OS version, PowerShell version, user context |
| **Node.js** | Version, path, npm path, global modules location |
| **PATH** | User PATH, session PATH, npm presence |
| **Config** | File location, validity, all configured servers |
| **Server Details** | Command, args, env vars, file existence checks |
| **MCP Directory** | Local clones, build status, node_modules presence |
| **Processes** | Claude Desktop status, running Node processes |
| **Logs** | Claude Desktop log location, recent entries, MCP errors |
| **Issues** | Automated detection with recommended fixes |

### Manual Information Collection

If the script isn't available, collect this information manually:

#### 1. System Environment
```powershell
# PowerShell version
$PSVersionTable | Format-List

# Node.js
node --version
(Get-Command node).Source

# npm
npm --version
npm root -g
```

#### 2. Claude Desktop Config
```powershell
# Config location and content
$configPath = "$env:APPDATA\Claude\claude_desktop_config.json"
Test-Path $configPath
Get-Content $configPath | ConvertFrom-Json | ConvertTo-Json -Depth 10
```

#### 3. PATH Analysis
```powershell
# Check for npm in PATH
$env:PATH -split ';' | Where-Object { $_ -like "*npm*" -or $_ -like "*node*" }

# User PATH (registry)
[Environment]::GetEnvironmentVariable('PATH', 'User') -split ';'
```

#### 4. Test Server Manually
```powershell
# For npx servers
npx.cmd -y @modelcontextprotocol/server-filesystem --help

# For local servers
node "D:/mcp/server-name/dist/index.js" --help
```

#### 5. Check Claude Logs
```powershell
# Find logs
Get-ChildItem "$env:APPDATA\Claude\logs" -Recurse

# View recent log
Get-Content "$env:APPDATA\Claude\logs\main.log" -Tail 50

# Search for MCP errors
Select-String -Path "$env:APPDATA\Claude\logs\*.log" -Pattern "mcp|MCP|error|ENOENT"
```

#### 6. Process Information
```powershell
# Claude Desktop process
Get-Process -Name "Claude" | Format-List *

# All Node processes (potential MCP servers)
Get-Process -Name "node" | ForEach-Object {
    $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId = $($_.Id)").CommandLine
    [PSCustomObject]@{
        PID = $_.Id
        Memory = [math]::Round($_.WorkingSet64 / 1MB, 2)
        CommandLine = $cmdLine
    }
} | Format-Table -AutoSize
```

#### 7. Verify File Paths
```powershell
# Check all paths referenced in config
$config = Get-Content "$env:APPDATA\Claude\claude_desktop_config.json" | ConvertFrom-Json

foreach ($server in $config.mcpServers.PSObject.Properties) {
    Write-Host "`n=== $($server.Name) ===" -ForegroundColor Cyan

    # Check command
    $cmd = $server.Value.command
    Write-Host "Command: $cmd"
    Write-Host "  Exists: $(Test-Path $cmd -ErrorAction SilentlyContinue)"

    # Check args that look like paths
    foreach ($arg in $server.Value.args) {
        if ($arg -match '^[A-Za-z]:' -or $arg -match '\.(js|mjs|ts)$') {
            Write-Host "Arg: $arg"
            Write-Host "  Exists: $(Test-Path $arg)"
        }
    }
}
```

### Information to Include in Bug Reports

When reporting MCP issues, include:

1. **Diagnostic report** from `diagnose-mcp.ps1`
2. **Exact error message** from Claude Desktop or logs
3. **Server configuration** (redact API keys)
4. **Steps to reproduce**
5. **What you've already tried**

---

## Troubleshooting

### Problem: MCP server not starting

**Symptoms**: Server shows as disabled or tools not available

**Diagnostic Steps**:
```powershell
# 1. Check config syntax
$config = Get-Content "$env:APPDATA\Claude\claude_desktop_config.json" | ConvertFrom-Json
$config.mcpServers.'server-name'

# 2. Test command manually
node "D:/mcp/server/dist/index.js"

# 3. Check Node.js version
node --version  # Should be 18+

# 4. Check for missing dependencies
cd D:/mcp/server && npm install
```

**Common Fixes**:
- Ensure `command` path exists: `Test-Path "C:/path/to/node.exe"`
- Use forward slashes or escaped backslashes: `D:/mcp` or `D:\\mcp`
- Restart Claude Desktop completely (check Task Manager)

### Problem: "spawn ENOENT" error

**Cause**: Command executable not found

**Fix**:
```powershell
# Use absolute path to node
$nodePath = (Get-Command node).Source
Write-Host "Use this path: $nodePath"
# Example: C:\Program Files\nodejs\node.exe
```

### Problem: Environment variables not available

**Cause**: `env` block not properly formatted

**Fix**:
```json
{
  "mcpServers": {
    "server": {
      "command": "node",
      "args": ["server.js"],
      "env": {
        "API_KEY": "your-key-here",
        "DEBUG": "true"
      }
    }
  }
}
```

### Problem: Server works in terminal but not in Claude

**Cause**: Different PATH/environment in Claude vs terminal

**Fix**: Use absolute paths for everything:
```json
{
  "command": "C:/Program Files/nodejs/node.exe",
  "args": ["C:/Users/Owner/AppData/Roaming/npm/node_modules/@org/server/dist/index.js"]
}
```

### Problem: Config file corrupted

**Recovery**:
```powershell
# Restore from backup
$configPath = "$env:APPDATA\Claude\claude_desktop_config.json"
$backups = Get-ChildItem "$env:APPDATA\Claude\*.backup.*" | Sort-Object LastWriteTime -Descending
Copy-Item $backups[0].FullName $configPath

# Or create minimal config
@{
    mcpServers = @{}
} | ConvertTo-Json | Set-Content $configPath
```

---

## Known Issues Prevention

### Issue #1: Path escaping in JSON
**Error**: Invalid JSON syntax
**Prevention**: Use forward slashes `D:/mcp` or double backslashes `D:\\mcp`

### Issue #2: npx.cmd vs npx on Windows
**Error**: spawn npx ENOENT
**Prevention**: Use `npx.cmd` on Windows:
```json
{
  "command": "npx.cmd",
  "args": ["-y", "@package/name"]
}
```

### Issue #3: Node version mismatch
**Error**: Unexpected token, SyntaxError
**Prevention**: Verify Node 18+ is in PATH and used by Claude

### Issue #4: Config edited while Claude running
**Error**: Config resets or corrupts
**Prevention**: Always close Claude Desktop before editing config

### Issue #5: Missing build step for cloned repos
**Error**: Cannot find module './dist/index.js'
**Prevention**: Always run `npm install && npm run build` after cloning

---

## Using Bundled Resources

### Scripts (scripts/)

**add-mcp-server.ps1** - Add server to Claude Desktop config
```powershell
.\scripts\add-mcp-server.ps1 -Name "server-name" -Command "node" -Args @("path/to/server.js")
```

**backup-config.ps1** - Backup Claude Desktop config
```powershell
.\scripts\backup-config.ps1
```

### Templates (templates/)

**claude-desktop-config.json** - Example config structure
**mcp-registry.json** - Registry template
**win-cli-config.json** - Win-CLI configuration template

---

## Complete Setup Checklist

- [ ] Node.js 18+ installed and in PATH
- [ ] Claude Desktop installed
- [ ] Config file exists at `%APPDATA%\Claude\claude_desktop_config.json`
- [ ] Config file backed up
- [ ] MCP server installed (npx, npm, or clone)
- [ ] Server added to config with absolute paths
- [ ] Claude Desktop restarted
- [ ] Server tools visible in Claude
- [ ] Registry updated (if using)
- [ ] Installation logged

---

## Official Documentation

- **MCP Protocol**: https://modelcontextprotocol.io/
- **MCP Servers**: https://github.com/modelcontextprotocol/servers
- **Claude Desktop**: https://claude.ai/download
- **Desktop Commander**: https://github.com/anthropics/desktop-commander

---

## Package Versions (Verified 2025-12-06)

```json
{
  "dependencies": {
    "node": ">=18.0.0",
    "@modelcontextprotocol/server-filesystem": "^0.6.x",
    "@anthropic-ai/desktop-commander": "^0.1.x"
  }
}
```
