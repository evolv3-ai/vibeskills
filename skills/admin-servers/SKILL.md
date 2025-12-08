---
name: admin-servers
description: |
  Manage infrastructure inventory with Agent DevOps Inventory format. Track cloud providers (OCI, Hetzner, DigitalOcean, Vultr, Linode, Contabo), local networks, and servers in a simple .env-style file.

  Use when: managing server inventory, provisioning infrastructure, checking existing servers, deploying to cloud providers, administering multi-provider environments.

  Keywords: server admin, inventory, devops, infrastructure, cloud providers, ssh, server management, provisioning, OCI, hetzner, digitalocean, vultr, linode, contabo
license: MIT
---

# Server Admin - Infrastructure Management

**Purpose**: Manage infrastructure inventory and coordinate deployments across cloud providers
**Inventory Format**: Agent DevOps Inventory v1 (`.env`-style)
**Provider Discovery**: Automatic via `*-infrastructure` skills

---

## Agent DevOps Inventory v1

A minimal, `.env`-style text format for tracking:

- Cloud providers (OCI, Hetzner, GCP, Contabo, etc.)
- Local/network providers (home lab, LAN)
- Nodes (remote servers, local PCs, dev boxes)
- Connection methods (local vs SSH)
- Metadata (env, role, status, tags)

### File Locations

Recommended names (check in order):
1. `.agent-devops.env` (project root)
2. `agent-devops.env.local` (project root)
3. `~/.agent-devops.env` (user home)

---

## Inventory Format

### General Rules

- One entry per line: `KEY=VALUE`
- Lines starting with `#` are comments (ignored)
- Blank lines are allowed (ignored)
- Keys use **UPPER_SNAKE_CASE**: `A-Z`, `0-9`, `_`
- Values are arbitrary strings

### Metadata Keys

| Key | Required | Description |
|-----|----------|-------------|
| `AGENT_DEVOPS_VERSION` | No | Version of spec (default: `1`) |
| `AGENT_DEVOPS_PROJECT` | No | Project name (e.g., `infra-lab`) |
| `AGENT_DEVOPS_OWNER` | No | Owner identifier |
| `AGENT_DEVOPS_NOTES` | No | Short notes about inventory |

### Provider Keys

Pattern: `PROVIDER_<NAME>_<FIELD>`

| Field | Required | Description |
|-------|----------|-------------|
| `PROVIDER_<NAME>_TYPE` | **Yes** | Provider type: `oci`, `hetzner`, `gcp`, `contabo`, `digitalocean`, `vultr`, `linode`, `local_network` |
| `PROVIDER_<NAME>_AUTH_METHOD` | No | Auth type: `file`, `env`, `inline`, `none` |
| `PROVIDER_<NAME>_AUTH_FILE` | No | Path to credentials file |
| `PROVIDER_<NAME>_DEFAULT_REGION` | No | Default region/zone |
| `PROVIDER_<NAME>_LABEL` | No | Human-friendly label |
| `PROVIDER_<NAME>_NOTES` | No | Notes about provider |

**Special Provider Names**:
- `LOCALNET` - Local network/home lab
- `LOCAL_AGENT` - This machine (where agent runs)

### Server Keys

Pattern: `SERVER_<ID>_<FIELD>`

**Required Fields**:

| Field | Description |
|-------|-------------|
| `SERVER_<ID>_PROVIDER` | Provider name (must match a `PROVIDER_<NAME>`) |
| `SERVER_<ID>_KIND` | Node type: `vm`, `physical`, `local_pc`, `container_host`, `other` |
| `SERVER_<ID>_NAME` | Human-friendly name |
| `SERVER_<ID>_CONNECT_VIA` | Connection method: `local` or `ssh` |

**Recommended Metadata**:

| Field | Description |
|-------|-------------|
| `SERVER_<ID>_ENV` | Environment: `prod`, `staging`, `dev`, `test`, `personal`, `lab` |
| `SERVER_<ID>_ROLE` | Primary role: `web`, `db`, `dev`, `desktop`, `coolify`, `kasm` |
| `SERVER_<ID>_OS` | OS: `linux`, `windows`, `macos`, `bsd` |
| `SERVER_<ID>_STATUS` | Status: `active`, `stopped`, `retired`, `unreachable` |
| `SERVER_<ID>_TAGS` | Comma-separated tags |
| `SERVER_<ID>_NOTES` | Short notes |

