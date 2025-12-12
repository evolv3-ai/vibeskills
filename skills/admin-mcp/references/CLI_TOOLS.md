# MCP CLI Tools on Windows

## Contents
- Desktop Commander
- Win-CLI
- Claude Code MCP
- Tool selection guide

---

## Desktop Commander (Primary for Local Work)

**Package**: `@anthropic-ai/desktop-commander`  
**Best for**: File operations, code editing, persistent sessions.

Example entry:

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

Key features:
- Persistent process sessions
- Diff‑based code editing
- Interactive REPL support

---

## Win-CLI (SSH and Multi‑Shell)

**Best for**: SSH operations, remote servers, multiple shell types.

Example entry:

```json
{
  "mcpServers": {
    "win-cli": {
      "command": "node",
      "args": [
        "<MCP_ROOT>/win-cli-mcp-server/dist/index.js",
        "--config",
        "<MCP_ROOT>/win-cli-mcp-server/config.json"
      ]
    }
  }
}
```

Example `config.json`:

```json
{
  "shells": {
    "powershell": {
      "enabled": true,
      "command": "C:/Program Files/PowerShell/7/pwsh.exe",
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
        "host": "<server-ip>",
        "username": "<username>",
        "privateKeyPath": "C:/Users/<YourUsername>/.ssh/id_rsa"
      }
    ]
  }
}
```

Key features:
- Multiple shell support (PowerShell, CMD, Git Bash)
- Pre‑configured SSH connections
- Isolated shell sessions

---

## Claude Code MCP (Complex Multi‑File Tasks)

**Package**: `@anthropic-ai/claude-code-mcp`  
**Best for**: Complex refactoring, git workflows, multi‑file edits.

Example entry:

```json
{
  "mcpServers": {
    "claude-code-mcp": {
      "command": "node",
      "args": ["<MCP_ROOT>/claude-code-mcp/dist/index.js"],
      "env": {
        "CLAUDE_CLI_PATH": "C:/Users/<YourUsername>/AppData/Roaming/npm/claude.cmd"
      }
    }
  }
}
```

---

## Tool Selection Guide

| Task | Recommended Tool | Reason |
|------|-----------------|--------|
| Read/write files | Desktop Commander | Native file tools |
| Edit code blocks | Desktop Commander | Diff‑based edits |
| Run local commands | Desktop Commander | Better PATH handling |
| SSH to remote server | Win‑CLI | SSH support |
| Use specific shell | Win‑CLI | Multi‑shell support |
| Complex refactoring | Claude Code MCP | Multi‑file awareness |
| Git operations | Claude Code MCP | Git workflow support |

