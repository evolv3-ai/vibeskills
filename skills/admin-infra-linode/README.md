# Linode Infrastructure

Deploy Linodes on Akamai Cloud with firewalls and Kubernetes Cluster Autoscaler support.

## Quick Start

```bash
# 1. Install linode-cli
pip3 install linode-cli

# 2. Configure authentication
linode-cli configure
# Or: export LINODE_CLI_TOKEN="your_token"

# 3. Upload SSH key
linode-cli sshkeys create --label "my-key" --ssh_key "$(cat ~/.ssh/id_rsa.pub)"

# 4. Create Linode
linode-cli linodes create \
  --region us-east \
  --type g6-standard-2 \
  --image linode/ubuntu22.04 \
  --label my-server \
  --authorized_keys "$(cat ~/.ssh/id_rsa.pub)" \
  --root_pass "$(openssl rand -base64 32)"

# 5. Get IP and connect
LINODE_ID=$(linode-cli linodes list --label my-server --format id --text --no-headers)
SERVER_IP=$(linode-cli linodes view "$LINODE_ID" --format ipv4 --text --no-headers | head -1)
ssh root@$SERVER_IP
```

## Server Profiles

| Use Case | Type | Specs | Cost |
|----------|------|-------|------|
| Coolify | g6-standard-2 | 2 vCPU, 4GB | $24/mo |
| KASM | g6-standard-4 | 4 vCPU, 8GB | $48/mo |
| Both | g6-standard-8 | 8 vCPU, 16GB | $96/mo |

## Dedicated CPU Plans

| Type | Specs | Cost |
|------|-------|------|
| g6-dedicated-2 | 2 vCPU, 4GB | $36/mo |
| g6-dedicated-4 | 4 vCPU, 8GB | $72/mo |
| g6-dedicated-8 | 8 vCPU, 16GB | $144/mo |

## Regions

- `us-east` - Newark, NJ
- `us-central` - Dallas, TX
- `us-west` - Fremont, CA
- `eu-west` - London, UK
- `eu-central` - Frankfurt, Germany
- `ap-south` - Singapore
- `ap-northeast` - Tokyo, Japan

## Kubernetes Auto-Scaling

LKE supports Cluster Autoscaler for automatic node pool scaling.

## See Also

- [SKILL.md](SKILL.md) - Full documentation
- [Linode Cloud Manager](https://cloud.linode.com/)
