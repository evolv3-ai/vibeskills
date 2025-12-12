# Admin Skills Suite - Implementation Phases

**Project**: Admin Skills Redesign
**Created**: 2025-12-08
**Source**: planning/admin-skills-redesign.md
**Total Phases**: 6
**Estimated Effort**: ~8-10 hours total

---

## Overview

Restructure 14 `admin-*` skills into a cohesive, user-agnostic system with a central orchestrator. Goals:

1. Work for ANY user (no hardcoded author-specific values)
2. Single entry point (`admin`) that routes to specialists
3. Centralized logging and configuration
4. Installable in any project, activates on relevant keywords
5. Works both standalone and as integrated suite

**Final State**: 13 skills (absorb 2 into orchestrator)

---

## Phase 1: Create `admin` Orchestrator

**Type**: Foundation | **Effort**: ~2 hours

### Tasks

- [ ] Create `skills/admin/` directory structure
- [ ] Write `admin/SKILL.md` with:
  - Platform detection logic (Windows/WSL/Linux/macOS)
  - Routing decision tree
  - Centralized logging function
  - Device profile management
  - First-run setup flow
- [ ] Write `admin/README.md` with comprehensive keywords
- [ ] Create `admin/.env.template` (master configuration)
- [ ] Move `admin-servers/assets/env-spec.txt` → `admin/assets/env-spec.txt`
- [ ] Create `admin/assets/profile-schema.json`
- [ ] Create `admin/references/routing-guide.md`
- [ ] Create `admin/references/first-run-setup.md`
- [ ] Test skill activation on "admin" keyword

### Key Files

```
skills/admin/
├── SKILL.md
├── README.md
├── .env.template
├── assets/
│   ├── env-spec.txt          (moved from admin-servers)
│   └── profile-schema.json
├── references/
│   ├── routing-guide.md
│   └── first-run-setup.md
└── templates/
    └── profile.json
```

### Success Criteria

- `admin` skill activates correctly
- Platform detection works in WSL
- Routing logic documented and testable
- No breaking changes to existing skills

---

## Phase 2: Absorb admin-specs

**Type**: Migration | **Effort**: ~1.5 hours

### Tasks

- [ ] Review `admin-specs/SKILL.md` for content to extract
- [ ] Move `admin-specs/templates/profile.json` → `admin/templates/`
- [ ] Create `admin/references/logging.md` from specs content
- [ ] Merge `admin-specs/.env.template` variables into `admin/.env.template`
- [ ] Update `admin/SKILL.md` with profile management section
- [ ] Test profile creation and logging
- [ ] Mark `admin-specs/` for archival

### Content to Extract

- Profile JSON schema
- Log-Operation function
- Installation history tracking
- Multi-device sync patterns

### Success Criteria

- All admin-specs functionality available in admin
- Logging function works correctly
- Profile template generates valid JSON

---

## Phase 3: Absorb admin-sync

**Type**: Migration | **Effort**: ~1.5 hours

### Tasks

- [ ] Review `admin-sync/SKILL.md` for content to extract
- [ ] Create `admin/references/cross-platform.md` with:
  - Windows ↔ WSL path conversion
  - `.wslconfig` management guidance
  - Handoff tags (`[REQUIRES-WINADMIN]`, `[REQUIRES-WSL-ADMIN]`)
  - Decision matrix (which admin handles what)
- [ ] Integrate handoff protocol into `admin/SKILL.md` routing
- [ ] Merge `admin-sync/.env.template` variables into `admin/.env.template`
- [ ] Update path mapping tables
- [ ] Test cross-platform handoff detection
- [ ] Mark `admin-sync/` for archival

### Success Criteria

- Cross-platform coordination documented
- Handoff detection works correctly
- Path conversion examples available

---

## Phase 4: Update Sub-Skills

**Type**: Refactoring | **Effort**: ~2-3 hours

### Tasks

For each remaining skill (11 skills):

