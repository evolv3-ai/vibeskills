---
name: admin-app-kasm
description: |
  Installs and manages KASM Workspaces, a container-based VDI platform for streaming desktops to browsers.
  Supports Ubuntu ARM64, desktop streaming, isolated browser sessions, and remote workspace access.

  Use when: installing KASM on Ubuntu ARM64, setting up VDI, configuring browser-based desktops, deploying on OCI instances.

  Keywords: kasm workspaces, VDI, virtual desktop, browser streaming, ARM64, kasm port 8443, container desktop
license: MIT
---

# KASM Workspaces - Container VDI

**Purpose**: Install KASM Workspaces on a single Ubuntu server and configure secure browser‑based desktops. Detailed install steps and the post‑install wizard live in references.

## Navigation

Longer material is split into references (one level deep):
- Manual installation: `references/INSTALLATION.md`
- Cloudflare Tunnel secure access: `references/cloudflare-tunnel.md`
- Post‑installation wizard quick start: `references/QUICKSTART.md`
- Wizard user guide: `references/README-WIZARD.md`
- Wizard implementation spec (draft): `references/post-installation-interview-spec.md`

## Quick Start

1. **Provision a server** (Ubuntu ARM64 recommended, 8GB+ RAM). Use `admin-servers` and a provider skill.
2. **Install KASM** following `references/INSTALLATION.md`.
3. **Extract credentials** from `install_log.txt` and log in at `https://<SERVER_IP>` (default port 443).
4. **Run the post‑installation wizard** to enable backups, persistent profiles, storage, and other modules:
   - Quick path: `references/QUICKSTART.md`.
5. **Secure public access** via Cloudflare Tunnel in `references/cloudflare-tunnel.md` (uses `noTLSVerify: true`).

## Critical Rules

- Ensure Docker CE + Compose plugin installed before KASM.
- Allocate sufficient RAM per concurrent session (2–4GB).
- Do not expose installer port 8443 publicly without HTTPS/tunnel.

## Logging Integration

```bash
log_admin "SUCCESS" "installation" "Installed KASM Workspaces" "version=1.x server=$SERVER_ID"
log_admin "SUCCESS" "operation" "Ran KASM post-install wizard" "modules=$MODULES"
```

## Related Skills

- `admin-servers` for inventory and provisioning.
- `admin-infra-*` for OCI/Hetzner/etc server setup.

## References

- KASM docs: https://kasmweb.com/docs/latest/
- KASM GitHub: https://github.com/kasmtech
