# Skills Catalog

**18 production-ready skills** for system administration and infrastructure management.

Each skill includes auto-trigger keywords and links to full documentation.

---

## System Administration Core (6 skills)

### admin
Context-aware development companion that knows your machine and adapts instructions accordingly. Central orchestrator for system administration - reads device profile, routes to specialists.

**Triggers**: `system admin`, `install tools`, `manage servers`, `dev environment setup`

**Role**: Orchestrator - routes to specialized admin-* skills based on context.

---

### admin-unix
Native macOS and Linux administration (non-WSL). Profile-aware - reads preferences from `~/.admin/profiles/{hostname}.json`.

**Triggers**: `macos admin`, `linux admin`, `homebrew`, `apt packages`, `systemctl`

**NOT for WSL** - use admin-wsl instead.

---

### admin-windows
Windows system administration with PowerShell 7.x. Profile-aware - reads your preferences for package managers (scoop vs winget), paths, and installed tools.

**Triggers**: `windows admin`, `powershell`, `scoop`, `winget`, `PATH config`

---

### admin-wsl
WSL2 Ubuntu administration from Linux side. Profile-aware - reads preferences from Windows-side profile at `/mnt/c/Users/{WIN_USER}/.admin/profiles/{hostname}.json`.

**Triggers**: `wsl`, `wsl2`, `ubuntu wsl`, `docker wsl`, `systemd wsl`

---

### admin-devops
Infrastructure management using the device profile. Servers stored in `profile.servers[]`, deployments reference `.env.local` files via `profile.deployments{}`.

**Triggers**: `devops`, `server inventory`, `infrastructure`, `deployment config`

---

### admin-mcp
MCP server management for Claude Desktop. Profile-aware - reads MCP server inventory from `profile.mcp.servers{}` and config path from `profile.paths.claudeConfig`.

**Triggers**: `mcp server`, `claude desktop config`, `mcp install`, `mcp troubleshoot`

---

## Cloud Infrastructure (6 skills)

### admin-infra-digitalocean
Deploys infrastructure on DigitalOcean with Droplets (VMs), Firewalls, and VPCs. Includes Kasm Workspaces auto-scaling integration.

**Triggers**: `digitalocean`, `droplet`, `doctl`, `do firewall`, `do vpc`

**Best for**: US/global cloud with excellent API, Kasm auto-scaling.

---

### admin-infra-vultr
Deploys infrastructure on Vultr with Cloud Compute instances, High-Frequency servers, and VPCs. Excellent value with Kubernetes autoscaling support.

**Triggers**: `vultr`, `vultr vps`, `vultr-cli`, `high frequency`, `vultr firewall`

**Best for**: Good price/performance with global reach.

---

### admin-infra-linode
Deploys infrastructure on Linode (Akamai Cloud) with Linodes, Firewalls, and VLANs. Strong Kubernetes support with Cluster Autoscaler.

**Triggers**: `linode`, `akamai cloud`, `linode-cli`, `lke`, `linode kubernetes`

**Best for**: Kubernetes autoscaling, Akamai CDN integration.

---

### admin-infra-hetzner
Deploys infrastructure on Hetzner Cloud with ARM64 or x86 servers. Cost-effective European cloud with excellent price/performance ratio.

**Triggers**: `hetzner`, `hcloud`, `cax`, `hetzner arm64`, `hetzner dedicated`

**Best for**: European hosting, affordable ARM64 servers (CAX).

---

### admin-infra-contabo
Deploys infrastructure on Contabo using Cloud VPS and Object Storage. Focuses on cost-effective provisioning and Contabo-specific CLI/API quirks.

**Triggers**: `contabo`, `contabo vps`, `contabo storage`, `budget vps`

**Best for**: Ultra-budget VPS, basic workloads.

---

### admin-infra-oci
Deploys infrastructure on Oracle Cloud Infrastructure (OCI) with ARM64 instances. Handles compartments, VCNs, subnets, security lists, and compute instances.

**Triggers**: `oracle cloud`, `oci`, `always free`, `arm64 free`, `OUT_OF_HOST_CAPACITY`

**Best for**: Always Free tier ARM64 instances.

---

## Applications (2 skills)

### admin-app-coolify
Installs and manages Coolify, an open-source self-hosted PaaS for deploying applications with Docker. Provides a Heroku-like experience on your own infrastructure.

**Triggers**: `coolify`, `self-hosted paas`, `docker deploy`, `traefik proxy`

---

### admin-app-kasm
Installs and manages KASM Workspaces, a container-based VDI platform for streaming desktops to browsers. Supports Ubuntu ARM64.

**Triggers**: `kasm`, `kasm workspaces`, `vdi`, `browser desktop`, `workspace streaming`

---

## Specialized Tools (4 skills)

### deckmate
Stream Deck integration assistant for VSCode. Create, manage, and organize Stream Deck profiles, buttons, snippets, and scripts. Helps build productivity workflows for developers using Stream Deck with Claude Code.

**Triggers**: `stream deck`, `deckmate`, `stream deck vscode`, `tac patterns`

---

### imagemagick
Guide for using ImageMagick command-line tools to perform advanced image processing tasks including format conversion, resizing, cropping, effects, transformations, and batch operations.

**Triggers**: `imagemagick`, `convert images`, `image resize`, `batch image`, `magick command`

---

### cloudflare-python-workers
Build Python APIs on Cloudflare Workers using pywrangler CLI and WorkerEntrypoint class pattern. Includes Python Workflows for multi-step DAG automation.

**Triggers**: `python workers`, `cloudflare python`, `pywrangler`, `python serverless`

**From upstream**: Synced from jezweb/claude-skills.

---

### mcp-oauth-cloudflare
Add OAuth authentication to MCP servers on Cloudflare Workers. Uses @cloudflare/workers-oauth-provider with Google OAuth for Claude.ai-compatible authentication.

**Triggers**: `mcp oauth`, `mcp authentication`, `workers oauth`, `claude.ai oauth`

**From upstream**: Synced from jezweb/claude-skills.

---

## Quick Reference

| Category | Count | Key Skills |
|----------|-------|------------|
| System Admin | 6 | admin, admin-unix, admin-windows, admin-wsl |
| Cloud Infra | 6 | digitalocean, vultr, linode, hetzner, contabo, oci |
| Applications | 2 | coolify, kasm |
| Tools | 4 | deckmate, imagemagick, cloudflare-python-workers |

**Total: 18 skills | Infrastructure-focused | ~50% average token savings**

---

## Installation

```bash
# Manual (recommended)
./scripts/install-skill.sh admin

# Install all skills
./scripts/install-all.sh
```

See [README.md](README.md) for full installation instructions.
