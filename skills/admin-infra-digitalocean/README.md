# DigitalOcean Infrastructure

Deploy Droplets (VMs) on DigitalOcean with firewalls and native Kasm auto-scaling integration.

## Quick Start

```bash
# 1. Install doctl CLI
brew install doctl  # macOS
# or: snap install doctl  # Linux

# 2. Configure authentication
doctl auth init
# Paste your API token

# 3. Upload SSH key
doctl compute ssh-key import my-key --public-key-file ~/.ssh/id_rsa.pub

# 4. Create droplet
doctl compute droplet create my-server \
  --region nyc1 \
  --size s-2vcpu-4gb \
  --image ubuntu-22-04-x64 \
  --ssh-keys $(doctl compute ssh-key list --format ID --no-header | head -1) \
  --wait

# 5. Get IP and connect
SERVER_IP=$(doctl compute droplet get my-server --format PublicIPv4 --no-header)
ssh root@$SERVER_IP
```

## Server Profiles

| Use Case | Size | Specs | Cost |
|----------|------|-------|------|
| Coolify | s-2vcpu-4gb | 2 vCPU, 4GB | $24/mo |
| KASM | s-4vcpu-8gb | 4 vCPU, 8GB | $48/mo |
| Both | s-8vcpu-16gb | 8 vCPU, 16GB | $96/mo |

## Regions

- `nyc1`, `nyc3` - New York, USA
- `sfo2`, `sfo3` - San Francisco, USA
- `tor1` - Toronto, Canada
- `lon1` - London, UK
- `ams3` - Amsterdam, Netherlands
- `fra1` - Frankfurt, Germany
- `sgp1` - Singapore
- `blr1` - Bangalore, India
- `syd1` - Sydney, Australia

## Kasm Auto-Scaling

DigitalOcean has native Kasm Workspaces integration. Enable "Digital Ocean Scaling Enabled" in Kasm Infrastructure settings.

## See Also

- [SKILL.md](SKILL.md) - Full documentation
- [DigitalOcean Console](https://cloud.digitalocean.com/)
