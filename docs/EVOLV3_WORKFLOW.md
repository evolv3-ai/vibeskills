# EVOLV3.AI Fork Workflow

This document describes the workflow for maintaining the evolv3-ai/vibe-skills fork of jezweb/claude-skills.

---

## Branch Hierarchy

```
upstream (jezweb/claude-skills)
    │
    ▼
  jezweb  ←── Direct sync with upstream/main
    │
    ▼
   vibe   ←── Apply rebranding + preserve EVOLV3.AI skills
    │
    ▼
   main   ←── Production-ready, tested changes
```

### Branch Purposes

| Branch | Purpose | Contents |
|--------|---------|----------|
| `jezweb` | Mirror of upstream | Exact copy of jezweb/claude-skills:main |
| `vibe` | Integration branch | Rebranded content + EVOLV3.AI skills |
| `main` | Production | Stable, tested releases |

---

## What to Bring vs. Preserve

### ✅ Bring from Upstream (Processes)

- Commands in `/commands/`
- Templates in `/templates/`
- Agents in `.claude/agents/`
- Scripts in `/scripts/`
- Documentation patterns
- Audit tools
- Plugin infrastructure

### 🛡️ Preserve (EVOLV3.AI Owned)

| Path | Reason |
|------|--------|
| `skills/` | ALL skills belong to EVOLV3.AI |
| `.claude-plugin/marketplace.json` | Our plugin bundles |
| `CLAUDE.md` | Our project context |
| `README.md` | Our branded readme |
| `docs/EVOLV3_WORKFLOW.md` | This file |
| `.roomodes` | Our custom modes |

---

## Sync Workflow

### Step 1: Fetch Upstream Changes

```bash
# Ensure upstream remote is configured
git remote add upstream https://github.com/jezweb/claude-skills.git 2>/dev/null || true

# Fetch latest from upstream
git fetch upstream

# Check out jezweb branch
git checkout jezweb

# Pull upstream changes
git pull upstream main
```

### Step 2: Preview Changes

```bash
# See what changed upstream since last sync
git log vibe..jezweb --oneline

# See detailed changes
git log vibe..jezweb --stat

# Check for specific areas (commands, agents, templates)
git diff vibe..jezweb -- commands/ .claude/agents/ templates/
```

### Step 3: Merge to Vibe (with Preserved Paths)

```bash
# Switch to vibe branch
git checkout vibe

# Merge jezweb, keeping our versions of preserved paths
git merge jezweb --no-commit

# Check for conflicts in preserved paths and reset them
git checkout --ours skills/
git checkout --ours .claude-plugin/marketplace.json
git checkout --ours CLAUDE.md
git checkout --ours README.md
git checkout --ours docs/EVOLV3_WORKFLOW.md
git checkout --ours .roomodes

# Complete the merge
git add .
git commit -m "chore: merge jezweb upstream changes"
```

### Step 4: Rebrand with bulk-updater Agent

After merging, use the `bulk-updater` agent to apply EVOLV3.AI branding:

```
Use bulk-updater agent to apply these replacements across commands/, templates/, scripts/:

| Find | Replace With |
|------|--------------|
| Jeremy Dawes | EVOLV3.AI |
| jeremy@jezweb.net | hello@evolv3.ai |
| jezweb/claude-skills | evolv3-ai/vibe-skills |
| jezweb.net | evolv3.ai |
| jezweb.com.au | evolv3.ai |

Exclude: skills/ directory, README.md, CLAUDE.md
Include: commands/, templates/, scripts/, .claude/agents/
```

**Or use the prompt:**

```
@bulk-updater Rebrand these files for EVOLV3.AI:
- Replace "Jeremy Dawes" with "EVOLV3.AI"
- Replace "jeremy@jezweb.net" with "hello@evolv3.ai"  
- Replace "jezweb/claude-skills" with "evolv3-ai/vibe-skills"
- Replace "jezweb.net" and "jezweb.com.au" with "evolv3.ai"

Target: commands/, templates/, scripts/, .claude/agents/
Skip: skills/, README.md, CLAUDE.md
```

### Step 5: Test and Commit Rebranding

```bash
# Review rebranding changes
git diff

# Commit rebranding
git add .
git commit -m "chore: apply EVOLV3.AI rebranding"
```

### Step 6: Test on Vibe Branch

Before merging to main:
1. Test key commands work
2. Verify agents function correctly
3. Check plugin installation
4. Run skill audits if needed

### Step 7: Merge to Main

```bash
git checkout main
git merge vibe -m "release: sync upstream changes with EVOLV3.AI branding"
git push origin main
```

---

## Quick Reference Commands

### Check Sync Status

```bash
# How far behind is jezweb?
git rev-list --count jezweb..upstream/main

# How far behind is vibe?
git rev-list --count vibe..jezweb

# See last sync dates
git log --oneline -1 jezweb
git log --oneline -1 vibe
git log --oneline -1 main
```

### Handle Merge Conflicts

```bash
# For preserved paths (always keep ours)
git checkout --ours <path>

# For process paths, resolve manually then:
git add <resolved-file>
git commit
```

### Reset a Bad Merge

```bash
# If merge goes wrong, reset
git merge --abort

# Or if already committed, reset to before merge
git reset --hard HEAD~1
```

---

## Using Jeremy's Agents

The upstream repo provides agents that work well with this workflow:

| Agent | Use For |
|-------|---------|
| `bulk-updater` | Applying rebranding after merges |
| `version-checker` | Checking package versions in skills |
| `skill-auditor` | Auditing skill quality and accuracy |
| `doc-validator` | Validating documentation |

### Example: Pre-Release Audit

```
@skill-auditor Quick audit all skills in skills/

@version-checker Check npm versions for cloudflare-worker-base, ai-sdk-core
```

---

## Deprecation Note

This workflow replaces the custom `scripts/sync-upstream.sh` script. The bulk-updater agent provides the rebranding functionality, while standard git commands handle sync operations.

**Deprecated**: `scripts/sync-upstream.sh` (stashed on vibe branch)
**Replaced by**: This document + bulk-updater agent

---

## Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                     EVOLV3.AI SYNC WORKFLOW                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  upstream/main ──fetch──▶ jezweb ──merge──▶ vibe ──merge──▶ main   │
│                              │                │                     │
│                              │                ▼                     │
│                              │         bulk-updater                 │
│                              │         (rebranding)                 │
│                              │                │                     │
│                              │                ▼                     │
│                              │           Testing                    │
│                              │                │                     │
│                              ▼                ▼                     │
│                     Process changes   EVOLV3.AI branded             │
│                     from Jeremy       ready for main                │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

*Last updated: 2026-01-11*
*Author: EVOLV3.AI*
