---
name: admin-sync
description: |
  Coordinate between Windows and WSL environments. Manage .wslconfig for resource allocation, WSL distribution management, cross-platform file access paths, and handoff protocols between admin-windows and admin-wsl roles.

  Use when: configuring WSL resources, managing WSL distributions, accessing files across Windows/WSL boundaries, coordinating Windows and Linux admin tasks, or troubleshooting "WSL memory", "mount not found", "permission denied" issues.
license: MIT
---

# Windows-WSL Coordination

**Status**: Production Ready
**Last Updated**: 2025-12-06
**Dependencies**: admin-windows skill, admin-wsl skill, WSL2 installed
**WSL Version**: WSL2 with systemd support

---

## Quick Start (5 Minutes)

### 1. Verify WSL Installation

```powershell
# Check WSL version
wsl --version

# List installed distributions
wsl --list --verbose

# Check default distribution
wsl --status
```

### 2. Configure Resources (.wslconfig)

```powershell
# Create or edit .wslconfig
notepad "$env:USERPROFILE\.wslconfig"
```

### 3. Apply Configuration

```powershell
# Shutdown WSL to apply changes
wsl --shutdown

# Start default distribution
wsl
```

---

## Critical Rules

### WinAdmin Handles (Windows Side)

- WSL installation and updates (`wsl --install`, `wsl --update`)
- Resource allocation (`.wslconfig`: memory, CPU, swap)
- WSL distribution management (`wsl --list`, `wsl --set-default`)
- Windows Terminal WSL profile configuration
- Docker Desktop settings (Windows app)
- Git Credential Manager configuration

### WSL Admin Handles (Linux Side)

- Linux package installation (`apt install`)
- Docker container management
- Python environments (`uv`, `venv`)
- Shell configuration (`.zshrc`, `.bashrc`)
- systemd services
- Linux file permissions (`chmod`, `chown`)
- Git operations within WSL

### Never Do

- Run `apt install` from Windows PowerShell
- Modify `.wslconfig` from inside WSL
- Use Windows paths directly in Linux scripts
- Edit Linux files with Windows tools that don't handle line endings
- Assume PATH is shared between Windows and WSL

---

## .wslconfig Reference

### File Location

```
C:\Users\{USERNAME}\.wslconfig
```

PowerShell:
```powershell
$wslConfigPath = "$env:USERPROFILE\.wslconfig"
```

### Complete .wslconfig Template

```ini
# Settings apply to all WSL 2 distributions

[wsl2]
# Memory - How much memory to assign to the WSL 2 VM
# Default: 50% of total memory on Windows or 8GB, whichever is less
memory=16GB

# Processors - How many processors to assign to the WSL 2 VM
# Default: Same number as Windows
processors=8

# Swap - How much swap space to add to the WSL 2 VM
# Default: 25% of available memory
swap=4GB

# Swap file path - Custom swap VHD path
# swapFile=C:\\temp\\wsl-swap.vhdx

# Page reporting - Enable/disable page reporting (memory release)
# Default: true
pageReporting=true

# Localhost forwarding - Enable localhost access from Windows to WSL
# Default: true
localhostForwarding=true

# Nested virtualization - Enable nested virtualization
# Default: true
nestedVirtualization=true

# Debug console - Enable output console for debug messages
# debugConsole=false

# GUI applications - Enable WSLg GUI support
# Default: true
guiApplications=true

# GPU support - Enable GPU compute support
# Default: true
# gpuSupport=true

# Firewall - Apply Windows Firewall rules to WSL
# Default: true
# firewall=true

# DNS tunneling - Enable DNS tunneling
# Default: true
# dnsTunneling=true

# Auto proxy - Use Windows HTTP proxy settings
# Default: true
# autoProxy=true

[experimental]
# Sparse VHD - Enable automatic compaction of WSL virtual hard disk
sparseVhd=true

# Auto memory reclaim - Reclaim cached memory
# Options: disabled, dropcache, gradual
autoMemoryReclaim=gradual

# Network mode - mirrored mirrors Windows networking
# networkingMode=mirrored
```

### Resource Recommendations

| System RAM | WSL Memory | Processors | Swap |
|------------|------------|------------|------|
| 16GB | 8GB | 4 | 2GB |
| 32GB | 16GB | 8 | 4GB |
| 64GB | 24GB | 12 | 8GB |
| 128GB | 48GB | 16 | 16GB |

---

## WSL Commands Reference

### Distribution Management

```powershell
# List all distributions
wsl --list --verbose
wsl -l -v

# Set default distribution
wsl --set-default Ubuntu-24.04

# Run specific distribution
wsl -d Ubuntu-24.04

# Run as specific user
wsl -d Ubuntu-24.04 -u root

# Terminate specific distribution
wsl --terminate Ubuntu-24.04

# Shutdown all WSL
wsl --shutdown

# Unregister (delete) distribution
wsl --unregister Ubuntu-24.04
```

