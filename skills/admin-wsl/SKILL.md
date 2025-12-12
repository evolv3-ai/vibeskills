---
name: admin-wsl
description: |
  Administer WSL2 Ubuntu 24.04 environments from Linux. Covers apt package management, Docker containers, Python/uv environments, shell configuration, and systemd services. Coordinates with admin-windows via shared `.admin` root and handoff protocol.

  Use when: managing WSL Linux packages, Docker containers, Python venv/uv, shell configs (.zshrc/.bashrc), systemd services, or troubleshooting "command not found", "permission denied", "Docker socket missing" errors in WSL.
license: MIT
---

# WSL Admin

**Status**: Production Ready
**Last Updated**: 2025-12-11
**Dependencies**: WSL2, Ubuntu 24.04, shared `.admin` root (Windows + WSL)
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
- Hand off Windows tasks to admin-windows (handoff via shared logs)

---

## Mandatory Initialization (EVERY SESSION)

```bash
# 1. Verify identity (values from environment)
hostname          # Should return: $DEVICE_NAME
whoami            # Should return: $ADMIN_USER
echo $SHELL       # Should return: /usr/bin/zsh (or /bin/bash)

# 2. Load environment
WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
WSL_ADMIN_PATH="${WSL_ADMIN_PATH:-/mnt/c/Users/$WIN_USER/.admin}"
source "$WSL_ADMIN_PATH/.env"

# 3. Check WSL profile
cat "$WSL_ADMIN_PATH/wsl-profile.json"

# 4. Check recent logs
tail -20 "${ADMIN_LOG_PATH:-$WSL_ADMIN_PATH/logs}/operations.log"

# 5. Cross-reference Windows changes (if mounted)
[[ -d "$WSL_ADMIN_PATH" ]] && tail -10 "$WSL_ADMIN_PATH/logs/devices/$DEVICE_NAME/history.log"

# 6. Verify tools
node --version    # Expected: 18.x or 20.x
uv --version      # Expected: 0.9.x+
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
$WSL_ADMIN_PATH/                        # Shared Windows+WSL admin root (default: /mnt/c/Users/$WIN_USER/.admin)
├── .env                                # Environment config
├── wsl-profile.json                    # Source of truth for WSL state
├── logs/
│   ├── operations.log                  # General operations
│   ├── installations.log               # Package installs
│   ├── system-changes.log              # Config changes
│   └── devices/$DEVICE_NAME/history.log# Device-specific history
├── profiles/
│   └── $DEVICE_NAME.json               # Device profile (shared)
└── config/
    └── ...                             # Additional config files
```

**Environment Variables Required:**
- `$WSL_ADMIN_PATH` - Shared admin directory (default: `/mnt/c/Users/$WIN_USER/.admin`)
- `$ADMIN_ROOT` - Shared admin root (default: `$WSL_ADMIN_PATH`)
- `$ADMIN_LOG_PATH` - Log directory (default: `$WSL_ADMIN_PATH/logs`)
- `$DEVICE_NAME` - Current device name
- `$ADMIN_USER` - Current admin username

---

## WSL Profile Schema

**Location**: `$WSL_ADMIN_PATH/wsl-profile.json`

```json
{
  "wslInfo": {
    "distro": "Ubuntu-24.04",
    "version": "24.04.2 LTS",
    "user": "$ADMIN_USER",
    "shell": "zsh",
    "systemd": true,
    "lastUpdated": "YYYY-MM-DDTHH:MM:SSZ"
  },
  "installedTools": {
    "node": {
      "present": true,
      "version": "v18.x.x",
      "path": "/usr/bin/node",
      "installedVia": "apt"
    },
    "uv": {
      "present": true,
      "version": "0.9.x",
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

## Logging Integration

Use the centralized logging system from the `admin` skill. See `admin/references/logging.md` for full documentation.

### Log Locations

| Log | Location | Purpose |
|-----|----------|---------|
| Operations | `$ADMIN_LOG_PATH/operations.log` | General operations |
| Installations | `$ADMIN_LOG_PATH/installations.log` | Package installs |
| System Changes | `$ADMIN_LOG_PATH/system-changes.log` | Config changes |
| Device History | `$ADMIN_LOG_PATH/devices/$DEVICE_NAME/history.log` | Device-specific history |

### Quick Reference

```bash
# Use log_admin from centralized logging
log_admin "SUCCESS" "installation" "Installed postgresql" "version=16 method=apt"
log_admin "ERROR" "operation" "Docker failed to start" "error=socket not found"
log_admin "SUCCESS" "system-change" "Updated .zshrc" "added=PATH entry"
log_admin "HANDOFF" "handoff" "Windows task required" "task=update .wslconfig"
```

### Log Levels

| Level | Use Case |
|-------|----------|
| SUCCESS | Completed operations |
| ERROR | Failed operations |
| WARNING | Non-critical issues |
| INFO | General information |
| HANDOFF | Cross-platform coordination |

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
| `C:\Users\<username>` | `/mnt/c/Users/<username>` |
| `D:\<path>` | `/mnt/d/<path>` |
| `$WIN_ADMIN_ROOT` | `$ADMIN_ROOT` (mounted) |

**Note:** The exact mount paths depend on your Windows drive letters and configuration.

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
# Log the handoff using centralized logging
log_admin "HANDOFF" "handoff" "Windows task required" "task=.wslconfig memory increase to 32GB"
```

---

## Troubleshooting

### WSL Running Slow

```bash
# Check resources
free -h
df -h
top

# If resource constrained, request via handoff:
log_admin "HANDOFF" "handoff" "WSL slow - consider .wslconfig memory increase"
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

Git should be configured with your credentials. Verify with:

```bash
git config --list              # View config
git config user.name           # Check username
git config user.email          # Check email
```

**Note:** If using WSL with Windows Git Credential Manager, the credential helper should be configured automatically.

---

## Known Issues Prevention

| Issue | Cause | Prevention |
|-------|-------|------------|
| `Get-Content not found` | Using PowerShell syntax | Use `cat` |
| Line ending corruption | CRLF/LF mismatch | Use `dos2unix` |
| Docker socket missing | Docker Desktop not running | Start from Windows |
| WSL slow/OOM | Resource limits | Request via admin-windows |
| Permission denied | Wrong ownership | Use `chown`/`chmod` |

---

## Complete Setup Checklist

- [ ] WSL2 with Ubuntu 24.04 installed
- [ ] Shell configured (zsh or bash)
- [ ] uv installed at `~/.local/bin/uv`
- [ ] Docker Desktop integration working
- [ ] Git configured with credentials
- [ ] `$WSL_ADMIN_PATH` directory structure created
- [ ] Environment variables configured in `.env`
- [ ] Central logs accessible via `$ADMIN_ROOT` mount

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
