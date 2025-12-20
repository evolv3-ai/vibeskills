# START HERE

**Welcome to VibeSkills!** This is your entry point for building and using production-ready skills for Claude Code.

---

## What Do You Want To Do?

### Use Existing Skills

**Quick Install** (all 18 skills):
```bash
git clone https://github.com/evolv3-ai/vibe-skills.git ~/Documents/vibeskills
cd ~/Documents/vibeskills
./scripts/install-all.sh
```

**Single Skill**:
```bash
./scripts/install-skill.sh admin
```

**View All Skills**: See [SKILLS_CATALOG.md](SKILLS_CATALOG.md)

---

### Build a New Skill

**Quick Start** (5 minutes):
1. Copy the template: `cp -r templates/skill-skeleton/ skills/my-skill-name/`
2. Fill in the TODOs in `SKILL.md` and `README.md`
3. Add your resources (scripts, references, assets)
4. Install locally: `./scripts/install-skill.sh my-skill-name`
5. Test by mentioning it to Claude Code
6. Verify with [ONE_PAGE_CHECKLIST.md](ONE_PAGE_CHECKLIST.md)

**Detailed Workflow**: See [QUICK_WORKFLOW.md](QUICK_WORKFLOW.md)

---

### Verify an Existing Skill

**Compliance Check**:
- Use [ONE_PAGE_CHECKLIST.md](ONE_PAGE_CHECKLIST.md) for quick verification
- Check against [planning/claude-code-skill-standards.md](planning/claude-code-skill-standards.md)

---

### Research Before Building

**Research Protocol**:
1. Read [planning/research-protocol.md](planning/research-protocol.md)
2. Check Context7 MCP for library docs
3. Verify latest package versions on npm
4. Document findings in `planning/research-logs/`
5. Build working example first

---

### Understand the Standards