**SSH Connection Fields** (when `CONNECT_VIA=ssh`):

| Field | Description |
|-------|-------------|
| `SERVER_<ID>_HOST` | IP or DNS hostname |
| `SERVER_<ID>_PORT` | SSH port (default: 22) |
| `SERVER_<ID>_USER` | SSH username |
| `SERVER_<ID>_SSH_KEY_PATH` | Path to private key |

---

## Agent Behavior

### Reading Inventory

1. Read all lines, skip blank and `#` comments
2. Split each line on first `=` into key and value
3. For `PROVIDER_*` keys: extract provider name and field
4. For `SERVER_*` keys: extract server ID and field
5. Build in-memory maps for providers and servers

### Before Provisioning

When asked to create a new node, first check existing servers:

```bash
# Search inventory for matching servers
grep -E "SERVER_.*_(ENV|ROLE|PROVIDER|STATUS)" .agent-devops.env
```

Look for:
- `SERVER_*_ENV=prod` (if user wants prod)
- `SERVER_*_ROLE=web` (if user wants web server)
- `SERVER_*_PROVIDER=OCI` (if user wants OCI)
- `SERVER_*_STATUS=active` (active servers only)

Decide whether to reuse existing or create new.

### After Provisioning

When a node is successfully created:

1. Choose new server ID (e.g., `WEB02`)
2. Write block of `SERVER_<ID>_*` keys to inventory
3. Minimum required fields:

```env
SERVER_WEB02_PROVIDER=OCI
SERVER_WEB02_KIND=vm
SERVER_WEB02_NAME=prod-web-2
SERVER_WEB02_CONNECT_VIA=ssh
SERVER_WEB02_HOST=203.0.113.11
SERVER_WEB02_PORT=22
SERVER_WEB02_USER=ubuntu
SERVER_WEB02_SSH_KEY_PATH=~/.ssh/id_rsa
SERVER_WEB02_ENV=prod
SERVER_WEB02_OS=linux
SERVER_WEB02_ROLE=web
SERVER_WEB02_STATUS=active
```

### Retiring Nodes

- Set `SERVER_<ID>_STATUS=stopped` for stopped VMs
- Set `SERVER_<ID>_STATUS=retired` for destroyed nodes
- **Do not delete** the block - preserve history
- Avoid reusing IDs of retired nodes

---

## Quick Start

### 1. Check for Existing Inventory

```bash
# Look for inventory file
for f in .agent-devops.env agent-devops.env.local ~/.agent-devops.env; do
  [ -f "$f" ] && echo "Found: $f" && cat "$f"
done
```

### 2. Create Inventory from Template

```bash
cp ~/.claude/skills/admin-servers/assets/agent-devops.env.template .agent-devops.env
```

### 3. Discover Available Providers

```bash
# List installed infrastructure skills
ls -d ~/.claude/skills/admin-infra-* 2>/dev/null | xargs -I{} basename {} | sed 's/^admin-infra-//'
```

### 4. List Servers

```bash
# Extract server IDs from inventory
grep -oP 'SERVER_\K[A-Z0-9_]+(?=_NAME)' .agent-devops.env | sort -u
```

### 5. Connect to Server

```bash
# Get connection details for a server
SERVER_ID="WEB01"
HOST=$(grep "SERVER_${SERVER_ID}_HOST=" .agent-devops.env | cut -d= -f2)
USER=$(grep "SERVER_${SERVER_ID}_USER=" .agent-devops.env | cut -d= -f2)
KEY=$(grep "SERVER_${SERVER_ID}_SSH_KEY_PATH=" .agent-devops.env | cut -d= -f2)

ssh -i "$KEY" "$USER@$HOST"
```

---

## Provider Discovery

Claude should discover available infrastructure skills:

```bash
# Discover available infrastructure skills
AVAILABLE_PROVIDERS=$(ls -d ~/.claude/skills/admin-infra-* 2>/dev/null | \
  xargs -I{} basename {} | sed 's/^admin-infra-//' | sort)
echo "Available providers: $AVAILABLE_PROVIDERS"
```

**Known Provider Skills**:

