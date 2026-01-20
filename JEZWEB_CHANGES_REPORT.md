# Jezweb Changes Report

> **Context**: Following your Discord conversation with Jeremy Dawes about fork workflows, skill authorship, and repo management, this report highlights the relevant changes he made to the upstream repo.

---

# Sync 2: January 11-20, 2026

**Commits reviewed**: 22 commits (`c6d2161..30ebebe`)
**Releases**: v2.11.0, v2.12.0
**Report focus**: Workflow-affecting changes, new patterns, and process updates

---

## 🚨 WORKFLOW-CRITICAL: Sub-Agent Patterns Update

Jeremy added a **new rule file** that affects how we use agents: `skills/sub-agent-patterns/rules/sub-agent-patterns.md`

### Key Learnings (Action Required)

**1. Tool Access Principle**
> "If an agent doesn't need Bash, don't give it Bash."

| Agent needs to... | Give tools | Don't give |
|-------------------|------------|------------|
| Create files only | Read, Write, Edit, Glob, Grep | Bash |
| Run scripts/CLIs | Read, Write, Edit, Glob, Grep, Bash | — |
| Read/audit only | Read, Glob, Grep | Write, Edit, Bash |

**Why?** Models default to `cat > file << 'EOF'` heredocs instead of Write tool. Each bash command requires approval, causing dozens of prompts per agent run.

**2. Model Selection**
| Model | Best For |
|-------|----------|
| **Sonnet** | Most agents - content, files, code (default) |
| **Opus** | Creative work, quality-critical outputs |
| **Haiku** | Only script runners where quality doesn't matter |

**3. Effective Prompt Template**
```
For each [item]:
1. Read [source file]
2. Verify with [external check]
3. Check [authoritative source]
4. Score/evaluate
5. FIX issues found ← Critical instruction
```

**Impact on EVOLV3_WORKFLOW.md**: Our bulk-updater agent usage should follow these patterns. Consider reviewing agent tool permissions.

---

## 🆕 New Plugin Bundles

### `design` Bundle (8 skills)
Web design and accessibility skills:

| Skill | Purpose |
|-------|---------|
| `accessibility` | WCAG 2.1 AA compliance, semantic HTML, ARIA |
| `color-palette` | Generate 11-shade scales from brand hex |
| `favicon-gen` | Custom favicons from logos, text, or brand colors |
| `icon-design` | Icon selection, library recommendations |
| `image-gen` | Gemini image generation for website assets |
| `responsive-images` | srcset, lazy loading, modern formats |
| `seo-meta` | Title, description, Open Graph, Twitter Cards, JSON-LD |
| `tailwind-patterns` | Production-ready Tailwind CSS patterns |

### `office` Bundle (1 skill)
Document generation:

| Skill | Purpose |
|-------|---------|
| `office` | Create DOCX, XLSX, PPTX, PDF documents with TypeScript |

---

## 🤖 New Agents (13 total)

### Design Bundle Agents (6)

| Agent | Purpose |
|-------|---------|
| `a11y-auditor` | WCAG compliance audits with scoring |
| `favicon-crafter` | SVG favicon generation (9 shapes, gradients) |
| `icon-selector` | Icon library selection and migration |
| `image-prompter` | Gemini prompt crafting with negative prompts |
| `palette-generator` | Color palette generation with contrast checking |
| `seo-generator` | Complete SEO metadata generation |

### Developer Toolbox Agents (7)

**New skill**: `developer-toolbox` with 7 essential workflow agents

| Agent | Purpose | Triggers On |
|-------|---------|-------------|
| `commit-helper` | Generate conventional commit messages | "commit message", "staged changes" |
| `build-verifier` | Verify dist/ matches source after builds | "changes not appearing", "verify build" |
| `code-reviewer` | Security audits and code quality reviews | "code review", "security audit", "OWASP" |
| `debugger` | Systematic debugging with root cause analysis | "error", "TypeError", "stack trace" |
| `test-runner` | TDD workflow and test creation | "write tests", "TDD", "coverage" |
| `orchestrator` | Coordinate complex multi-step projects | "coordinate", "multi-step" |
| `documentation-expert` | README, API docs, architecture diagrams | "document", "README", "API docs" |

**New Rule**: `agent-first-thinking` - Behavioral interrupt to consider agents before manual work

---

## 🔧 New Scripts

### `scripts/install-skill-agents.sh`
Installs agents from skill bundles to `~/.claude/agents/`

```bash
# Usage
./scripts/install-skill-agents.sh design      # Install design bundle agents
./scripts/install-skill-agents.sh cloudflare  # Install cloudflare bundle agents
./scripts/install-skill-agents.sh all         # Install all agents
./scripts/install-skill-agents.sh list        # List available bundles
```

