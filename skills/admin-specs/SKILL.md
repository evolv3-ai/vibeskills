---
name: admin-specs
description: |
  Manage multi-device profiles and centralized logging for Windows administration. Includes profile.json schema for tracking installed tools, installation history, centralized cross-device logs, and Dropbox/OneDrive synchronization patterns.

  Use when: tracking installed tools across devices, logging operations, maintaining installation history, setting up multi-device admin systems, or troubleshooting "profile not found", "log file missing", "sync conflict" issues.
license: MIT
---

# Device Profile Management

**Status**: Production Ready
**Last Updated**: 2025-12-06
**Dependencies**: admin-windows skill
**Sync Options**: Dropbox, OneDrive, Network Share, Local

---

## Quick Start (10 Minutes)

### 1. Set Up Admin Root

Choose a centralized location accessible from all devices:

```powershell
# Option A: Dropbox
$adminRoot = "N:/Dropbox/Admin"

# Option B: OneDrive
$adminRoot = "$env:USERPROFILE/OneDrive/Admin"

# Option C: Network Share
$adminRoot = "\\server\share\Admin"

# Option D: Local only
$adminRoot = "D:/Admin"
```

### 2. Create Directory Structure

```powershell
# Create admin structure
$adminRoot = "N:/Dropbox/Admin"  # Change to your path

New-Item -ItemType Directory -Path "$adminRoot/devices/$env:COMPUTERNAME" -Force
New-Item -ItemType Directory -Path "$adminRoot/logs/central" -Force
New-Item -ItemType Directory -Path "$adminRoot/registries" -Force
New-Item -ItemType Directory -Path "$adminRoot/configs" -Force

# Create initial files
@{} | ConvertTo-Json | Set-Content "$adminRoot/devices/$env:COMPUTERNAME/profile.json"
"" | Set-Content "$adminRoot/devices/$env:COMPUTERNAME/logs.txt"
"" | Set-Content "$adminRoot/logs/central/operations.log"
"" | Set-Content "$adminRoot/logs/central/installations.log"
"" | Set-Content "$adminRoot/logs/central/system-changes.log"
```

### 3. Initialize Device Profile

```powershell
# Run initialization script
.\scripts\Initialize-DeviceProfile.ps1 -AdminRoot $adminRoot
```

---

## Critical Rules

### Always Do

- Read existing profile before making updates
- Save to the SAME profile.json file (never create copies)
- Use ISO 8601 timestamps (`yyyy-MM-ddTHH:mm:ssZ`)
- Log all operations to both device and central logs
- Preserve installation history (append only)

### Never Do

- Create duplicate profile files (`profile_new.json`, `profile_backup.json`)
- Delete installation history entries
- Modify profiles without reading first
- Use inconsistent timestamp formats
- Skip logging for any operation

---

## Directory Structure

```
Admin/                              # ADMIN_ROOT
├── devices/                        # Per-device data
│   ├── DEVICE1/
│   │   ├── profile.json           # Device profile (source of truth)
│   │   └── logs.txt               # Device-specific operations log
│   ├── DEVICE2/
│   │   ├── profile.json
│   │   └── logs.txt
│   └── .../
├── logs/
│   └── central/                   # Cross-device logs
│       ├── operations.log         # General operations
│       ├── installations.log      # Software installations
│       └── system-changes.log     # Configuration changes
├── registries/
│   └── mcp-registry.json          # MCP server registry
└── configs/
    └── shared-settings.json       # Cross-device settings
```

---

## Profile Schema

### Complete profile.json Structure

