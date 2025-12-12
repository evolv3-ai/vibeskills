# KASM Workspaces Installation

Step‑by‑step installation for Ubuntu ARM64 servers. Use when you need a manual, repeatable install outside the post‑installation wizard.

## Contents
- Prerequisites
- Installation Steps
- Verify Installation
- Get Admin Credentials
- Access KASM
- Firewall Rules

---

## Prerequisites

Verify before installing:

1. **Server access**
   ```bash
   ssh ubuntu@<SERVER_IP> "echo connected"
   ```
   If this fails, check SSH key and IP in `.env.local`.

2. **Minimum resources**
   ```bash
   ssh ubuntu@<SERVER_IP> "free -h | grep Mem"
   ```
   Required: 8GB+ RAM (4GB KASM + 4GB per session).

3. **Docker installed (or will be installed)**
   ```bash
   ssh ubuntu@<SERVER_IP> "docker --version"
   ```

4. **Required ports available**
   ```bash
   ssh ubuntu@<SERVER_IP> "sudo netstat -tlnp | grep -E ':(8443|3389)'"
   ```
   Ports:
   - 8443: KASM UI (installer listens here)
   - 443: KASM UI default after install
   - 3389: RDP (optional)
   - 3000–4000: session streaming

## Installation Steps

### Step 1: System update

```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$KASM_SERVER_IP "
  sudo apt-get update && sudo apt-get upgrade -y
"
```

### Step 2: Install Docker and dependencies

```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$KASM_SERVER_IP "
  # Install dependencies including expect (for EULA automation)
  sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release expect

  # Add Docker GPG key and repository
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo 'deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Install Docker
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  sudo systemctl start docker && sudo systemctl enable docker
  sudo usermod -aG docker \$USER
"
```

### Step 3: Create swap file (8GB)

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

### Step 4: Download and install KASM

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

## Verify Installation

```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$KASM_SERVER_IP "
  docker ps | grep kasm | wc -l  # Should be 8+
  curl -k -s -o /dev/null -w '%{http_code}' https://localhost:8443
"
```

## Get Admin Credentials

```bash
ssh -i $SSH_KEY_PATH $SSH_USER@$KASM_SERVER_IP "
  echo '=== KASM Admin Credentials ==='
  grep -A1 'admin@kasm.local' /opt/kasm/current/install_log.txt 2>/dev/null || \
  grep -A1 'admin@kasm.local' /tmp/kasm-install/kasm_release/install_log.txt 2>/dev/null
  echo ''
  grep -A1 'user@kasm.local' /opt/kasm/current/install_log.txt 2>/dev/null || \
  grep -A1 'user@kasm.local' /tmp/kasm-install/kasm_release/install_log.txt 2>/dev/null || echo 'No user@kasm.local found'
  echo '=== End Credentials ==='
"
```

Credentials appear on the line following the username. If not found in `/opt/kasm/current/`, check `/tmp/kasm-install/kasm_release/`.

## Access KASM

Open in browser: `https://$KASM_SERVER_IP` (default port 443, or `:$KASM_PORT` if custom).  
Accept the self‑signed certificate warning and login with admin credentials.

For secure public HTTPS access, use Cloudflare Tunnel: `references/cloudflare-tunnel.md`.

## Firewall Rules

```bash
sudo ufw --force enable
sudo ufw allow 22/tcp
sudo ufw allow 8443/tcp
sudo ufw allow 3389/tcp
sudo ufw allow 3000:4000/tcp
```

## Required Environment Variables

```bash
KASM_SERVER_IP=your_server_ip
SSH_USER=ubuntu
SSH_KEY_PATH=~/.ssh/id_rsa
KASM_PORT=443   # Default KASM install uses 443, not 8443
RDP_PORT=3389
```

