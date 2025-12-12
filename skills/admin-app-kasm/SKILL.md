---
name: admin-app-kasm
description: |
  Installs and manages KASM Workspaces, a container-based VDI platform for streaming desktops to browsers.
  Supports Ubuntu ARM64, desktop streaming, isolated browser sessions, and remote workspace access.

  Use when: installing KASM on Ubuntu ARM64, setting up VDI, configuring browser-based desktops, deploying on OCI instances.

  Keywords: kasm workspaces, VDI, virtual desktop, browser streaming, ARM64, kasm port 8443, container desktop
license: MIT
---

# KASM Workspaces

**Status**: Production Ready | **Dependencies**: Docker, Docker Compose | **Version**: 1.17.0

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

**Required**: 8GB+ RAM (4GB KASM + 4GB per session)

### 3. Docker Installed (or will be installed)

```bash
ssh ubuntu@<SERVER_IP> "docker --version"
```

**If missing**: The installation script installs Docker automatically

### 4. Required Ports Available

```bash
ssh ubuntu@<SERVER_IP> "sudo netstat -tlnp | grep -E ':(8443|3389)'"
```

**Should return nothing** (ports not in use). Required ports:
- 8443: KASM Web UI
- 3389: RDP (optional)
- 3000-4000: Session streaming

---

## Installation Steps

### Step 1: System Update

```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$KASM_SERVER_IP "
  sudo apt-get update && sudo apt-get upgrade -y
"
```

### Step 2: Install Docker and Dependencies

```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$KASM_SERVER_IP "
  # Install dependencies including expect (for EULA automation)
  sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release expect

  # Add Docker GPG key and repository
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo 'deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Install Docker
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  sudo systemctl start docker && sudo systemctl enable docker
  sudo usermod -aG docker \$USER
"
```

### Step 3: Create Swap File (8GB)

```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$KASM_SERVER_IP "
  if ! sudo swapon --show | grep -q '/swapfile'; then
    sudo fallocate -l 8G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  fi
  free -h
"
```

### Step 4: Download and Install KASM

```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$KASM_SERVER_IP "
  mkdir -p /tmp/kasm-install && cd /tmp/kasm-install
  curl -O https://kasm-static-content.s3.amazonaws.com/kasm_release_1.17.0.7f020d.tar.gz
  tar -xf kasm_release_1.17.0.7f020d.tar.gz
  cd kasm_release

  # Use expect to automate EULA acceptance
  expect <<'EXPECT_EOF'
set timeout 600
spawn sudo bash install.sh
expect {
    \"I have read and accept End User License Agreement (y/n)?\" {
        send \"y\r\"
        exp_continue
    }
    \"Installation Complete\" { }
    timeout { exit 1 }
    eof
}
EXPECT_EOF
"
```

### Step 5: Configure Firewall

```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$KASM_SERVER_IP "
  sudo ufw --force enable
  sudo ufw allow 22/tcp       # SSH
  sudo ufw allow 8443/tcp     # KASM UI
  sudo ufw allow 3389/tcp     # RDP
  sudo ufw allow 3000:4000/tcp  # Sessions
  sudo ufw status
"
```

### Step 6: Verify Installation

```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$KASM_SERVER_IP "
  docker ps | grep kasm | wc -l  # Should be 8+
  curl -k -s -o /dev/null -w '%{http_code}' https://localhost:8443
"
```

### Step 7: Get Admin Credentials

```bash
# Extract credentials from install log (cleaner output)
ssh -i $SSH_KEY_PATH $SSH_USER@$KASM_SERVER_IP "
  echo '=== KASM Admin Credentials ==='
  # Admin user (default admin account)
  grep -A1 'admin@kasm.local' /opt/kasm/current/install_log.txt 2>/dev/null || \
  grep -A1 'admin@kasm.local' /tmp/kasm-install/kasm_release/install_log.txt 2>/dev/null
  echo ''
  # User account (if created)
  grep -A1 'user@kasm.local' /opt/kasm/current/install_log.txt 2>/dev/null || \
  grep -A1 'user@kasm.local' /tmp/kasm-install/kasm_release/install_log.txt 2>/dev/null || echo 'No user@kasm.local found'
  echo '=== End Credentials ==='
"
```

**Note**: Credentials appear on the line following the username. If not found in `/opt/kasm/current/`, check `/tmp/kasm-install/kasm_release/`.

### Step 8: Access KASM

