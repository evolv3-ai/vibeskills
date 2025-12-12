---
name: admin-servers
description: |
  Manages infrastructure inventory with Agent DevOps Inventory format. Supports both Bash and PowerShell workflows. Tracks cloud providers (OCI, Hetzner, DigitalOcean, Vultr, Linode, Contabo), local networks, and servers in a simple .env-style file.

  Use when: managing server inventory, provisioning infrastructure, checking existing servers, deploying to cloud providers, or administering multi-provider environments.

  Keywords: server admin, inventory, devops, infrastructure, cloud providers, ssh, server management, provisioning, OCI, hetzner, digitalocean, vultr, linode, contabo
license: MIT
---

# Server Admin - Infrastructure Management

**Purpose**: Maintain a single inventory of servers/providers and coordinate provisioning across `admin-infra-*` and `admin-app-*` skills.

## Navigation

Longer material is split into references (one level deep):
- Inventory spec and agent behavior: `references/INVENTORY_FORMAT.md`
- Provider discovery and adding providers: `references/PROVIDER_DISCOVERY.md`
- Full example inventory file: `references/EXAMPLE_INVENTORY.md`
- Coolify/KASM/multi‑server workflows and cost snapshot: `references/DEPLOYMENT_WORKFLOWS.md`
- Troubleshooting SSH/parse/provider issues: `references/TROUBLESHOOTING.md`

## Quick Start

### 1. Find inventory file

Bash:
```bash
for f in .agent-devops.env agent-devops.env.local ~/.agent-devops.env; do
  [ -f "$f" ] && echo "Found: $f"
done
```

PowerShell:
```powershell
@('.agent-devops.env', 'agent-devops.env.local', "$env:USERPROFILE/.agent-devops.env") |
  ForEach-Object { if (Test-Path $_) { Write-Host "Found: $_" } }
```

### 2. Create inventory from template (if missing)

Bash:
```bash
cp ~/.claude/skills/admin-servers/assets/agent-devops.env.template .agent-devops.env
```

PowerShell:
```powershell
Copy-Item "$env:USERPROFILE/.claude/skills/admin-servers/assets/agent-devops.env.template" ".agent-devops.env"
```

### 3. Discover installed providers

```bash
ls -d ~/.claude/skills/admin-infra-* 2>/dev/null | xargs -I{} basename {} | sed 's/^admin-infra-//'
```

Full discovery and adding providers: `references/PROVIDER_DISCOVERY.md`.

### 4. List servers

```bash
grep -oP 'SERVER_\\K[A-Z0-9_]+(?=_NAME)' .agent-devops.env | sort -u
```

### 5. Connect to a server

```bash
SERVER_ID="WEB01"
HOST=$(grep "SERVER_${SERVER_ID}_HOST=" .agent-devops.env | cut -d= -f2)
USER=$(grep "SERVER_${SERVER_ID}_USER=" .agent-devops.env | cut -d= -f2)
KEY=$(grep "SERVER_${SERVER_ID}_SSH_KEY_PATH=" .agent-devops.env | cut -d= -f2)
ssh -i "$KEY" "$USER@$HOST"
```

## Common Operations

### Provision a new server

1. Check inventory for an existing match (env/role/provider/status).
2. If none found, load the relevant `admin-infra-*` skill.
3. Provision via the provider’s CLI.
4. Add the new `SERVER_<ID>_*` block to inventory.
5. Verify SSH connectivity.

Inventory field details and required keys: `references/INVENTORY_FORMAT.md`.

### Update server status

Example (Bash):
```bash
sed -i "s/SERVER_WEB01_STATUS=active/SERVER_WEB01_STATUS=stopped/" .agent-devops.env
```

### Retire a server

Set `SERVER_<ID>_STATUS=retired` but keep the block for history.

## Parser Scripts

Programmatic parsers live in `scripts/`:
- `scripts/agentDevopsInventory.ts`
- `scripts/agent_devops_inventory.py`

Use these when you need to query or update inventory in code.

## Related Skills

Infrastructure providers are discovered dynamically:
- `admin-infra-oci`, `admin-infra-hetzner`, `admin-infra-digitalocean`, `admin-infra-vultr`, `admin-infra-linode`, `admin-infra-contabo`

Service skills for deployments:
- `admin-app-coolify`, `admin-app-kasm`

## Logging Integration

Log provisioning and inventory changes using centralized logging from `admin`:

```bash
log_admin "SUCCESS" "operation" "Provisioned server" "id=WEB02 provider=OCI"
log_admin "SUCCESS" "operation" "Updated server status" "id=WEB01 status=stopped"
log_admin "INFO" "operation" "Updated inventory" "action=added servers=WEB02"
```

## References

- Oracle Cloud Free Tier: https://www.oracle.com/cloud/free/
- Hetzner Cloud: https://www.hetzner.com/cloud
- Coolify docs: https://coolify.io/docs
- KASM docs: https://kasmweb.com/docs
