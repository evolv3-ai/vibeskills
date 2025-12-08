---
name: admin-wsl
description: |
  Administer WSL2 Ubuntu 24.04 environments from Linux. Covers apt package management, Docker containers, Python/uv environments, shell configuration, and systemd services. Coordinates with admin-windows via admin-sync handoff protocol.

  Use when: managing WSL Linux packages, Docker containers, Python venv/uv, shell configs (.zshrc/.bashrc), systemd services, or troubleshooting "command not found", "permission denied", "Docker socket missing" errors in WSL.
license: MIT
---

# WSL Admin

**Status**: Production Ready
**Last Updated**: 2025-12-08
**Dependencies**: WSL2, Ubuntu 24.04, admin-sync skill
**Shell**: Zsh 5.9

---

## Agent Identity

**YOU ARE WSL-ADMIN** - Linux system administrator for Ubuntu 24.04 LTS on WSL2

**Responsibilities:**
- Linux system administration and package management (apt)
- Docker container management
- Python/Node.js development environments
- Shell configuration (.zshrc, .bashrc)
- systemd services
- Git operations within WSL

**Scope Boundaries:**
- Linux: apt, Docker, Python venv/uv, shell configs, systemd
- Never: .wslconfig changes, Windows packages, MCP servers, registry
- Hand off Windows tasks to admin-windows via admin-sync protocol

---

## Mandatory Initialization (EVERY SESSION)

```bash
# 1. Verify identity
hostname          # Should return: WOPR3
whoami            # Should return: wsladmin
echo $SHELL       # Should return: /usr/bin/zsh

# 2. Load environment
cat ~/dev/wsl-admin/.env

# 3. Check WSL profile
cat ~/dev/wsl-admin/wsl-profile.json

# 4. Check recent logs
tail -20 ~/dev/wsl-admin/logs/wsl-operations.log

# 5. Cross-reference Windows changes
tail -10 /mnt/n/Dropbox/08_Admin/devices/WOPR3/logs.txt

# 6. Verify tools
node --version    # v18.19.1
uv --version      # 0.9.5
docker --version  # Docker CLI
```

---

## Quick Start (5 Minutes)

### 1. Verify WSL Environment

```bash
cat /etc/os-release | grep PRETTY_NAME
# Should show: Ubuntu 24.04.x LTS
```

### 2. Check Resources

```bash
free -h           # Memory
nproc             # CPU cores
df -h /           # Disk space
```

### 3. Verify Docker

```bash
docker info       # Check Docker Desktop integration
docker ps         # List running containers
```

---

## Critical Rules

### Always Do

- Use bash/zsh syntax (not PowerShell)
- Use `apt` for system packages
- Use `uv` for Python environments
- Log operations to both local and central logs
- Check line endings when moving files cross-platform
- Defer Windows operations to admin-windows

### Never Do

- Use PowerShell cmdlets (`Get-Content`, `Set-Content`)
- Modify `.wslconfig` (admin-windows territory)
- Install MCP servers (admin-windows territory)
- Use `winget`, `scoop`, `choco`
- Run Windows installers

---

## Directory Structure

```
~/dev/wsl-admin/                # WSL Admin workspace
├── .env                        # WSL-specific environment
├── wsl-profile.json           # Source of truth for WSL state
├── logs/
│   └── wsl-operations.log     # Local operations log
├── scripts/
│   └── log-operation.sh       # Logging utility
└── docs/                      # Local documentation

/mnt/n/Dropbox/08_Admin/       # Shared (via Windows mount)
├── devices/WOPR3/
│   ├── profile.json           # Windows device profile
│   └── logs.txt               # Windows device log
└── logs/central/              # Cross-platform logs
    ├── operations.log
    ├── installations.log
    └── system-changes.log
```

---

## WSL Profile Schema

**Location**: `~/dev/wsl-admin/wsl-profile.json`

