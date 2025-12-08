# Admin Skills Suite - Architecture Redesign Plan

**Created**: 2025-12-08
**Status**: PLANNING
**Author**: Claude Code + Jeremy Dawes

---

## Executive Summary

This document outlines the restructuring of 14 `admin-*` skills into a cohesive, user-agnostic system with a central orchestrator. The goal is to create skills that:

1. Work for ANY user (no hardcoded author-specific values)
2. Have a single entry point (`admin`) that routes to specialists
3. Use centralized logging and configuration
4. Can be installed in any project and activate on relevant keywords
5. Work both standalone and as an integrated suite

---

## Table of Contents

1. [Current State](#1-current-state)
2. [Problems to Solve](#2-problems-to-solve)
3. [Proposed Architecture](#3-proposed-architecture)
4. [The `admin` Orchestrator](#4-the-admin-orchestrator)
5. [Skills to Absorb](#5-skills-to-absorb)
6. [Environment Variable Standardization](#6-environment-variable-standardization)
7. [Logging System](#7-logging-system)
8. [Routing Logic](#8-routing-logic)
9. [Migration Plan](#9-migration-plan)
10. [File-by-File Changes](#10-file-by-file-changes)
11. [Testing Plan](#11-testing-plan)
12. [Open Questions](#12-open-questions)

---

## 1. Current State

### 1.1 Existing Skills (14 total)

| Skill | Purpose | Status |
|-------|---------|--------|
| `admin-app-coolify` | Coolify PaaS deployment | Keep |
| `admin-app-kasm` | KASM Workspaces VDI | Keep |
| `admin-infra-contabo` | Contabo cloud provider | Keep |
| `admin-infra-digitalocean` | DigitalOcean provider | Keep |
| `admin-infra-hetzner` | Hetzner cloud provider | Keep |
| `admin-infra-linode` | Linode/Akamai provider | Keep |
| `admin-infra-oci` | Oracle Cloud Infrastructure | Keep |
| `admin-infra-vultr` | Vultr cloud provider | Keep |
| `admin-mcp` | MCP server management | Keep |
| `admin-servers` | Server inventory | Keep (demote) |
| `admin-specs` | Device profiles & logging | **ABSORB into admin** |
| `admin-sync` | Windows-WSL coordination | **ABSORB into admin** |
| `admin-windows` | Windows administration | Keep |
| `admin-wsl` | WSL/Linux administration | Keep |

### 1.2 Current Directory Structure

```
skills/
├── admin-app-coolify/
├── admin-app-kasm/
├── admin-infra-contabo/
├── admin-infra-digitalocean/
├── admin-infra-hetzner/
├── admin-infra-linode/
├── admin-infra-oci/
├── admin-infra-vultr/
├── admin-mcp/
├── admin-servers/
│   └── assets/env-spec.txt      # Canonical .env spec
├── admin-specs/                  # TO BE ABSORBED
│   └── templates/profile.json
├── admin-sync/                   # TO BE ABSORBED
│   └── .env.template
├── admin-windows/
└── admin-wsl/
```

### 1.3 Current Relationships

```
admin-servers (de facto orchestrator)
├── admin-infra-* (providers)
│   └── admin-app-* (applications)

admin-windows
├── admin-mcp
├── admin-specs (logging)
└── admin-sync ←→ admin-wsl
```

**Problems:**
- No single entry point
- `admin-specs` and `admin-sync` are awkwardly positioned
- Logging is fragmented
- Hardcoded author-specific paths throughout

---

## 2. Problems to Solve

### 2.1 Hardcoded Author-Specific Values

**Found in multiple skills:**

| Value | Occurrences | Should Be |
|-------|-------------|-----------|
| `wsladmin` | ~20+ | `$ADMIN_USER` |
| `WOPR3` | ~10+ | `$DEVICE_NAME` |
| `~/dev/wsl-admin` | ~15+ | `$WSL_ADMIN_PATH` |
| `/mnt/n/Dropbox/08_Admin` | ~10+ | `$ADMIN_ROOT` |
| `/home/wsladmin/` | ~10+ | `$HOME` or `$WSL_HOME` |
| `C:\Users\Owner` | ~5+ | `$WIN_USER_HOME` |

### 2.2 No Central Entry Point

- Users must know which skill to invoke
- No automatic context detection
- No unified logging across operations

### 2.3 Fragmented Configuration

- Each skill has its own `.env.template` (or none)
- No standard for variable naming
- `env-spec.txt` exists but isn't enforced

### 2.4 Awkward Skill Positioning

- `admin-specs`: Really just "logging and profiles" - belongs in orchestrator
- `admin-sync`: Really just "cross-platform coordination" - belongs in orchestrator
- `admin-servers`: Tries to be orchestrator but is really "server inventory"

### 2.5 Not User-Agnostic

- Skills assume author's environment
- First-run experience is poor
- No setup wizard or guidance

---

## 3. Proposed Architecture

### 3.1 New Hierarchy

```
admin/                           # NEW: Central orchestrator
├── Responsibilities:
│   ├── Context detection (Windows/WSL/Linux/macOS)
│   ├── Routing to sub-skills
│   ├── Centralized logging
│   ├── Device profile management
│   ├── Environment configuration
│   └── Cross-platform coordination
│
├── Routes to:
│   ├── admin-servers            # Server inventory & provisioning
│   │   └── admin-infra-*        # Cloud providers (6)
│   │       └── admin-app-*      # Applications (2)
│   │
│   ├── admin-windows            # Windows administration
│   │   └── admin-mcp            # MCP servers
│   │
│   └── admin-wsl                # WSL/Linux administration
```

### 3.2 Skill Count After Redesign

| Category | Skills | Count |
|----------|--------|-------|
| Orchestrator | `admin` | 1 |
| Server Management | `admin-servers` | 1 |
| Infrastructure | `admin-infra-*` | 6 |
| Applications | `admin-app-*` | 2 |
| Local Admin | `admin-windows`, `admin-wsl`, `admin-mcp` | 3 |
| **Absorbed** | ~~admin-specs~~, ~~admin-sync~~ | -2 |
| **Total** | | **13** (was 14) |

### 3.3 New Directory Structure

```
skills/
├── admin/                        # NEW ORCHESTRATOR
│   ├── SKILL.md
│   ├── README.md
│   ├── .env.template            # Master config
│   ├── assets/
│   │   ├── env-spec.txt         # Moved from admin-servers
│   │   └── profile-schema.json  # From admin-specs
│   ├── references/
│   │   ├── logging.md           # From admin-specs
│   │   ├── cross-platform.md    # From admin-sync
│   │   ├── routing-guide.md     # NEW
│   │   └── first-run-setup.md   # NEW
│   └── templates/
│       └── profile.json         # From admin-specs
│
├── admin-servers/                # Demoted to specialist
│   ├── SKILL.md                 # Updated, logging removed
│   ├── assets/
│   │   └── agent-devops.env.template
│   └── scripts/
│
├── admin-windows/
├── admin-wsl/
├── admin-mcp/
├── admin-infra-*/
├── admin-app-*/
│
├── [ARCHIVED]/
│   ├── admin-specs/             # Absorbed into admin
│   └── admin-sync/              # Absorbed into admin
```

---

## 4. The `admin` Orchestrator

### 4.1 Core Responsibilities

#### 4.1.1 Context Detection

```markdown
## Platform Detection Logic

1. Check $ADMIN_PLATFORM environment variable (if set, trust it)
2. Otherwise auto-detect:
   - Check for /proc/version containing "Microsoft" → WSL
   - Check $OS == "Windows_NT" → Windows
   - Check uname -s == "Darwin" → macOS
   - Default → Linux
3. Store result for session
```

#### 4.1.2 Routing

```markdown
## Routing Decision Tree

START
│
├─ Is this a SERVER task? (provision, deploy, cloud, infrastructure)
│  └─ YES → Route to admin-servers
│     └─ admin-servers may further route to:
│        ├─ admin-infra-* (for provisioning)
│        └─ admin-app-* (for application deployment)
│
├─ Is this a WINDOWS SYSTEM task? (powershell, winget, registry, .wslconfig)
│  ├─ Am I in WSL context?
│  │  └─ YES → Log handoff, instruct user to use Windows
│  └─ NO (Windows context) → Route to admin-windows
│     └─ If MCP-related → admin-windows routes to admin-mcp
│
├─ Is this a WSL/LINUX task? (apt, docker, bash, systemd)
│  ├─ Am I in Windows (non-WSL) context?
│  │  └─ YES → Log handoff, instruct user to enter WSL
│  └─ NO (WSL/Linux context) → Route to admin-wsl
│
└─ Is this a PROFILE/LOGGING task?
   └─ Handle directly in admin (don't route)
```

#### 4.1.3 Centralized Logging

```bash
# Logging function defined in admin/SKILL.md

log_admin() {
    local level="$1"      # INFO|SUCCESS|ERROR|WARN
    local category="$2"   # operation|installation|system-change|handoff
    local message="$3"
    local details="${4:-}"

    local timestamp=$(date -Iseconds)
    local device="${DEVICE_NAME:-$(hostname)}"
    local platform="${ADMIN_PLATFORM:-unknown}"

    local log_line="$timestamp [$device][$platform] $level: $message"
    [[ -n "$details" ]] && log_line="$log_line | $details"

    # Central log
    local log_dir="${ADMIN_LOG_PATH:-$HOME/.admin/logs}"
    mkdir -p "$log_dir/devices/$device"

    echo "$log_line" >> "$log_dir/${category}s.log"
    echo "$log_line" >> "$log_dir/devices/$device/history.log"
}

# Usage in any admin-* skill:
# source the function, then:
log_admin "SUCCESS" "installation" "Installed Docker" "version=24.0.7"
```

#### 4.1.4 Profile Management

```json
// Profile schema (admin/assets/profile-schema.json)
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["deviceInfo"],
  "properties": {
    "deviceInfo": {
      "type": "object",
      "properties": {
        "name": { "type": "string" },
        "platform": { "enum": ["windows", "wsl", "linux", "macos"] },
        "hostname": { "type": "string" },
        "user": { "type": "string" },
        "lastUpdated": { "type": "string", "format": "date-time" }
      }
    },
    "installedTools": {
      "type": "object",
      "additionalProperties": {
        "type": "object",
        "properties": {
          "version": { "type": "string" },
          "installedVia": { "type": "string" },
          "path": { "type": "string" },
          "lastChecked": { "type": "string", "format": "date-time" }
        }
      }
    },
    "managedServers": {
      "type": "array",
      "items": { "type": "string" },
      "description": "Server IDs from admin-servers inventory"
    }
  }
}
```

#### 4.1.5 First-Run Setup

```markdown
## First-Run Experience

When admin is activated and no .env.local exists:

1. **Detect Environment**
   - Platform: [auto-detected]
   - Hostname: [auto-detected]
   - User: [auto-detected]

2. **Prompt for Configuration**
   - Device name (default: hostname)
   - Admin root directory (default: ~/.admin)
   - Sync location (optional: Dropbox/OneDrive path)

3. **Create Configuration**
   - Generate .env.local with detected/provided values
   - Create directory structure
   - Initialize empty profile

4. **Verify Setup**
   - Test write permissions
   - Log setup completion
   - Display summary

5. **Guide Next Steps**
   - "To manage servers, say 'provision a server'"
   - "To manage this Windows PC, say 'install [package]'"
   - "To manage WSL, enter WSL and activate admin again"
```

### 4.2 SKILL.md Outline

```markdown
---
name: admin
description: |
  Central orchestrator for system administration. Detects context (Windows/WSL/Linux),
  routes to specialist skills, provides centralized logging and device profiles.

  Use when: managing servers, administering Windows or Linux systems, tracking
  installed tools, coordinating cross-platform tasks, or troubleshooting any
  admin-related issues.
license: MIT
---

# Admin - System Administration Orchestrator

## Quick Start
[First-run detection and setup]

## Context Detection
[Platform detection logic]

## Routing
[Decision tree for sub-skill routing]

## Logging
[Centralized logging functions]

## Device Profiles
[Profile management]

## Configuration
[Environment variables reference]

## Sub-Skills Reference
[Brief description of each sub-skill and when it's invoked]
```

### 4.3 README.md Keywords

```markdown
## Auto-Trigger Keywords

### Primary (always trigger admin)
- admin, administration, system admin, sysadmin
- devops, ops, operations
- manage system, system management
- device profile, my setup, my tools

### Server Keywords (routes to admin-servers)
- server, servers, provision, deploy
- cloud, infrastructure, VPS, VM
- OCI, oracle cloud, hetzner, digitalocean, vultr, linode, contabo

### Windows Keywords (routes to admin-windows)
- windows, powershell, pwsh, winget, scoop, chocolatey
- windows admin, windows setup
- registry, environment variable windows

### WSL/Linux Keywords (routes to admin-wsl)
- wsl, ubuntu, linux, bash, apt
- docker, container
- systemd, systemctl

### MCP Keywords (routes via admin-windows)
- mcp, model context protocol, claude desktop
- mcp server, mcp install

### Application Keywords (routes via admin-servers)
- coolify, self-hosted, paas
- kasm, workspaces, vdi, virtual desktop
```

---

## 5. Skills to Absorb

### 5.1 admin-specs → admin

**What moves:**

| From | To | Notes |
|------|-----|-------|
| `admin-specs/SKILL.md` | `admin/references/logging.md` + `admin/SKILL.md` | Split content |
| `admin-specs/templates/profile.json` | `admin/templates/profile.json` | Direct move |
| `admin-specs/.env.template` | Merge into `admin/.env.template` | Consolidate |
| `admin-specs/scripts/*` | `admin/scripts/` or inline | Evaluate each |

**Content to extract:**
- Profile JSON schema
- Log-Operation function
- Installation history tracking
- Multi-device sync patterns

### 5.2 admin-sync → admin

**What moves:**

| From | To | Notes |
|------|-----|-------|
| `admin-sync/SKILL.md` | `admin/references/cross-platform.md` | Core content |
| `admin-sync/.env.template` | Merge into `admin/.env.template` | Consolidate |
| Handoff protocol | `admin/SKILL.md` routing section | Integrate |
| Path mapping tables | `admin/references/cross-platform.md` | Keep as reference |

**Content to extract:**
- Windows ↔ WSL path conversion
- `.wslconfig` management guidance
- Handoff tags (`[REQUIRES-WINADMIN]`, `[REQUIRES-WSL-ADMIN]`)
- Decision matrix (which admin handles what)

### 5.3 Deprecation Plan

```markdown
## Deprecation Notice for admin-specs and admin-sync

These skills have been absorbed into the `admin` orchestrator.

### For Existing Users

If you have `admin-specs` or `admin-sync` installed:

1. Install the new `admin` skill
2. Migrate your .env.local settings (see migration guide)
3. Remove the old skills from ~/.claude/skills/

### Functionality Mapping

| Old | New |
|-----|-----|
| `admin-specs` profile management | `admin` profile management |
| `admin-specs` logging | `admin` centralized logging |
| `admin-sync` coordination | `admin` routing + cross-platform.md |
| `admin-sync` .wslconfig | `admin-windows` (routed by admin) |
```

---

## 6. Environment Variable Standardization

### 6.1 Canonical Variable Specification

**Location:** `admin/assets/env-spec.txt`

```bash
# ============================================================================
# ADMIN SKILLS SUITE - ENVIRONMENT VARIABLE SPECIFICATION
# ============================================================================
# Version: 2.0
# Updated: 2025-12-08
#
# This is the CANONICAL specification for all admin-* skills.
# All .env.template files MUST comply with this spec.
# ============================================================================

# ----------------------------------------------------------------------------
# CORE IDENTITY
# ----------------------------------------------------------------------------
DEVICE_NAME=                     # Unique identifier for this device
                                 # Default: $(hostname)
                                 # Example: WOPR3, macbook-pro, dev-server-01

ADMIN_USER=                      # Primary admin username
                                 # Default: $(whoami)
                                 # Used for: SSH, ownership, logs

ADMIN_PLATFORM=                  # Operating platform (auto-detected if empty)
                                 # Values: windows | wsl | linux | macos
                                 # Auto-detection uses /proc/version, $OS, uname

# ----------------------------------------------------------------------------
# PATHS - CORE
# ----------------------------------------------------------------------------
ADMIN_ROOT=                      # Central admin directory
                                 # Default: ~/.admin
                                 # Contains: logs/, profiles/, config/
                                 # Can be: local path OR synced folder (Dropbox, etc.)

ADMIN_LOG_PATH=                  # Logging directory
                                 # Default: $ADMIN_ROOT/logs
                                 # Structure: operations.log, installations.log,
                                 #            system-changes.log, devices/*/

ADMIN_PROFILE_PATH=              # Device profiles directory
                                 # Default: $ADMIN_ROOT/profiles
                                 # Contains: $DEVICE_NAME.json

# ----------------------------------------------------------------------------
# PATHS - PLATFORM SPECIFIC
# ----------------------------------------------------------------------------
# Windows
WIN_USER_HOME=                   # Windows user home
                                 # Default: $USERPROFILE or C:\Users\$USERNAME
                                 # WSL access: /mnt/c/Users/$WIN_USERNAME

WIN_ADMIN_PATH=                  # Windows admin workspace
                                 # Default: $WIN_USER_HOME\.admin

# WSL
WSL_ADMIN_PATH=                  # WSL admin workspace
                                 # Default: ~/dev/wsl-admin
                                 # From Windows: \\wsl$\Ubuntu-24.04$WSL_ADMIN_PATH

WSL_DISTRO=                      # WSL distribution name
                                 # Default: Ubuntu-24.04
                                 # Used for: wsl -d commands, path construction

# ----------------------------------------------------------------------------
# SSH
# ----------------------------------------------------------------------------
SSH_KEY_PATH=                    # Default private key
                                 # Default: ~/.ssh/id_rsa

SSH_PUBLIC_KEY_PATH=             # Default public key
                                 # Default: ${SSH_KEY_PATH}.pub

SSH_CONFIG_PATH=                 # SSH config file
                                 # Default: ~/.ssh/config

# ----------------------------------------------------------------------------
# SYNC (Optional)
# ----------------------------------------------------------------------------
ADMIN_SYNC_ENABLED=              # Enable cross-device sync
                                 # Values: true | false
                                 # Default: false

ADMIN_SYNC_PATH=                 # Synced folder path (Dropbox, OneDrive, etc.)
                                 # Example: /mnt/n/Dropbox/Admin
                                 # Example: ~/Dropbox/Admin
                                 # Only used if ADMIN_SYNC_ENABLED=true

# ----------------------------------------------------------------------------
# CLOUD PROVIDERS (used by admin-infra-*)
# ----------------------------------------------------------------------------
# OCI
OCI_CONFIG_PATH=                 # OCI CLI config
                                 # Default: ~/.oci/config
OCI_TENANCY_OCID=
OCI_USER_OCID=
OCI_REGION=
OCI_COMPARTMENT_OCID=

# Hetzner
HCLOUD_TOKEN=
HCLOUD_CONTEXT=

# DigitalOcean
DIGITALOCEAN_TOKEN=

# Vultr
VULTR_API_KEY=

# Linode
LINODE_TOKEN=

# Contabo
CONTABO_CLIENT_ID=
CONTABO_CLIENT_SECRET=
CONTABO_USER=
CONTABO_PASS=

# ----------------------------------------------------------------------------
# APPLICATIONS (used by admin-app-*)
# ----------------------------------------------------------------------------
# Coolify
COOLIFY_DOMAIN=                  # e.g., coolify.yourdomain.com
COOLIFY_ADMIN_EMAIL=
COOLIFY_WILDCARD_DOMAIN=         # e.g., *.yourdomain.com

# KASM
KASM_DOMAIN=                     # e.g., kasm.yourdomain.com
KASM_ADMIN_PASSWORD=

# ----------------------------------------------------------------------------
# CLOUDFLARE (used by tunnel configs)
# ----------------------------------------------------------------------------
CLOUDFLARE_API_TOKEN=
CLOUDFLARE_ZONE_ID=
CLOUDFLARE_ACCOUNT_ID=
CLOUDFLARE_TUNNEL_NAME=
CLOUDFLARE_TUNNEL_ID=
```

### 6.2 Per-Skill Variable Requirements

| Variable | admin | admin-servers | admin-windows | admin-wsl | admin-mcp | admin-infra-* | admin-app-* |
|----------|-------|---------------|---------------|-----------|-----------|---------------|-------------|
| DEVICE_NAME | req | opt | opt | opt | opt | - | - |
| ADMIN_USER | req | opt | opt | opt | opt | - | - |
| ADMIN_PLATFORM | auto | - | - | - | - | - | - |
| ADMIN_ROOT | req | opt | opt | opt | opt | - | - |
| ADMIN_LOG_PATH | req | uses | uses | uses | uses | uses | uses |
| WIN_USER_HOME | win | - | req | - | req | - | - |
| WSL_ADMIN_PATH | wsl | - | - | req | - | - | - |
| SSH_KEY_PATH | opt | req | opt | opt | - | req | req |
| Provider creds | - | - | - | - | - | req | - |
| App domains | - | - | - | - | - | - | req |

**Legend:** req=required, opt=optional, auto=auto-detected, uses=inherits from admin, -=not used

### 6.3 .env.local Pattern

```bash
# User creates .env.local (gitignored) by copying .env.template

# In skill scripts/SKILL.md:
# Load configuration with defaults
if [[ -f ".env.local" ]]; then
    source .env.local
elif [[ -f "$HOME/.admin/.env" ]]; then
    source "$HOME/.admin/.env"
fi

# Apply defaults for any unset variables
DEVICE_NAME="${DEVICE_NAME:-$(hostname)}"
ADMIN_USER="${ADMIN_USER:-$(whoami)}"
ADMIN_ROOT="${ADMIN_ROOT:-$HOME/.admin}"
ADMIN_LOG_PATH="${ADMIN_LOG_PATH:-$ADMIN_ROOT/logs}"
```

---

## 7. Logging System

### 7.1 Log Structure

```
$ADMIN_LOG_PATH/
├── operations.log           # General operations
├── installations.log        # Software installations
├── system-changes.log       # Configuration changes
├── handoffs.log            # Cross-platform handoffs
└── devices/
    ├── DEVICE1/
    │   └── history.log     # All logs for this device
    └── DEVICE2/
        └── history.log
```

### 7.2 Log Format

```
# Format: ISO8601 [DEVICE][PLATFORM] LEVEL: message | details

2025-12-08T14:30:00-05:00 [WOPR3][wsl] SUCCESS: Package installed | apt install postgresql-client
2025-12-08T14:31:00-05:00 [WOPR3][wsl] INFO: HANDOFF | requires=admin-windows, task=update .wslconfig
2025-12-08T14:32:00-05:00 [WOPR3][windows] SUCCESS: Config updated | .wslconfig memory=32GB
```

### 7.3 Logging Function (Portable)

```bash
# Works on: Windows (PowerShell), WSL, Linux, macOS

log_admin() {
    local level="$1"      # INFO|SUCCESS|ERROR|WARN|HANDOFF
    local category="$2"   # operation|installation|system-change|handoff
    local message="$3"
    local details="${4:-}"

    # Get values with defaults
    local timestamp=$(date -Iseconds 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)
    local device="${DEVICE_NAME:-$(hostname)}"
    local platform="${ADMIN_PLATFORM:-unknown}"
    local log_dir="${ADMIN_LOG_PATH:-$HOME/.admin/logs}"

    # Construct log line
    local log_line="$timestamp [$device][$platform] $level: $message"
    [[ -n "$details" ]] && log_line="$log_line | $details"

    # Ensure directories exist
    mkdir -p "$log_dir/devices/$device" 2>/dev/null

    # Write to category log
    echo "$log_line" >> "$log_dir/${category}s.log"

    # Write to device history
    echo "$log_line" >> "$log_dir/devices/$device/history.log"

    # Also echo for visibility (optional)
    [[ "$level" == "ERROR" ]] && echo "ERROR: $message" >&2
}
```

### 7.4 PowerShell Equivalent

```powershell
function Log-Admin {
    param(
        [ValidateSet("INFO","SUCCESS","ERROR","WARN","HANDOFF")]
        [string]$Level,
        [ValidateSet("operation","installation","system-change","handoff")]
        [string]$Category,
        [string]$Message,
        [string]$Details = ""
    )

    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"
    $device = if ($env:DEVICE_NAME) { $env:DEVICE_NAME } else { $env:COMPUTERNAME }
    $platform = if ($env:ADMIN_PLATFORM) { $env:ADMIN_PLATFORM } else { "windows" }
    $logDir = if ($env:ADMIN_LOG_PATH) { $env:ADMIN_LOG_PATH } else { "$env:USERPROFILE\.admin\logs" }

    $logLine = "$timestamp [$device][$platform] ${Level}: $Message"
    if ($Details) { $logLine += " | $Details" }

    # Ensure directories exist
    New-Item -ItemType Directory -Force -Path "$logDir\devices\$device" | Out-Null

    # Write logs
    Add-Content -Path "$logDir\${Category}s.log" -Value $logLine
    Add-Content -Path "$logDir\devices\$device\history.log" -Value $logLine

    if ($Level -eq "ERROR") { Write-Error $Message }
}
```

---

## 8. Routing Logic

### 8.1 Complete Decision Tree

```
┌─────────────────────────────────────────────────────────────────┐
│                     ADMIN ROUTING ENGINE                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │ Detect Platform │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
    ┌─────────┐        ┌─────────┐        ┌─────────┐
    │ Windows │        │   WSL   │        │  Linux  │
    │(non-WSL)│        │         │        │ /macOS  │
    └────┬────┘        └────┬────┘        └────┬────┘
         │                  │                  │
         ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                      TASK CLASSIFICATION                        │
└─────────────────────────────────────────────────────────────────┘
                              │
    ┌────────────┬────────────┼────────────┬────────────┐
    ▼            ▼            ▼            ▼            ▼
┌────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐
│ Server │ │ Windows  │ │WSL/Linux │ │   MCP    │ │ Profile │
│  Task  │ │  System  │ │  System  │ │   Task   │ │/Logging │
└───┬────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬────┘
    │           │            │            │            │
    ▼           ▼            ▼            ▼            ▼
┌────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐
│ admin- │ │  admin-  │ │  admin-  │ │  admin-  │ │  admin  │
│servers │ │ windows  │ │   wsl    │ │   mcp    │ │ (self)  │
└───┬────┘ └──────────┘ └──────────┘ └────┬─────┘ └─────────┘
    │                                      │
    ▼                                      │
┌────────────────┐                         │
│ Provider Task? │                         │
└───────┬────────┘                         │
        │ YES                              │
        ▼                                  │
┌────────────────┐                         │
│ admin-infra-*  │◄────────────────────────┘
│ (oci, hetzner, │    (MCP may need
│  vultr, etc.)  │     server provisioned)
└───────┬────────┘
        │
        ▼
┌────────────────┐
│ App Deployment?│
└───────┬────────┘
        │ YES
        ▼
┌────────────────┐
│  admin-app-*   │
│(coolify, kasm) │
└────────────────┘
```

### 8.2 Keyword → Skill Mapping

```yaml
# admin/references/routing-guide.md

routing_rules:

  # SERVER MANAGEMENT
  - keywords:
      - server, servers, provision, deploy, infrastructure
      - cloud, VPS, VM, instance, droplet, linode
      - inventory, "my servers", "server list"
    route_to: admin-servers
    sub_routing:
      - keywords: [oracle, oci, "oracle cloud", ARM64, "always free"]
        route_to: admin-infra-oci
      - keywords: [hetzner, hcloud, CAX, european]
        route_to: admin-infra-hetzner
      - keywords: [digitalocean, doctl, droplet]
        route_to: admin-infra-digitalocean
      - keywords: [vultr, "vultr-cli", "high frequency"]
        route_to: admin-infra-vultr
      - keywords: [linode, akamai, "linode-cli"]
        route_to: admin-infra-linode
      - keywords: [contabo, cntb, budget]
        route_to: admin-infra-contabo
      - keywords: [coolify, paas, "self-hosted heroku"]
        route_to: admin-app-coolify
      - keywords: [kasm, workspaces, vdi, "virtual desktop"]
        route_to: admin-app-kasm

  # WINDOWS ADMINISTRATION
  - keywords:
      - powershell, pwsh, windows, winget, scoop, chocolatey
      - registry, "environment variable", PATH
      - ".wslconfig", "windows terminal"
      - "Get-", "Set-", "New-", "Remove-"  # PowerShell cmdlets
    route_to: admin-windows
    requires_context: windows
    if_wrong_context: |
      This is a Windows task but you're in WSL/Linux.
      Please open a Windows terminal to proceed.
    sub_routing:
      - keywords: [mcp, "model context protocol", "claude desktop", mcpServers]
        route_to: admin-mcp

  # WSL/LINUX ADMINISTRATION
  - keywords:
      - wsl, ubuntu, apt, dpkg, linux, bash, zsh
      - docker, container, "docker-compose"
      - systemd, systemctl, journalctl
      - python, pip, uv, venv
      - node, npm, nvm
    route_to: admin-wsl
    requires_context: [wsl, linux, macos]
    if_wrong_context: |
      This is a Linux/WSL task but you're in Windows.
      Please run: wsl -d Ubuntu-24.04

  # PROFILE/LOGGING (handled by admin itself)
  - keywords:
      - profile, "my tools", "installed tools"
      - log, logs, history, "what did I install"
      - sync, "cross-device", "my devices"
    route_to: self

  # CROSS-PLATFORM
  - keywords:
      - "both windows and", "windows and wsl"
      - cross-platform, "on both"
    route_to: self
    note: Admin coordinates calling multiple sub-skills
```

### 8.3 Context Validation

```markdown
## Before Routing

1. **Check Context Compatibility**
   - Task requires Windows but context is WSL?
     → Log handoff, provide instructions
   - Task requires WSL but context is Windows?
     → Log handoff, provide instructions

2. **Check Skill Availability**
   - Is required sub-skill installed?
   - If not: provide installation instructions

3. **Check Prerequisites**
   - Does sub-skill have required config?
   - If not: guide through setup
```

---

## 9. Migration Plan

### 9.1 Phase 1: Create `admin` Orchestrator

**Tasks:**
1. Create `skills/admin/` directory structure
2. Write `admin/SKILL.md` with routing logic
3. Write `admin/README.md` with comprehensive keywords
4. Create `admin/.env.template` (master config)
5. Move `admin-servers/assets/env-spec.txt` → `admin/assets/env-spec.txt`

**No breaking changes yet.**

### 9.2 Phase 2: Absorb admin-specs

**Tasks:**
1. Move `admin-specs/templates/profile.json` → `admin/templates/`
2. Extract logging content → `admin/references/logging.md`
3. Merge `.env.template` variables into `admin/.env.template`
4. Update `admin/SKILL.md` with profile management section
5. Mark `admin-specs/` for archival

### 9.3 Phase 3: Absorb admin-sync

**Tasks:**
1. Extract cross-platform content → `admin/references/cross-platform.md`
2. Integrate handoff protocol into `admin/SKILL.md` routing
3. Merge `.env.template` variables into `admin/.env.template`
4. Update path mapping tables
5. Mark `admin-sync/` for archival

### 9.4 Phase 4: Update Sub-Skills

**For each remaining skill:**
1. Remove local logging functions → use centralized
2. Update `.env.template` to comply with `env-spec.txt`
3. Replace hardcoded paths with variables
4. Update cross-references to use new skill names
5. Add "Requires: admin" to dependencies (optional)

### 9.5 Phase 5: Testing

1. Test `admin` standalone activation
2. Test routing to each sub-skill
3. Test sub-skills standalone (without `admin`)
4. Test new user first-run experience
5. Test cross-platform scenarios

### 9.6 Phase 6: Archive Old Skills

```bash
# Move to archive branch
git checkout -b archive/admin-specs-admin-sync
git mv skills/admin-specs archive/
git mv skills/admin-sync archive/
git commit -m "Archive admin-specs and admin-sync (absorbed into admin)"
git checkout main

# Remove from main
rm -rf skills/admin-specs skills/admin-sync
git commit -m "Remove admin-specs and admin-sync (absorbed into admin orchestrator)"
```

---

## 10. File-by-File Changes

### 10.1 New Files to Create

| File | Purpose |
|------|---------|
| `admin/SKILL.md` | Orchestrator main documentation |
| `admin/README.md` | Keywords and overview |
| `admin/.env.template` | Master configuration template |
| `admin/assets/env-spec.txt` | Canonical variable specification |
| `admin/assets/profile-schema.json` | Device profile JSON schema |
| `admin/references/logging.md` | Logging system documentation |
| `admin/references/cross-platform.md` | Windows-WSL coordination |
| `admin/references/routing-guide.md` | Routing rules and decision tree |
| `admin/references/first-run-setup.md` | New user setup guide |
| `admin/templates/profile.json` | Empty device profile template |

### 10.2 Files to Modify

| File | Changes |
|------|---------|
| `admin-servers/SKILL.md` | Remove logging, update to use centralized |
| `admin-servers/assets/env-spec.txt` | DELETE (moved to admin) |
| `admin-windows/SKILL.md` | Add logging calls, parameterize paths |
| `admin-wsl/SKILL.md` | Add logging calls, parameterize paths |
| `admin-mcp/SKILL.md` | Add logging calls |
| `admin-infra-*/SKILL.md` | Ensure .env.template compliance |
| `admin-app-*/SKILL.md` | Ensure .env.template compliance |
| All `README.md` files | Update Related Skills sections |

### 10.3 Files to Delete/Archive

| File | Action |
|------|--------|
| `admin-specs/*` | Archive then delete |
| `admin-sync/*` | Archive then delete |

### 10.4 Hardcoded Values to Replace

**admin-wsl/SKILL.md:**
| Line | Current | Replace With |
|------|---------|--------------|
| ~38 | `cat ~/dev/wsl-admin/.env` | `cat "${WSL_ADMIN_PATH:-.}/.env"` |
| ~44 | `tail -20 ~/dev/wsl-admin/logs/` | `tail -20 "${ADMIN_LOG_PATH}/devices/${DEVICE_NAME}/"` |
| ~107 | `~/dev/wsl-admin/` | `$WSL_ADMIN_PATH/` |
| Multiple | `wsladmin` | `$ADMIN_USER` |
| Multiple | `WOPR3` | `$DEVICE_NAME` |

**admin-windows/SKILL.md:**
(Similar audit needed)

**admin-sync/.env.template:**
| Line | Current | Replace With |
|------|---------|--------------|
| 12 | `\\wsl$\Ubuntu-24.04\home\wsladmin\dev\wsl-admin` | `\\wsl$\${WSL_DISTRO}\home\${ADMIN_USER}\${WSL_ADMIN_PATH}` |

---

## 11. Testing Plan

### 11.1 Unit Tests (per skill)

```markdown
## Test: admin

- [ ] Activates on "admin" keyword
- [ ] Activates on "manage my servers"
- [ ] Detects Windows platform correctly
- [ ] Detects WSL platform correctly
- [ ] Routes server tasks to admin-servers
- [ ] Routes Windows tasks to admin-windows
- [ ] Routes WSL tasks to admin-wsl
- [ ] Logging function works
- [ ] Profile creation works
- [ ] First-run setup completes
```

### 11.2 Integration Tests

```markdown
## Test: Full Workflow

1. Fresh install (no .env.local)
   - [ ] Admin detects first-run
   - [ ] Setup wizard runs
   - [ ] .env.local created
   - [ ] Directories created

2. Server provisioning
   - [ ] "provision OCI server" → admin → admin-servers → admin-infra-oci
   - [ ] Logging captures all steps
   - [ ] Server added to inventory

3. Application deployment
   - [ ] "install coolify" → admin → admin-servers → admin-app-coolify
   - [ ] Logging captures installation
   - [ ] Credentials stored

4. Windows administration
   - [ ] "install with winget" → admin → admin-windows
   - [ ] Logging captures operation
   - [ ] Profile updated with installed tool

5. Cross-platform
   - [ ] Task requiring both Windows and WSL
   - [ ] Admin coordinates both sub-skills
   - [ ] Both operations logged
```

### 11.3 User Acceptance Tests

```markdown
## Test: New User Experience

Persona: Developer installing skills for first time

1. Install admin skill to ~/.claude/skills/
2. Open new project
3. Say "help me manage my servers"
4. Verify:
   - [ ] Admin activates
   - [ ] Setup wizard offers to configure
   - [ ] Clear next steps provided
   - [ ] No errors about missing config
```

---

## 12. Open Questions

### 12.1 Architecture Questions

1. **Should `admin` always load first?**
   - Option A: Yes, it's the mandatory entry point
   - Option B: No, expert users can invoke sub-skills directly
   - **Recommendation**: Option B - sub-skills work standalone but integrate when admin present

2. **Where should .env.local live?**
   - Option A: Project root (`./.env.local`)
   - Option B: User home (`~/.admin/.env`)
   - Option C: Both, with project overriding user
   - **Recommendation**: Option C - allows global defaults with project overrides

3. **How to handle skill not installed?**
   - Option A: Error with install instructions
   - Option B: Offer to create stub/redirect
   - **Recommendation**: Option A - clear error with `install-skill.sh` command

### 12.2 Implementation Questions

1. **Should logging be synchronous or async?**
   - Sync is simpler, async is faster
   - **Recommendation**: Sync for simplicity, logs are small

2. **Profile format: JSON or YAML?**
   - JSON is more universal
   - YAML is more readable
   - **Recommendation**: JSON (matches existing env-spec pattern)

3. **How to handle platform detection in scripts?**
   - Each script does its own detection?
   - Or source a common detection library?
   - **Recommendation**: Common library in `admin/lib/detect-platform.sh`

### 12.3 Migration Questions

1. **How long to keep admin-specs/admin-sync available?**
   - **Recommendation**: Archive immediately, they're not published externally

2. **Backward compatibility for existing .env files?**
   - **Recommendation**: Document migration, don't auto-migrate (too complex)

---

## Appendix A: Complete Skill Inventory After Redesign

| Skill | Type | Purpose | Dependencies |
|-------|------|---------|--------------|
| `admin` | Orchestrator | Central routing, logging, profiles | None |
| `admin-servers` | Specialist | Server inventory & provisioning | admin (optional) |
| `admin-infra-oci` | Provider | Oracle Cloud | admin-servers (optional) |
| `admin-infra-hetzner` | Provider | Hetzner Cloud | admin-servers (optional) |
| `admin-infra-digitalocean` | Provider | DigitalOcean | admin-servers (optional) |
| `admin-infra-vultr` | Provider | Vultr | admin-servers (optional) |
| `admin-infra-linode` | Provider | Linode/Akamai | admin-servers (optional) |
| `admin-infra-contabo` | Provider | Contabo | admin-servers (optional) |
| `admin-app-coolify` | Application | Coolify PaaS | admin-servers (optional) |
| `admin-app-kasm` | Application | KASM VDI | admin-servers (optional) |
| `admin-windows` | Specialist | Windows administration | admin (optional) |
| `admin-wsl` | Specialist | WSL/Linux administration | admin (optional) |
| `admin-mcp` | Specialist | MCP servers | admin-windows (optional) |

**Total: 13 skills** (down from 14, absorbed 2 into 1)

---

## Appendix B: Checklist for Implementation

- [ ] Create `admin/` directory structure
- [ ] Write `admin/SKILL.md`
- [ ] Write `admin/README.md`
- [ ] Create `admin/.env.template`
- [ ] Move `env-spec.txt` to admin
- [ ] Create `admin/references/logging.md`
- [ ] Create `admin/references/cross-platform.md`
- [ ] Create `admin/references/routing-guide.md`
- [ ] Create `admin/templates/profile.json`
- [ ] Update `admin-servers` to remove logging
- [ ] Update `admin-windows` with centralized logging
- [ ] Update `admin-wsl` with centralized logging
- [ ] Update `admin-mcp` with centralized logging
- [ ] Audit all skills for hardcoded paths
- [ ] Update all `.env.template` files for compliance
- [ ] Archive `admin-specs`
- [ ] Archive `admin-sync`
- [ ] Test standalone operation
- [ ] Test integrated operation
- [ ] Test first-run experience
- [ ] Update CLAUDE.md with new structure

---

**Document Status**: READY FOR REVIEW
**Next Step**: Review and approve, then begin Phase 1 implementation
