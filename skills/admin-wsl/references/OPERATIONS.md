# WSL Operations Reference

Extended operations for WSL administration: troubleshooting, Git setup, known issues prevention, setup checklist, and version snapshots.

## Contents
- Troubleshooting
- Git Configuration
- Known Issues Prevention
- Complete Setup Checklist
- Official Documentation
- Package Versions (Snapshot)

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
- [ ] `$ADMIN_ROOT` directory structure created
- [ ] Environment variables configured in `.env`
- [ ] Central logs accessible via `$ADMIN_ROOT` mount

---

## Official Documentation

- **Ubuntu**: https://ubuntu.com/wsl
- **Docker WSL2**: https://docs.docker.com/desktop/wsl/
- **uv**: https://docs.astral.sh/uv/

---

## Package Versions (Snapshot, Verified 2025-12-08)

```json
{
  "wsl": "2.4.x",
  "ubuntu": "24.04.2 LTS",
  "node": "18.19.x",
  "uv": "0.9.x",
  "docker": "Docker Desktop WSL2"
}
```

