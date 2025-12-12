# Unix Operations Reference

Extended operations for macOS and Linux administration (outside of WSL). This file is expanded in later phases; keep `SKILL.md` as the overview.

## Contents

- Platform Detection
- Logging (Centralized)
- Linux (apt): Standard Workflow
- Linux (apt): Common Errors + Fixes
- Linux (systemd): Common Operations
- macOS (Homebrew): Standard Workflow
- macOS (Homebrew): PATH Notes (Apple Silicon)
- macOS (Homebrew): Services
- macOS (Homebrew): Common Errors + Fixes
- Troubleshooting Checklist

---

## Platform Detection

```bash
uname -s
# Darwin → macOS
# Linux  → Linux (native). If in WSL, use admin-wsl.
```

WSL detection:

```bash
grep -qi microsoft /proc/version 2>/dev/null && echo "wsl"
```

If this returns `wsl`, use `admin-wsl` instead of `admin-unix`.

---

## Logging (Centralized)

Prefer the `admin` logging functions:

- `admin/references/logging.md`

Quick examples:

```bash
log_admin "SUCCESS" "installation" "Installed package" "pkg=<PKG>"
log_admin "SUCCESS" "operation" "Updated system" "method=apt"
log_admin "ERROR" "operation" "Command failed" "cmd=<CMD> exit=<CODE>"
```

---

## Linux (apt): Standard Workflow

Use these steps for Debian/Ubuntu systems.

### 0. Identify distro and version (for correct packages)

```bash
cat /etc/os-release
uname -a
```

### 1. Update package lists and upgrade

```bash
sudo apt update
sudo apt upgrade -y
```

If you changed sources recently:

```bash
sudo apt update --allow-releaseinfo-change
```

Log:

```bash
log_admin "SUCCESS" "operation" "Updated system packages" "method=apt"
```

### 2. Install packages

```bash
sudo apt install -y <PKG>
```

Verify install:

```bash
dpkg -l | rg -n "^ii\\s+<PKG>\\b" || true
apt-cache policy <PKG>
command -v <CMD> || true
<CMD> --version || true
```

Log:

```bash
log_admin "SUCCESS" "installation" "Installed package" "pkg=<PKG> method=apt"
```

### 3. Remove packages

```bash
sudo apt remove -y <PKG>
sudo apt autoremove -y
```

For config purge:

```bash
sudo apt purge -y <PKG>
```

Log:

```bash
log_admin "SUCCESS" "installation" "Removed package" "pkg=<PKG> method=apt"
```

### 4. Search packages

```bash
apt-cache search <TERM>
apt-cache show <PKG> | sed -n '1,120p'
```

### 5. Hold/unhold packages (pin versions)

```bash
sudo apt-mark hold <PKG>
apt-mark showhold
sudo apt-mark unhold <PKG>
```

### 6. Cleanup

