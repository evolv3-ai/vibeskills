# Admin Skills: Windows + WSL Environment Map

How the admin skills map to a Windows PC running both native Windows and WSL.

## Physical Machine Layout

```mermaid
flowchart TB
    subgraph Hardware["Physical Machine (e.g., WOPR3)"]
        subgraph Windows["Windows 11"]
            subgraph WinApps["Windows Applications"]
                CLAUDE_DESKTOP["Claude Desktop"]
                VSCODE["VS Code"]
                TERMINAL["Windows Terminal"]
            end

            subgraph WinTools["Windows Tools"]
                PWSH["PowerShell 7"]
                WINGET["winget"]
                SCOOP["scoop"]
                GIT_BASH["Git Bash"]
            end

            subgraph WinPaths["Windows Paths"]
                WIN_ADMIN["C:\Users\Owner\.admin\"]
                WIN_CLAUDE["C:\Users\Owner\AppData\Roaming\Claude\"]
            end
        end

        subgraph WSL["WSL2 (Ubuntu)"]
            subgraph WSLApps["WSL Applications"]
                DOCKER["Docker"]
                NODE["Node.js"]
                PYTHON["Python"]
            end

            subgraph WSLTools["WSL Tools"]
                BASH["Bash/Zsh"]
                APT["apt"]
                SYSTEMD["systemd"]
            end

            subgraph WSLPaths["WSL Paths"]
                WSL_ADMIN["/home/wsladmin/.admin/"]
                WSL_CLAUDE["/home/wsladmin/.claude/"]
            end
        end
    end

    style Windows fill:#b3d9ff,stroke:#0066cc
    style WSL fill:#b3ffb3,stroke:#009900
```

## Skill Ownership by Environment

```mermaid
flowchart LR
    subgraph WindowsNative["Windows Native Domain"]
        direction TB
        W_WIN["admin-windows<br>PowerShell, winget, scoop,<br>registry, PATH, env vars"]
        W_MCP["admin-mcp<br>Claude Desktop config,<br>MCP servers"]
    end

    subgraph WSLDomain["WSL/Linux Domain"]
        direction TB
        W_WSL["admin-wsl<br>apt, docker, systemd,<br>python, node"]
    end

    subgraph CrossPlatform["Cross-Platform (Works in Both)"]
        direction TB
        W_ADMIN["admin<br>Orchestrator, logging,<br>profiles, routing"]
        W_SERVERS["admin-servers<br>Server inventory"]
        W_INFRA["admin-infra-*<br>Cloud CLI tools"]
        W_APPS["admin-app-*<br>Coolify, KASM"]
    end

    style WindowsNative fill:#b3d9ff,stroke:#0066cc
    style WSLDomain fill:#b3ffb3,stroke:#009900
    style CrossPlatform fill:#ffffb3,stroke:#999900
```

## Detailed Environment Mapping

```mermaid
flowchart TB
    subgraph Machine["Windows PC with WSL"]
        subgraph WinEnv["WINDOWS ENVIRONMENT"]
            subgraph WinSkills["Skills that run HERE"]
                SK_WIN["admin-windows"]
                SK_MCP["admin-mcp"]
            end

            subgraph WinConfig["Config Locations"]
                WIN_ADMIN_DIR["C:\Users\Owner\.admin\<br>├── logs\<br>├── profiles\<br>└── config\"]
                WIN_MCP_CONFIG["C:\Users\Owner\AppData\Roaming\Claude\<br>└── claude_desktop_config.json"]
            end

            subgraph WinClaude["Claude Code (Windows)"]
                CC_WIN["Claude Code<br>runs in Git Bash<br>ADMIN_SHELL=bash<br>ADMIN_PLATFORM=windows"]
            end
        end

        subgraph WSLEnv["WSL ENVIRONMENT"]
            subgraph WSLSkills["Skills that run HERE"]
                SK_WSL["admin-wsl"]
            end

            subgraph WSLConfig["Config Locations"]
                WSL_ADMIN_DIR["/home/wsladmin/.admin/<br>├── logs/<br>├── profiles/<br>└── config/"]
                WSL_CLAUDE_DIR["/home/wsladmin/.claude/<br>└── skills/ (symlinks)"]
            end

            subgraph WSLClaude["Claude Code (WSL)"]
                CC_WSL["Claude Code<br>runs in Zsh/Bash<br>ADMIN_SHELL=zsh<br>ADMIN_PLATFORM=wsl"]
            end
        end

        subgraph SharedSkills["SKILLS THAT WORK IN BOTH"]
            SK_ADMIN["admin (orchestrator)"]
            SK_SERVERS["admin-servers"]
            SK_INFRA["admin-infra-*<br>(oci, hetzner, do, vultr, linode, contabo)"]
            SK_APPS["admin-app-*<br>(coolify, kasm)"]
        end
    end

    SK_ADMIN --> SK_WIN
    SK_ADMIN --> SK_WSL
    SK_ADMIN --> SK_MCP
    SK_ADMIN --> SK_SERVERS
    SK_SERVERS --> SK_INFRA
    SK_SERVERS --> SK_APPS

    style WinEnv fill:#b3d9ff,stroke:#0066cc
    style WSLEnv fill:#b3ffb3,stroke:#009900
    style SharedSkills fill:#ffffb3,stroke:#999900
```