**Relevance**: This is a new way to distribute agents. We should evaluate if this pattern fits our workflow.

---

## 📊 Statusline Updates (v3.4.0)

New features in `tools/statusline/`:

- **Working directory display** - Shows tilde-compressed path (e.g., `~/Documents/project`)
- **Official percentage fields** - Uses `used_percentage` and `remaining_percentage` (Claude Code 2.1.6+)
- **More accurate context display** - No calculation drift, uses official values directly
- **Backwards compatible** - Falls back to token calculation for older versions

---

## 🧠 AI Model Updates

Updated all AI skills to current models (January 2026):

| Skill | Updates |
|-------|---------|
| `claude-api` | Claude 4.5 Opus, Sonnet, Haiku |
| `openai-agents` | GPT-5.1, GPT-5.2, o3, o3-mini |
| `openai-assistants` | Updated model references |
| `google-gemini-file-search` | Gemini 2.5 Pro/Flash |
| `image-gen` | Gemini-native image generation |

New planning doc: `planning/AI_SDK_STATE_2026.md` - Current state of AI SDKs

---

## 🆕 Other New Skills

| Skill | Purpose |
|-------|---------|
| `agent-development` | Building custom Claude Code agents with proper frontmatter |
| `oauth-integrations` | OAuth patterns for MCP servers and Workers (GitHub, Microsoft) |

---

## 📦 Marketplace Updates

**Version**: 3.0.0 → 3.1.0

**New bundles added**:
- `design` (8 skills)
- `office` (1 skill)

---

## 📋 Summary Stats (Sync 2)

| Category | Count |
|----------|-------|
| New skills | 12 |
| New agents | 13 |
| New rules | 3 |
| New scripts | 1 |
| Updated skills | 7 |
| New tags | 3 |

---

## 💡 Recommendations for EVOLV3.AI Workflow

1. **Review sub-agent patterns** - Critical learnings about tool permissions and model selection
2. **Consider adopting developer-toolbox** - Workflow agents could accelerate development
3. **Update statusline** - v3.4.0 has better context tracking for Claude Code 2.1.6+
4. **No changes needed to EVOLV3_WORKFLOW.md** - Process remains valid, just apply learnings

---

*Sync 2 completed: 2026-01-20*
*Branch: jezweb (synced with upstream/main)*
*Commits analyzed: `c6d2161..30ebebe` (22 commits)*

---
---

# Sync 1: January 8-11, 2026

**Total commits reviewed**: 72 commits since Jan 8, 2026
**Report focus**: Fork guidance, skill management, commands, and processes (NOT individual skills)

---

## 🎯 DIRECTLY RELEVANT: Fork Guidance & Skill Request Workflow

### Commit `7c9ff07` - Skill Request Workflow and Fork Guidance

**This is the most relevant change** - Jeremy added documentation specifically addressing the topics you discussed:

**New file**: `.github/ISSUE_TEMPLATE/skill_request.md`
- Official skill request form: https://github.com/jezweb/claude-skills/issues/new?template=skill_request.md
- Allows community to request skills without forking

**What this means for you**:
- Jeremy is open to receiving skill suggestions via issues
- You can continue maintaining your own skills in your fork while potentially contributing process improvements upstream

---

## 🤖 Custom Agents for Skill Management

Jeremy added **10 custom agents** specifically for managing skills. These are automation tools that could help YOUR workflow:

### New `.claude/agents/` directory:

| Agent | Purpose |
|-------|---------|
| `skill-creator.md` | Automates creating new skills |
| `skill-auditor.md` | Reviews skills for compliance |
| `doc-validator.md` | Validates documentation |
| `version-checker.md` | Checks package versions |
| `bulk-updater.md` | Bulk updates across skills |
| `web-researcher.md` | Researches official docs |
| `cloudflare-deploy.md` | Deploys to Cloudflare |
| `cloudflare-debug.md` | Debugs Cloudflare issues |
| `d1-migration.md` | D1 database migrations |
| `worker-scaffold.md` | Scaffolds CF Workers |

**Relevance**: These agents could help you maintain your own skills with less manual work.

---

## 📂 Command Reorganization

### Commands Moved INTO Skills

Jeremy reorganized commands to live within their related skills:

| Old Location | New Location |
|--------------|--------------|
| `commands/deploy.md` | `skills/cloudflare-worker-base/commands/deploy.md` |
| `commands/brief.md` | `skills/project-workflow/commands/brief.md` |
| `commands/reflect.md` | `skills/project-workflow/commands/reflect.md` |
| `commands/update-docs.md` | `skills/docs-workflow/commands/docs-update.md` |

### Commands Remaining in Root `/commands/`:

