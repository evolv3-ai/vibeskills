# Tutorial 5 — Device Profiles

## Outcome

You understand device profiles and can keep them accurate.

## What a profile is

Profiles live at:

```
$ADMIN_PROFILE_PATH/<DEVICE_NAME>.json
```

They track:

- Installed tools and versions.
- Package managers present.
- Managed servers you provisioned.
- Basic system info.

Schema: `skills/admin/assets/profile-schema.json`.

## When profiles update

- After installs: add to `installedTools`.
- After provisioning: add to `managedServers`.
- After major OS changes: update system info.

`admin` should update the profile after any relevant action.

## Demo prompt

Paste:

```
Open my current device profile and show me:
1) installedTools summary,
2) managedServers summary,
3) anything missing or stale.
Then propose the minimal JSON edits you would apply.
```

Expected behavior:

- Claude finds the profile location from env.
- It summarizes without rewriting the whole file.
- It suggests minimal diffs.

## Exercise

1. Install a tool you don’t currently have.
2. Ask `admin` to update your profile.
3. Re‑ask for profile summary and confirm the tool shows up.

Next: `06-admin-devops-inventory.md`.