```bash
sudo apt autoremove -y
sudo apt clean
```

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install -y <PKG>
sudo apt remove -y <PKG>
apt-cache policy <PKG>
```

---

## Linux (apt): Common Errors + Fixes

### Error: Could not get lock (another apt/dpkg process)

Symptoms:
- `Could not get lock /var/lib/dpkg/lock-frontend`
- `Unable to acquire the dpkg frontend lock`

Steps:

```bash
ps aux | rg -n \"apt|dpkg\" || true
sudo lsof /var/lib/dpkg/lock-frontend 2>/dev/null || true
sudo lsof /var/lib/dpkg/lock 2>/dev/null || true
```

If you confirm it’s a stuck process (not actively running upgrades), stop it carefully and retry:

```bash
sudo apt update
```

Log failures:

```bash
log_admin "ERROR" "operation" "apt lock prevented update" "path=/var/lib/dpkg/lock-frontend"
```

### Error: dpkg was interrupted

Symptoms:
- `dpkg was interrupted, you must manually run 'sudo dpkg --configure -a'`

Fix:

```bash
sudo dpkg --configure -a
sudo apt -f install
sudo apt update
sudo apt upgrade -y
```

### Error: Unmet dependencies / held broken packages

```bash
sudo apt --fix-broken install
sudo apt -f install
apt-mark showhold
```

If a package is held:

```bash
sudo apt-mark unhold <PKG>
sudo apt install -y <PKG>
```

### Error: Temporary failure resolving (DNS)

```bash
cat /etc/resolv.conf
ping -c 1 1.1.1.1 || true
ping -c 1 deb.debian.org || true
```

Log:

```bash
log_admin "ERROR" "operation" "DNS resolution failed" "host=deb.debian.org"
```

### Error: Release file changed / repository metadata changed

```bash
sudo apt update --allow-releaseinfo-change
```

### Error: Hash Sum mismatch

```bash
sudo rm -rf /var/lib/apt/lists/*
sudo apt clean
sudo apt update
```

---

## Linux (systemd): Common Operations

```bash
# Status and logs
sudo systemctl status <SERVICE>
sudo journalctl -u <SERVICE> --no-pager -n 200
sudo journalctl -u <SERVICE> -f

# Start/stop/restart
sudo systemctl start <SERVICE>
sudo systemctl stop <SERVICE>
sudo systemctl restart <SERVICE>

# Enable/disable at boot
sudo systemctl enable <SERVICE>
sudo systemctl disable <SERVICE>

# After editing unit files
sudo systemctl daemon-reload
sudo systemctl restart <SERVICE>

# Discover services
systemctl list-units --type=service --state=running
```

---

## macOS (Homebrew): Standard Workflow

```bash
# Verify platform
uname -s
# Darwin → macOS

# Verify brew
brew --version
command -v brew
brew config
```

### Install Homebrew (if missing)

Use the official installer. This requires network access.

```bash
/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"
```

Log:

```bash
log_admin "SUCCESS" "installation" "Installed Homebrew" "method=brew-install"
```

### Update and upgrade

```bash
brew update
brew upgrade
brew cleanup
```

Log:

```bash
log_admin "SUCCESS" "operation" "Updated brew packages" "method=brew"
```

### Install and uninstall formulae

```bash
brew install <FORMULA>
brew uninstall <FORMULA>
brew list --formula
brew info <FORMULA>
```

Verify installed formula and binary:

```bash
brew --prefix <FORMULA>
command -v <CMD> || true
<CMD> --version || true
```

Log:

```bash
log_admin "SUCCESS" "installation" "Installed formula" "formula=<FORMULA> method=brew"
```

### Pin / unpin (freeze versions)

```bash
brew pin <FORMULA>
brew unpin <FORMULA>
brew list --pinned
```

---

## macOS (Homebrew): PATH Notes (Apple Silicon)

If `brew` is installed but not found, you almost always have a PATH issue.

Common locations:

- Apple Silicon: `/opt/homebrew/bin/brew`
- Intel: `/usr/local/bin/brew`

Check:

```bash
ls -la /opt/homebrew/bin/brew /usr/local/bin/brew 2>/dev/null || true
```

Recommended shell setup:

```bash
# Apple Silicon default
echo 'eval \"$(/opt/homebrew/bin/brew shellenv)\"' >> ~/.zprofile
eval \"$(/opt/homebrew/bin/brew shellenv)\"
```

If your shell is bash:

```bash
echo 'eval \"$(/opt/homebrew/bin/brew shellenv)\"' >> ~/.bash_profile
eval \"$(/opt/homebrew/bin/brew shellenv)\"
```

Re-check:

```bash
brew --version
```

---

## macOS (Homebrew): Services

Some formulae provide background services via `brew services`:

```bash
brew services list
brew services start <FORMULA>
brew services restart <FORMULA>
brew services stop <FORMULA>
```

Log:

```bash
log_admin "SUCCESS" "system-change" "Updated brew service" "service=<FORMULA> action=start"
```

---

## macOS (Homebrew): Common Errors + Fixes

### Error: `brew` not found

Use the PATH guidance above and re-check:

```bash
command -v brew || true
```

### Error: `brew doctor` reports issues

Run:

```bash
brew doctor
```

Then apply the minimal changes it recommends (avoid random permission changes).

### Error: Xcode Command Line Tools missing

Symptoms:
- compilers missing, `git` missing, build errors

Fix:

```bash
xcode-select --install
```

### Error: Update/upgrade fails intermittently

```bash
brew update
brew doctor
brew config
```

Log failures:

```bash
log_admin "ERROR" "operation" "brew update failed" "check=brew-doctor"
```

---

## Troubleshooting Checklist

- Confirm platform (`uname -s`) and avoid WSL-only paths unless you are in WSL.
- If you detect WSL (`grep -qi microsoft /proc/version`), use `admin-wsl`.
- Confirm tool path:
  - `command -v <CMD>`
  - `which <CMD>`
- For permissions issues:
  - `ls -la <PATH>`
  - `stat <PATH>`
- For services:
  - Linux: `systemctl status`, `journalctl -u`
  - macOS: `brew services list`