## Handoff Scenarios

```mermaid
flowchart TD
    subgraph Scenario1["Scenario: User in WSL asks to edit .wslconfig"]
        S1_START["User in WSL:<br>'Edit .wslconfig to increase memory'"]
        S1_DETECT["admin detects:<br>ADMIN_PLATFORM=wsl"]
        S1_ROUTE["Routes to: admin-windows<br>(because .wslconfig is Windows file)"]
        S1_CHECK{"Context valid?"}
        S1_HANDOFF["HANDOFF:<br>'Open Windows terminal<br>to edit .wslconfig'<br>[REQUIRES-WINADMIN]"]
    end

    S1_START --> S1_DETECT --> S1_ROUTE --> S1_CHECK
    S1_CHECK -->|"No - wrong platform"| S1_HANDOFF

    subgraph Scenario2["Scenario: User in Windows asks to install Docker"]
        S2_START["User in Windows:<br>'Install Docker'"]
        S2_DETECT["admin detects:<br>ADMIN_PLATFORM=windows"]
        S2_ROUTE["Routes to: admin-wsl<br>(because Docker runs in WSL)"]
        S2_CHECK{"Context valid?"}
        S2_HANDOFF["HANDOFF:<br>'Run wsl -d Ubuntu-24.04<br>to install Docker'<br>[REQUIRES-WSL-ADMIN]"]
    end

    S2_START --> S2_DETECT --> S2_ROUTE --> S2_CHECK
    S2_CHECK -->|"No - wrong platform"| S2_HANDOFF

    subgraph Scenario3["Scenario: User in WSL asks to provision OCI server"]
        S3_START["User in WSL:<br>'Provision an OCI server'"]
        S3_DETECT["admin detects:<br>ADMIN_PLATFORM=wsl"]
        S3_ROUTE["Routes to: admin-servers<br>→ admin-infra-oci"]
        S3_CHECK{"Context valid?"}
        S3_PROCEED["PROCEED:<br>OCI CLI works in both<br>environments"]
    end

    S3_START --> S3_DETECT --> S3_ROUTE --> S3_CHECK
    S3_CHECK -->|"Yes - cross-platform"| S3_PROCEED

    style S1_HANDOFF fill:#ffcccc,stroke:#cc0000
    style S2_HANDOFF fill:#ffcccc,stroke:#cc0000
    style S3_PROCEED fill:#ccffcc,stroke:#00cc00
```

## File System Access Between Environments