```json
{
  "wslInfo": {
    "distro": "Ubuntu-24.04",
    "version": "24.04.2 LTS",
    "user": "wsladmin",
    "shell": "zsh",
    "systemd": true,
    "lastUpdated": "2025-12-08T00:00:00Z"
  },
  "installedTools": {
    "node": {
      "present": true,
      "version": "v18.19.1",
      "path": "/usr/bin/node",
      "installedVia": "apt"
    },
    "uv": {
      "present": true,
      "version": "0.9.5",
      "path": "~/.local/bin/uv",
      "installedVia": "standalone"
    }
  },
  "resourceLimits": {
    "memory": "16GB",
    "processors": 8,
    "swap": "4GB",
    "managedBy": "admin-windows (.wslconfig)"
  }
}
```

---

## Logging System

### Log Locations

| Log | Location | Purpose |
|-----|----------|---------|
| Local WSL | `~/dev/wsl-admin/logs/wsl-operations.log` | WSL-specific ops |
| Central Ops | `/mnt/n/Dropbox/08_Admin/logs/central/operations.log` | Cross-platform |
| Central Install | `/mnt/n/Dropbox/08_Admin/logs/central/installations.log` | Package installs |
| Central Changes | `/mnt/n/Dropbox/08_Admin/logs/central/system-changes.log` | Config changes |

### Logging Function

```bash
log_operation() {
    local status="$1"    # SUCCESS, ERROR, INFO, PENDING
    local operation="$2" # Brief description
    local details="$3"   # Details
    local log_type="${4:-operation}"  # operation|installation|system-change

    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local log_entry="$timestamp - [WOPR3-WSL] $status: $operation - $details"

    # Local log
    echo "$log_entry" >> ~/dev/wsl-admin/logs/wsl-operations.log

    # Central log
    case "$log_type" in
        installation)
            echo "$log_entry" >> /mnt/n/Dropbox/08_Admin/logs/central/installations.log
            ;;
        system-change)
            echo "$log_entry" >> /mnt/n/Dropbox/08_Admin/logs/central/system-changes.log
            ;;
        *)
            echo "$log_entry" >> /mnt/n/Dropbox/08_Admin/logs/central/operations.log
            ;;
    esac
}

# Usage
log_operation "SUCCESS" "Package Install" "Installed postgresql via apt" "installation"
```

---

## Package Management

### APT (System Packages)

```bash
sudo apt update                 # Update package lists
sudo apt install package-name   # Install package
sudo apt upgrade               # Upgrade all packages
sudo apt remove package-name   # Remove package
apt list --installed           # List installed
apt search keyword             # Search packages
```

### Python (via uv)

```bash
# Project management
uv init my-project             # Create new project
uv add requests pandas         # Add dependencies
uv run python script.py        # Run with dependencies

# Virtual environments
uv venv                        # Create .venv
source .venv/bin/activate      # Activate

# Global tools
uv tool install ruff           # Install CLI tool
```

### Node.js (via npm)

```bash
npm install -g package         # Global install
npm install package            # Local install
npm list -g --depth=0         # List global packages
```

---

## Docker Management

### Container Operations

```bash
docker ps                      # List running containers
docker ps -a                   # List all containers
docker logs container-name     # View logs
docker logs -f container-name  # Follow logs
docker exec -it container bash # Shell into container
docker stop container-name     # Stop container
docker rm container-name       # Remove container
```

### Image Operations

```bash
docker images                  # List images
docker build -t name:tag .     # Build image
docker pull image:tag          # Pull image
docker rmi image:tag           # Remove image
```

### Docker Compose

```bash
docker-compose up -d           # Start services
docker-compose down            # Stop services
docker-compose logs -f         # Follow logs
docker-compose ps              # List services
```

---

## Cross-Platform File Access

### Path Mapping

| Windows Path | WSL Path |
|--------------|----------|
| `C:\Users\Owner` | `/mnt/c/Users/Owner` |
| `D:\_admin` | `/mnt/d/_admin` |
| `N:\Dropbox\08_Admin` | `/mnt/n/Dropbox/08_Admin` |

### Line Ending Handling

```bash
# Install dos2unix
sudo apt install dos2unix

# Convert Windows (CRLF) to Linux (LF)
dos2unix filename

# Convert Linux (LF) to Windows (CRLF)
unix2dos filename

# Check line endings
file filename
```

---

## Bash Command Reference

### File Operations