Open in browser: `https://$KASM_SERVER_IP` (default port 443, or `:$KASM_PORT` if custom)

Accept the self-signed certificate warning and login with admin credentials.

<details>
<summary><strong>Required environment variables</strong></summary>

```bash
KASM_SERVER_IP=your_server_ip
SSH_USER=ubuntu
SSH_KEY_PATH=~/.ssh/id_rsa
KASM_PORT=443   # Default KASM install uses 443, not 8443
RDP_PORT=3389
```

</details>

<details>
<summary><strong>What gets installed</strong></summary>

| Component | Port | Purpose |
|-----------|------|---------|
| KASM Web UI | 443 (default) | Management interface (HTTPS) |
| Session ports | 3000-4000 | WebSocket streaming |
| RDP | 3389 | Optional remote desktop |
| PostgreSQL | Internal | KASM database |
| Redis | Internal | Session caching |
| Guacamole | Internal | Session management |

Creates 8+ Docker containers for full VDI functionality.

**Note**: Default KASM installation uses port 443. Custom installations may use 8443.

</details>

---

## Notes

For Cloudflare Tunnel setup, see [references/cloudflare-tunnel.md](references/cloudflare-tunnel.md). KASM requires `noTLSVerify: true` for its self-signed certificate.

---

## Critical Rules

### Always Do

✅ Install Docker first (20.10+ with Compose Plugin)
✅ Ensure 8GB+ RAM (4GB KASM + 4GB per session)
✅ Open ports: 8443, 3389, 3000-4000
✅ Save admin credentials from install_log.txt
✅ Accept self-signed SSL certificate warning
✅ Wait for 8+ containers before accessing

### Never Do

❌ Install on <4GB RAM systems
❌ Skip Docker installation
❌ Expose port 8443 without HTTPS/tunnel
❌ Delete /opt/kasm directory
❌ Stop KASM containers individually
❌ Ignore memory warnings (2-4GB per session)

---

## Firewall Configuration

```bash
# Enable UFW
sudo ufw --force enable

# Required ports
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 8443/tcp  # KASM UI
sudo ufw allow 3389/tcp  # RDP (optional)
sudo ufw allow 3000:4000/tcp  # Sessions
```

---

## Workspace Types

<details>
<summary><strong>Desktop workspaces</strong></summary>

- **Ubuntu Desktop**: Full XFCE/KDE environment
- **Windows**: Windows 10/11 (requires license)
- **Kali Linux**: Penetration testing desktop
- **CentOS/Fedora**: Enterprise Linux desktops

</details>

<details>
<summary><strong>Application workspaces</strong></summary>

- **Chrome/Firefox**: Isolated browser sessions
- **VS Code**: Browser-based development
- **Terminal**: Linux CLI with tools
- **GIMP/Inkscape**: Graphics applications

</details>

<details>
<summary><strong>Custom workspaces</strong></summary>

- Build custom Docker images
- Deploy isolated applications
- Configure persistent storage

</details>

---

## Troubleshooting

<details>
<summary><strong>Web interface not loading</strong></summary>

```bash
# Check all KASM containers (should be 8+)
docker ps | grep kasm | wc -l

# View logs
docker logs kasm_api
docker logs kasm_manager

# Verify port 8443
sudo netstat -tlnp | grep 8443

# Test local access
curl -k -v https://localhost:8443
```

</details>

<details>
<summary><strong>Sessions won't launch</strong></summary>

```bash
# Check agent status
docker ps | grep kasm_agent
docker logs kasm_agent

# Verify session ports
sudo netstat -tlnp | grep -E ":(3000|3001|3002)"

# Check memory
free -h

# Check Docker network
docker network ls | grep kasm
```

</details>

<details>
<summary><strong>Black screen or frozen desktop</strong></summary>

**Checklist**:
1. Verify firewall allows ports 3000-4000
2. Check browser console for WebSocket errors
3. Review session container logs
4. Restart KASM services

```bash
# Check firewall
sudo ufw status | grep "3000:4000"

# Restart services
cd ~/kasm-install/kasm_release
sudo docker compose restart
```

</details>

<details>
<summary><strong>High resource usage</strong></summary>

```bash
# Check per-container usage
docker stats

# Identify heavy sessions
docker ps --format "table {{.Names}}\t{{.Status}}"

# Terminate via KASM web UI: Admin → Sessions → Terminate
```

</details>

---

## Known Issues Prevention

