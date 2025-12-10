# Admin Skills Architecture

Visual overview of how the admin skills suite works together across different environments.

## High-Level Flow

```mermaid
flowchart TB
    subgraph User["User Request"]
        REQ["'Manage my servers'<br>'Install Docker'<br>'Configure MCP'"]
    end

    subgraph Detection["Environment Detection"]
        SHELL{{"Detect Shell"}}
        PLATFORM{{"Detect Platform"}}
    end

    subgraph Shells["ADMIN_SHELL"]
        BASH["bash/zsh"]
        PWSH["powershell"]
    end

    subgraph Platforms["ADMIN_PLATFORM"]
        WSL["wsl"]
        WIN["windows"]
        LIN["linux"]
        MAC["macos"]
    end

    subgraph Orchestrator["admin (Orchestrator)"]
        ROUTE["Route by Keywords"]
        LOG["Centralized Logging"]
        PROFILE["Device Profiles"]
    end

    subgraph SubSkills["Sub-Skills"]
        SERVERS["admin-servers"]
        WINDOWS["admin-windows"]
        WSLSKILL["admin-wsl"]
        MCP["admin-mcp"]
        INFRA["admin-infra-*"]
        APPS["admin-app-*"]
    end

    REQ --> SHELL
    REQ --> PLATFORM

    SHELL --> BASH
    SHELL --> PWSH

    PLATFORM --> WSL
    PLATFORM --> WIN
    PLATFORM --> LIN
    PLATFORM --> MAC

    BASH --> Orchestrator
    PWSH --> Orchestrator

    ROUTE --> SERVERS
    ROUTE --> WINDOWS
    ROUTE --> WSLSKILL
    ROUTE --> MCP
    ROUTE --> INFRA
    ROUTE --> APPS

    LOG -.-> SERVERS
    LOG -.-> WINDOWS
    LOG -.-> WSLSKILL
    LOG -.-> MCP
    PROFILE -.-> SERVERS
```

## Shell Detection Flow

```mermaid
flowchart LR
    subgraph ClaudeCode["Claude Code Bash Tool"]
        START["Execute Command"]
    end

    subgraph Detection["Shell Detection"]
        CHECK_BASH{"$BASH_VERSION<br>or $ZSH_VERSION?"}
        CHECK_PS{"$PSVersionTable?"}
    end

    subgraph Result["ADMIN_SHELL"]
        BASH["bash"]
        ZSH["zsh"]
        PS["powershell"]
    end

    START --> CHECK_BASH
    CHECK_BASH -->|"Has value"| BASH
    CHECK_BASH -->|"Has value"| ZSH
    CHECK_BASH -->|"Empty"| CHECK_PS
    CHECK_PS -->|"Has value"| PS
    CHECK_PS -->|"Error"| BASH
```

## Platform Detection Flow

```mermaid
flowchart TD
    START["Detect Platform"]

    CHECK_PROC{"/proc/version<br>contains 'microsoft'?"}
    CHECK_OS{"$OS == 'Windows_NT'?"}
    CHECK_UNAME{"uname -s"}

    WSL["ADMIN_PLATFORM=wsl"]
    WIN["ADMIN_PLATFORM=windows"]
    MAC["ADMIN_PLATFORM=macos"]
    LIN["ADMIN_PLATFORM=linux"]

    START --> CHECK_PROC
    CHECK_PROC -->|"Yes (case-insensitive)"| WSL
    CHECK_PROC -->|"No"| CHECK_OS
    CHECK_OS -->|"Yes (Git Bash)"| WIN
    CHECK_OS -->|"No"| CHECK_UNAME
    CHECK_UNAME -->|"Darwin"| MAC
    CHECK_UNAME -->|"Linux"| LIN
```

## Claude Code on Windows (Git Bash)

```mermaid
flowchart TB
    subgraph UserTerminal["User's Terminal"]
        PS7["PowerShell 7<br>(pwsh.exe)"]
    end

    subgraph VSCode["VS Code / Terminal"]
        INTEGRATED["Integrated Terminal"]
    end

    subgraph ClaudeCode["Claude Code"]
        BASH_TOOL["Bash Tool<br>(Git Bash / MINGW64)"]
    end

    subgraph Execution["Command Execution"]
        BASH_CMD["Bash Commands<br>mkdir, cat, ls, grep"]
        WIN_EXE["Windows Executables<br>winget, scoop, git"]
        PWSH_CMD["PowerShell via pwsh<br>pwsh -Command '...'"]
    end

    PS7 --> INTEGRATED
    INTEGRATED -->|"claude"| ClaudeCode
    BASH_TOOL --> BASH_CMD
    BASH_TOOL --> WIN_EXE
    BASH_TOOL --> PWSH_CMD

    style BASH_TOOL fill:#f9f,stroke:#333
    style PWSH_CMD fill:#bbf,stroke:#333
```

