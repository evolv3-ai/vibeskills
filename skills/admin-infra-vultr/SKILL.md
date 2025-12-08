---
name: admin-infra-vultr
description: |
  Deploy infrastructure on Vultr with Cloud Compute instances, High-Frequency servers, and VPCs.
  Excellent value with Kubernetes autoscaling support and global data centers.

  Use when: setting up Vultr infrastructure, deploying cloud compute or high-frequency instances, configuring firewalls, needing good price/performance with global reach.

  Keywords: vultr, vultr-cli, VPS, cloud compute, high-frequency, firewall, VPC, kubernetes autoscale, infrastructure
license: MIT
---

# Vultr Infrastructure

**Status**: Production Ready | **Dependencies**: vultr-cli, SSH key pair

---

## Prerequisites

Before using this skill, verify the following:

### 1. Vultr CLI Installed

```bash
vultr-cli version
```

**If missing**, install with:

```bash
# macOS
brew install vultr/vultr-cli/vultr-cli

# Linux (download binary)
curl -sL https://github.com/vultr/vultr-cli/releases/latest/download/vultr-cli_linux_amd64.tar.gz | tar xz
sudo mv vultr-cli /usr/local/bin/

# Windows (scoop)
scoop bucket add vultr https://github.com/vultr/scoop-vultr.git
scoop install vultr-cli

# Go install
go install github.com/vultr/vultr-cli/v3@latest
```

### 2. Vultr Account & API Key

**If you don't have a Vultr account**:

Sign up at: https://www.vultr.com/?ref=YOUR_REFERRAL_CODE

> *Disclosure: This is a referral link. You'll receive $100 in credit, and the skill author receives $35 after you spend $25. Using this link helps support the development of these skills.*

**Get API Key**: https://my.vultr.com/settings/#settingsapi

Create a Personal Access Token with **All** permissions.

### 3. vultr-cli Configured

```bash
vultr-cli account
```

**If it shows an error**, configure with:

```bash
# Set API key
vultr-cli config set api-key YOUR_API_KEY_HERE

# Or via environment variable
export VULTR_API_KEY="your_api_key_here"
vultr-cli account
```

### 4. SSH Key Pair

```bash
ls ~/.ssh/id_rsa.pub
```

**If missing**, generate with:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

### 5. SSH Key Uploaded to Vultr

```bash
vultr-cli ssh-key list
```

**If empty**, upload with:

```bash
vultr-cli ssh-key create --name "my-key" --key "$(cat ~/.ssh/id_rsa.pub)"
```

### 6. Test Authentication

```bash
vultr-cli regions list
```

**If this fails**: API key may be invalid. Create a new one.

---

## Server Profiles

### Coolify/Kasm Deployments

| Profile | Plan | vCPU | RAM | Disk | Monthly Cost |
|---------|------|------|-----|------|--------------|
| `coolify` | vc2-2c-4gb | 2 | 4GB | 80GB | $24 |
| `kasm` | vc2-4c-8gb | 4 | 8GB | 160GB | $48 |
| `both` | vc2-8c-32gb | 8 | 32GB | 640GB | $192 |

### High-Frequency (NVMe, Best Performance)

| Profile | Plan | vCPU | RAM | Disk | Monthly Cost |
|---------|------|------|-----|------|--------------|
| `hf-small` | vhf-2c-4gb | 2 | 4GB | 64GB NVMe | $24 |
| `hf-medium` | vhf-4c-16gb | 4 | 16GB | 256GB NVMe | $72 |
| `hf-large` | vhf-6c-24gb | 6 | 24GB | 384GB NVMe | $108 |

<details>
<summary><strong>AMD High Performance (Dedicated vCPU)</strong></summary>

| Plan | vCPU | RAM | Disk | Monthly Cost |
|------|------|-----|------|--------------|
| vhp-2c-4gb-amd | 2 | 4GB | 60GB NVMe | $30 |
| vhp-4c-8gb-amd | 4 | 8GB | 120GB NVMe | $60 |
| vhp-8c-16gb-amd | 8 | 16GB | 240GB NVMe | $120 |

</details>

---

## Deployment Steps

### Step 1: Set Environment Variables

