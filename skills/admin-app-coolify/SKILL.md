---
name: admin-app-coolify
description: |
  Installs and manages Coolify, an open-source self-hosted PaaS for deploying applications with Docker.
  Provides a Heroku-like experience on your own infrastructure.

  Use when: installing Coolify, deploying Docker apps, setting up a self-hosted PaaS, or configuring the Traefik proxy.

  Keywords: coolify, self-hosted paas, docker deployment, traefik proxy, open source heroku
license: MIT
---

# Coolify - Self-Hosted PaaS

**Purpose**: Install and operate Coolify on a single server, then deploy apps via Nixpacks, Dockerfile, or Docker Compose. This skill focuses on install + secure access; advanced automation and troubleshooting live in references.

## Navigation

Longer material is split into references (one level deep):
- Manual SSH installation: `references/INSTALLATION.md`
- Fully automated enhanced setup: `references/ENHANCED_SETUP.md`
- Bundled scripts and usage: `references/BUNDLED_SCRIPTS.md`
- Cloudflare Tunnel secure access (wildcard mode): `references/cloudflare-tunnel.md`
- Cloudflare origin certificates (for OAuth/webhooks): `references/cloudflare-origin-certificates.md`
- Cloudflare Error 1033 troubleshooting: `references/TROUBLESHOOTING_CF1033.md`

## Quick Start

1. **Provision a server** (recommended 4GB+ RAM, Ubuntu LTS). Use `admin-servers` and a provider skill.
2. **Install Coolify**:
   - Preferred: run enhanced automation in `references/ENHANCED_SETUP.md`.
   - Alternative: follow manual steps in `references/INSTALLATION.md`.
3. **Verify UI** at `http://<SERVER_IP>:8000` and confirm **localhost** is “Connected”.
4. **Secure HTTPS access**:
   - Default: Cloudflare Tunnel in `references/cloudflare-tunnel.md`.
   - If apps need OAuth/webhooks: add origin certs in `references/cloudflare-origin-certificates.md`.
5. **Deploy first app** from the Coolify UI:
   - Nixpacks for standard frameworks.
   - Dockerfile for custom builds.
   - Docker Compose for multi‑service stacks.

## Critical Rules

- Always install Docker CE with the Compose plugin before Coolify.
- Do not expose port 8000 publicly without HTTPS (tunnel or reverse proxy).
- Keep `/data/coolify` intact; treat it as state.

## Logging Integration

Log major operations using centralized logging from `admin`:

```bash
log_admin "SUCCESS" "installation" "Installed Coolify" "version=4.x server=$SERVER_ID"
log_admin "SUCCESS" "system-change" "Configured Coolify" "domain=$DOMAIN"
log_admin "SUCCESS" "operation" "Deployed app via Coolify" "app=$APP_NAME"
```

## Related Skills

- `admin-servers` for inventory and provisioning.
- `admin-infra-*` for provider‑specific VM setup.
- `admin-wsl` for local Docker/CLI support when coordinating from WSL.

## References

- Coolify docs: https://coolify.io/docs
- Coolify GitHub: https://github.com/coollabsio/coolify
