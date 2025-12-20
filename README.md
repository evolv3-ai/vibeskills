# VibeSkills - Claude Code Skills

**Custom skills collection** for Claude Code CLI — Built on the excellent foundation of [claude-skills](https://github.com/jezweb/claude-skills) by Jeremy Dawes.

~50% token savings | Auto-discovered by Claude | Infrastructure-focused

---

## Attribution

This repository is a fork of **[claude-skills](https://github.com/jezweb/claude-skills)** by **[Jeremy Dawes](https://jezweb.com.au)**.

The original project provides an outstanding framework for Claude AI skills development. This fork maintains the core framework while customizing the skills collection for specific use cases.

### What's Different in VibeSkills
- **18 custom skills** focused on system administration and infrastructure
- Periodic upstream syncs to incorporate framework improvements
- Maintained separately to allow independent skill development

### Upstream Repository
- **Original**: [github.com/jezweb/claude-skills](https://github.com/jezweb/claude-skills)
- **License**: MIT License
- **Author**: Jeremy Dawes

---

## Quick Install

### Manual Installation (Recommended)

```bash
git clone https://github.com/evolv3-ai/vibe-skills.git ~/Documents/vibeskills
cd ~/Documents/vibeskills
./scripts/install-skill.sh admin  # Single skill
# or
./scripts/install-all.sh          # All 18 skills
```

### Marketplace

```bash
/plugin marketplace add https://github.com/evolv3-ai/vibe-skills
/plugin install admin@vibeskills
```

---

## Skills by Category (18 Total)

### System Administration (14 skills)

| Skill | Description |
|-------|-------------|
| `admin` | Base system administration - orchestrator for admin-* skills |
| `admin-unix` | Unix/Linux administration patterns |
| `admin-windows` | Windows administration and PowerShell |
| `admin-wsl` | Windows Subsystem for Linux management |
| `admin-devops` | DevOps tooling and automation practices |
| `admin-mcp` | MCP server management and configuration |

### Cloud Infrastructure (6 skills)

| Skill | Description |
|-------|-------------|
| `admin-infra-digitalocean` | DigitalOcean droplets, networking, volumes |
| `admin-infra-vultr` | Vultr VPS and cloud management |
| `admin-infra-linode` | Linode/Akamai infrastructure |
| `admin-infra-hetzner` | Hetzner Cloud and dedicated servers |
| `admin-infra-contabo` | Contabo VPS management |
| `admin-infra-oci` | Oracle Cloud Infrastructure |

### Applications (2 skills)

| Skill | Description |
|-------|-------------|
| `admin-app-coolify` | Coolify self-hosted PaaS deployment |
| `admin-app-kasm` | Kasm Workspaces container streaming |

### Specialized Tools (4 skills)

| Skill | Description |
|-------|-------------|
| `deckmate` | Stream Deck integration for VSCode |
| `imagemagick` | Image processing CLI operations |
| `cloudflare-python-workers` | Python Workers on Cloudflare (from upstream) |
| `mcp-oauth-cloudflare` | OAuth for MCP servers (from upstream) |

---

## How It Works

Claude Code automatically discovers skills in `~/.claude/skills/` and suggests them when relevant:

```
You: "Set up a new Vultr VPS with Docker"
Claude: "Found admin-infra-vultr skill. Use it?"
You: "Yes"
→ Production-ready setup with best practices
```

---

## Creating Skills

**Quick start**:
```bash
cp -r templates/skill-skeleton/ skills/my-skill/
# Edit SKILL.md and README.md
./scripts/install-skill.sh my-skill
```

**Guides**:
- [CONTRIBUTING.md](CONTRIBUTING.md) — Full contribution guide
- [templates/](templates/) — Starter templates
- [ONE_PAGE_CHECKLIST.md](ONE_PAGE_CHECKLIST.md) — Quality checklist

---

## Token Efficiency

| Metric | Manual | With Skills |
|--------|--------|-------------|
| Tokens | 12-15k | 4-6k (~50% less) |
| Errors | 2-4 | 0 (prevented) |
| Time | 2-4 hours | 15-45 min |

---

## Documentation

- [START_HERE.md](START_HERE.md) — Navigation guide
- [SKILLS_CATALOG.md](SKILLS_CATALOG.md) — All skills with details
- [CONTRIBUTING.md](CONTRIBUTING.md) — How to contribute
- [MARKETPLACE.md](MARKETPLACE.md) — Marketplace installation
- [CLAUDE.md](CLAUDE.md) — Project standards

---

## Syncing with Upstream

This fork periodically syncs with the upstream repository to incorporate framework improvements:

```bash
# Sync with upstream (preserves custom skills)
./scripts/sync-upstream.sh
```

The sync script automatically:
- Fetches latest changes from upstream
- Merges framework updates
- Preserves your custom skills folder
- Maintains your customizations

---

## Tools

### ContextBricks — Status Line

Real-time context tracking for Claude Code.

```bash
npx contextbricks  # One-command install
```

[![npm](https://img.shields.io/npm/v/contextbricks.svg)](https://www.npmjs.com/package/contextbricks)

---

## Links

- **This Fork**: [github.com/evolv3-ai/vibe-skills](https://github.com/evolv3-ai/vibe-skills)
- **Upstream**: [github.com/jezweb/claude-skills](https://github.com/jezweb/claude-skills)
- **Issues**: [github.com/evolv3-ai/vibe-skills/issues](https://github.com/evolv3-ai/vibe-skills/issues)
- **Claude Code**: [claude.com/claude-code](https://claude.com/claude-code)

---

MIT License | Fork maintained by evolv3.ai | Original by Jeremy Dawes ([jezweb.com.au](https://jezweb.com.au))
