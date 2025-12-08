# Server Admin - Infrastructure Management

**Status**: Production Ready
**Type**: Infrastructure Management Skill

---

## Auto-Trigger Keywords

- server admin, infrastructure inventory, devops management
- cloud providers, multi-cloud, server provisioning
- OCI, hetzner, digitalocean, vultr, linode, contabo
- SSH management, server status, infrastructure tracking
- "list my servers", "provision new server", "check server inventory"

---

## What This Skill Does

Server Admin manages infrastructure inventory using the Agent DevOps Inventory v1 format:

```
.agent-devops.env
├── METADATA (version, project, owner)
├── PROVIDERS (OCI, Hetzner, DigitalOcean, etc.)
└── SERVERS (VMs, physical servers, local PCs)
```

**Core capabilities:**
- Track servers across multiple cloud providers
- Check existing servers before provisioning new ones
- Maintain inventory history (retired servers preserved)
- Connect to servers via SSH using stored credentials

---

## Quick Start

```bash
# 1. Create inventory from template
cp ~/.claude/skills/admin-servers/assets/agent-devops.env.template .agent-devops.env

# 2. Discover available providers
ls -d ~/.claude/skills/admin-infra-* 2>/dev/null | xargs -I{} basename {} | sed 's/^admin-infra-//'

# 3. List servers in inventory
grep -oP 'SERVER_\K[A-Z0-9_]+(?=_NAME)' .agent-devops.env | sort -u

# 4. Connect to a server
SERVER_ID="WEB01"
HOST=$(grep "SERVER_${SERVER_ID}_HOST=" .agent-devops.env | cut -d= -f2)
USER=$(grep "SERVER_${SERVER_ID}_USER=" .agent-devops.env | cut -d= -f2)
ssh "$USER@$HOST"
```

---

## Inventory Format

```env
# Metadata
AGENT_DEVOPS_VERSION=1
AGENT_DEVOPS_PROJECT=myproject

# Provider
PROVIDER_OCI_TYPE=oci
PROVIDER_OCI_DEFAULT_REGION=us-ashburn-1

# Server
SERVER_WEB01_PROVIDER=OCI
SERVER_WEB01_KIND=vm
SERVER_WEB01_NAME=web-server-1
SERVER_WEB01_CONNECT_VIA=ssh
SERVER_WEB01_HOST=203.0.113.10
SERVER_WEB01_USER=ubuntu
SERVER_WEB01_STATUS=active
```

---

## Known Provider Skills

| Provider | Skill | Cost Range |
|----------|-------|------------|
| Oracle Cloud | `admin-infra-oci` | $0 (Free Tier) |
| Hetzner | `admin-infra-hetzner` | EUR4-32/mo |
| DigitalOcean | `admin-infra-digitalocean` | $24-96/mo |
| Vultr | `admin-infra-vultr` | $24-192/mo |
| Linode | `admin-infra-linode` | $24-192/mo |
| Contabo | `admin-infra-contabo` | EUR5-39/mo |

---

## File Structure

```
admin-servers/
├── SKILL.md                              # Full documentation
├── README.md                             # This file
├── assets/
│   ├── agent-devops.env.template         # Inventory template
│   └── env-template                      # Legacy template
└── scripts/
    ├── agentDevopsInventory.ts           # TypeScript parser
    └── agent_devops_inventory.py         # Python parser
```

---

## Deployment Workflows

Server Admin coordinates with service skills for deployments:

| Workflow | Skills Used |
|----------|-------------|
| **Coolify** | `admin-infra-*` -> `admin-app-coolify` |
| **KASM** | `admin-infra-*` -> `admin-app-kasm` |

See `<details>` sections in SKILL.md for full workflows.

---

## When to Use This Skill

**Use when:**
- Managing multi-provider infrastructure
- Checking if suitable servers exist before provisioning
- Tracking server inventory and status
- Deploying to any supported cloud provider

**Don't use when:**
- Single-provider, single-server setup
- No need for inventory tracking
- Using managed Kubernetes (use provider's tools)

---

## Parser Scripts

For programmatic inventory management:

**TypeScript:**
```typescript
import { parseInventoryFromEnv, findServers } from './scripts/agentDevopsInventory';

const { inventory, errors } = parseInventoryFromEnv(text);
const devServers = findServers(inventory, { env: 'dev', status: 'active' });
```

**Python:**
```python
from scripts.agent_devops_inventory import parse_inventory_from_env, find_servers

inventory, errors = parse_inventory_from_env(text)
dev_servers = find_servers(inventory, env='dev', status='active')
```

---

## License

MIT - Part of the claude-skills collection
