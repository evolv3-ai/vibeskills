# Tutorial 2 — Install & First‑Run Setup

## Outcome

You set up a portable admin environment and confirm logs/profiles work.

## Why setup matters

The suite is designed to be user‑agnostic. It needs a small `.env` configuration so it can:

- Know your shared admin root.
- Name your device correctly.
- Log operations consistently.

## Step 1: Choose your `ADMIN_ROOT`

Pick a single folder that holds:

- `logs/`
- `profiles/`
- `config/`

Recommended defaults:

- Windows + WSL machine:
  - Windows path: `C:/Users/<USERNAME>/.admin`
  - WSL path: `/mnt/c/Users/<USERNAME>/.admin`
- Linux/macOS:
  - `~/.admin`

## Step 2: Create config

Either:

- **Project local**: `.env.local` in the repo you’re working in.
- **Global**: `$ADMIN_ROOT/.env`.

Minimum variables:

```env
DEVICE_NAME=<DEVICE_NAME>
ADMIN_USER=<ADMIN_USER>
ADMIN_ROOT=<ABSOLUTE_PATH_TO_.admin>
WSL_DISTRO=Ubuntu-24.04
```

Full spec: `skills/admin/assets/env-spec.txt`.

## Step 3: Verify first‑run flow

Paste this into Claude:

```
Run the admin first-run setup. Ask me for any missing values, then show the `.env` you would write. Assume a shared Windows+WSL admin root unless I say otherwise.
```

Expected behavior:

- Claude detects platform/shell.
- It asks you for missing pieces (device name, root path, sync preference).
- It produces an absolute‑path `.env` (never `~`).

## Step 4: Confirm directories

You should now have:

```
$ADMIN_ROOT/
  .env
  logs/
    operations.log
    installations.log
    system-changes.log
    handoffs.log
    devices/<DEVICE_NAME>/history.log
  profiles/
    <DEVICE_NAME>.json
```

If you don’t, ask:

```
Admin setup completed, but I don’t see logs/profiles. Diagnose what’s missing and give me exact commands to fix it.
```

## Exercise

1. Install any small tool (e.g., `jq` in WSL or `git` in Windows) using the suite.
2. Find the install in `installations.log`.
3. Ask Claude to summarize your last 10 ops entries.

Next: `03-routing.md`.

