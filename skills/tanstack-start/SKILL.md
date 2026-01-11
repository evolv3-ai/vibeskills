---
name: TanStack Start
description: |
  Build full-stack React apps with TanStack Start on Cloudflare Workers. Type-safe routing, server functions, SSR/streaming, D1/KV/R2 integration.

  Use when building full-stack React apps with SSR, or migrating from Next.js. RC status - monitor #5734 before production.
user-invocable: true
allowed-tools: [Bash, Read, Write, Edit]
---

# TanStack Start Skill [DRAFT - NOT READY]

⚠️ **Status: Release Candidate - Ready for Production Testing**

This skill is prepared but NOT published. Waiting for:
- ⏸️ v1.0 stable release (currently RC v1.146.3 as of 2026-01-09)
- ✅ GitHub #5734 resolved (memory leak with TanStack Form - **FIXED** Jan 5, 2026)
- ⏸️ Final RC stabilization period
- ⏸️ Template/reference content creation

**Current Package:** `@tanstack/react-start@1.146.3` (Jan 2026)

**OK FOR PRODUCTION TESTING** - RC status, memory leak issue resolved

**Issue #5734 Resolution** (Jan 5, 2026): Memory leak with TanStack Form was fixed in form/start latest versions. The issue that caused server crashes every ~30 min on pages with forms is now resolved. Update to latest versions of both @tanstack/react-start and @tanstack/form.

---

## Skill Overview

TanStack Start is a full-stack React framework with:
- Client-first architecture with opt-in SSR
- Built on TanStack Router (type-safe routing)
- Server functions for API logic
- Official Cloudflare Workers support
- Integrates with TanStack Query

---

## When v1.0 Stable

This skill will provide:
- Cloudflare Workers + D1/KV/R2 setup
- Server function patterns
- SSR vs CSR strategies
- Migration guide from Next.js
- Known issues and solutions

---

## Monitoring

Track stability at: `planning/stability-tracker.md`

**Check weekly:**
- Package: `npm view @tanstack/react-start version`
- [TanStack Start Releases](https://github.com/TanStack/router/releases)
- [Issue #5734](https://github.com/TanStack/router/issues/5734) - Memory leak blocker

---

## Installation (When Ready)

```bash
npm create cloudflare@latest -- --framework=tanstack-start
```

---

**Last Updated:** 2026-01-09
**RC Announced:** September 22, 2025
**Expected Stable:** Final RC feedback period (issue #5734 resolved)
**Monitoring:** Issue #5734 closed (Jan 5, 2026). Memory leak fixed in latest form/start versions.