## Skill Routing

```mermaid
flowchart TD
    subgraph Keywords["User Keywords"]
        K_SERVER["server, provision, deploy,<br>OCI, hetzner, vultr..."]
        K_WIN["powershell, winget, scoop,<br>registry, PATH..."]
        K_WSL["wsl, ubuntu, apt,<br>docker, systemctl..."]
        K_MCP["mcp, claude desktop,<br>mcpServers..."]
        K_PROFILE["profile, my tools,<br>installed, logs..."]
    end

    subgraph Router["admin Orchestrator"]
        MATCH["Keyword Matching"]
        CONTEXT["Context Validation"]
    end

    subgraph Skills["Target Skill"]
        S_SERVERS["admin-servers"]
        S_WIN["admin-windows"]
        S_WSL["admin-wsl"]
        S_MCP["admin-mcp"]
        S_SELF["admin (self)"]
    end

    subgraph SubRoute["Sub-Routing"]
        INFRA_OCI["admin-infra-oci"]
        INFRA_HETZ["admin-infra-hetzner"]
        INFRA_DO["admin-infra-digitalocean"]
        INFRA_OTHER["admin-infra-*"]
        APP_COOL["admin-app-coolify"]
        APP_KASM["admin-app-kasm"]
    end

    K_SERVER --> MATCH --> S_SERVERS
    K_WIN --> MATCH --> S_WIN
    K_WSL --> MATCH --> S_WSL
    K_MCP --> MATCH --> S_MCP
    K_PROFILE --> MATCH --> S_SELF

    S_SERVERS --> INFRA_OCI
    S_SERVERS --> INFRA_HETZ
    S_SERVERS --> INFRA_DO
    S_SERVERS --> INFRA_OTHER
    S_SERVERS --> APP_COOL
    S_SERVERS --> APP_KASM

    CONTEXT -.->|"Validates platform<br>before routing"| Skills
```

## Handoff Protocol

```mermaid
flowchart TD
    subgraph Current["Current Context"]
        CTX_WSL["In WSL/Bash"]
        CTX_WIN["In Windows/PowerShell"]
    end

    subgraph Task["Requested Task"]
        TASK_WIN["Windows Task<br>(registry, winget, .wslconfig)"]
        TASK_WSL["WSL Task<br>(apt, docker, systemctl)"]
    end

    subgraph Validation["Context Check"]
        CHECK{{"Context matches<br>task requirements?"}}
    end

    subgraph Action["Action"]
        PROCEED["Proceed with task"]
        HANDOFF["Generate Handoff Message"]
    end

    subgraph Messages["Handoff Messages"]
        MSG_WIN["'Open Windows terminal<br>for this task'<br>[REQUIRES-WINADMIN]"]
        MSG_WSL["'Run wsl -d Ubuntu-24.04<br>first'<br>[REQUIRES-WSL-ADMIN]"]
    end

    CTX_WSL --> TASK_WIN --> CHECK
    CTX_WIN --> TASK_WSL --> CHECK
    CTX_WSL --> TASK_WSL --> CHECK
    CTX_WIN --> TASK_WIN --> CHECK

    CHECK -->|"Yes"| PROCEED
    CHECK -->|"No"| HANDOFF

    HANDOFF --> MSG_WIN
    HANDOFF --> MSG_WSL

    style HANDOFF fill:#ff9,stroke:#333
    style MSG_WIN fill:#fbb,stroke:#333
    style MSG_WSL fill:#fbb,stroke:#333
```

## Logging Architecture

```mermaid
flowchart TB
    subgraph Operations["Admin Operations"]
        OP1["Install package"]
        OP2["Provision server"]
        OP3["Configure MCP"]
        OP4["Cross-platform handoff"]
    end

    subgraph LogFunction["log_admin()"]
        FORMAT["[timestamp] [DEVICE][PLATFORM] LEVEL: message | details"]
    end

    subgraph LogFiles["~/.admin/logs/"]
        OPS_LOG["operations.log"]
        INSTALL_LOG["installations.log"]
        HANDOFF_LOG["handoffs.log"]
        DEVICE_LOG["devices/DEVICE_NAME/history.log"]
    end

    OP1 --> LogFunction
    OP2 --> LogFunction
    OP3 --> LogFunction
    OP4 --> LogFunction

    LogFunction --> OPS_LOG
    LogFunction --> INSTALL_LOG
    LogFunction --> HANDOFF_LOG
    LogFunction --> DEVICE_LOG
```

