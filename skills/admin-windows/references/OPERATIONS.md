# Windows Operations Reference

Extended operations for Windows administration: known issues prevention, bundled resources, troubleshooting, setup checklist, and version snapshots.

## Contents
- Known Issues Prevention
- Using Bundled Resources
- Troubleshooting
- Complete Setup Checklist
- Official Documentation
- Package Versions (Snapshot)

---

## Known Issues Prevention

This skill prevents **15** documented issues:

### Issue #1: Using bash commands in PowerShell
**Error**: `cat : The term 'cat' is not recognized`
**Why It Happens**: PowerShell uses different cmdlets than bash
**Prevention**: Use translation table above (`cat` -> `Get-Content`)

### Issue #2: PATH not persisting
**Error**: Commands work in one session but not another
**Why It Happens**: Setting `$env:PATH` only affects current session
**Prevention**: Use `[Environment]::SetEnvironmentVariable()` for persistence

### Issue #3: JSON depth truncation
**Error**: JSON output shows `@{...}` instead of nested values
**Why It Happens**: Default `-Depth` is 2
**Prevention**: Always use `ConvertTo-Json -Depth 10`

### Issue #4: Profile not loading
**Error**: Profile functions/aliases not available
**Why It Happens**: Wrong profile location or `-NoProfile` flag
**Prevention**: Verify `$PROFILE` path and check startup flags

### Issue #5: Script execution blocked
**Error**: `script.ps1 cannot be loaded because running scripts is disabled`
**Why It Happens**: Execution policy is Restricted
**Prevention**: Set `RemoteSigned` for current user

### Issue #6: npm global commands not found
**Error**: `npm : The term 'npm' is not recognized`
**Why It Happens**: npm path not in system PATH
**Prevention**: Add `%APPDATA%\npm` to User PATH via registry

### Issue #7: PowerShell 5.1 vs 7.x confusion
**Error**: Features not working, different behavior
**Why It Happens**: Using `powershell.exe` (5.1) instead of `pwsh.exe` (7.x)
**Prevention**: Always use `pwsh` command or verify with `$PSVersionTable`

---

## Using Bundled Resources

### Scripts (scripts/)

**Verify-ShellEnvironment.ps1** - Comprehensive environment check
```powershell
.\scripts\Verify-ShellEnvironment.ps1
```

Tests: PowerShell version, profile location, PATH configuration, tool availability

### Templates (templates/)

**profile-template.ps1** - Recommended PowerShell profile
```powershell
Copy-Item templates/profile-template.ps1 $PROFILE
```

---

## Troubleshooting

### Problem: Command not found after installation
**Solution**:
1. Check PATH: `$env:PATH -split ';' | Select-String "expected-path"`
2. Refresh session: Start new PowerShell window
3. Check registry PATH vs session PATH

### Problem: Profile changes not taking effect
**Solution**:
1. Verify profile path: `$PROFILE`
2. Dot-source to reload: `. $PROFILE`
3. Check for syntax errors: `pwsh -NoProfile -Command ". '$PROFILE'"`

### Problem: JSON losing data on save
**Solution**: Always use `-Depth 10` or higher with `ConvertTo-Json`

### Problem: Scripts from internet won't run
**Solution**:
```powershell
# Unblock single file
Unblock-File -Path script.ps1

# Or set execution policy
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## Complete Setup Checklist

- [ ] PowerShell 7.x installed (`pwsh --version`)
- [ ] Execution policy set to RemoteSigned
- [ ] npm path in User PATH (registry)
- [ ] Profile created and loading
- [ ] `.env` file created from template
- [ ] Verification script passes
- [ ] Package managers working (winget, scoop, npm)

---

## Official Documentation

- **PowerShell**: https://learn.microsoft.com/en-us/powershell/
- **winget**: https://learn.microsoft.com/en-us/windows/package-manager/winget/
- **scoop**: https://scoop.sh/
- **chocolatey**: https://chocolatey.org/

---

## Package Versions (Snapshot, Verified 2025-12-06)

```json
{
  "tools": {
    "PowerShell": "7.5.x",
    "winget": "1.9.x",
    "scoop": "0.5.x"
  }
}
```

