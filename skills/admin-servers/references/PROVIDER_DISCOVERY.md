# Provider Discovery and Setup

## Contents
- Discover installed provider skills
- Known provider skills
- Add a new provider block

---

## Discover Installed Provider Skills

`admin-servers` discovers which `admin-infra-*` skills are installed and uses them for provisioning.

Bash:

```bash
AVAILABLE_PROVIDERS=$(ls -d ~/.claude/skills/admin-infra-* 2>/dev/null | \
  xargs -I{} basename {} | sed 's/^admin-infra-//' | sort)
echo "Available providers: $AVAILABLE_PROVIDERS"
```

PowerShell:

```powershell
$providersPath = Join-Path $env:USERPROFILE '.claude/skills/admin-infra-*'
$AVAILABLE_PROVIDERS = Get-ChildItem $providersPath -Directory |
    ForEach-Object { $_.Name -replace '^admin-infra-', '' } | Sort-Object
Write-Host "Available providers: $($AVAILABLE_PROVIDERS -join ', ')"
```

---

## Known Provider Skills (snapshot)

| Provider | Skill | Notes |
|----------|-------|-------|
| Oracle Cloud | `admin-infra-oci` | Always Free ARM64 tier; capacity can be limited |
| Hetzner | `admin-infra-hetzner` | EU‑centric, strong ARM value |
| DigitalOcean | `admin-infra-digitalocean` | Good US availability; native Kasm autoscale |
| Vultr | `admin-infra-vultr` | Global regions; High‑Frequency NVMe options |
| Linode | `admin-infra-linode` | Akamai edge integration |
| Contabo | `admin-infra-contabo` | Best paid price/perf in many regions |

Use the provider skill’s SKILL.md for exact CLI steps.

---

## Add a New Provider Block

Example: add Hetzner provider to inventory.

Bash:

```bash
cat >> .agent-devops.env << 'EOF'

# Hetzner Cloud
PROVIDER_HETZNER_TYPE=hetzner
PROVIDER_HETZNER_AUTH_METHOD=file
PROVIDER_HETZNER_AUTH_FILE=~/.config/hcloud/token
PROVIDER_HETZNER_DEFAULT_REGION=nbg1
PROVIDER_HETZNER_LABEL=Hetzner Cloud
EOF
```

PowerShell:

```powershell
@"

# Hetzner Cloud
PROVIDER_HETZNER_TYPE=hetzner
PROVIDER_HETZNER_AUTH_METHOD=file
PROVIDER_HETZNER_AUTH_FILE=~/.config/hcloud/token
PROVIDER_HETZNER_DEFAULT_REGION=nbg1
PROVIDER_HETZNER_LABEL=Hetzner Cloud
"@ | Add-Content .agent-devops.env
```