```mermaid
flowchart LR
    subgraph Windows["Windows File System"]
        W_ROOT["C:\"]
        W_USERS["C:\Users\Owner\"]
        W_ADMIN["C:\Users\Owner\.admin\"]
    end

    subgraph WSL["WSL File System"]
        L_ROOT["/"]
        L_HOME["/home/wsladmin/"]
        L_ADMIN["/home/wsladmin/.admin/"]
        L_MNT["/mnt/c/"]
    end

    subgraph Access["Cross-Access"]
        WIN_TO_WSL["Windows → WSL:<br>\\\\wsl$\\Ubuntu\\home\\wsladmin\\"]
        WSL_TO_WIN["WSL → Windows:<br>/mnt/c/Users/Owner/"]
    end

    W_USERS -.->|"via /mnt/c/"| L_MNT
    L_HOME -.->|"via \\\\wsl$\\"| W_ROOT

    style Windows fill:#b3d9ff,stroke:#0066cc
    style WSL fill:#b3ffb3,stroke:#009900
```

## Claude Code Execution Context

```mermaid
flowchart TB
    subgraph UserStarts["User Starts Claude Code"]
        START_WIN["From Windows Terminal<br>(PowerShell)"]
        START_WSL["From WSL Terminal<br>(Bash/Zsh)"]
    end

    subgraph ClaudeCode["Claude Code Bash Tool"]
        CC_WIN_BASH["Windows: Git Bash (MINGW64)<br>$BASH_VERSION = 5.2.x<br>$HOME = /c/Users/Owner"]
        CC_WSL_BASH["WSL: Native Bash/Zsh<br>$ZSH_VERSION = 5.9<br>$HOME = /home/wsladmin"]
    end

    subgraph Detection["Environment Detection"]
        DET_WIN["ADMIN_PLATFORM=windows<br>ADMIN_SHELL=bash"]
        DET_WSL["ADMIN_PLATFORM=wsl<br>ADMIN_SHELL=zsh"]
    end

    subgraph Available["Available Commands"]
        CMD_WIN["Bash: mkdir, cat, ls, grep<br>Windows: winget, scoop, git<br>PowerShell: pwsh -Command '...'"]
        CMD_WSL["Bash: mkdir, cat, ls, grep<br>Linux: apt, docker, systemctl<br>Python: python, pip, uv"]
    end

    START_WIN --> CC_WIN_BASH --> DET_WIN --> CMD_WIN
    START_WSL --> CC_WSL_BASH --> DET_WSL --> CMD_WSL

    style CC_WIN_BASH fill:#ffccff,stroke:#990099
    style CC_WSL_BASH fill:#ccffcc,stroke:#009900
```

## Skill Installation Locations

```mermaid
flowchart TB
    subgraph SkillsRepo["claude-skills Repository"]
        REPO["/home/wsladmin/dev/claude-skills/skills/"]
        ADMIN_SRC["admin/"]
        WIN_SRC["admin-windows/"]
        WSL_SRC["admin-wsl/"]
        MCP_SRC["admin-mcp/"]
        SERVERS_SRC["admin-servers/"]
        INFRA_SRC["admin-infra-*/"]
        APPS_SRC["admin-app-*/"]
    end

    subgraph WSLInstall["WSL Installation"]
        WSL_SKILLS["/home/wsladmin/.claude/skills/"]
        WSL_LINKS["Symlinks to repo"]
    end

    subgraph WinInstall["Windows Installation"]
        WIN_SKILLS["C:\Users\Owner\.claude\skills\"]
        WIN_COPY["Copy or symlink"]
    end

    subgraph SharedAdmin["SHARED .admin Folder"]
        SHARED_ROOT["C:\Users\Owner\.admin\<br>= /mnt/c/Users/Owner/.admin/"]
        SHARED_LOGS["logs/ (unified)"]
        SHARED_PROFILES["profiles/ (single WOPR3.json)"]
        SHARED_CONFIG["config/"]
    end

    REPO --> ADMIN_SRC
    REPO --> WIN_SRC
    REPO --> WSL_SRC
    REPO --> MCP_SRC
    REPO --> SERVERS_SRC
    REPO --> INFRA_SRC
    REPO --> APPS_SRC

    ADMIN_SRC -.->|"symlink"| WSL_LINKS
    WIN_SRC -.->|"symlink"| WSL_LINKS
    WSL_SRC -.->|"symlink"| WSL_LINKS
    MCP_SRC -.->|"symlink"| WSL_LINKS

    WSL_LINKS --> WSL_SKILLS

    ADMIN_SRC -.->|"copy/symlink"| WIN_COPY
    WIN_SRC -.->|"copy/symlink"| WIN_COPY
    MCP_SRC -.->|"copy/symlink"| WIN_COPY

    WIN_COPY --> WIN_SKILLS

    WSL_SKILLS -->|"writes to"| SHARED_ROOT
    WIN_SKILLS -->|"writes to"| SHARED_ROOT
    SHARED_ROOT --> SHARED_LOGS
    SHARED_ROOT --> SHARED_PROFILES
    SHARED_ROOT --> SHARED_CONFIG

    style SkillsRepo fill:#ffffcc,stroke:#999900
    style WSLInstall fill:#b3ffb3,stroke:#009900
    style WinInstall fill:#b3d9ff,stroke:#0066cc
    style SharedAdmin fill:#ffccff,stroke:#990099
```