| Provider | Skill | Cost Range | Notes |
|----------|-------|------------|-------|
| Oracle Cloud | `admin-infra-oci` | $0 (Free Tier) | 4 OCPU ARM64, 24GB RAM |
| Hetzner | `admin-infra-hetzner` | EUR4-32/mo | ARM (CAX) or x86 (CX) |
| DigitalOcean | `admin-infra-digitalocean` | $24-96/mo | Native Kasm auto-scaling |
| Vultr | `admin-infra-vultr` | $24-192/mo | High-frequency NVMe |
| Linode | `admin-infra-linode` | $24-192/mo | Akamai network |
| Contabo | `admin-infra-contabo` | EUR5-39/mo | Best price/performance |

---

## Common Operations

### Provision New Server

1. Check inventory for existing suitable servers
2. If none found, load appropriate `admin-infra-*` skill
3. Create server with provider's CLI
4. Add server to inventory
5. Verify SSH connectivity

```bash
# Example: Check for existing dev servers before provisioning
grep -E "SERVER_.*_ENV=dev" .agent-devops.env
grep -E "SERVER_.*_ROLE=web" .agent-devops.env
grep -E "SERVER_.*_STATUS=active" .agent-devops.env
```

### Update Server Status

```bash
# Mark server as stopped
sed -i "s/SERVER_WEB01_STATUS=active/SERVER_WEB01_STATUS=stopped/" .agent-devops.env

# Mark server as retired (destroyed)
sed -i "s/SERVER_WEB01_STATUS=.*/SERVER_WEB01_STATUS=retired/" .agent-devops.env
```

### Add New Provider

```bash
# Add Hetzner provider to inventory
cat >> .agent-devops.env << 'EOF'

# Hetzner Cloud
PROVIDER_HETZNER_TYPE=hetzner
PROVIDER_HETZNER_AUTH_METHOD=file
PROVIDER_HETZNER_AUTH_FILE=~/.config/hcloud/token
PROVIDER_HETZNER_DEFAULT_REGION=nbg1
PROVIDER_HETZNER_LABEL=Hetzner Cloud
EOF
```

---

## Example Inventory

```env
# =========================
# METADATA
# =========================
AGENT_DEVOPS_VERSION=1
AGENT_DEVOPS_PROJECT=myproject
AGENT_DEVOPS_OWNER=admin

# =========================
# PROVIDERS
# =========================

# Oracle Cloud
PROVIDER_OCI_TYPE=oci
PROVIDER_OCI_AUTH_METHOD=file
PROVIDER_OCI_AUTH_FILE=~/.oci/config
PROVIDER_OCI_DEFAULT_REGION=us-ashburn-1
PROVIDER_OCI_LABEL=OCI Free Tier

# Hetzner Cloud
PROVIDER_HETZNER_TYPE=hetzner
PROVIDER_HETZNER_AUTH_METHOD=file
PROVIDER_HETZNER_AUTH_FILE=~/.config/hcloud/token
PROVIDER_HETZNER_DEFAULT_REGION=nbg1
PROVIDER_HETZNER_LABEL=Hetzner Cloud

# Home LAN
PROVIDER_LOCALNET_TYPE=local_network
PROVIDER_LOCALNET_LABEL=Home LAN
PROVIDER_LOCALNET_NOTES=192.168.1.0/24

# This machine
PROVIDER_LOCAL_AGENT_TYPE=local_network
PROVIDER_LOCAL_AGENT_LABEL=This machine

# =========================
# SERVERS / NODES
# =========================

# Local dev machine
SERVER_LOCALBOX_PROVIDER=LOCAL_AGENT
SERVER_LOCALBOX_KIND=local_pc
SERVER_LOCALBOX_NAME=dev-laptop
SERVER_LOCALBOX_CONNECT_VIA=local
SERVER_LOCALBOX_ENV=personal
SERVER_LOCALBOX_OS=linux
SERVER_LOCALBOX_STATUS=active
SERVER_LOCALBOX_ROLE=dev
SERVER_LOCALBOX_TAGS=dev,primary

# OCI Coolify server
SERVER_COOLIFY01_PROVIDER=OCI
SERVER_COOLIFY01_KIND=vm
SERVER_COOLIFY01_NAME=coolify-prod
SERVER_COOLIFY01_CONNECT_VIA=ssh
SERVER_COOLIFY01_HOST=129.213.10.50
SERVER_COOLIFY01_PORT=22
SERVER_COOLIFY01_USER=ubuntu
SERVER_COOLIFY01_SSH_KEY_PATH=~/.ssh/id_rsa
SERVER_COOLIFY01_ENV=prod
SERVER_COOLIFY01_OS=linux
SERVER_COOLIFY01_ROLE=coolify
SERVER_COOLIFY01_STATUS=active
SERVER_COOLIFY01_TAGS=paas,docker,critical

# Hetzner KASM server
SERVER_KASM01_PROVIDER=HETZNER
SERVER_KASM01_KIND=vm
SERVER_KASM01_NAME=kasm-workspaces
SERVER_KASM01_CONNECT_VIA=ssh
SERVER_KASM01_HOST=65.109.10.11
SERVER_KASM01_PORT=22
SERVER_KASM01_USER=root
SERVER_KASM01_SSH_KEY_PATH=~/.ssh/id_rsa_hetzner
SERVER_KASM01_ENV=prod
SERVER_KASM01_OS=linux
SERVER_KASM01_ROLE=kasm
SERVER_KASM01_STATUS=active
SERVER_KASM01_TAGS=vdi,workspaces

# Retired server (history preserved)
SERVER_WEB01_PROVIDER=OCI
SERVER_WEB01_KIND=vm
SERVER_WEB01_NAME=old-web-server
SERVER_WEB01_CONNECT_VIA=ssh
SERVER_WEB01_HOST=0.0.0.0
SERVER_WEB01_USER=ubuntu
SERVER_WEB01_STATUS=retired
SERVER_WEB01_NOTES=Terminated 2024-12-01
```

