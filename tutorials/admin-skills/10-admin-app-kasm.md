# Tutorial 10 — Deploy KASM with `admin-app-kasm`

## Outcome

You install KASM Workspaces and run the post‑install wizard.

## KASM flow

1. Provision a server (8GB+ RAM recommended).
2. Install Docker CE + Compose plugin.
3. Install KASM.
4. Extract credentials from `install_log.txt`.
5. Log in via `https://<SERVER_IP>`.
6. Run post‑install wizard modules (backups, storage, etc.).
7. Secure public access (tunnel) if exposed.

Skill overview: `skills/admin-app-kasm/SKILL.md`.  
Wizard quick start: `skills/admin-app-kasm/references/QUICKSTART.md`.

## Demo prompt

Paste:

```
I have a server in inventory named KASM01.
Install KASM on it, then run the post-install wizard Module 03 (backups).
Ask me for any missing values.
```

Expected behavior:

- Claude validates server resources.
- It follows the install guide.
- It walks through wizard inputs and logs the module run.

## Exercise

Decide your concurrency:

1. Tell Claude how many concurrent KASM sessions you want.
2. Ask it to compute RAM/CPU needs and compare to your server.

Next: `11-admin-windows-vs-wsl.md`.