- [ ] `admin-servers`: Remove local logging, use centralized, delete env-spec.txt
- [ ] `admin-windows`: Add logging calls, parameterize hardcoded paths
- [ ] `admin-wsl`: Add logging calls, parameterize hardcoded paths
- [ ] `admin-mcp`: Add logging calls
- [ ] `admin-infra-oci`: Ensure .env.template compliance
- [ ] `admin-infra-hetzner`: Ensure .env.template compliance
- [ ] `admin-infra-digitalocean`: Ensure .env.template compliance
- [ ] `admin-infra-vultr`: Ensure .env.template compliance
- [ ] `admin-infra-linode`: Ensure .env.template compliance
- [ ] `admin-infra-contabo`: Ensure .env.template compliance
- [ ] `admin-app-coolify`: Ensure .env.template compliance
- [ ] `admin-app-kasm`: Ensure .env.template compliance

### Hardcoded Values to Replace

| Value | Replacement |
|-------|-------------|
| `wsladmin` | `$ADMIN_USER` |
| `WOPR3` | `$DEVICE_NAME` |
| `~/dev/wsl-admin` | `$WSL_ADMIN_PATH` |
| `/mnt/n/Dropbox/08_Admin` | `$ADMIN_ROOT` |
| `/home/wsladmin/` | `$HOME` or `$WSL_HOME` |
| `C:\Users\Owner` | `$WIN_USER_HOME` |

### Success Criteria

- All skills use centralized logging
- No hardcoded author-specific paths
- All .env.template files comply with env-spec.txt

---

## Phase 5: Testing

**Type**: Verification | **Effort**: ~1 hour

### Unit Tests (per skill)

- [ ] `admin` activates on "admin" keyword
- [ ] `admin` activates on "manage my servers"
- [ ] Platform detection works (Windows, WSL, Linux)
- [ ] Routing works: server tasks → admin-servers
- [ ] Routing works: Windows tasks → admin-windows
- [ ] Routing works: WSL tasks → admin-wsl
- [ ] Logging function writes to correct files
- [ ] Profile creation works
- [ ] First-run setup completes

### Integration Tests

- [ ] Fresh install flow (no .env.local exists)
- [ ] Server provisioning flow: admin → admin-servers → admin-infra-*
- [ ] Application deployment flow: admin → admin-servers → admin-app-*
- [ ] Windows administration flow: admin → admin-windows
- [ ] Cross-platform task coordination

### User Acceptance Tests

- [ ] New user experience (first-time setup)
- [ ] Sub-skills work standalone (without admin)
- [ ] Integrated operation works

### Success Criteria

- All tests pass
- New user can complete setup without errors
- Existing functionality preserved

---

## Phase 6: Archive Old Skills

**Type**: Cleanup | **Effort**: ~0.5 hours

### Tasks

- [ ] Create archive branch: `archive/admin-specs-admin-sync`
- [ ] Move skills to archive branch
- [ ] Remove from main branch
- [ ] Update CLAUDE.md with new structure
- [ ] Update any cross-references in other skills
- [ ] Update skills-roadmap.md
- [ ] Final commit and documentation

### Git Commands

```bash
# Archive to branch
git checkout -b archive/admin-specs-admin-sync
git mv skills/admin-specs archive/
git mv skills/admin-sync archive/
git commit -m "Archive admin-specs and admin-sync (absorbed into admin)"
git push origin archive/admin-specs-admin-sync

# Remove from main
git checkout main
rm -rf skills/admin-specs skills/admin-sync
git commit -m "Remove admin-specs and admin-sync (absorbed into admin orchestrator)"
```

### Success Criteria

- Old skills archived (retrievable if needed)
- Main branch clean
- Documentation updated
- Total: 13 skills (down from 14)

---

## Dependency Graph