Only "orphan" commands without a specific skill home remain:
- `/create-skill`
- `/review-skill`
- `/audit`
- `/deep-audit` (NEW - comprehensive skill auditing)

### New `deep-audit` Command

**File**: `commands/deep-audit.md`
A powerful 4-phase audit system:
1. Content accuracy checking
2. Sub-agent comparison
3. Change tracking with hashing
4. Bulk operations

**Relevance**: This could help you audit your own skills more systematically.

---

## 📦 Plugin Installation Migration

### Commit `f729604` - Major Refactor

**Change**: Moving from symlinks to plugin-based installation

**Old way**: Required symlinking skills to `~/.claude/skills/`
**New way**: Plugin bundles installed via marketplace

**Scripts deprecated** (moved to `archive/deprecated-scripts/`):
- `install-skill.sh`
- `install-all.sh`
- `check-symlinks.sh`

### Plugin Bundles Renamed (Commit `ac68294`)

Shorter bundle names for better command access:

| Old Name | New Name |
|----------|----------|
| `tooling-skills` | `project` + `mcp` + `contrib` (split) |
| `cloudflare-skills` | `cloudflare` |
| `ai-skills` | `ai` |
| `frontend-skills` | `frontend` |
| `auth-skills` | `auth` |

**Relevance**: Affects how skills are packaged and distributed. Your `.claude-plugin/marketplace.json` defines YOUR bundles independently.

---

## 📝 Documentation Structure Changes

### Files Moved

| From | To |
|------|-----|
| `GEMINI_GUIDE.md` | `docs/GEMINI_GUIDE.md` |
| `MARKETPLACE.md` | `docs/MARKETPLACE.md` |
| `SKILLS_CATALOG.md` | `docs/SKILLS_CATALOG.md` |

### Files Deleted

| File | Status |
|------|--------|
| `ATOMIC-SKILLS-SUMMARY.md` | Removed |
| `QUICK_WORKFLOW.md` | Removed |
| `START_HERE.md` | Removed |

### New Documentation

| File | Contents |
|------|----------|
| `docs/SKILLS_COMMANDS_ARCHITECTURE.md` | How commands relate to skills |
| `planning/SKILLS_COMMAND_REVIEW.md` | Command review process |
| `planning/deep-audit-agent-prompts.md` | Prompts for audit agents |
| `templates/CONTENT_AUDIT_TEMPLATE.md` | Template for skill audits |
| `templates/skill-metadata-v2.yaml` | NEW metadata format |

---

## 📋 New Skill Management Templates

### `templates/skill-metadata-v2.yaml`
New standardized metadata schema for skills. Could be useful for your own skills.

### `templates/CONTENT_AUDIT_TEMPLATE.md`
Structured template for auditing skill content accuracy.

---

## 🔧 New Scripts for Skill Auditing

| Script | Purpose |
|--------|---------|
| `scripts/deep-audit-scrape.py` | Scrapes official docs for accuracy checks |
| `scripts/deep-audit-diff.py` | Compares skill content vs official docs |
| `scripts/deep-audit-bulk.py` | Bulk audit operations |

---

## 🆕 New Skills Added (for reference)

These are Jeremy's new skills - **not to be copied**, but for awareness:

| Skill | Description |
|-------|-------------|
| `docs-workflow` | Commands for documentation management (/docs, /docs-init, etc.) |
| `email-gateway` | Mailgun, SendGrid, Resend, SMTP2Go integrations |
| `firecrawl-scraper` | Web scraping with Firecrawl |
| `playwright-local` | Local Playwright browser automation |
| `snowflake-platform` | Snowflake data platform |
| `sub-agent-patterns` | Patterns for using sub-agents |

---

## 💡 Recommendations for Your Workflow

Based on these changes:

1. **Consider adopting the custom agents** - They could automate your skill maintenance
2. **Don't worry about plugin migration** - Your marketplace.json is independent
3. **Use `/deep-audit` command** - For maintaining your own skills
4. **Keep your fork structure** - Jeremy's changes support forks maintaining separate skills
5. **Submit skill requests upstream** - If you think a skill would benefit the community

---

## Tags/Releases

New tags created:
- `v2.7.0`
- `v2.8.0`
- `v2.9.0`
- `v2.10.0`

---

## Summary Stats (Sync 1)

| Category | Count |
|----------|-------|
| New agents | 10 |
| Commands reorganized | 4 |
| Files deleted | 3 |
| Files moved | 3 |
| New templates | 2 |
| New scripts | 3 |
| New documentation | 4 |
| New skills | 6 |

---

*Report generated: 2026-01-11*
*Branch: jezweb (synced with upstream/main)*
*Commits analyzed: `2ff2ba1..c6d2161` (72 commits since Jan 8, 2026)*
