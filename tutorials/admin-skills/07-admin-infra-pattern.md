# Tutorial 7 — The Shared `admin-infra-*` Pattern

## Outcome

You learn one provisioning pattern that applies to every provider skill.

## The universal flow

All provider skills follow:

1. Verify provider CLI and auth.
2. Check quotas and capacity.
3. Create network primitives (VPC/VCN, subnet, firewall rules).
4. Launch instance with correct image/shape.
5. Validate SSH reachability.
6. Harden basics (firewall, updates).
7. Log and update inventory/profile.

Only the provider‑specific commands change.

## What you should provide Claude

Before provisioning, gather:

- Region / datacenter.
- Instance shape/size.
- OS image.
- SSH public key.
- Budget/limits (if on free tiers).
- Any naming conventions.

## Demo prompt

Paste:

```
I want to provision a new server. Ask me for the minimum required details using the universal admin-infra workflow, then tell me which provider skill you’ll route to based on my answers.
```

Expected behavior:

- Claude asks a short, structured set of questions.
- It confirms routing to the correct `admin-infra-*`.

## Exercise

Pick your provider and write down:

1. The exact shape you want.
2. The region.
3. The OS image.
4. Your SSH key path.
5. Your server’s intended role.

Next: `08-admin-infra-oci.md`.

