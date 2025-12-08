---
name: admin-app-coolify
description: |
  Install and manage Coolify, an open-source self-hosted PaaS for deploying applications with Docker.
  Heroku-like experience on your own infrastructure.

  Use when: installing Coolify, deploying Docker apps, setting up self-hosted PaaS, configuring Traefik proxy.

  Keywords: coolify, self-hosted paas, docker deployment, traefik proxy, open source heroku
license: MIT
---

# Coolify

**Status**: Production Ready | **Dependencies**: Docker, Docker Compose

---

## Prerequisites

Before using this skill, verify the following:

### 1. Server Access

```bash
ssh ubuntu@<SERVER_IP> "echo connected"
```

**If this fails**: Check SSH key and server IP in `.env.local`

### 2. Minimum Resources

```bash
ssh ubuntu@<SERVER_IP> "free -h | grep Mem"
```

**Required**: 4GB+ RAM (2GB Coolify + 2GB for apps)

### 3. Docker Installed (or will be installed)

```bash
ssh ubuntu@<SERVER_IP> "docker --version"
```

**If missing**: The installation script installs Docker automatically

### 4. Required Ports Available

```bash
ssh ubuntu@<SERVER_IP> "sudo netstat -tlnp | grep -E ':(8000|80|443)'"
```

**Should return nothing** (ports not in use). Required ports:
- 8000: Coolify Web UI
- 80/443: Traefik proxy (HTTP/HTTPS)
- 6001/6002: Coolify internal

---

## Installation Steps

### Step 1: System Update

```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$COOLIFY_SERVER_IP "
  sudo apt-get update && sudo apt-get upgrade -y
"
```

### Step 2: Install Docker

```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$COOLIFY_SERVER_IP "
  # Install Docker dependencies
  sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

  # Add Docker GPG key and repository
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo 'deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Install Docker
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  sudo systemctl start docker && sudo systemctl enable docker
  sudo usermod -aG docker \$USER

  # Verify
  docker --version && docker compose version
"
```

### Step 3: Install Dependencies

```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$COOLIFY_SERVER_IP "
  sudo apt-get install -y curl wget git unzip jq openssh-server
  sudo systemctl enable --now ssh
"
```

### Step 4: Install Coolify

```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$COOLIFY_SERVER_IP "
  export ROOT_USERNAME='$COOLIFY_ROOT_USERNAME'
  export ROOT_USER_EMAIL='$COOLIFY_ROOT_USER_EMAIL'
  export ROOT_USER_PASSWORD='$COOLIFY_ROOT_USER_PASSWORD'
  curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
"

# Wait for services to start
sleep 30
```

> **Note**: The install script uses `ROOT_USERNAME`, `ROOT_USER_EMAIL`, `ROOT_USER_PASSWORD` internally. We use `COOLIFY_` prefixed variables in `.env.local` for clarity.

### Step 5: Configure Firewall

```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$COOLIFY_SERVER_IP "
  sudo ufw --force enable
  sudo ufw allow 22/tcp    # SSH
  sudo ufw allow 8000/tcp  # Coolify UI
  sudo ufw allow 80/tcp    # HTTP
  sudo ufw allow 443/tcp   # HTTPS
  sudo ufw allow 6001/tcp  # Coolify proxy
  sudo ufw allow 6002/tcp  # Coolify proxy
  sudo ufw status
"
```

### Step 6: Verify Installation

```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$COOLIFY_SERVER_IP "
  docker ps | grep coolify
  curl -s -o /dev/null -w '%{http_code}' http://localhost:8000
"
```

**Expected**: Coolify containers running, HTTP 200 or 302

### Step 7: Configure Coolify SSH Access for Localhost Management

> **CRITICAL**: Coolify generates its own SSH key during installation. This key must be added to the server's `authorized_keys` so Coolify can manage Docker containers on localhost.

> **Note on SSH Key Naming (v4.x)**: Coolify v4.x (beta.451+) uses a new naming convention: `ssh_key@<random_id>` instead of the old `id.root@host.docker.internal.pub`. The key is a **private key** (Ed25519) - we extract the public key using `ssh-keygen -y`.

**Wait for Coolify to be fully ready** (key generation takes ~30-60 seconds):
```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$COOLIFY_SERVER_IP "
  # Wait for any SSH key to be generated (v4.x uses ssh_key@* naming)
  until docker exec coolify find /var/www/html/storage/app/ssh/keys/ -name 'ssh_key*' 2>/dev/null | grep -q .; do
    echo 'Waiting for Coolify SSH key generation...'
    sleep 10
  done
  echo 'SSH key found'
"
```