### Installation and Updates

```powershell
# Install WSL (first time)
wsl --install

# Install specific distribution
wsl --install -d Ubuntu-24.04

# Update WSL
wsl --update

# Check WSL version
wsl --version

# List available distributions
wsl --list --online
```

### Import/Export

```powershell
# Export distribution to tar
wsl --export Ubuntu-24.04 D:\backups\ubuntu-backup.tar

# Import distribution from tar
wsl --import Ubuntu-Custom D:\wsl\ubuntu-custom D:\backups\ubuntu-backup.tar

# Set imported distribution version to WSL2
wsl --set-version Ubuntu-Custom 2
```

### Run Commands

```powershell
# Run single command in WSL
wsl -d Ubuntu-24.04 -e bash -c "echo Hello from WSL"

# Run command and return to Windows
wsl -d Ubuntu-24.04 -- ls -la /home

# Run with specific working directory
wsl -d Ubuntu-24.04 --cd /home/user -- pwd
```

---

## Cross-Platform File Access

### Windows Accessing WSL Files

```powershell
# UNC path to WSL filesystem
\\wsl$\Ubuntu-24.04\home\username\

# In PowerShell
$wslHome = "\\wsl$\Ubuntu-24.04\home\username"
Get-ChildItem $wslHome

# Read file from WSL
Get-Content "\\wsl$\Ubuntu-24.04\home\username\.bashrc"

# Copy file from WSL to Windows
Copy-Item "\\wsl$\Ubuntu-24.04\home\username\file.txt" "C:\Users\Owner\Documents\"
```

### WSL Accessing Windows Files

```bash
# Windows drives are mounted at /mnt/
/mnt/c/Users/Owner/Documents/
/mnt/d/projects/

# Access Windows file from WSL
cat /mnt/c/Users/Owner/.gitconfig

# Copy file from Windows to WSL
cp /mnt/d/projects/file.txt ~/

# Navigate to Windows directory
cd /mnt/d/projects
```

### Path Conversion

```powershell
# Windows to WSL path (PowerShell)
function Convert-ToWslPath {
    param([string]$WindowsPath)
    $path = $WindowsPath -replace '\\', '/'
    $path = $path -replace '^([A-Za-z]):', '/mnt/$1'.ToLower()
    $path
}

# Usage
Convert-ToWslPath "D:\projects\myapp"
# Returns: /mnt/d/projects/myapp
```

```bash
# WSL to Windows path (Bash)
wslpath -w /home/username/file.txt
# Returns: \\wsl$\Ubuntu-24.04\home\username\file.txt

# Windows to WSL path (Bash)
wslpath -u 'C:\Users\Owner\Documents'
# Returns: /mnt/c/Users/Owner/Documents
```

### Path Mapping Table

| Windows Path | WSL Path |
|--------------|----------|
| `C:\Users\Owner` | `/mnt/c/Users/Owner` |
| `D:\projects` | `/mnt/d/projects` |
| `N:\Dropbox` | `/mnt/n/Dropbox` |
| `\\wsl$\Ubuntu\home\user` | `/home/user` |

---

## Handoff Protocols

### WinAdmin → WSL Admin Handoff

When Windows admin encounters a WSL-specific task:

```powershell
function Request-WslAdminHandoff {
    param(
        [Parameter(Mandatory)][string]$Task,
        [string]$Details,
        [string]$AdminRoot = $env:ADMIN_ROOT
    )

    # Log handoff request
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - [$env:COMPUTERNAME-WIN] [REQUIRES-WSL-ADMIN] $Task - $Details"

    if ($AdminRoot) {
        Add-Content "$AdminRoot/logs/central/operations.log" -Value $logEntry
    }

    # Display handoff message
    Write-Host "`n" -NoNewline
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "  This operation requires WSL Admin" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please switch to WSL environment:" -ForegroundColor Cyan
    Write-Host "  wsl -d Ubuntu-24.04" -ForegroundColor White
    Write-Host "  cd ~/dev/wsl-admin" -ForegroundColor White
    Write-Host ""
    Write-Host "Task for WSL Admin:" -ForegroundColor Cyan
    Write-Host "  $Task" -ForegroundColor White
    if ($Details) {
        Write-Host "  $Details" -ForegroundColor Gray
    }
    Write-Host ""
}

# Usage
Request-WslAdminHandoff -Task "Install Python packages" -Details "pip install pandas numpy"
```

### WSL Admin → WinAdmin Handoff

When WSL admin encounters a Windows-specific task:

```bash
#!/bin/bash
# request-winadmin-handoff.sh

