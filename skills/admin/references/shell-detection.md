# Shell Detection Reference

This document explains how the admin skill detects and adapts to different shell environments.

## Why Shell Detection Matters

Claude Code can run in different shell environments:
- **PowerShell** (Windows native)
- **Bash** (WSL, Linux, macOS, Git Bash)

The commands for these shells are completely different. Using bash syntax in PowerShell (or vice versa) causes errors.

## Detection Method

### Automatic Detection

Claude Code determines the shell based on which commands work:

1. **Try `echo $BASH_VERSION`**
   - If it returns a version string → Bash mode
   - If it fails or returns empty → Check PowerShell

2. **Try `$PSVersionTable.PSVersion`**
   - If it returns version info → PowerShell mode
   - If it fails → Likely Bash mode

### Environment Indicators

| Indicator | Bash | PowerShell |
|-----------|------|------------|
| `$BASH_VERSION` | Has value | Empty/Error |
| `$PSVersionTable` | Error | Has value |
| `$HOME` | User home | Empty |
| `$env:USERPROFILE` | Empty | User home |
| Path separator | `/` | `\` |

## Shell Mode Syntax Comparison

### Directory Creation

**Bash:**
```bash
mkdir -p ~/.admin/logs/devices/$(hostname)
```

**PowerShell:**
```powershell
New-Item -ItemType Directory -Force -Path (Join-Path $env:USERPROFILE '.admin\logs\devices' $env:COMPUTERNAME)
```

### Environment Variables

**Bash:**
```bash
DEVICE_NAME="${DEVICE_NAME:-$(hostname)}"
echo $DEVICE_NAME
```

**PowerShell:**
```powershell
$DEVICE_NAME = if ($env:DEVICE_NAME) { $env:DEVICE_NAME } else { $env:COMPUTERNAME }
Write-Output $DEVICE_NAME
```

### File Existence Check

**Bash:**
```bash
if [[ -f ".env.local" ]]; then
    source .env.local
fi
```

**PowerShell:**
```powershell
if (Test-Path '.env.local') {
    # Load env file
    Get-Content '.env.local' | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
        }
    }
}
```

### Command Output

**Bash:**
```bash
result=$(some_command)
echo "$result"
```

**PowerShell:**
```powershell
$result = some_command
Write-Output $result
```

### Conditional Logic

**Bash:**
```bash
if [[ "$platform" == "wsl" ]]; then
    echo "In WSL"
elif [[ "$platform" == "windows" ]]; then
    echo "In Windows"
fi
```

**PowerShell:**
```powershell
if ($platform -eq 'wsl') {
    Write-Output "In WSL"
} elseif ($platform -eq 'windows') {
    Write-Output "In Windows"
}
```

### Path Handling

**Bash:**
```bash
log_file="$HOME/.admin/logs/operations.log"
```

**PowerShell:**
```powershell
$logFile = Join-Path $env:USERPROFILE '.admin\logs\operations.log'
```

## Common Issues

### Issue: Environment Variable Expansion Fails

**Symptom:** `$env:USERPROFILE` becomes `:USERPROFILE` or empty

**Cause:** Bash trying to interpret PowerShell syntax

**Solution:** Use the correct syntax for the detected shell

### Issue: Path Format Errors

**Symptom:** `The given path's format is not supported`

**Cause:** Using forward slashes or Unix paths in PowerShell

**Solution:** Use `Join-Path` in PowerShell, string paths in Bash

### Issue: Command Not Found

**Symptom:** `mkdir: command not found` in PowerShell

**Cause:** PowerShell uses different command names

**Solution:** Use `New-Item -ItemType Directory` in PowerShell

## Best Practices

1. **Always detect shell first** - Before running any commands
2. **Don't mix syntaxes** - Use all Bash or all PowerShell
3. **Use Join-Path in PowerShell** - Never concatenate paths with strings
4. **Test in both environments** - Verify commands work in both shells
5. **Provide clear handoff messages** - When a task needs the other shell

## Platform + Shell Matrix

| Platform | Shell | Detection | Config Location |
|----------|-------|-----------|-----------------|
| Windows | PowerShell | Native Windows Claude Code | `%USERPROFILE%\.admin` |
| Windows | Bash | Git Bash Claude Code | `~/.admin` |
| WSL | Bash | WSL Claude Code | `~/.admin` |
| Linux | Bash | Linux Claude Code | `~/.admin` |
| macOS | Bash/Zsh | macOS Claude Code | `~/.admin` |

## Related Files

- `admin/SKILL.md` - Main skill with dual-mode commands
- `admin/references/first-run-setup.md` - Setup guide with both syntaxes
- `admin/references/cross-platform.md` - Windows ↔ WSL coordination
