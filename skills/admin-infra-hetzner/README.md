# Hetzner Cloud Infrastructure

Deploy servers on Hetzner Cloud with ARM64 (CAX) or x86 (CX) instances.

## Quick Start

```bash
# 1. Install hcloud CLI
brew install hcloud  # macOS

# 2. Configure authentication
hcloud context create myproject

# 3. Upload SSH key
hcloud ssh-key create --name myproject-key --public-key-from-file ~/.ssh/id_rsa.pub

# 4. Create server
hcloud server create \
  --name myproject-coolify \
  --type cax21 \
  --image ubuntu-22.04 \
  --location nbg1 \
  --ssh-key myproject-key

# 5. Get IP and connect
SERVER_IP=$(hcloud server ip myproject-coolify)
ssh root@$SERVER_IP
```

## Server Profiles

| Use Case | Type | Specs | Cost |
|----------|------|-------|------|
| Coolify | CAX11 | 2 vCPU, 4GB | ~$4/mo |
| KASM | CAX21 | 4 vCPU, 8GB | ~$8/mo |
| Both | CAX31 | 8 vCPU, 16GB | ~$16/mo |

## Locations

- `nbg1` - Nuremberg, Germany
- `fsn1` - Falkenstein, Germany
- `hel1` - Helsinki, Finland
- `ash` - Ashburn, USA
- `hil` - Hillsboro, USA

Note: ARM (CAX) servers only available in European locations.

## See Also

- [SKILL.md](SKILL.md) - Full documentation
- [Hetzner Console](https://console.hetzner.cloud/)
