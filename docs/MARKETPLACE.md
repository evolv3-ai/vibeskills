# VibeSkills Marketplace

A curated collection of **18 production-ready skills** for Claude Code CLI, focused on system administration and infrastructure management.

## Quick Start

### Step 1: Add the Marketplace

```bash
/plugin marketplace add https://github.com/evolv3-ai/vibe-skills
```

### Step 2: Install Skills

Install individual skills or all at once:

```bash
# Install the admin skill (orchestrator)
/plugin install admin@vibeskills

# Install a specific infrastructure skill
/plugin install admin-infra-vultr@vibeskills

# Install all skills
/plugin install all@vibeskills
```

### Step 3: Use the Skills

Once installed, Claude Code automatically discovers and uses skills when relevant:

```
User: "Set up a new Hetzner ARM64 server with Docker"
Claude: [Automatically uses admin-infra-hetzner skill]

User: "Configure my WSL2 environment"
Claude: [Automatically uses admin-wsl skill]
```

### Alternative: Manual Installation

For development or if you prefer symlinks:

```bash
git clone https://github.com/evolv3-ai/vibe-skills.git ~/Documents/vibeskills
cd ~/Documents/vibeskills

# Install single skill
./scripts/install-skill.sh admin

# Install all skills
./scripts/install-all.sh
```

---

## Available Skills (18)

### System Administration (6 skills)

| Skill | Description |
|-------|-------------|
| `admin` | Central orchestrator - routes to specialized admin-* skills |
| `admin-unix` | macOS and Linux administration |
| `admin-windows` | Windows and PowerShell administration |
| `admin-wsl` | WSL2 Ubuntu administration |
| `admin-devops` | Infrastructure and deployment management |
| `admin-mcp` | MCP server management for Claude Desktop |

### Cloud Infrastructure (6 skills)

| Skill | Description |
|-------|-------------|
| `admin-infra-digitalocean` | DigitalOcean Droplets, firewalls, VPCs |
| `admin-infra-vultr` | Vultr Cloud Compute and High-Frequency servers |
| `admin-infra-linode` | Linode/Akamai with Kubernetes support |
| `admin-infra-hetzner` | Hetzner Cloud ARM64 and x86 servers |
| `admin-infra-contabo` | Contabo budget VPS and storage |
| `admin-infra-oci` | Oracle Cloud Always Free ARM64 instances |

### Applications (2 skills)

| Skill | Description |
|-------|-------------|
| `admin-app-coolify` | Coolify self-hosted PaaS |
| `admin-app-kasm` | Kasm Workspaces VDI platform |

### Specialized Tools (2 skills)

| Skill | Description |
|-------|-------------|
| `deckmate` | Stream Deck integration for VSCode |
| `imagemagick` | Image processing CLI |

---

## Benefits

### For Users

- One-command installation via marketplace or script
- Automatic updates with `/plugin update`
- Auto-discovery - Claude automatically uses relevant skills
- Team deployment via `.claude/settings.json`

### For Projects

- ~50% token savings vs manual implementation
- Production-tested patterns and templates
- Current package versions (verified quarterly)

---

## Managing Skills

### Update Skills

```bash
# Update single skill
/plugin update admin@vibeskills

# Update all from marketplace
/plugin update-all@vibeskills
```

### List Installed Skills

```bash
/plugin list
```

### Remove Skills

```bash
/plugin uninstall admin@vibeskills
```

---

## Team Deployment

Add to `.claude/settings.json` for automatic marketplace availability:

```json
{
  "extraKnownMarketplaces": [
    {
      "name": "vibeskills",
      "url": "https://github.com/evolv3-ai/vibe-skills"
    }
  ]
}
```

Team members will automatically have access to the marketplace.

---

## Syncing with Upstream

This fork periodically syncs with [jezweb/claude-skills](https://github.com/jezweb/claude-skills) for framework improvements:

```bash
./scripts/sync-upstream.sh
```

---

## Troubleshooting

### Skills not triggering automatically

Skills auto-trigger based on keywords in their description. If a skill isn't triggering:

1. Try explicitly asking: "Use the admin-unix skill to..."
2. Restart Claude Code after installing new skills
3. Verify the skill is installed: `/plugin list`

### Skill not found

Make sure you've added the marketplace first:
```bash
/plugin marketplace add https://github.com/evolv3-ai/vibe-skills
```

Then install the skill:
```bash
/plugin install admin@vibeskills
```

---

## Support

**Issues**: https://github.com/evolv3-ai/vibe-skills/issues
**Documentation**: See individual skill directories for detailed guides

---

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Quick process**:
1. Fork repository
2. Create new skill in `skills/` directory
3. Run `./scripts/generate-plugin-manifests.sh`
4. Submit pull request

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

**Last Updated**: 2025-12-18
**Skills**: 18
**Maintainer**: evolv3.ai | Original framework by Jeremy Dawes