---

## Parser Scripts

Parsers are available in the `scripts/` directory for programmatic inventory management:

- **TypeScript**: `scripts/agentDevopsInventory.ts`
- **Python**: `scripts/agent_devops_inventory.py`

See scripts for API documentation.

---

## Deployment Workflows

<details>
<summary><strong>Coolify Deployment</strong></summary>

Deploy self-hosted PaaS with Coolify:

### Prerequisites
- Infrastructure skill installed (e.g., `admin-infra-oci`)
- `admin-app-coolify` skill installed

### Steps

1. **Provision Server**
   - Load `{provider}-infrastructure` skill
   - Create VM with 2+ vCPU, 8GB+ RAM
   - Add to inventory with `ROLE=coolify`

2. **Install Coolify**
   - Load `admin-app-coolify` skill
   - Run installation on provisioned server
   - Store credentials in `.env.local`

3. **Configure Tunnel** (optional)
   - Tunnel configuration is included in the `admin-app-coolify` skill
   - See `admin-app-coolify/references/cloudflare-tunnel.md`

4. **Update Inventory**
   ```env
   SERVER_COOLIFY01_ROLE=coolify
   SERVER_COOLIFY01_TAGS=paas,docker,prod
   ```

### Related Skills
- `admin-app-coolify` - Coolify installation, configuration, and tunnel setup

</details>

<details>
<summary><strong>KASM Workspaces Deployment</strong></summary>

Deploy virtual desktop infrastructure with KASM:

### Prerequisites
- Infrastructure skill installed
- `admin-app-kasm` skill installed

### Steps

1. **Provision Server**
   - Load `{provider}-infrastructure` skill
   - Create VM with 4+ vCPU, 16GB+ RAM (VDI is resource-intensive)
   - Add to inventory with `ROLE=kasm`

2. **Install KASM**
   - Load `admin-app-kasm` skill
   - Run installation (takes 10-15 minutes)
   - Store admin credentials

3. **Configure Tunnel** (optional)
   - Tunnel configuration is included in the `admin-app-kasm` skill
   - Route `kasm.yourdomain.com` to port 8443

4. **Update Inventory**
   ```env
   SERVER_KASM01_ROLE=kasm
   SERVER_KASM01_TAGS=vdi,workspaces,secure
   ```

### Related Skills
- `admin-app-kasm` - KASM installation, configuration, and tunnel setup

</details>

<details>
<summary><strong>Multi-Server Deployment</strong></summary>

Deploy complete infrastructure with multiple services:

### Recommended Architecture

| Server | Role | Provider | Resources |
|--------|------|----------|-----------|
| COOLIFY01 | coolify | OCI | 2 OCPU, 12GB |
| KASM01 | kasm | Hetzner | 4 vCPU, 16GB |
| DB01 | database | OCI | 2 OCPU, 12GB |

### Steps