```bash
export VULTR_REGION="ewr"                  # See regions below
export VULTR_PLAN="vc2-2c-4gb"             # See profiles above
export VULTR_OS_ID="1743"                  # Ubuntu 22.04 x64
export SERVER_NAME="my-server"
export SSH_KEY_NAME="my-key"
```

<details>
<summary><strong>Region options</strong></summary>

| Code | Location | Region |
|------|----------|--------|
| `ewr` | New Jersey | US East |
| `ord` | Chicago | US Central |
| `dfw` | Dallas | US South |
| `lax` | Los Angeles | US West |
| `sea` | Seattle | US Northwest |
| `atl` | Atlanta | US Southeast |
| `mia` | Miami | US Southeast |
| `yto` | Toronto | Canada |
| `lhr` | London | UK |
| `ams` | Amsterdam | Netherlands |
| `fra` | Frankfurt | Germany |
| `cdg` | Paris | France |
| `nrt` | Tokyo | Japan |
| `sgp` | Singapore | Asia |
| `syd` | Sydney | Australia |
| `blr` | Bangalore | India |

Run `vultr-cli regions list` for full list.

</details>

<details>
<summary><strong>OS ID reference</strong></summary>

| OS ID | Operating System |
|-------|------------------|
| 1743 | Ubuntu 22.04 x64 |
| 2136 | Ubuntu 24.04 x64 |
| 477 | Debian 12 x64 |
| 447 | Debian 11 x64 |
| 215 | CentOS 7 x64 |

Run `vultr-cli os list` for full list.

</details>

### Step 2: Get SSH Key ID

```bash
SSH_KEY_ID=$(vultr-cli ssh-key list | grep "$SSH_KEY_NAME" | awk '{print $1}')
echo "SSH Key ID: $SSH_KEY_ID"

# Verify
if [ -z "$SSH_KEY_ID" ]; then
  echo "ERROR: SSH key '$SSH_KEY_NAME' not found. Upload it first."
  exit 1
fi
```

### Step 3: Create Firewall Group

```bash
# Create firewall group
FW_GROUP_ID=$(vultr-cli firewall group create --description "my-firewall" | grep -oP 'ID: \K\S+')
echo "Firewall Group ID: $FW_GROUP_ID"

# Allow SSH
vultr-cli firewall rule create --id "$FW_GROUP_ID" --protocol tcp --port 22 --subnet 0.0.0.0/0

# Allow HTTP/HTTPS
vultr-cli firewall rule create --id "$FW_GROUP_ID" --protocol tcp --port 80 --subnet 0.0.0.0/0
vultr-cli firewall rule create --id "$FW_GROUP_ID" --protocol tcp --port 443 --subnet 0.0.0.0/0

# Allow Coolify ports
vultr-cli firewall rule create --id "$FW_GROUP_ID" --protocol tcp --port 8000 --subnet 0.0.0.0/0
vultr-cli firewall rule create --id "$FW_GROUP_ID" --protocol tcp --port "6001:6002" --subnet 0.0.0.0/0

# Allow KASM ports
vultr-cli firewall rule create --id "$FW_GROUP_ID" --protocol tcp --port 8443 --subnet 0.0.0.0/0
vultr-cli firewall rule create --id "$FW_GROUP_ID" --protocol tcp --port 3389 --subnet 0.0.0.0/0
vultr-cli firewall rule create --id "$FW_GROUP_ID" --protocol tcp --port "3000:4000" --subnet 0.0.0.0/0
```

### Step 4: Create Instance

```bash
vultr-cli instance create \
  --region "$VULTR_REGION" \
  --plan "$VULTR_PLAN" \
  --os "$VULTR_OS_ID" \
  --ssh-keys "$SSH_KEY_ID" \
  --firewall-group "$FW_GROUP_ID" \
  --label "$SERVER_NAME" \
  --hostname "$SERVER_NAME"
```

### Step 5: Wait and Get Instance IP

```bash
# Wait for instance to be ready
echo "Waiting for instance to be active..."
sleep 30

# Get instance ID
INSTANCE_ID=$(vultr-cli instance list | grep "$SERVER_NAME" | awk '{print $1}')
echo "Instance ID: $INSTANCE_ID"

# Get IP address
SERVER_IP=$(vultr-cli instance get "$INSTANCE_ID" | grep "Main IP" | awk '{print $3}')
echo "SERVER_IP=$SERVER_IP"
```