```
Phase 1 (admin orchestrator)
    │
    ├── Phase 2 (absorb admin-specs)
    │
    └── Phase 3 (absorb admin-sync)
            │
            └── Phase 4 (update sub-skills)
                    │
                    └── Phase 5 (testing)
                            │
                            └── Phase 6 (archive)
```

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Breaking existing workflows | Sub-skills continue to work standalone |
| Missing functionality | Extract all content from absorbed skills |
| Hardcoded values missed | Use grep to find all occurrences |
| Logging failures | Test logging function thoroughly |
| Platform detection errors | Test on Windows, WSL, and Linux |

---

## Post-Implementation

After all phases complete:

1. Update CLAUDE.md with new admin suite structure
2. Generate marketplace manifests for new `admin` skill
3. Consider deprecation notice period for absorbed skills
4. Monitor for issues in production use

---
---

# Feature: PowerShell Compatibility (Added 2025-12-08)

Add native Windows PowerShell support to admin skills so they work correctly when Claude Code runs on Windows (not WSL). The admin orchestrator should detect the shell environment and provide platform-appropriate commands.

**Problem**: When running Claude Code natively on Windows, the admin skill provides bash commands that fail. Environment variables like `$env:USERPROFILE` get mangled when passed through bash wrappers.

**Solution**: Add dual-mode support - detect shell environment at initialization and provide PowerShell commands when on Windows, bash commands when on WSL/Linux/macOS.

---

## Phase 7: Add Shell Detection to Admin Orchestrator

**Type**: Enhancement | **Effort**: ~1.5 hours

### Tasks

- [ ] Add shell detection logic to `admin/SKILL.md`:
  - Detect if running in PowerShell vs Bash
  - Check `$PSVersionTable` for PowerShell
  - Check `$BASH_VERSION` for Bash
- [ ] Create `admin/references/shell-detection.md` with detection patterns
- [ ] Update platform detection to be shell-aware:
  - Windows + PowerShell = native Windows
  - Windows + Bash = Git Bash or WSL
  - WSL + Bash = WSL Linux
- [ ] Add "Shell Context" section to skill output
- [ ] Test detection in both environments

### Shell Detection Logic

```markdown
## Detecting Shell Environment

When activated, determine shell context:

1. **Check for PowerShell**:
   - If `$PSVersionTable` exists → PowerShell
   - If `$env:PSModulePath` exists → PowerShell

2. **Check for Bash**:
   - If `$BASH_VERSION` exists → Bash
   - If `/proc/version` contains "microsoft" → WSL Bash
   - Otherwise → Native Linux/macOS Bash

3. **Set execution mode**:
   - PowerShell mode: Use PowerShell syntax for all commands
   - Bash mode: Use Bash syntax for all commands
```

### Success Criteria

- Shell detection works in PowerShell terminal
- Shell detection works in WSL bash
- Shell detection works in Git Bash
- Clear output shows detected shell

---

## Phase 8: Add PowerShell Initialization Commands

**Type**: Enhancement | **Effort**: ~2 hours

### Tasks

- [ ] Add PowerShell version of first-run setup to `admin/SKILL.md`
- [ ] Add PowerShell version of directory creation
- [ ] Add PowerShell version of environment loading
- [ ] Add PowerShell logging function (already exists, verify works)
- [ ] Add PowerShell profile creation
- [ ] Update `admin/references/first-run-setup.md` with PowerShell section

### PowerShell Commands to Add

```powershell
# First-run setup (PowerShell)
$adminRoot = Join-Path $env:USERPROFILE '.admin'
New-Item -ItemType Directory -Force -Path (Join-Path $adminRoot 'logs\devices\' + $env:COMPUTERNAME)
New-Item -ItemType Directory -Force -Path (Join-Path $adminRoot 'profiles')
New-Item -ItemType Directory -Force -Path (Join-Path $adminRoot 'config')

# Environment loading
if (Test-Path '.env.local') {
    Get-Content '.env.local' | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
        }
    }
}

# Profile creation
$profile = @{
    deviceInfo = @{
        name = $env:COMPUTERNAME
        platform = 'windows'
        hostname = $env:COMPUTERNAME
        user = $env:USERNAME
        lastUpdated = (Get-Date -Format 'o')
    }
    installedTools = @{}
    managedServers = @()
}
$profile | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $adminRoot "profiles\$env:COMPUTERNAME.json")
```