request_winadmin_handoff() {
    local task="$1"
    local details="$2"

    # Log handoff request
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local hostname=$(hostname)
    local log_entry="$timestamp - [$hostname-WSL] [REQUIRES-WINADMIN] $task - $details"

    if [ -n "$ADMIN_ROOT" ]; then
        echo "$log_entry" >> "$ADMIN_ROOT/logs/central/operations.log"
    fi

    # Display handoff message
    echo ""
    echo "========================================"
    echo "  This operation requires WinAdmin"
    echo "========================================"
    echo ""
    echo "Please exit WSL and use PowerShell:"
    echo "  exit"
    echo "  cd D:\\_admin"
    echo ""
    echo "Task for WinAdmin:"
    echo "  $task"
    if [ -n "$details" ]; then
        echo "  $details"
    fi
    echo ""
}

# Usage
# request_winadmin_handoff "Increase WSL memory" "Edit .wslconfig, set memory=32GB"
```

### Log Tags for Cross-Admin Communication

| Tag | Meaning | Example |
|-----|---------|---------|
| `[REQUIRES-WSL-ADMIN]` | WinAdmin needs WSL Admin | Package installation |
| `[REQUIRES-WINADMIN]` | WSL Admin needs WinAdmin | Memory increase |
| `[AFFECTS-WSL]` | Windows change affects WSL | .wslconfig edit |
| `[AFFECTS-WINDOWS]` | WSL change affects Windows | Git credential |
| `[CROSS-PLATFORM]` | Involves both | Shared project setup |

---

## Decision Matrix

| Operation | WinAdmin | WSL Admin | Notes |
|-----------|----------|-----------|-------|
| Install Windows app | ✅ | - | winget, scoop |
| Install Linux package | - | ✅ | apt, dpkg |
| Edit .wslconfig | ✅ | - | Windows file |
| Docker containers | - | ✅ | Runs in WSL |
| Docker Desktop settings | ✅ | - | Windows app |
| MCP server setup | ✅ | - | Claude Desktop is Windows |
| Python venv (WSL) | - | ✅ | uv, venv |
| Python venv (Windows) | ✅ | - | Windows Python |
| Windows Terminal profile | ✅ | - | Windows Terminal app |
| .zshrc / .bashrc | - | ✅ | WSL user config |
| systemd services | - | ✅ | Linux systemd |
| Windows services | ✅ | - | sc.exe |
| WSL memory/CPU | ✅ | - | .wslconfig |
| npm global (Windows) | ✅ | - | Windows npm |
| npm global (WSL) | - | ✅ | WSL npm |
| Git commits | Either | Either | User preference |
| Git credential manager | ✅ | - | Windows GCM |

---

## Common Operations

### Increase WSL Memory

```powershell
# 1. Check current memory usage
wsl -d Ubuntu-24.04 -e free -h

# 2. Edit .wslconfig
$config = @"
[wsl2]
memory=32GB
processors=12
swap=8GB
"@
$config | Set-Content "$env:USERPROFILE\.wslconfig"

# 3. Restart WSL
wsl --shutdown
Start-Sleep 2
wsl -d Ubuntu-24.04 -e free -h

# 4. Log the change
Log-Operation -Status "SUCCESS" -Operation "WSL Config" `
    -Details "Increased memory to 32GB" -LogType "system-change"
```

### Check WSL Resource Usage

```powershell
function Get-WslResourceUsage {
    param([string]$Distribution = "Ubuntu-24.04")

    Write-Host "`n=== WSL Resource Usage ===" -ForegroundColor Cyan

    # Memory
    Write-Host "`nMemory:" -ForegroundColor Yellow
    wsl -d $Distribution -e free -h

    # Disk
    Write-Host "`nDisk:" -ForegroundColor Yellow
    wsl -d $Distribution -e df -h /

    # Processes
    Write-Host "`nTop Processes:" -ForegroundColor Yellow
    wsl -d $Distribution -e bash -c "ps aux --sort=-%mem | head -10"
}

Get-WslResourceUsage
```

### Reclaim WSL Disk Space

```powershell
# 1. Inside WSL - clean up
wsl -d Ubuntu-24.04 -e sudo apt autoremove -y
wsl -d Ubuntu-24.04 -e sudo apt clean

# 2. Shutdown WSL
wsl --shutdown

# 3. Compact the virtual disk (requires admin PowerShell)
$vhdxPath = "$env:LOCALAPPDATA\Packages\CanonicalGroupLimited.Ubuntu24.04LTS_*\LocalState\ext4.vhdx"
$vhdx = Get-ChildItem $vhdxPath | Select-Object -First 1

