# Vultr Infrastructure

Deploy Cloud Compute and High-Frequency instances on Vultr with firewalls and Kubernetes autoscaling.

## Quick Start

```bash
# 1. Install vultr-cli
brew install vultr/vultr-cli/vultr-cli  # macOS
# or download from GitHub releases for Linux

# 2. Configure authentication
vultr-cli config set api-key YOUR_API_KEY_HERE

# 3. Upload SSH key
vultr-cli ssh-key create --name "my-key" --key "$(cat ~/.ssh/id_rsa.pub)"

# 4. Create instance
SSH_KEY_ID=$(vultr-cli ssh-key list | grep "my-key" | awk '{print $1}')
vultr-cli instance create \
  --region ewr \
  --plan vc2-2c-4gb \
  --os 1743 \
  --ssh-keys "$SSH_KEY_ID" \
  --label my-server

# 5. Get IP and connect
sleep 60
INSTANCE_ID=$(vultr-cli instance list | grep "my-server" | awk '{print $1}')
SERVER_IP=$(vultr-cli instance get "$INSTANCE_ID" | grep "Main IP" | awk '{print $3}')
ssh root@$SERVER_IP
```

## Server Profiles

| Use Case | Plan | Specs | Cost |
|----------|------|-------|------|
| Coolify | vc2-2c-4gb | 2 vCPU, 4GB | $24/mo |
| KASM | vc2-4c-8gb | 4 vCPU, 8GB | $48/mo |
| Both | vc2-8c-32gb | 8 vCPU, 32GB | $192/mo |

## High-Frequency Plans (NVMe)

| Plan | Specs | Cost |
|------|-------|------|
| vhf-2c-4gb | 2 vCPU, 4GB, 64GB NVMe | $24/mo |
| vhf-4c-16gb | 4 vCPU, 16GB, 256GB NVMe | $72/mo |
| vhf-6c-24gb | 6 vCPU, 24GB, 384GB NVMe | $108/mo |

## Regions

- `ewr` - New Jersey, USA
- `ord` - Chicago, USA
- `lax` - Los Angeles, USA
- `lhr` - London, UK
- `fra` - Frankfurt, Germany
- `nrt` - Tokyo, Japan
- `sgp` - Singapore
- `syd` - Sydney, Australia

## Kubernetes Auto-Scaling

Vultr Kubernetes Engine supports node pool autoscaling with `--auto-scaler true`.

## See Also

- [SKILL.md](SKILL.md) - Full documentation
- [Vultr Console](https://my.vultr.com/)
