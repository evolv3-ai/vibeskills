# Tutorial 8 — OCI Always‑Free ARM with `admin-infra-oci`

## Outcome

You can reliably get an OCI A1.Flex ARM instance and handle capacity issues.

## OCI specifics

OCI free tier ARM servers are great but often hit `OUT_OF_HOST_CAPACITY`. The skill handles this by:

- Scanning availability domains.
- Retrying when capacity appears.
- Logging each attempt.

Docs: `skills/admin-infra-oci/SKILL.md` and `skills/admin-infra-oci/docs/`.

## Demo prompt

Paste:

```
Provision an OCI Always Free A1.Flex ARM server for Coolify.
Start with capacity checks across ADs, then create networking, then launch the instance.
Ask me for any missing tenancy/region/key values.
```

Expected behavior:

- Claude runs/requests capacity checks first.
- It uses the OCI CLI pattern from the skill.
- It logs capacity failures and retries.

## Exercise

Run only the capacity step:

1. Ask `admin-infra-oci` to check capacity in your region.
2. If capacity is unavailable, ask for a retry plan and alerting approach.

Next: `09-admin-app-coolify.md`.