## Quick Reference Table

| Skill | Windows Native | WSL | Notes |
|-------|---------------|-----|-------|
| **admin** | ✅ Works | ✅ Works | Orchestrator, adapts to environment |
| **admin-windows** | ✅ Native | ⚠️ Handoff | PowerShell tasks need Windows |
| **admin-wsl** | ⚠️ Handoff | ✅ Native | Linux tasks need WSL |
| **admin-mcp** | ✅ Native | ✅ Works* | *Can edit config via /mnt/c/ from WSL |
| **admin-servers** | ✅ Works | ✅ Works | Cross-platform |
| **admin-infra-*** | ✅ Works | ✅ Works | CLI tools work in both |
| **admin-app-*** | ✅ Works | ✅ Works | Cross-platform |

## Config File Locations

| Config | Windows Path | WSL Path | Shared? |
|--------|-------------|----------|---------|
| **Admin root** | `C:\Users\Owner\.admin\` | `/mnt/c/Users/Owner/.admin/` | **YES** |
| **Admin logs** | `C:\Users\Owner\.admin\logs\` | `/mnt/c/Users/Owner/.admin/logs/` | **YES** |
| **Device profile** | `C:\Users\Owner\.admin\profiles\WOPR3.json` | `/mnt/c/Users/Owner/.admin/profiles/WOPR3.json` | **YES** |
| Claude Desktop config | `C:\Users\Owner\AppData\Roaming\Claude\claude_desktop_config.json` | `/mnt/c/Users/Owner/AppData/Roaming/Claude/claude_desktop_config.json` | Yes (via /mnt/c) |
| Skills directory | `C:\Users\Owner\.claude\skills\` | `/home/wsladmin/.claude/skills/` | No (separate) |

**IMPORTANT**: The `.admin` folder is now **shared** between Windows and WSL. Both environments read/write to the same physical location on the Windows filesystem.

## Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                     WINDOWS PC (e.g., WOPR3)                    │
├─────────────────────────────┬───────────────────────────────────┤
│      WINDOWS NATIVE         │              WSL                  │
├─────────────────────────────┼───────────────────────────────────┤
│  admin-windows ◄────────────┼──────────► admin-wsl              │
│  admin-mcp                  │                                   │
│                             │                                   │
│  Claude Code uses Git Bash  │  Claude Code uses Zsh/Bash        │
│  ADMIN_PLATFORM=windows     │  ADMIN_PLATFORM=wsl               │
│  ADMIN_SHELL=bash           │  ADMIN_SHELL=zsh                  │
├─────────────────────────────┴───────────────────────────────────┤
│                    CROSS-PLATFORM SKILLS                        │
│  admin (orchestrator) │ admin-servers │ admin-infra-*           │
│  admin-app-coolify    │ admin-app-kasm                          │
├─────────────────────────────────────────────────────────────────┤
│                 SHARED .admin FOLDER (Windows FS)               │
│         C:\Users\Owner\.admin\ = /mnt/c/Users/Owner/.admin/     │
│  ├── logs/           (unified logs from both environments)      │
│  ├── profiles/       (single WOPR3.json device profile)         │
│  └── config/         (shared configuration)                     │
└─────────────────────────────────────────────────────────────────┘
```
