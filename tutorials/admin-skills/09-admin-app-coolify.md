# Tutorial 9 — Deploy Coolify with `admin-app-coolify`

## Outcome

You install Coolify on a server and deploy a first app.

## Coolify flow

1. Provision a server (4GB+ RAM, Ubuntu LTS recommended).
2. Install Docker CE + Compose plugin.
3. Install Coolify (manual or enhanced automation).
4. Verify UI at `http://<SERVER_IP>:8000`.
5. Secure with HTTPS (Cloudflare tunnel or reverse proxy).
6. Deploy first app via UI.

Skill overview: `skills/admin-app-coolify/SKILL.md`.  
Manual install: `skills/admin-app-coolify/references/INSTALLATION.md`.  
Enhanced automation: `skills/admin-app-coolify/references/ENHANCED_SETUP.md`.

## Demo prompt

Paste:

```
I have a server in inventory named COOLIFY01.
Install Coolify on it, secure access with HTTPS, and deploy a demo Next.js app.
Ask me for any missing values (domain, tunnel preference, SSH details).
```

Expected behavior:

- Claude confirms server exists in `.agent-devops.env`.
- It chooses manual vs enhanced setup based on your preference.
- It logs installation and deployment.

## Exercise

Deploy a trivial container:

1. In Coolify, deploy `nginxdemos/hello`.
2. Ask Claude to log the deployment and update your device profile.

Next: `10-admin-app-kasm.md`.