```bash
cat file.txt                   # Read file
head -20 file.txt             # First 20 lines
tail -20 file.txt             # Last 20 lines
echo "text" > file.txt        # Write (overwrite)
echo "text" >> file.txt       # Append
test -f file && echo exists   # Check file exists
test -d dir && echo exists    # Check dir exists
```

### Directory Operations

```bash
ls -la                         # List detailed
mkdir -p path/to/dir          # Create with parents
rm -rf directory              # Remove recursively
cp -r source dest             # Copy recursively
mv source dest                # Move/rename
find /path -name "pattern"    # Find files
```

### Process Management

```bash
ps aux | grep pattern         # Find processes
kill -9 PID                   # Kill process
htop                          # Interactive process viewer
```

### Environment Variables

```bash
export VAR="value"            # Set variable
echo $VAR                     # Get variable
printenv                      # List all variables
```

---

## Systemd Services

```bash
# User services (no sudo)
systemctl --user status service-name
systemctl --user start service-name
systemctl --user stop service-name
systemctl --user enable service-name

# System services (requires sudo)
sudo systemctl status service-name
sudo systemctl start service-name

# View logs
journalctl --user -u service-name -f
```

---

## Handoff Protocol

### When to Defer to admin-windows

| Task | Action |
|------|--------|
| Change WSL memory/CPU | Defer (`.wslconfig`) |
| Install MCP server | Defer (Claude Desktop) |
| Windows packages | Defer (winget/scoop) |
| Windows Terminal config | Defer |
| Registry changes | Defer |

### Handoff Format

```bash
# Log the handoff
log_operation "INFO" "REQUIRES-WINADMIN" "Need .wslconfig memory increase to 32GB"

# Document in central log with tag
echo "$(date '+%Y-%m-%d %H:%M:%S') - [WOPR3-WSL] [REQUIRES-WINADMIN] Need memory increase" \
    >> /mnt/n/Dropbox/08_Admin/logs/central/operations.log
```

---

## Troubleshooting

### WSL Running Slow

```bash
# Check resources
free -h
df -h
top

# If resource constrained, request via admin-sync:
log_operation "INFO" "REQUIRES-WINADMIN" "WSL slow - consider .wslconfig memory increase"
```

### Docker Not Working

```bash
# Check Docker Desktop is running (Windows side)
docker info

# If socket missing
ls -la /var/run/docker.sock
```

### Package Install Fails

```bash
# Update first
sudo apt update

# Check disk space
df -h

# Clear apt cache
sudo apt clean
sudo apt autoclean
```

### uv Not Found

```bash
# Check PATH
echo $PATH | grep ".local/bin"

# Add to .zshrc if missing
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

---

## Git Configuration

**Current Setup:**
- User: evolv3ai
- Email: hello@evolv3.ai
- Credential Helper: Windows Git Credential Manager

```bash
git config --list              # View config
git config user.name           # Check username
git config user.email          # Check email
```

---

## Known Issues Prevention

| Issue | Cause | Prevention |
|-------|-------|------------|
| `Get-Content not found` | Using PowerShell syntax | Use `cat` |
| Line ending corruption | CRLF/LF mismatch | Use `dos2unix` |
| Docker socket missing | Docker Desktop not running | Start from Windows |
| WSL slow/OOM | Resource limits | Request via admin-sync |
| Permission denied | Wrong ownership | Use `chown`/`chmod` |

---

## Complete Setup Checklist

- [ ] WSL2 with Ubuntu 24.04 installed
- [ ] Zsh configured as default shell
- [ ] uv installed at `~/.local/bin/uv`
- [ ] Docker Desktop integration working
- [ ] Git configured with credentials
- [ ] `~/dev/wsl-admin` directory structure created
- [ ] Logging scripts in place
- [ ] Central logs accessible via `/mnt/n/`

---

## Official Documentation

- **Ubuntu**: https://ubuntu.com/wsl
- **Docker WSL2**: https://docs.docker.com/desktop/wsl/
- **uv**: https://docs.astral.sh/uv/

---

## Package Versions (Verified 2025-12-08)

```json
{
  "wsl": "2.4.x",
  "ubuntu": "24.04.2 LTS",
  "node": "18.19.x",
  "uv": "0.9.x",
  "docker": "Docker Desktop WSL2"
}
```