**Get Coolify's public key and add to authorized_keys**:
```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$COOLIFY_SERVER_IP "
  # Find the SSH key file (v4.x naming: ssh_key@<random_id>)
  KEY_FILE=\$(docker exec coolify find /var/www/html/storage/app/ssh/keys/ -type f -name 'ssh_key*' | head -1)
  echo \"Found key file: \$KEY_FILE\"

  # Extract public key from private key (v4.x keys are Ed25519 private keys)
  COOLIFY_KEY=\$(docker exec coolify ssh-keygen -y -f \"\$KEY_FILE\")
  echo \"Coolify's public key: \$COOLIFY_KEY\"

  # Add to root's authorized_keys (Coolify connects as root)
  # NOTE: OCI images have a restrictive entry that blocks root SSH - we REPLACE not append
  sudo mkdir -p /root/.ssh

  # Check if this is OCI (has restrictive 'Please login as' entry)
  if sudo grep -q 'Please login as the user' /root/.ssh/authorized_keys 2>/dev/null; then
    echo 'OCI detected - replacing restrictive authorized_keys'
    echo \"\$COOLIFY_KEY coolify\" | sudo tee /root/.ssh/authorized_keys > /dev/null
  else
    echo 'Adding key to existing authorized_keys'
    echo \"\$COOLIFY_KEY\" | sudo tee -a /root/.ssh/authorized_keys > /dev/null
  fi

  sudo chmod 700 /root/.ssh
  sudo chmod 600 /root/.ssh/authorized_keys

  # Ensure root login is allowed with key (OCI may have it disabled)
  sudo sed -i 's/^#*PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config
  sudo systemctl restart sshd

  # Also add to current user as backup
  echo \"\$COOLIFY_KEY\" >> ~/.ssh/authorized_keys

  echo 'SSH key added to authorized_keys'
"
```

> **OCI Note**: OCI Ubuntu images have a restrictive entry in `/root/.ssh/authorized_keys` that blocks root SSH. The script above detects this and replaces the file instead of appending.

**Verify SSH connectivity from Coolify's perspective**:
```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$COOLIFY_SERVER_IP "
  # Test that root can SSH to localhost
  sudo ssh -o StrictHostKeyChecking=no -o BatchMode=yes root@localhost 'echo SSH connection successful'
"
```

**Expected**: "SSH connection successful" - Coolify can now manage localhost.

### Step 8: Access Coolify

Open in browser: `http://$COOLIFY_SERVER_IP:8000`

Login with configured admin credentials.

**Verify localhost server is connected**:
1. Go to **Servers** in the left sidebar
2. Click on **localhost**
3. Server should show as "Connected" (green checkmark)
4. If not connected, click "Validate Server" to refresh

### Step 9: Configure Domain Settings (Turnkey Setup)

> **IMPORTANT**: This step auto-configures Coolify's domain settings in the database. Skip if you prefer manual configuration via the UI.

```bash
# Wait for database to be ready
ssh -i $SSH_KEY_PATH $SSH_USER@$COOLIFY_SERVER_IP "
  until docker exec coolify-db pg_isready -U coolify -d coolify 2>/dev/null; do
    echo 'Waiting for Coolify database...'
    sleep 5
  done
  echo 'Database ready'
"

# Configure Instance FQDN (main Coolify URL - shown in Settings > Configuration)
ssh -i $SSH_KEY_PATH $SSH_USER@$COOLIFY_SERVER_IP "
  docker exec coolify-db psql -U coolify -d coolify -c \\
    \"UPDATE instance_settings SET fqdn = 'https://${COOLIFY_INSTANCE_DOMAIN}', updated_at = CURRENT_TIMESTAMP WHERE id = 0;\"
"

# Configure Wildcard Domain (for deployed apps - shown in Servers > localhost > Settings)
ssh -i $SSH_KEY_PATH $SSH_USER@$COOLIFY_SERVER_IP "
  docker exec coolify-db psql -U coolify -d coolify -c \\
    \"UPDATE server_settings SET wildcard_domain = 'https://${COOLIFY_WILDCARD_DOMAIN}', updated_at = CURRENT_TIMESTAMP WHERE server_id = 0;\"
"

# Restart Coolify to apply changes
ssh -i $SSH_KEY_PATH $SSH_USER@$COOLIFY_SERVER_IP "docker restart coolify"
sleep 15

# Verify configuration
ssh -i $SSH_KEY_PATH $SSH_USER@$COOLIFY_SERVER_IP "
  docker exec coolify-db psql -U coolify -d coolify -c \\
    \"SELECT 'Instance FQDN' as setting, fqdn as value FROM instance_settings WHERE id = 0
     UNION ALL
     SELECT 'Wildcard Domain', wildcard_domain FROM server_settings WHERE server_id = 0;\"
"
```