### Success Criteria

- First-run setup works in PowerShell
- Directories created correctly
- Profile JSON created with correct structure
- No bash syntax errors

---

## Phase 9: Update Sub-Skills with PowerShell Support

**Type**: Enhancement | **Effort**: ~2-3 hours

### Tasks

Update each Windows-relevant skill with PowerShell commands:

- [ ] `admin-windows`: Already PowerShell-focused, verify commands work
- [ ] `admin-mcp`: Add PowerShell commands for MCP server management
- [ ] `admin-servers`: Add PowerShell SSH/connection commands
- [ ] `admin-infra-*` (6 skills): Add PowerShell CLI alternatives where applicable

### Priority Order

1. **admin-windows** - Core Windows skill, must work perfectly
2. **admin-mcp** - Claude Desktop configuration is Windows-only
3. **admin-servers** - SSH works from PowerShell, verify syntax
4. **admin-infra-*** - Lower priority, most use CLI tools that work in both

### Command Pattern

Each skill should have dual-mode sections:

```markdown
### Create Directory

**Bash/WSL**:
```bash
mkdir -p ~/.admin/logs
```

**PowerShell**:
```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.admin\logs"
```
```

### Success Criteria

- admin-windows works natively on Windows
- admin-mcp works natively on Windows
- Other skills degrade gracefully with clear instructions

---

## Phase 10: Testing PowerShell Compatibility

**Type**: Verification | **Effort**: ~1 hour

### Test Matrix

| Test | WSL Claude Code | Windows Claude Code |
|------|-----------------|---------------------|
| Shell detection | ✅ Detects Bash | ✅ Detects PowerShell |
| Platform detection | ✅ Returns "wsl" | ✅ Returns "windows" |
| First-run setup | ✅ Creates ~/.admin | ✅ Creates %USERPROFILE%\.admin |
| Logging | ✅ Writes logs | ✅ Writes logs |
| Profile creation | ✅ Creates JSON | ✅ Creates JSON |
| admin-windows | ⚠️ Handoff | ✅ Works natively |
| admin-mcp | ⚠️ Handoff | ✅ Works natively |
| admin-wsl | ✅ Works natively | ⚠️ Handoff |

### Test Procedure

1. Run Claude Code from WSL terminal
   - Invoke admin skill
   - Verify bash commands work
   - Verify Windows tasks show handoff message

2. Run Claude Code from Windows (D:\admin or similar)
   - Invoke admin skill
   - Verify PowerShell commands work
   - Verify WSL tasks show handoff message

3. Cross-environment test
   - Create profile in Windows
   - Verify readable from WSL (via shared ~/.admin)
   - Create log in WSL
   - Verify readable from Windows

### Success Criteria

- All tests in matrix pass
- No shell syntax errors in either environment
- Handoff messages clear and actionable

---

## Phase 11: Documentation Update

**Type**: Documentation | **Effort**: ~0.5 hours

### Tasks

- [ ] Update `admin/SKILL.md` Quick Start with dual-mode examples
- [ ] Update `admin/README.md` keywords to include "powershell"
- [ ] Create `admin/references/powershell-commands.md` reference
- [ ] Update `admin/references/first-run-setup.md` with PowerShell flow
- [ ] Add troubleshooting section for Windows-specific issues

### Documentation Sections to Add

```markdown
## Shell Compatibility

This skill works in both PowerShell and Bash environments:

| Environment | Shell | Commands Used |
|-------------|-------|---------------|
| Windows native | PowerShell | PowerShell cmdlets |
| WSL | Bash | Bash commands |
| macOS | Bash/Zsh | Bash commands |
| Linux | Bash | Bash commands |

The skill automatically detects your shell and provides appropriate commands.
```

