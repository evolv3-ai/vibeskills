# Device Profiles

Device profiles are per‑device JSON files stored under `ADMIN_ROOT` that track installed tools, package managers, and servers managed by this machine. Profiles are shared between Windows and WSL when applicable.

## Contents
- Profile Location
- Profile Schema
- Bash Profile Operations
- Logging Tool Installations
- Notes

---

## Profile Location

Profiles live at:

```
$ADMIN_PROFILE_PATH/$DEVICE_NAME.json
```

Defaults:
- Windows: `C:/Users/<USERNAME>/.admin/profiles/<COMPUTERNAME>.json`
- WSL: `/mnt/c/Users/<USERNAME>/.admin/profiles/<HOSTNAME>.json`
- Linux/macOS: `~/.admin/profiles/<HOSTNAME>.json`

## Profile Schema

See `assets/profile-schema.json` for the full JSON Schema.

Key sections:
- `deviceInfo`: name, platform, hostname, user, shell, adminRoot, lastUpdated
- `packageManagers`: presence + versions for apt/brew/winget/scoop/npm
- `installedTools`: tool → {version, installedVia, path, lastChecked}
- `installationHistory`: append‑only history entries
- `managedServers`: server IDs from admin‑servers inventory
- `cloudProviders`, `syncSettings`, `customMetadata`: optional extensions

## Bash Profile Operations

Use `update_profile()` to create (if missing) and return the profile path.

```bash
update_profile() {
    # Determine profile directory (WSL uses Windows path for shared profiles)
    local profile_dir
    local admin_root
    if [[ -n "$ADMIN_PROFILE_PATH" ]]; then
        profile_dir="$ADMIN_PROFILE_PATH"
        admin_root="${ADMIN_ROOT:-$(dirname "$ADMIN_PROFILE_PATH")}"
    elif grep -qi microsoft /proc/version 2>/dev/null; then
        local win_user=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
        profile_dir="/mnt/c/Users/$win_user/.admin/profiles"
        admin_root="/mnt/c/Users/$win_user/.admin"
    else
        profile_dir="$HOME/.admin/profiles"
        admin_root="$HOME/.admin"
    fi

    local profile_path="$profile_dir/${DEVICE_NAME:-$(hostname)}.json"
    mkdir -p "$(dirname "$profile_path")"

    # Create if doesn't exist
    if [[ ! -f "$profile_path" ]]; then
        cat > "$profile_path" << EOF
{
  "schemaVersion": "2.0",
  "deviceInfo": {
    "name": "${DEVICE_NAME:-$(hostname)}",
    "platform": "$(detect_platform)",
    "hostname": "$(hostname)",
    "user": "${ADMIN_USER:-$(whoami)}",
    "shell": "${ADMIN_SHELL:-bash}",
    "os": "",
    "osVersion": "",
    "adminRoot": "$admin_root",
    "timezone": "",
    "lastUpdated": "$(date -Iseconds)"
  },
  "packageManagers": {
    "apt": { "present": false, "version": null, "lastChecked": null },
    "brew": { "present": false, "version": null, "lastChecked": null },
    "winget": { "present": false, "version": null, "lastChecked": null, "location": null },
    "scoop": { "present": false, "version": null, "lastChecked": null, "location": null },
    "npm": { "present": false, "version": null, "lastChecked": null, "location": null }
  },
  "installedTools": {},
  "installationHistory": [],
  "systemInfo": {
    "shell": "",
    "shellVersion": "",
    "architecture": "",
    "cpu": "",
    "ram": "",
    "lastSystemCheck": null
  },
  "paths": {
    "npmGlobal": "",
    "projectsRoot": ""
  },
  "managedServers": [],
  "cloudProviders": {},
  "syncSettings": {
    "enabled": false,
    "syncPath": null,
    "lastSync": null,
    "linkedDevices": []
  },
  "customMetadata": {}
}
EOF
    fi

    echo "$profile_path"
}
```

## Logging Tool Installations

Use `log_tool_install()` after installing a tool to update `installedTools` and central logs. Requires `jq` on WSL/Linux/macOS.

```bash
log_tool_install() {
    local tool="$1"
    local version="$2"
    local method="$3"  # apt, brew, winget, npm, etc.

    local profile_path=$(update_profile)

    # Update installedTools section (requires jq)
    if command -v jq &>/dev/null; then
        jq --arg tool "$tool" \
           --arg ver "$version" \
           --arg method "$method" \
           --arg ts "$(date -Iseconds)" \
           '.installedTools[$tool] = {version: $ver, installedVia: $method, lastChecked: $ts}' \
           "$profile_path" > "${profile_path}.tmp" && mv "${profile_path}.tmp" "$profile_path"
    fi

    log_admin "SUCCESS" "installation" "Installed $tool" "version=$version method=$method"
}
```

Example:

```bash
log_tool_install "docker" "24.0.7" "apt"
```

## Notes

- Profiles are shared between Windows and WSL when `ADMIN_ROOT` points to the Windows filesystem.
- For initial profile creation in PowerShell, see `references/first-run-setup.md`.
- Use `managedServers` to link to inventory entries from admin‑servers.