**Expected output**:
```
      setting      |           value
-------------------+---------------------------
 Instance FQDN     | https://coolify.domain.com
 Wildcard Domain   | https://domain.com
```

**Variables required**:
- `COOLIFY_INSTANCE_DOMAIN` - Main Coolify URL (e.g., `coolify.yourdomain.com`)
- `COOLIFY_WILDCARD_DOMAIN` - Base domain for apps (e.g., `yourdomain.com`)

<details>
<summary><strong>Required environment variables</strong></summary>

```bash
# Server connection
COOLIFY_SERVER_IP=your_server_ip
SSH_USER=ubuntu
SSH_KEY_PATH=~/.ssh/id_rsa

# Admin credentials (COOLIFY_ prefix for clarity)
COOLIFY_ROOT_USERNAME=admin
COOLIFY_ROOT_USER_EMAIL=admin@yourdomain.com
COOLIFY_ROOT_USER_PASSWORD=your-secure-password  # See password requirements below

# Domain configuration (for Step 8)
COOLIFY_INSTANCE_DOMAIN=coolify.yourdomain.com   # Main Coolify URL
COOLIFY_WILDCARD_DOMAIN=yourdomain.com           # Base domain for apps
```

**Password Requirements (Coolify enforced)**:
- Minimum 8 characters
- At least one uppercase letter (A-Z)
- At least one lowercase letter (a-z)
- At least one number (0-9)
- At least one symbol (!@#$%^&*)

</details>

---

## What Coolify Creates

| Service | Port | Purpose |
|---------|------|---------|
| Coolify Web UI | 8000 | Management interface |
| Traefik Proxy | 80/443 | HTTP/HTTPS routing |
| PostgreSQL | Internal | Coolify database |
| Redis | Internal | Caching |

---

## Scripts

| Script | Purpose |
|--------|---------|
| `coolify-fix-dns.sh` | Fix DNS/NXDOMAIN issues |

<details>
<summary><strong>Script details</strong></summary>

### coolify-fix-dns.sh

Fixes common DNS issues:
- CNAME proxied flag
- DNS propagation
- Hostname mismatches

</details>

**Note**: For Cloudflare Tunnel setup, see [references/cloudflare-tunnel.md](references/cloudflare-tunnel.md).

---

## Critical Rules

### Always Do

✅ Install Docker first (20.10+ with Compose Plugin)
✅ Ensure 4GB+ RAM (2GB Coolify + 2GB apps)
✅ Open ports: 8000, 80, 443, 6001, 6002
✅ Save admin credentials from install output
✅ Wait 30-60s for services to start

### Never Do

❌ Install on <2GB RAM systems
❌ Use standalone docker-compose (need plugin)
❌ Expose port 8000 without HTTPS/tunnel
❌ Delete /data/coolify directory
❌ Stop Coolify containers manually

---

## Firewall Configuration

```bash
# Enable UFW
sudo ufw --force enable

# Required ports
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 8000/tcp # Coolify UI
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw allow 6001/tcp # Coolify proxy
sudo ufw allow 6002/tcp # Coolify proxy
```

---

## Deployment Types

<details>
<summary><strong>Nixpacks (automatic)</strong></summary>

Auto-detects language and framework:
- Node.js, Python, Ruby, Go, Rust, PHP, Java
- Zero configuration required
- Recommended for standard frameworks

</details>

<details>
<summary><strong>Dockerfile</strong></summary>

- Use existing Dockerfile
- Full control over build
- Supports multi-stage builds
- Best for complex apps

</details>

<details>
<summary><strong>Docker Compose</strong></summary>

- Deploy multiple containers
- Service dependencies
- Internal networking
- Ideal for full-stack apps

</details>

<details>
<summary><strong>Static Sites</strong></summary>

- HTML/CSS/JS deployment
- Built-in CDN support
- Automatic HTTPS
- Perfect for frontends

</details>

---

## Troubleshooting

<details>
<summary><strong>Web interface not loading</strong></summary>

```bash
# Check container status
docker ps | grep coolify

# View logs
docker logs coolify

# Verify port 8000
sudo netstat -tlnp | grep 8000

# Test local access
curl -v http://localhost:8000
```

</details>

<details>
<summary><strong>Apps not accessible via domain</strong></summary>

```bash
# Check Traefik proxy
docker ps | grep coolify-proxy
docker logs coolify-proxy

# Verify DNS
dig yourdomain.com

# Check proxy ports
sudo netstat -tlnp | grep -E ":(80|443)"
```

</details>

<details>
<summary><strong>Build/deployment fails</strong></summary>

**Common fixes**:
1. Check Dockerfile syntax
2. Verify Node.js/Python version
3. Set required environment variables
4. Review build command configuration
5. Check available disk space

</details>

<details>
<summary><strong>High memory usage</strong></summary>

```bash
# Check container resources
docker stats

# List containers by memory
docker ps --format "table {{.Names}}\t{{.Status}}"
```

Use Coolify UI for safe container restarts.

</details>

<details>
<summary><strong>Port conflicts</strong></summary>

**Port 8000 in use**:
```bash
sudo netstat -tlnp | grep 8000
# Stop conflicting service or change Coolify port
```

**Ports 80/443 in use**:
```bash
# Stop existing web server
sudo systemctl stop nginx
sudo systemctl stop apache2
```

</details>

---

## Service Management

```bash
# Check all Coolify containers
docker ps | grep coolify

# View logs
docker logs coolify
docker logs coolify-proxy

# Restart Coolify
docker restart coolify

# Check version
docker exec coolify cat /version

# Update Coolify
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
```

---

## Access Methods

<details>
<summary><strong>Direct IP (development)</strong></summary>

```
http://YOUR_SERVER_IP:8000
```

Not recommended for production.

</details>

<details>
<summary><strong>Cloudflare Tunnel (recommended)</strong></summary>

See [references/cloudflare-tunnel.md](references/cloudflare-tunnel.md) for complete setup.

**Quick config for Coolify**:
```bash
SERVICE_PROTOCOL=http
SERVICE_PORT=8000
SERVICE_IP=localhost
TUNNEL_HOSTNAME=coolify.yourdomain.com
```

For wildcard mode (multiple apps), use Option B in the tunnel reference.

Access via: `https://coolify.yourdomain.com`

Secure, no open ports needed.

</details>

<details>
<summary><strong>Reverse proxy</strong></summary>

Use nginx/caddy with Let's Encrypt SSL in front of Coolify.

</details>

---

## Architecture

```
Internet → Cloudflare/Direct → Traefik (80/443)
                                    │
         ┌─────────────────────────┼─────────────────────┐
         │                         │                     │
    Coolify UI (8000)         App 1 (Node)          App N (Python)
                                   │                     │
                              Internal Docker Network
                            (PostgreSQL, Redis, etc.)
```

---

## Post-Installation

1. **Initial Setup**: Add localhost as server in Coolify UI
2. **First App**: Connect GitHub/GitLab, select repo, deploy
3. **Domain**: Add custom domain, point DNS, auto-HTTPS via Traefik
4. **Secure Access** (recommended):
   - **Tunnel**: See [references/cloudflare-tunnel.md](references/cloudflare-tunnel.md)
   - **Origin Certs** (for OAuth/webhooks): See [references/cloudflare-origin-certificates.md](references/cloudflare-origin-certificates.md)
5. **Backups**: Configure database and app data backups

---

## Cost Comparison

| Provider | Specs | Monthly |
|----------|-------|---------|
| OCI Always Free | 4 OCPU ARM64, 24GB | $0 |
| Hetzner | 2 vCPU, 4GB | ~$5 |
| DigitalOcean | 2 vCPU, 4GB | $24 |
| AWS Lightsail | 2 vCPU, 4GB | $24 |

**Coolify**: Free and open-source (MIT)

---

## Files

```
coolify/
├── SKILL.md                      # This file
├── README.md                     # Quick reference
├── input-schema.json             # Parameter validation
├── scripts/
│   └── coolify-fix-dns.sh       # DNS troubleshooting
├── references/                   # Documentation
├── templates/
└── assets/
```

---

## References

- [Coolify Website](https://coolify.io)
- [Coolify Docs](https://coolify.io/docs)
- [GitHub Repository](https://github.com/coollabsio/coolify)
- [Discord Community](https://discord.gg/coolify)