### Success Criteria

- Clear documentation for both environments
- Troubleshooting covers common Windows issues
- Keywords updated for discoverability

---

## Dependency Graph (PowerShell Feature)

```
Phase 7 (shell detection)
    │
    └── Phase 8 (PowerShell init commands)
            │
            └── Phase 9 (update sub-skills)
                    │
                    └── Phase 10 (testing)
                            │
                            └── Phase 11 (documentation)
```

---

## Risk Mitigation (PowerShell Feature)

| Risk | Mitigation |
|------|------------|
| PowerShell version differences | Test on PowerShell 5.1 and 7.x |
| Path format issues | Use Join-Path instead of string concatenation |
| Environment variable expansion | Use proper PowerShell syntax ($env:VAR) |
| Breaking bash functionality | Keep both modes, don't remove bash |
| Claude Code shell detection | Test actual behavior in both terminals |

---

# Feature: Admin Compatibility & Shared Root Fixes (Added 2025-12-11)

Patch the admin suite after Windows/WSL unification: align generated profiles with the expanded schema, fix PowerShell detection/back-compat, and update WSL docs to the shared Windows `.admin` root.

---

## Phase 12: Schema-Compliant Profile Creation

**Type**: Bugfix | **Effort**: ~0.5 hours

### Tasks

- [x] Update `skills/admin/SKILL.md` `update_profile()` to emit `schemaVersion` and all required top-level sections (deviceInfo fields, packageManagers, installationHistory, systemInfo, paths, syncSettings).
- [x] Ensure default values match `skills/admin/templates/profile.json` and `assets/profile-schema.json`.
- [x] Keep WSL shared-root logic intact when selecting profile path.

### Verification Criteria

- Running `update_profile` creates a profile that validates against `assets/profile-schema.json`.
- Profile contains `schemaVersion` and the new sections with sensible defaults.
- No regressions to logging or handoff behavior.

---

## Phase 13: PowerShell Detection & Back-Compat

**Type**: Bugfix | **Effort**: ~0.5 hours

### Tasks

- [x] Update `Get-AdminPlatform` in `skills/admin/SKILL.md` to handle PowerShell Core on non-Windows (detect platform or explicitly guard with a clear error).
- [x] Replace the `??` operator in `Test-AdminContext` with Windows PowerShell 5.1-safe logic for handoff messaging.
- [x] Keep Bash behavior unchanged.

### Verification Criteria

- PowerShell logic does not assume Windows when running on pwsh on Linux/macOS/WSL (or errors with clear guidance).
- `Test-AdminContext` runs without syntax errors on Windows PowerShell 5.1 and PowerShell 7.x.
- Handoff messages still include WSL distro guidance when available.

---

## Phase 14: WSL Doc Alignment to Shared `.admin` Root

**Type**: Documentation | **Effort**: ~0.5 hours

### Tasks

- [x] Update `skills/admin-wsl/SKILL.md` and `skills/admin-wsl/README.md` to default to the shared Windows `.admin` path (`/mnt/c/Users/$WIN_USER/.admin`) and remove admin-sync references.
- [x] Update `skills/admin/references/first-run-setup.md` and `skills/admin/references/shell-detection.md` to reflect the shared root, dual-shell setup, and new log/profile paths.
- [x] Align logging paths/examples with the unified `.admin` structure.

### Verification Criteria

- WSL docs consistently show the shared Windows `.admin` root and modern log paths.
- No remaining references to `admin-sync` as a dependency.
- Examples match current routing/logging behavior.

---

# Feature: Admin Skills Best‑Practices Compliance (Added 2025-12-12)

Bring the admin skill suite into alignment with `SKILLS_BEST_PRACTICES.md`: improve discovery metadata, enforce progressive disclosure and token budgets, standardize path examples, and fix any broken references.

---

## Phase 15: Metadata + Quick Anti‑Patterns