### Step 6: Wait for Server Ready

```bash
# Wait for SSH to be available (typically 60-90 seconds)
echo "Waiting for server to be ready..."
until ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no root@$SERVER_IP "echo connected" 2>/dev/null; do
  sleep 5
done
echo "Server is ready!"
```

### Step 7: Verify Connection

```bash
ssh root@$SERVER_IP "uname -a && free -h && df -h /"
```

### Step 8: Output for Downstream Skills

```bash
# Vultr only offers x86 architecture
SERVER_ARCH="amd64"

# Save to .env.local for downstream skills
echo "SERVER_IP=$SERVER_IP" >> .env.local
echo "SSH_USER=root" >> .env.local
echo "SSH_KEY_PATH=~/.ssh/id_rsa" >> .env.local
echo "SERVER_ARCH=$SERVER_ARCH" >> .env.local
echo "COOLIFY_SERVER_IP=$SERVER_IP" >> .env.local
echo "KASM_SERVER_IP=$SERVER_IP" >> .env.local

echo ""
echo "Instance deployed successfully!"
echo "  IP: $SERVER_IP"
echo "  Arch: $SERVER_ARCH"
echo "  SSH: ssh root@$SERVER_IP"
```

---

## Verify Deployment

```bash
ssh root@$SERVER_IP "echo 'Vultr instance connected successfully'"
```

---

## Kubernetes Auto-Scaling

Vultr Kubernetes Engine (VKE) supports node pool autoscaling.

### Create VKE Cluster with Autoscaling

```bash
# Create cluster
vultr-cli kubernetes create \
  --region "$VULTR_REGION" \
  --version "v1.28.2+1" \
  --label "my-k8s"

# Get cluster ID
CLUSTER_ID=$(vultr-cli kubernetes list | grep "my-k8s" | awk '{print $1}')

# Create autoscaling node pool
vultr-cli kubernetes node-pool create "$CLUSTER_ID" \
  --plan "vc2-2c-4gb" \
  --label "worker-pool" \
  --quantity 2 \
  --min-nodes 1 \
  --max-nodes 5 \
  --auto-scaler true
```

### How It Works

- Vultr automatically adds nodes when workload increases
- Nodes are removed when demand decreases
- Specify min-nodes and max-nodes to control scaling range

---

## Cleanup

**Warning**: This is destructive and cannot be undone.

```bash
# Delete instance
INSTANCE_ID=$(vultr-cli instance list | grep "$SERVER_NAME" | awk '{print $1}')
vultr-cli instance delete "$INSTANCE_ID"

# Delete firewall group
FW_GROUP_ID=$(vultr-cli firewall group list | grep "my-firewall" | awk '{print $1}')
vultr-cli firewall group delete "$FW_GROUP_ID"

# Optionally delete SSH key
# vultr-cli ssh-key delete "$SSH_KEY_ID"
```

---

## Troubleshooting

<details>
<summary><strong>Instance creation fails</strong></summary>

**Common causes**:
1. Invalid region (check `vultr-cli regions list`)
2. Invalid plan for region (check `vultr-cli plans list`)
3. SSH key not found (check `vultr-cli ssh-key list`)
4. API key permissions (needs full access)

**Fix**: Verify each component separately:
```bash
vultr-cli regions list
vultr-cli plans list
vultr-cli ssh-key list
vultr-cli account
```

</details>

<details>
<summary><strong>Cannot SSH to instance</strong></summary>

**Checklist**:
1. Instance is running: `vultr-cli instance list`
2. Firewall allows port 22: `vultr-cli firewall rule list --id $FW_GROUP_ID`
3. Correct SSH key used
4. Wait 60-90 seconds after creation

**Debug**:
```bash
# Check instance status
vultr-cli instance get "$INSTANCE_ID"

# Check firewall
vultr-cli firewall rule list --id "$FW_GROUP_ID"

# Try with verbose SSH
ssh -v root@$SERVER_IP
```

</details>

<details>
<summary><strong>Plan not available in region</strong></summary>

Not all plans are available in every region.