if ($vhdx) {
    Write-Host "Compacting: $($vhdx.FullName)"
    Optimize-VHD -Path $vhdx.FullName -Mode Full
    Write-Host "Compaction complete" -ForegroundColor Green
}
```

### Set Up Shared Directory

```powershell
# Create shared directory accessible from both
$sharedPath = "D:\shared"
New-Item -ItemType Directory -Path $sharedPath -Force

# WSL can access via /mnt/d/shared
Write-Host "Windows path: $sharedPath"
Write-Host "WSL path: /mnt/d/shared"
```

---

## Line Ending Handling

### Problem: CRLF vs LF

Windows uses CRLF (`\r\n`), Linux uses LF (`\n`).

### Solutions

```powershell
# Convert Windows file to Unix (for use in WSL)
$content = Get-Content "script.sh" -Raw
$content = $content -replace "`r`n", "`n"
[System.IO.File]::WriteAllText("script.sh", $content)
```

```bash
# Convert in WSL using dos2unix
sudo apt install dos2unix
dos2unix script.sh

# Convert back to Windows
unix2dos script.sh
```

### Git Configuration

```powershell
# Configure Git to handle line endings
git config --global core.autocrlf true     # Windows
git config --global core.autocrlf input    # WSL

# Or use .gitattributes
@"
* text=auto
*.sh text eol=lf
*.ps1 text eol=crlf
"@ | Set-Content ".gitattributes"
```

---

## Troubleshooting

### Problem: WSL not starting

```powershell
# Check WSL status
wsl --status

# Update WSL
wsl --update

# Reset network
netsh winsock reset

# Restart WSL service
Restart-Service LxssManager
```

### Problem: WSL using too much memory

```powershell
# Add memory reclaim to .wslconfig
@"
[wsl2]
memory=16GB

[experimental]
autoMemoryReclaim=gradual
"@ | Set-Content "$env:USERPROFILE\.wslconfig"

wsl --shutdown
```

### Problem: Can't access Windows files from WSL

```bash
# Check if drives are mounted
ls /mnt/

# If missing, check /etc/wsl.conf
cat /etc/wsl.conf

# Should have:
# [automount]
# enabled = true
# root = /mnt/
# options = "metadata"
```

### Problem: Permission denied on WSL files from Windows

```powershell
# Access WSL files through \\wsl$ path
# NOT through the AppData path directly

# Correct:
Get-Content "\\wsl$\Ubuntu-24.04\home\user\file.txt"

# Wrong (may have permission issues):
Get-Content "$env:LOCALAPPDATA\Packages\...\LocalState\rootfs\home\user\file.txt"
```

---

## Known Issues Prevention

### Issue #1: Editing .wslconfig from WSL
**Error**: Changes don't take effect
**Prevention**: Always edit from Windows, then `wsl --shutdown`

### Issue #2: Running apt from PowerShell
**Error**: Command not found
**Prevention**: Use `wsl -e apt install` or switch to WSL

### Issue #3: Windows paths in Linux scripts
**Error**: Path not found
**Prevention**: Use `wslpath` to convert paths

### Issue #4: Line ending corruption
**Error**: Script has `^M` characters
**Prevention**: Use `dos2unix` or configure Git

### Issue #5: Memory not reclaimed
**Error**: WSL VM keeps growing
**Prevention**: Enable `autoMemoryReclaim=gradual`

---

## Using Bundled Resources

### Scripts (scripts/)

**Get-WslStatus.ps1** - Comprehensive WSL status report
```powershell
.\scripts\Get-WslStatus.ps1
```

**Set-WslResources.ps1** - Configure WSL resources
```powershell
.\scripts\Set-WslResources.ps1 -Memory 16GB -Processors 8
```

### Templates (templates/)

- `.wslconfig` - Complete configuration template
- `wsl.conf` - WSL distribution configuration

---

## Complete Setup Checklist

- [ ] WSL2 installed (`wsl --version`)
- [ ] Distribution installed (`wsl -l -v`)
- [ ] .wslconfig created with resource limits
- [ ] WSL restarted after config changes
- [ ] Cross-platform paths working
- [ ] Git line endings configured
- [ ] Handoff protocols understood
- [ ] Logging configured for cross-admin

---

## Official Documentation

- **WSL Documentation**: https://learn.microsoft.com/en-us/windows/wsl/
- **WSL Config**: https://learn.microsoft.com/en-us/windows/wsl/wsl-config
- **WSL Filesystems**: https://learn.microsoft.com/en-us/windows/wsl/filesystems

---

## Package Versions (Verified 2025-12-06)

```json
{
  "wsl": "2.x",
  "distributions": {
    "Ubuntu-24.04": "Supported",
    "Ubuntu-22.04": "Supported",
    "Debian": "Supported"
  }
}
```