**Official Documentation**:
- Anthropic Skills Repo: https://github.com/anthropics/skills
- Agent Skills Spec: [anthropics/skills/agent_skills_spec.md](https://github.com/anthropics/skills/blob/main/agent_skills_spec.md)
- Our Standards Doc: [planning/claude-code-skill-standards.md](planning/claude-code-skill-standards.md)
- Comparison: [planning/STANDARDS_COMPARISON.md](planning/STANDARDS_COMPARISON.md)

---

### Learn From Examples

**Working Examples**:
- **Admin Suite** (14 skills): admin, admin-unix, admin-windows, admin-wsl, admin-devops, admin-mcp, admin-infra-*
- **Infrastructure**: admin-infra-digitalocean, admin-infra-vultr, admin-infra-hetzner
- **Applications**: admin-app-coolify, admin-app-kasm
- **Official Examples**: https://github.com/anthropics/skills

---

### Teach AI Agents About This Repository

**For Other AI Assistants** (Gemini, GPT, etc.):

If you want to teach another AI agent how to use these skills:
1. Share **[GEMINI_GUIDE.md](GEMINI_GUIDE.md)** - Comprehensive onboarding guide
2. Grant access to `/home/wsladmin/dev/claude-skills/` directory
3. Point them to specific skills in `skills/[skill-name]/SKILL.md`

**What GEMINI_GUIDE.md Contains**:
- Navigation priorities (which files to read first)
- Skill structure explanation (YAML frontmatter, templates, etc.)
- How to extract knowledge from skills
- Tech stack context and critical rules
- Practical examples and integration tips
- Full skills inventory (18 production skills)
- Command reference for accessing skills

**Use Cases**:
- Onboarding Google Gemini to use Claude Code skills
- Teaching GPT models about production patterns
- Creating meta-prompts for AI agents
- Cross-platform knowledge transfer

---

## Quick Reference Workflow

```
┌─────────────────────────────────────────────────────────────┐
│  START: I want to build a skill for [technology]           │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │ 1. RESEARCH                  │
        │ • Check Context7 MCP         │
        │ • Verify package versions    │
        │ • Build working example      │
        └──────────┬───────────────────┘
                   │
                   ▼
        ┌──────────────────────────────┐
        │ 2. COPY TEMPLATE             │
        │ cp -r templates/skill-       │
        │   skeleton/ skills/my-skill/ │
        └──────────┬───────────────────┘
                   │
                   ▼
        ┌──────────────────────────────┐
        │ 3. FILL TODOS                │
        │ • Edit SKILL.md frontmatter  │
        │ • Write instructions         │
        │ • Add README keywords        │
        └──────────┬───────────────────┘
                   │
                   ▼
        ┌──────────────────────────────┐
        │ 4. ADD RESOURCES             │
        │ • scripts/ (executable code) │
        │ • references/ (docs)         │
        │ • assets/ (templates)        │
        └──────────┬───────────────────┘
                   │
                   ▼
        ┌──────────────────────────────┐
        │ 5. TEST LOCALLY              │
        │ ./scripts/install-skill.sh   │
        │ • Ask Claude to use skill    │
        │ • Verify discovery works     │
        └──────────┬───────────────────┘
                   │
                   ▼
        ┌──────────────────────────────┐
        │ 6. VERIFY COMPLIANCE         │
        │ Check ONE_PAGE_CHECKLIST.md  │
        └──────────┬───────────────────┘
                   │
                   ▼
        ┌──────────────────────────────┐
        │ 7. COMMIT                    │
        │ • git add skills/my-skill    │
        │ • git commit with details    │
        │ • git push                   │
        └──────────────────────────────┘
```

---

## Key Files Quick Reference

| File | Purpose | When To Read |
|------|---------|--------------|
| **START_HERE.md** (this file) | Navigation hub | Always (entry point) |
| **CLAUDE.md** | Project context | When working on this repo |
| **GEMINI_GUIDE.md** | AI agent onboarding | Teaching other AI agents |
| **ONE_PAGE_CHECKLIST.md** | Quick verification | Before committing |
| **QUICK_WORKFLOW.md** | 5-minute process | Building new skill |
| **templates/SKILL-TEMPLATE.md** | Copy-paste starter | Building new skill |
| **planning/claude-code-skill-standards.md** | Official standards | Understanding requirements |
| **planning/research-protocol.md** | Research process | Before building skill |

---

## Project Status (2025-12-18)

### Active Skills (18) - All Production-Ready

| Category | Count | Skills |
|----------|-------|--------|
| System Admin | 6 | admin, admin-unix, admin-windows, admin-wsl, admin-devops, admin-mcp |
| Cloud Infra | 6 | admin-infra-digitalocean, vultr, linode, hetzner, contabo, oci |
| Applications | 2 | admin-app-coolify, admin-app-kasm |
| Tools | 2 | deckmate, imagemagick |

**Full List**: Run `ls skills/` or see [SKILLS_CATALOG.md](SKILLS_CATALOG.md)

---

## Common Questions

**Q: Where do I start after clearing context?**
A: Read this file, then go to [CLAUDE.md](CLAUDE.md) for project context.

**Q: How do I know if my skill is correct?**
A: Check [ONE_PAGE_CHECKLIST.md](ONE_PAGE_CHECKLIST.md) - if all boxes check, you're good!

**Q: Where are the templates?**
A: `templates/skill-skeleton/` - copy this entire directory to start a new skill.

**Q: What if I forget the workflow?**
A: See [QUICK_WORKFLOW.md](QUICK_WORKFLOW.md) for step-by-step instructions.

**Q: How do I verify against official Anthropic standards?**
A: See [planning/STANDARDS_COMPARISON.md](planning/STANDARDS_COMPARISON.md)

---

## Need Help?

1. Check [planning/COMMON_MISTAKES.md](planning/COMMON_MISTAKES.md) for what NOT to do
2. Look at existing skills in `skills/` directory for working examples
3. Review [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
4. Open an issue: https://github.com/evolv3-ai/vibe-skills/issues

---

## External Resources

- **Official Anthropic Skills**: https://github.com/anthropics/skills
- **Claude Code Docs**: https://docs.claude.com/en/docs/claude-code/skills
- **Support Articles**:
  - [What are skills?](https://support.claude.com/en/articles/12512176-what-are-skills)
  - [Creating custom skills](https://support.claude.com/en/articles/12512198-creating-custom-skills)
- **Engineering Blog**: [Equipping agents with skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- **Upstream Repository**: [jezweb/claude-skills](https://github.com/jezweb/claude-skills)

---

**Ready to build?** Start with the quick workflow above or dive into [QUICK_WORKFLOW.md](QUICK_WORKFLOW.md) for details!

**Questions about the project?** Read [CLAUDE.md](CLAUDE.md) for full context.

**Just need to verify?** Check [ONE_PAGE_CHECKLIST.md](ONE_PAGE_CHECKLIST.md) and you're done.