**Check availability**:
```bash
vultr-cli plans list --type vc2
```

Use a different region or plan if unavailable.

</details>

---

## Best Practices

<details>
<summary><strong>Always do</strong></summary>

- Use High-Frequency plans for I/O intensive workloads
- Create dedicated firewall groups
- Use SSH keys (not password auth)
- Choose region closest to your users
- Enable backups for production
- Use labels to organize instances

</details>

<details>
<summary><strong>Never do</strong></summary>

- Share API keys across projects
- Leave all ports open (use firewall)
- Use password authentication
- Delete resources without confirming
- Skip firewall configuration

</details>

---

## Configuration Reference

<details>
<summary><strong>Environment variables</strong></summary>

```bash
# Required
VULTR_API_KEY=...                # API key from settings

# Deployment configuration
VULTR_REGION=ewr                 # Region code
VULTR_PLAN=vc2-2c-4gb            # Plan ID
VULTR_OS_ID=1743                 # OS ID (Ubuntu 22.04)
SERVER_NAME=my-server   # Instance label
SSH_KEY_NAME=my-key       # SSH key name in Vultr

# Outputs (set after deployment)
SERVER_IP=...                    # Public IP
SSH_USER=root                    # SSH username
SSH_KEY_PATH=~/.ssh/id_rsa       # Local private key path
```

</details>

<details>
<summary><strong>Plan reference</strong></summary>

**Cloud Compute (VC2)**:
| Plan | vCPU | RAM | Disk | Price/month |
|------|------|-----|------|-------------|
| vc2-1c-1gb | 1 | 1GB | 25GB | $6 |
| vc2-1c-2gb | 1 | 2GB | 55GB | $12 |
| vc2-2c-4gb | 2 | 4GB | 80GB | $24 |
| vc2-4c-8gb | 4 | 8GB | 160GB | $48 |
| vc2-6c-16gb | 6 | 16GB | 320GB | $96 |
| vc2-8c-32gb | 8 | 32GB | 640GB | $192 |

**High-Frequency (VHF)**:
| Plan | vCPU | RAM | Disk | Price/month |
|------|------|-----|------|-------------|
| vhf-1c-2gb | 1 | 2GB | 32GB NVMe | $12 |
| vhf-2c-4gb | 2 | 4GB | 64GB NVMe | $24 |
| vhf-3c-8gb | 3 | 8GB | 128GB NVMe | $48 |
| vhf-4c-16gb | 4 | 16GB | 256GB NVMe | $72 |
| vhf-6c-24gb | 6 | 24GB | 384GB NVMe | $108 |

</details>

---

## Cost Comparison

| Provider | 4 vCPU, 8GB | Monthly |
|----------|-------------|---------|
| **Vultr vc2-4c-8gb** | 4 vCPU, 8GB | **$48** |
| DigitalOcean s-4vcpu-8gb | 4 vCPU, 8GB | $48 |
| Hetzner CAX21 | 4 vCPU ARM, 8GB | ~$8 |
| Contabo VPS 20 SP | 6 vCPU, 18GB | ~$8 |

Vultr offers excellent performance with High-Frequency NVMe plans and extensive global coverage.

---

## Logging Integration

When performing infrastructure operations, log to the centralized system:

```bash
# After provisioning
log_admin "SUCCESS" "operation" "Provisioned Vultr instance" "id=$INSTANCE_ID provider=Vultr"

# After destroying
log_admin "SUCCESS" "operation" "Deleted Vultr instance" "id=$INSTANCE_ID"

# On error
log_admin "ERROR" "operation" "Vultr deployment failed" "error=$ERROR_MSG"
```

See `admin` skill's `references/logging.md` for full logging documentation.

---

## Files

```
admin-infra-vultr/
├── SKILL.md                  # This file
├── README.md                 # Quick reference
└── assets/
    └── env-template          # Environment variable template
```

---

## References

- [Vultr Console](https://my.vultr.com/)
- [vultr-cli Documentation](https://github.com/vultr/vultr-cli)
- [Pricing](https://www.vultr.com/pricing/)
- [API Documentation](https://www.vultr.com/api/)
- [Kubernetes Documentation](https://www.vultr.com/docs/vultr-kubernetes-engine/)
