# Claude Code Skills

**60 production-ready skills** for Claude Code CLI — Cloudflare, React, AI integrations, and more.

~50% token savings | 400+ errors prevented | Auto-discovered by Claude

---

## Quick Install

### Marketplace (Recommended)

```bash
/plugin marketplace add https://github.com/jezweb/claude-skills
/plugin install cloudflare-worker-base@claude-skills
```

### Manual

```bash
git clone https://github.com/jezweb/claude-skills.git ~/Documents/claude-skills
cd ~/Documents/claude-skills
./scripts/install-skill.sh cloudflare-worker-base  # or ./scripts/install-all.sh
```

---

## Skills by Category

| Category | Skills | Highlights |
|----------|--------|------------|
| **Cloudflare** | 16 | Workers, D1, R2, KV, Agents, MCP Server, Durable Objects |
| **AI/ML** | 12 | Vercel AI SDK, OpenAI Agents, Claude API, Gemini |
| **Frontend** | 12 | Tailwind v4 + shadcn, TanStack (Query/Router/Table), Zustand |
| **Python** | 2 | FastAPI, Flask |
| **Database** | 4 | Drizzle, Neon Postgres, Vercel KV/Blob |
| **Auth** | 2 | Clerk, Better Auth |
| **Planning** | 5 | Project workflow, session management |
| **MCP/Tools** | 4 | FastMCP, TypeScript MCP |
| **CMS** | 3 | TinaCMS, Sveltia, WordPress |

**📋 Full list**: [SKILLS_CATALOG.md](SKILLS_CATALOG.md)

---

## How It Works

Claude Code automatically discovers skills in `~/.claude/skills/` and suggests them when relevant:

```
You: "Set up a Cloudflare Worker with D1"
Claude: "Found cloudflare-worker-base and cloudflare-d1 skills. Use them?"
You: "Yes"
→ Production-ready setup, zero errors
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
- [SKILLS_CATALOG.md](SKILLS_CATALOG.md) — All 60 skills with details
- [CONTRIBUTING.md](CONTRIBUTING.md) — How to contribute
- [MARKETPLACE.md](MARKETPLACE.md) — Marketplace installation
- [CLAUDE.md](CLAUDE.md) — Project standards

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

- **Issues**: [github.com/jezweb/claude-skills/issues](https://github.com/jezweb/claude-skills/issues)
- **Claude Code**: [claude.com/claude-code](https://claude.com/claude-code)
- **Jezweb**: [jezweb.com.au](https://jezweb.com.au)

---

MIT License | Built by Jeremy Dawes