1. **Check Inventory** for existing servers
2. **Provision** needed servers via infrastructure skills
3. **Install Services** via service skills
4. **Configure Tunnels** for public access
5. **Update Inventory** with all server details

### Cost Optimization

- Use OCI Free Tier for 2 ARM64 VMs ($0)
- Use Contabo for additional capacity (EUR8-14/mo)
- Use Hetzner for European presence (EUR4-20/mo)

</details>

---

## Cost Comparison

| Provider | Coolify/KASM (4-8GB) | Monthly | Notes |
|----------|----------------------|---------|-------|
| **OCI Free Tier** | 4 OCPU, 24GB | **$0** | Best value (capacity limited) |
| **Contabo** | 6 vCPU, 18GB | **EUR8** | Best paid option |
| **Hetzner** | 4 vCPU ARM, 8GB | EUR8 | ARM (EU only) |
| DigitalOcean | 4 vCPU, 8GB | $48 | Kasm auto-scaling |
| Vultr | 4 vCPU, 8GB | $48 | Global NVMe |
| Linode | 4 vCPU, 8GB | $48 | Akamai network |

---

## Troubleshooting

<details>
<summary><strong>SSH Connection Failed</strong></summary>

```bash
# Debug SSH connection
SERVER_ID="WEB01"
HOST=$(grep "SERVER_${SERVER_ID}_HOST=" .agent-devops.env | cut -d= -f2)
USER=$(grep "SERVER_${SERVER_ID}_USER=" .agent-devops.env | cut -d= -f2)
KEY=$(grep "SERVER_${SERVER_ID}_SSH_KEY_PATH=" .agent-devops.env | cut -d= -f2)

# Verbose SSH
ssh -v -i "$KEY" "$USER@$HOST" echo "connected"

# Check key permissions
ls -la "$KEY"
chmod 600 "$KEY"
```

</details>

<details>
<summary><strong>Inventory Parse Errors</strong></summary>

Common issues:
- Missing `=` in key-value pair
- Spaces around `=` (not allowed)
- Invalid characters in key names

```bash
# Validate inventory syntax
while IFS= read -r line; do
  [[ "$line" =~ ^[[:space:]]*$ ]] && continue
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  if ! [[ "$line" =~ ^[A-Z_][A-Z0-9_]*= ]]; then
    echo "Invalid line: $line"
  fi
done < .agent-devops.env
```

</details>

<details>
<summary><strong>Provider Not Found</strong></summary>

```bash
# Check if provider skill is installed
ls ~/.claude/skills/*-infrastructure

# Install missing skill
cd ~/.claude/skills
git clone <skill-repo> <provider>-infrastructure
```

</details>

---

## Files

```
admin-servers/
├── SKILL.md                              # This file
├── README.md                             # Quick reference
├── assets/
│   ├── agent-devops.env.template         # Inventory template
│   └── env-template                      # Legacy env template
└── scripts/
    ├── agentDevopsInventory.ts           # TypeScript parser
    └── agent_devops_inventory.py         # Python parser
```

---

## Related Skills

**Infrastructure Skills** (dynamically discovered):
| Skill | Provider | When Loaded |
|-------|----------|-------------|
| admin-infra-oci | Oracle Cloud | Provisioning OCI servers |
| admin-infra-hetzner | Hetzner | Provisioning Hetzner servers |
| admin-infra-digitalocean | DigitalOcean | Provisioning DO droplets |
| admin-infra-vultr | Vultr | Provisioning Vultr instances |
| admin-infra-linode | Linode | Provisioning Linodes |
| admin-infra-contabo | Contabo | Provisioning Contabo VPS |

**Service Skills** (progressive disclosure):
| Skill | Purpose | When Loaded |
|-------|---------|-------------|
| admin-app-coolify | Self-hosted PaaS (includes tunnel setup) | Deploying Coolify |
| admin-app-kasm | Virtual desktops (includes tunnel setup) | Deploying KASM |

> **Note**: Cloudflare tunnel and origin certificate configuration are bundled within the `admin-app-coolify` and `admin-app-kasm` skills as reference documentation.

---

## References

- [Oracle Cloud Free Tier](https://www.oracle.com/cloud/free/)
- [Hetzner Cloud](https://www.hetzner.com/cloud)
- [Coolify Documentation](https://coolify.io/docs)
- [KASM Documentation](https://kasmweb.com/docs)