```json
{
  "schemaVersion": "1.0",
  "deviceInfo": {
    "name": "DEVICE_NAME",
    "os": "Windows 11 Professional",
    "osVersion": "10.0.22631",
    "lastUpdated": "2025-12-06T12:00:00Z",
    "adminRoot": "N:/Dropbox/Admin",
    "timezone": "America/New_York"
  },
  "packageManagers": {
    "winget": {
      "present": true,
      "version": "1.9.25200",
      "lastChecked": "2025-12-06T12:00:00Z",
      "location": "C:/Users/Owner/AppData/Local/Microsoft/WindowsApps/winget.exe"
    },
    "scoop": {
      "present": true,
      "version": "0.5.3",
      "lastChecked": "2025-12-06T12:00:00Z",
      "location": "C:/Users/Owner/scoop/shims/scoop.ps1"
    },
    "npm": {
      "present": true,
      "version": "10.9.0",
      "lastChecked": "2025-12-06T12:00:00Z",
      "location": "C:/Users/Owner/AppData/Roaming/npm/npm.cmd"
    },
    "chocolatey": {
      "present": false,
      "version": null,
      "lastChecked": "2025-12-06T12:00:00Z",
      "location": null
    }
  },
  "installedTools": {
    "git": {
      "present": true,
      "version": "2.47.0.windows.1",
      "lastChecked": "2025-12-06T12:00:00Z",
      "installedVia": "winget",
      "path": "C:/Program Files/Git/cmd/git.exe",
      "shimPath": null,
      "notes": null
    },
    "node": {
      "present": true,
      "version": "22.11.0",
      "lastChecked": "2025-12-06T12:00:00Z",
      "installedVia": "winget",
      "path": "C:/Program Files/nodejs/node.exe",
      "shimPath": null,
      "notes": null
    },
    "claude": {
      "present": true,
      "version": "1.0.17",
      "lastChecked": "2025-12-06T12:00:00Z",
      "installedVia": "npm",
      "path": null,
      "shimPath": "C:/Users/Owner/AppData/Roaming/npm/claude.cmd",
      "notes": "Claude Code CLI"
    },
    "python": {
      "present": false,
      "version": null,
      "lastChecked": "2025-12-06T12:00:00Z",
      "installedVia": "scoop",
      "installStatus": "failed",
      "path": null,
      "shimPath": "C:/Users/Owner/scoop/shims/python.exe",
      "notes": "Installation failed 2025-12-01. Needs reinstall."
    }
  },
  "installationHistory": [
    {
      "date": "2025-12-01",
      "action": "install",
      "tool": "git",
      "method": "winget",
      "version": "2.47.0",
      "status": "success",
      "details": "Initial installation"
    },
    {
      "date": "2025-12-05",
      "action": "upgrade",
      "tool": "node",
      "method": "winget",
      "version": "22.11.0",
      "previousVersion": "20.18.0",
      "status": "success",
      "details": "Upgraded from LTS to current"
    },
    {
      "date": "2025-12-06",
      "action": "install",
      "tool": "claude",
      "method": "npm",
      "version": "1.0.17",
      "status": "success",
      "details": "npm install -g @anthropic-ai/claude-code"
    }
  ],
  "systemInfo": {
    "powershellVersion": "7.5.0",
    "powershellEdition": "Core",
    "architecture": "AMD64",
    "cpu": "AMD Ryzen 9 5900X",
    "ram": "64GB",
    "lastSystemCheck": "2025-12-06T12:00:00Z"
  },
  "paths": {
    "npmGlobal": "C:/Users/Owner/AppData/Roaming/npm",
    "scoopShims": "C:/Users/Owner/scoop/shims",
    "mcpRoot": "D:/mcp",
    "projectsRoot": "D:/projects"
  }
}
```

### Tool Entry Schema

Each tool in `installedTools` follows this schema:

```json
{
  "present": true,           // Required: Is tool currently installed?
  "version": "1.2.3",        // Required: Version string or null
  "lastChecked": "ISO8601",  // Required: When was this last verified?
  "installedVia": "winget",  // Required: winget|scoop|npm|chocolatey|manual
  "installStatus": "failed", // Optional: Only if not success
  "path": "/path/to/exe",    // Optional: Full path to executable
  "shimPath": "/path/shim",  // Optional: Shim path (scoop/npm)
  "notes": "Additional info" // Optional: Context or issues
}
```

### Installation History Entry Schema