## Directory Structure

**Note**: On Windows+WSL machines, the `.admin` folder is **shared** on the Windows filesystem.
- Windows: `C:\Users\Owner\.admin\`
- WSL: `/mnt/c/Users/Owner/.admin/` (same physical location)

```mermaid
flowchart TB
    subgraph AdminRoot["SHARED: C:\Users\Owner\.admin\<br>= /mnt/c/Users/Owner/.admin/"]
        LOGS["logs/"]
        PROFILES["profiles/"]
        CONFIG["config/"]
    end

    subgraph LogsDir["logs/"]
        OPS["operations.log"]
        INST["installations.log"]
        HAND["handoffs.log"]
        DEVICES["devices/"]
    end

    subgraph DevicesDir["devices/"]
        DEV1["WOPR3/"]
        DEV2["LAPTOP1/"]
    end

    subgraph DeviceFiles["WOPR3/"]
        HISTORY["history.log"]
    end

    subgraph ProfilesDir["profiles/"]
        PROF1["WOPR3.json"]
        PROF2["LAPTOP1.json"]
    end

    AdminRoot --> LOGS
    AdminRoot --> PROFILES
    AdminRoot --> CONFIG

    LOGS --> OPS
    LOGS --> INST
    LOGS --> HAND
    LOGS --> DEVICES

    DEVICES --> DEV1
    DEVICES --> DEV2

    DEV1 --> HISTORY

    PROFILES --> PROF1
    PROFILES --> PROF2

    style AdminRoot fill:#ffccff,stroke:#990099
```

## Complete Admin Skills Suite

```mermaid
flowchart TB
    subgraph Orchestrator["Orchestrator"]
        ADMIN["admin<br>(routing, logging, profiles)"]
    end

    subgraph CoreSkills["Core Skills"]
        SERVERS["admin-servers<br>(inventory)"]
        WINDOWS["admin-windows<br>(Windows admin)"]
        WSL["admin-wsl<br>(WSL/Linux admin)"]
        MCP["admin-mcp<br>(MCP servers)"]
    end

    subgraph InfraSkills["Infrastructure Skills"]
        OCI["admin-infra-oci"]
        HETZ["admin-infra-hetzner"]
        DO["admin-infra-digitalocean"]
        VULTR["admin-infra-vultr"]
        LINODE["admin-infra-linode"]
        CONTABO["admin-infra-contabo"]
    end

    subgraph AppSkills["Application Skills"]
        COOLIFY["admin-app-coolify"]
        KASM["admin-app-kasm"]
    end

    ADMIN --> SERVERS
    ADMIN --> WINDOWS
    ADMIN --> WSL
    ADMIN --> MCP

    SERVERS --> OCI
    SERVERS --> HETZ
    SERVERS --> DO
    SERVERS --> VULTR
    SERVERS --> LINODE
    SERVERS --> CONTABO

    SERVERS --> COOLIFY
    SERVERS --> KASM

    style ADMIN fill:#9f9,stroke:#333,stroke-width:2px
    style SERVERS fill:#bbf,stroke:#333
    style WINDOWS fill:#fbb,stroke:#333
    style WSL fill:#bfb,stroke:#333
    style MCP fill:#fbf,stroke:#333
```

## Summary

| Component | Purpose | Files |
|-----------|---------|-------|
| **admin** | Orchestrator - routing, logging, profiles | `SKILL.md`, `references/*.md` |
| **admin-servers** | Server inventory management | Routes to infra-* and app-* |
| **admin-windows** | Windows-specific administration | PowerShell commands |
| **admin-wsl** | WSL/Linux administration | Bash commands |
| **admin-mcp** | MCP server configuration | Dual-mode (Bash + PowerShell) |
| **admin-infra-*** | Cloud provider management | OCI, Hetzner, DO, Vultr, Linode, Contabo |
| **admin-app-*** | Application deployment | Coolify, KASM |

**Total Skills**: 13 (1 orchestrator + 4 core + 6 infrastructure + 2 application)