**Type**: Refactor | **Effort**: ~0.5 hours

### Tasks

- [x] Convert YAML `description` in all `skills/admin*/SKILL.md` to third‑person discovery style (e.g., “Installs…”, “Manages…”).
- [x] Standardize path examples to include forward‑slash variants; avoid Windows backslash paths in SKILL bodies.
- [x] Move time‑sensitive pricing or “verified on date” out of main narrative into explicit “Old patterns” or metadata blocks where needed.

### Verification Criteria

- Descriptions are third‑person, specific, and include “Use when” triggers.
- No new Windows‑style backslash paths in SKILL bodies.
- Time‑sensitive details are clearly isolated.

---

## Phase 16: `admin-mcp` Progressive Disclosure

**Type**: Refactor | **Effort**: ~1.0 hours

### Tasks

- [x] Split `skills/admin-mcp/SKILL.md` into an overview plus one‑level‑deep references for install, config, registry, and troubleshooting.
- [x] Add TOCs to any referenced files over 100 lines.
- [x] Reduce SKILL body below 500 lines and ensure a clear default install path/method.

### Verification Criteria

- `skills/admin-mcp/SKILL.md` < 500 lines and links directly to all long refs.
- Refs have TOCs and are only one level deep.
- Default path/method is recommended with a single escape hatch.

---

## Phase 17: `admin-servers` Progressive Disclosure

**Type**: Refactor | **Effort**: ~0.75 hours

### Tasks

- [x] Move long inventory format/provider discovery detail out of `skills/admin-servers/SKILL.md` into `references/`.
- [x] Add TOCs to new/long refs and keep SKILL as workflow + navigation.

### Verification Criteria

- `skills/admin-servers/SKILL.md` < 500 lines.
- Inventory spec and provider discovery are referenced one level deep.

---

## Phase 18: `admin` Orchestrator Tightening

**Type**: Refactor | **Effort**: ~0.75 hours

### Tasks

- [x] Trim `skills/admin/SKILL.md` to routing + core commands; push detailed explanations into existing references.
- [x] Add TOCs to `skills/admin/references/*.md` where >100 lines.

### Verification Criteria

- `skills/admin/SKILL.md` < 500 lines.
- Admin references have TOCs and remain one‑level deep.

---

## Phase 19: App Skills Concision (`admin-app-coolify`, `admin-app-kasm`)

**Type**: Refactor | **Effort**: ~0.75 hours

### Tasks

- [ ] Reduce both app SKILLs under 500 lines by moving extended procedures into refs.
- [ ] Add TOCs to large Cloudflare tunnel/origin‑cert refs.
- [ ] Surface any bundled refs from SKILL or remove if obsolete.

### Verification Criteria

- App SKILLs < 500 lines.
- All bundled refs are either linked from SKILL or removed.

---

## Phase 20: Infra Skills Concision + OCI Doc Fix

**Type**: Refactor | **Effort**: ~1.0 hours

### Tasks

- [ ] Reduce each `admin-infra-*` SKILL under 500 lines via targeted splits (tables, troubleshooting, long guides → refs).
- [ ] Add TOCs to long OCI docs in `skills/admin-infra-oci/docs/`.
- [ ] Fix broken script references in `skills/admin-infra-oci/docs/TROUBLESHOOTING.md` (`preflight-check.sh`, `validate-env.sh`).

### Verification Criteria

- All infra SKILLs < 500 lines.
- OCI docs have TOCs and no dead script links.

---

## Phase 21: Windows/WSL Skills Concision

**Type**: Refactor | **Effort**: ~0.75 hours

### Tasks

- [ ] Reduce `skills/admin-windows/SKILL.md` and `skills/admin-wsl/SKILL.md` under 500 lines using refs.
- [ ] Normalize path examples and add TOCs to any long refs.

### Verification Criteria

- Windows/WSL SKILLs < 500 lines.
- Path guidance is consistent and forward‑slash safe.