```json
{
  "date": "2025-12-06",           // Required: ISO date
  "action": "install",            // Required: install|upgrade|uninstall|repair
  "tool": "tool-name",            // Required: Tool identifier
  "method": "winget",             // Required: Installation method
  "version": "1.2.3",             // Required: Version installed
  "previousVersion": "1.2.0",     // Optional: For upgrades
  "status": "success",            // Required: success|failed|partial
  "details": "Description"        // Optional: Additional context
}
```

---

## Profile Operations

### Read Profile

```powershell
function Get-DeviceProfile {
    param(
        [string]$AdminRoot = $env:ADMIN_ROOT,
        [string]$DeviceName = $env:COMPUTERNAME
    )

    $profilePath = "$AdminRoot/devices/$DeviceName/profile.json"

    if (Test-Path $profilePath) {
        Get-Content $profilePath -Raw | ConvertFrom-Json
    } else {
        Write-Warning "Profile not found: $profilePath"
        $null
    }
}

# Usage
$profile = Get-DeviceProfile
$profile.installedTools.git.version
```

### Update Profile

```powershell
function Update-DeviceProfile {
    param(
        [Parameter(Mandatory)]
        [scriptblock]$UpdateScript,
        [string]$AdminRoot = $env:ADMIN_ROOT,
        [string]$DeviceName = $env:COMPUTERNAME
    )

    $profilePath = "$AdminRoot/devices/$DeviceName/profile.json"

    # Read existing profile
    $profile = Get-Content $profilePath -Raw | ConvertFrom-Json

    # Apply updates
    & $UpdateScript $profile

    # Update timestamp
    $profile.deviceInfo.lastUpdated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")

    # Save back to SAME file
    $profile | ConvertTo-Json -Depth 10 | Set-Content $profilePath

    Write-Host "Profile updated: $profilePath" -ForegroundColor Green
}

# Usage - Update a tool
Update-DeviceProfile -UpdateScript {
    param($p)
    $p.installedTools.node.version = "22.12.0"
    $p.installedTools.node.lastChecked = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
}
```

### Add Installation History

```powershell
function Add-InstallationHistory {
    param(
        [Parameter(Mandatory)][string]$Tool,
        [Parameter(Mandatory)][string]$Action,
        [Parameter(Mandatory)][string]$Method,
        [Parameter(Mandatory)][string]$Version,
        [string]$PreviousVersion,
        [ValidateSet("success", "failed", "partial")]
        [string]$Status = "success",
        [string]$Details,
        [string]$AdminRoot = $env:ADMIN_ROOT,
        [string]$DeviceName = $env:COMPUTERNAME
    )

    $profilePath = "$AdminRoot/devices/$DeviceName/profile.json"
    $profile = Get-Content $profilePath -Raw | ConvertFrom-Json

    $entry = [ordered]@{
        date = (Get-Date -Format "yyyy-MM-dd")
        action = $Action
        tool = $Tool
        method = $Method
        version = $Version
        status = $Status
    }

    if ($PreviousVersion) { $entry.previousVersion = $PreviousVersion }
    if ($Details) { $entry.details = $Details }

    # Append to history
    $profile.installationHistory += [PSCustomObject]$entry

    # Update timestamp
    $profile.deviceInfo.lastUpdated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")

    # Save
    $profile | ConvertTo-Json -Depth 10 | Set-Content $profilePath

    Write-Host "Added to history: $Action $Tool $Version" -ForegroundColor Green
}

# Usage
Add-InstallationHistory -Tool "claude" -Action "upgrade" -Method "npm" `
    -Version "1.0.18" -PreviousVersion "1.0.17" `
    -Details "npm update -g @anthropic-ai/claude-code"
```

### Verify Tool Installation

