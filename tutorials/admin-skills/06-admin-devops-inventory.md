# Tutorial 6 — `admin-devops`: Inventory First

## Outcome

You maintain a real server inventory and never “provision blind” again.

## Why inventory matters

Every provisioning action should start with:

1. “What do I already have?”
2. “Does something already fit this role?”

`admin-devops` keeps that memory in a single `.env`‑style file.

## The inventory file

Default names:

- `.agent-devops.env` (project)
- `agent-devops.env.local` (project‑local override)
- `~/.agent-devops.env` (global)

Template: `skills/admin-devops/assets/agent-devops.env.template`.

Spec: `skills/admin-devops/references/INVENTORY_FORMAT.md`.

## Core workflow

1. Create inventory from template (if missing).
2. Add providers.
3. Add server blocks with `SERVER_<ID>_*` keys.
4. Connect using stored host/user/key.

## Demo prompt

Paste:

```
Create a starter `.agent-devops.env` for:
- One OCI ARM server for Coolify
- One Hetzner x86 server for KASM
- My local dev machine
Use placeholders for any unknown values.
```

Expected behavior:

- Claude outputs a valid `.env` file with clear `PROVIDER_*` and `SERVER_*` blocks.
- It uses reserved example IPs or placeholders.

## Exercise

1. Add a real server you own to your inventory.
2. Ask: “List my servers and give me the SSH command for `<ID>`.”

Next: `07-admin-infra-pattern.md`.