<details>
<summary><strong>7 documented issues and solutions</strong></summary>

| Issue | Cause | Prevention |
|-------|-------|------------|
| Docker not installed | Missing dependency | Install Docker CE first |
| <8 containers running | Memory constraints | Ensure 8GB+ RAM |
| SSL certificate warning | Self-signed cert | Accept browser warning |
| Port 8443 blocked | Firewall rules | Open port before install |
| Credentials not found | Logs not saved | Extract from install_log.txt |
| Sessions fail to launch | Insufficient RAM | 2-4GB per active session |
| Black screen | Ports 3000-4000 blocked | Open session ports |

</details>

---

## Service Management

```bash
# Check containers
docker ps | grep kasm

# View logs
docker logs kasm_api

# Restart services
cd ~/kasm-install/kasm_release
sudo docker compose restart

# Check version
docker exec kasm_api cat /version
```

---

## Access Methods

<details>
<summary><strong>Direct IP (development)</strong></summary>

```
https://YOUR_SERVER_IP:8443
```

Accept self-signed certificate warning. Not recommended for production.

</details>

<details>
<summary><strong>Cloudflare Tunnel (recommended)</strong></summary>

See [references/cloudflare-tunnel.md](references/cloudflare-tunnel.md) for complete setup.

**KASM-specific config**:
```bash
SERVICE_PROTOCOL=https
SERVICE_PORT=443  # Default KASM port
SERVICE_IP=localhost
TUNNEL_HOSTNAME=kasm.yourdomain.com
```

**Required**: KASM uses self-signed certs, so `noTLSVerify: true` is included in the reference setup.

Access via: `https://kasm.yourdomain.com`

</details>

<details>
<summary><strong>VPN access</strong></summary>

Use Cloudflare Zero Trust Access or WireGuard VPN to keep KASM on private network.

</details>

---

## Architecture

<details>
<summary><strong>System architecture diagram</strong></summary>

```
Internet → Cloudflare/Direct → KASM Web UI (8443)
                                     │
         ┌───────────────────────────┼───────────────────────┐
         │                           │                       │
    KASM API                   Session #1              Session #N
                               (Chrome)                (Ubuntu)
                                    │                       │
                              Ports 3000-4000               │
                                    │                       │
         ┌──────────────────────────┴───────────────────────┘
         │            Internal Docker Network               │
         │        (PostgreSQL, Redis, Guacamole)            │
         └──────────────────────────────────────────────────┘
```

</details>

---

## Post-Installation

1. **Initial Setup**: Login with admin credentials, change password
2. **Add Workspaces**: Admin → Workspaces → Enable images (Ubuntu, Chrome, etc.)
3. **Create Users**: Admin → Users → Add accounts and permissions
4. **External Access**: See [references/cloudflare-tunnel.md](references/cloudflare-tunnel.md) for secure HTTPS
5. **Monitor**: Use `docker stats` to track resource usage

---

## Cost Comparison

| Provider | Specs | Monthly |
|----------|-------|---------|
| OCI Always Free | 4 OCPU ARM64, 24GB | $0 |
| Hetzner | 4 vCPU, 8GB | ~$10 |
| DigitalOcean | 4 vCPU, 8GB | $48 |
| AWS Lightsail | 4 vCPU, 8GB | $40 |

**KASM**: Free Community Edition (up to 5 concurrent sessions)

---

## Logging Integration

When performing KASM operations, log to the centralized system:

```bash
# After installation
log_admin "SUCCESS" "installation" "Installed KASM Workspaces" "version=1.x server=$SERVER_ID"

# After configuration
log_admin "SUCCESS" "system-change" "Configured KASM" "domain=$DOMAIN"

# After adding workspace
log_admin "SUCCESS" "operation" "Added KASM workspace" "workspace=$WORKSPACE_NAME"

# On error
log_admin "ERROR" "operation" "KASM operation failed" "error=$ERROR_MSG"
```

See `admin` skill's `references/logging.md` for full logging documentation.

---

## Files

```
admin-app-kasm/
├── SKILL.md                  # This file
├── README.md                 # Quick reference
├── input-schema.json         # Parameter validation
├── references/               # Documentation
└── assets/
```

---

## References

- [KASM Website](https://www.kasmweb.com)
- [KASM Docs](https://kasmweb.com/docs/latest/)
- [GitHub Repository](https://github.com/kasmtech)
- [Docker Hub](https://hub.docker.com/u/kasmweb)