```powershell
function Test-ToolInstallation {
    param(
        [Parameter(Mandatory)][string]$Tool,
        [string]$AdminRoot = $env:ADMIN_ROOT,
        [string]$DeviceName = $env:COMPUTERNAME
    )

    $profile = Get-DeviceProfile -AdminRoot $AdminRoot -DeviceName $DeviceName
    $toolInfo = $profile.installedTools.$Tool

    if (-not $toolInfo) {
        Write-Host "Tool not in profile: $Tool" -ForegroundColor Yellow
        return $false
    }

    # Check if command exists
    $cmd = Get-Command $Tool -ErrorAction SilentlyContinue

    $result = [PSCustomObject]@{
        Tool = $Tool
        ProfileSaysPresent = $toolInfo.present
        ActuallyPresent = $null -ne $cmd
        ProfileVersion = $toolInfo.version
        ActualVersion = $null
        Match = $false
    }

    if ($cmd) {
        try {
            $result.ActualVersion = & $Tool --version 2>&1 | Select-Object -First 1
        } catch {}
    }

    $result.Match = $result.ProfileSaysPresent -eq $result.ActuallyPresent

    $result
}

# Usage
Test-ToolInstallation -Tool "git"
Test-ToolInstallation -Tool "node"
```

---

## Logging System

### Log File Strategy

| Log File | Location | Purpose |
|----------|----------|---------|
| Device Log | `devices/{DEVICE}/logs.txt` | All operations on this device |
| Operations Log | `logs/central/operations.log` | General operations (all devices) |
| Installations Log | `logs/central/installations.log` | Software installations only |
| System Changes Log | `logs/central/system-changes.log` | Config/registry changes |

### Log Entry Format

```
YYYY-MM-DD HH:MM:SS - [DEVICE_NAME] STATUS: Operation - Details
```

Example entries:
```
2025-12-06 14:30:15 - [WOPR3] SUCCESS: Install - Installed git via winget
2025-12-06 14:31:00 - [WOPR3] ERROR: Install - Python installation failed
2025-12-06 14:32:00 - [DELTABOT] INFO: Session Start - WinAdmin initialized
2025-12-06 14:35:00 - [WOPR3] SUCCESS: Profile Update - Added claude to profile
```

### Log-Operation Function

```powershell
function Log-Operation {
    param(
        [Parameter(Mandatory)]
        [ValidateSet("SUCCESS", "ERROR", "INFO", "PENDING", "WARNING")]
        [string]$Status,

        [Parameter(Mandatory)]
        [string]$Operation,

        [Parameter(Mandatory)]
        [string]$Details,

        [ValidateSet("operation", "installation", "system-change")]
        [string]$LogType = "operation",

        [string]$AdminRoot = $env:ADMIN_ROOT,
        [string]$DeviceName = $env:COMPUTERNAME
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - [$DeviceName] $Status: $Operation - $Details"

    # Always log to device log
    $deviceLog = "$AdminRoot/devices/$DeviceName/logs.txt"
    if (Test-Path (Split-Path $deviceLog)) {
        Add-Content $deviceLog -Value $logEntry
    }

    # Log to appropriate central log
    $centralLogDir = "$AdminRoot/logs/central"
    if (Test-Path $centralLogDir) {
        $centralLog = switch ($LogType) {
            "installation" { "$centralLogDir/installations.log" }
            "system-change" { "$centralLogDir/system-changes.log" }
            default { "$centralLogDir/operations.log" }
        }
        Add-Content $centralLog -Value $logEntry
    }

    # Console output with color
    $color = switch ($Status) {
        "SUCCESS" { "Green" }
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        "PENDING" { "Cyan" }
        default { "White" }
    }
    Write-Host $logEntry -ForegroundColor $color
}

# Usage examples
Log-Operation -Status "SUCCESS" -Operation "Install" -Details "Installed git 2.47.0 via winget" -LogType "installation"
Log-Operation -Status "ERROR" -Operation "Install" -Details "Python installation failed: scoop error" -LogType "installation"
Log-Operation -Status "INFO" -Operation "Session" -Details "WinAdmin session started"
Log-Operation -Status "SUCCESS" -Operation "Config" -Details "Updated PATH in registry" -LogType "system-change"
```

