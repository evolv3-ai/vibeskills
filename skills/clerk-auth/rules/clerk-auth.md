---
paths: "**/*clerk*.ts", "**/*middleware*.ts", "**/*auth*.ts", src/app/api/**/*.ts
---

# Clerk Auth Corrections

Claude's training may reference older Clerk patterns. This project uses **Clerk v6+**.

## Next.js v6: auth() is Async

```typescript
/* ❌ v5 (synchronous) */
import { auth } from '@clerk/nextjs/server'
const { userId } = auth()

/* ✅ v6 (asynchronous) */
import { auth } from '@clerk/nextjs/server'
const { userId } = await auth()
```

## auth.protect() is Async

```typescript
/* ❌ v5 */
auth.protect()

/* ✅ v6 */
await auth.protect()
```

## API Version 2025-11-10 Changes

```typescript
/* ❌ Old field names */
{ payment_source_id: "...", payment_source: {...} }

/* ✅ New field names */
{ payment_method_id: "...", payment_method: {...} }

/* ❌ Old endpoints */
GET /v1/commerce/plans

/* ✅ New endpoints */
GET /v1/billing/plans
```

## Cloudflare Workers: authorizedParties Required

```typescript
import { verifyToken } from '@clerk/backend'

/* ❌ CSRF vulnerability */
const { data } = await verifyToken(token, {
  secretKey: c.env.CLERK_SECRET_KEY,
})

/* ✅ Always set authorizedParties */
const { data } = await verifyToken(token, {
  secretKey: c.env.CLERK_SECRET_KEY,
  authorizedParties: ['https://yourdomain.com'],
})
```

## JWT Size Limit: 1.2KB

```json
// ❌ Exceeds limit (large metadata)
{
  "bio": "{{user.public_metadata.bio}}",
  "all_metadata": "{{user.public_metadata}}"
}

// ✅ Keep claims minimal
{
  "user_id": "{{user.id}}",
  "email": "{{user.primary_email_address}}",
  "role": "{{user.public_metadata.role}}"
}
```

## Vite Dev Mode: 431 Error Fix

```json
// package.json - Increase header limit
{
  "scripts": {
    "dev": "NODE_OPTIONS='--max-http-header-size=32768' vite"
  }
}
```

## Quick Fixes

| If Claude suggests... | Use instead... |
|----------------------|----------------|
| `const { userId } = auth()` | `const { userId } = await auth()` |
| `auth.protect()` | `await auth.protect()` |
| `apiKey` | `secretKey` |
| Missing `authorizedParties` | Add `authorizedParties: ['https://yourdomain.com']` |
| `/v1/commerce/*` endpoints | `/v1/billing/*` endpoints |
| `payment_source` | `payment_method` |
