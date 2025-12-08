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