### Read Recent Logs

```powershell
function Get-RecentLogs {
    param(
        [int]$Lines = 20,
        [ValidateSet("device", "operations", "installations", "system-changes", "all")]
        [string]$LogType = "device",
        [string]$AdminRoot = $env:ADMIN_ROOT,
        [string]$DeviceName = $env:COMPUTERNAME
    )

    $logs = switch ($LogType) {
        "device" { @("$AdminRoot/devices/$DeviceName/logs.txt") }
        "operations" { @("$AdminRoot/logs/central/operations.log") }
        "installations" { @("$AdminRoot/logs/central/installations.log") }
        "system-changes" { @("$AdminRoot/logs/central/system-changes.log") }
        "all" {
            @(
                "$AdminRoot/devices/$DeviceName/logs.txt",
                "$AdminRoot/logs/central/operations.log",
                "$AdminRoot/logs/central/installations.log",
                "$AdminRoot/logs/central/system-changes.log"
            )
        }
    }

    foreach ($log in $logs) {
        if (Test-Path $log) {
            Write-Host "`n=== $(Split-Path $log -Leaf) ===" -ForegroundColor Cyan
            Get-Content $log -Tail $Lines
        }
    }
}

# Usage
Get-RecentLogs -Lines 10 -LogType "device"
Get-RecentLogs -Lines 50 -LogType "all"
```

---

## Multi-Device Synchronization

### Sync Strategies

| Strategy | Pros | Cons | Best For |
|----------|------|------|----------|
| **Dropbox** | Automatic sync, conflict handling | Requires Dropbox | Personal/small team |
| **OneDrive** | Windows integration | May have sync delays | Microsoft ecosystem |
| **Network Share** | Fast LAN access | No offline access | Enterprise/LAN |
| **Git** | Version history, branches | Manual sync | Developers |

### Handling Sync Conflicts

```powershell
function Resolve-ProfileConflict {
    param(
        [string]$AdminRoot = $env:ADMIN_ROOT,
        [string]$DeviceName = $env:COMPUTERNAME
    )

    $profilePath = "$AdminRoot/devices/$DeviceName/profile.json"
    $conflictPattern = "$AdminRoot/devices/$DeviceName/profile*.json"

    $conflicts = Get-ChildItem $conflictPattern | Where-Object {
        $_.Name -ne "profile.json"
    }

    if ($conflicts.Count -eq 0) {
        Write-Host "No conflicts found" -ForegroundColor Green
        return
    }

    Write-Host "Found $($conflicts.Count) conflict files:" -ForegroundColor Yellow
    $conflicts | ForEach-Object { Write-Host "  - $($_.Name)" }

    # Strategy: Keep newest, merge installation history
    $main = Get-Content $profilePath -Raw | ConvertFrom-Json
    $mainTime = [DateTime]::Parse($main.deviceInfo.lastUpdated)

    foreach ($conflict in $conflicts) {
        $other = Get-Content $conflict.FullName -Raw | ConvertFrom-Json
        $otherTime = [DateTime]::Parse($other.deviceInfo.lastUpdated)

        # Merge installation history (deduplicate by date+tool+action)
        $existingKeys = $main.installationHistory | ForEach-Object {
            "$($_.date)-$($_.tool)-$($_.action)"
        }

        foreach ($entry in $other.installationHistory) {
            $key = "$($entry.date)-$($entry.tool)-$($entry.action)"
            if ($key -notin $existingKeys) {
                $main.installationHistory += $entry
                Write-Host "  Merged history entry: $key" -ForegroundColor Gray
            }
        }

        # Use newer tool versions
        if ($otherTime -gt $mainTime) {
            foreach ($tool in $other.installedTools.PSObject.Properties) {
                $main.installedTools.($tool.Name) = $tool.Value
            }
            Write-Host "  Used newer tool info from conflict file" -ForegroundColor Gray
        }

        # Remove conflict file
        Remove-Item $conflict.FullName
        Write-Host "  Removed: $($conflict.Name)" -ForegroundColor Gray
    }

    # Sort installation history by date
    $main.installationHistory = $main.installationHistory | Sort-Object date

    # Save merged profile
    $main.deviceInfo.lastUpdated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    $main | ConvertTo-Json -Depth 10 | Set-Content $profilePath

    Write-Host "Conflicts resolved!" -ForegroundColor Green
}
```

### Cross-Device Profile Comparison

```powershell
function Compare-DeviceProfiles {
    param(
        [string]$AdminRoot = $env:ADMIN_ROOT
    )

    $devices = Get-ChildItem "$AdminRoot/devices" -Directory

    $comparison = @()

    foreach ($device in $devices) {
        $profilePath = "$($device.FullName)/profile.json"
        if (Test-Path $profilePath) {
            $profile = Get-Content $profilePath -Raw | ConvertFrom-Json

            foreach ($tool in $profile.installedTools.PSObject.Properties) {
                $comparison += [PSCustomObject]@{
                    Device = $device.Name
                    Tool = $tool.Name
                    Present = $tool.Value.present
                    Version = $tool.Value.version
                    LastChecked = $tool.Value.lastChecked
                }
            }
        }
    }

    # Pivot to show tool versions across devices
    $tools = $comparison | Select-Object -ExpandProperty Tool -Unique

    Write-Host "`n=== Tool Versions Across Devices ===" -ForegroundColor Cyan

    foreach ($tool in $tools) {
        Write-Host "`n$tool`:" -ForegroundColor Yellow
        $comparison | Where-Object { $_.Tool -eq $tool } | ForEach-Object {
            $status = if ($_.Present) { $_.Version } else { "[not installed]" }
            Write-Host "  $($_.Device): $status"
        }
    }
}
```

---

## Known Issues Prevention

### Issue #1: Creating duplicate profile files
**Error**: Multiple profile files causing confusion
**Prevention**: Always update `profile.json` directly, never create copies

### Issue #2: Installation history loss
**Error**: History entries disappearing
**Prevention**: Always append to history, never replace array

### Issue #3: Timestamp format inconsistency
**Error**: Date parsing failures
**Prevention**: Always use ISO 8601: `yyyy-MM-ddTHH:mm:ssZ`

### Issue #4: Sync conflicts overwriting data
**Error**: Lost changes after sync
**Prevention**: Use conflict resolution function, merge histories

### Issue #5: Missing log entries
**Error**: Operations not logged
**Prevention**: Always call `Log-Operation` for every action

---

## Using Bundled Resources

### Scripts (scripts/)

**Initialize-DeviceProfile.ps1** - Set up new device
```powershell
.\scripts\Initialize-DeviceProfile.ps1 -AdminRoot "N:/Dropbox/Admin"
```

**Sync-DeviceProfile.ps1** - Verify and update profile
```powershell
.\scripts\Sync-DeviceProfile.ps1
```

**Export-ProfileReport.ps1** - Generate device report
```powershell
.\scripts\Export-ProfileReport.ps1 -OutputFile "device-report.md"
```

### Templates (templates/)

- `profile.json` - Complete profile template
- `device-structure/` - Directory structure template

---

## Complete Setup Checklist

- [ ] Admin root directory chosen and accessible
- [ ] Device directory created (`devices/{DEVICE_NAME}/`)
- [ ] Profile.json initialized
- [ ] Device logs.txt created
- [ ] Central logs directory created
- [ ] Environment variables set (ADMIN_ROOT, DEVICE_NAME)
- [ ] Log-Operation function available
- [ ] Profile update functions available
- [ ] Cross-device sync working (if applicable)

---

## Official Documentation

- **ISO 8601 Timestamps**: https://en.wikipedia.org/wiki/ISO_8601
- **PowerShell JSON**: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertto-json

---

## Package Versions (Verified 2025-12-06)

```json
{
  "schemaVersion": "1.0",
  "requiredPowerShell": "7.0+"
}
```
