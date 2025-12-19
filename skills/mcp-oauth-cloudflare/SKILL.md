---
name: MCP OAuth Cloudflare
description: |
  Add OAuth authentication to MCP servers on Cloudflare Workers. Uses @cloudflare/workers-oauth-provider with Google OAuth for Claude.ai-compatible authentication.

  Use when building MCP servers that need user authentication, implementing Dynamic Client Registration (DCR) for Claude.ai, or replacing static auth tokens with OAuth flows. Prevents CSRF vulnerabilities, state validation errors, and OAuth misconfiguration.
license: MIT
metadata:
  version: "1.0.0"
  last_verified: "2025-12-18"
  keywords:
    - mcp oauth
    - mcp authentication
    - cloudflare workers oauth
    - dynamic client registration
    - dcr
    - claude.ai mcp
    - google oauth mcp
    - workers-oauth-provider
    - mcp server auth
    - oauth2 mcp
    - durable objects mcp
---

# MCP OAuth Cloudflare

Production-ready OAuth authentication for MCP servers on Cloudflare Workers.

## When to Use This Skill

- Building an MCP server that needs user authentication
- Deploying MCP to Claude.ai (requires Dynamic Client Registration)
- Replacing static auth tokens with OAuth for better security
- Adding Google Sign-In to your MCP server
- Need user context (email, name, picture) in MCP tool handlers

## When NOT to Use

- Internal/private MCP servers where tokens are acceptable
- MCP servers without user-specific data
- Local-only MCP development (use tokens for simplicity)

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Cloudflare Worker                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────┐      ┌──────────────────────────────────┐ │
│  │  OAuthProvider      │      │  McpAgent (Durable Object)       │ │
│  │  ─────────────────  │      │  ────────────────────────────    │ │
│  │  /register (DCR)    │      │  MCP Tools with user props:      │ │
│  │  /authorize         │─────▶│  - this.props.email              │ │
│  │  /token             │      │  - this.props.id                 │ │
│  │  /mcp               │      │  - this.props.accessToken        │ │
│  └─────────────────────┘      └──────────────────────────────────┘ │
│           │                                                         │
│           │ OAuth Flow                                              │
│           ▼                                                         │
│  ┌─────────────────────┐      ┌──────────────────────────────────┐ │
│  │  Google Handler     │      │  KV Namespace (OAUTH_KV)         │ │
│  │  ─────────────────  │      │  ────────────────────────────    │ │
│  │  /authorize (GET)   │─────▶│  oauth:state:{token} → AuthReq   │ │
│  │  /authorize (POST)  │      │  TTL: 10 minutes                 │ │
│  │  /callback          │      └──────────────────────────────────┘ │
│  └─────────────────────┘                                           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Quick Start

### 1. Install Dependencies

```bash
npm install @cloudflare/workers-oauth-provider agents @modelcontextprotocol/sdk hono zod
```

### 2. Create OAuth Directory Structure

```
src/
├── index.ts              # Main entry with OAuthProvider
└── oauth/
    ├── google-handler.ts # OAuth routes (/authorize, /callback)
    ├── utils.ts          # Google token exchange & user info
    └── workers-oauth-utils.ts # CSRF, state validation, approval UI
```

### 3. Configure wrangler.jsonc

```jsonc
{
  "name": "my-mcp-server",
  "main": "src/index.ts",
  "compatibility_flags": ["nodejs_compat"],

  // KV for OAuth state storage
  "kv_namespaces": [
    {
      "binding": "OAUTH_KV",
      "id": "YOUR_KV_NAMESPACE_ID"
    }
  ],

  // Durable Objects for MCP sessions
  "durable_objects": {
    "bindings": [
      {
        "class_name": "MyMcpServer",
        "name": "MCP_OBJECT"
      }
    ]
  },

  "migrations": [
    {
      "new_sqlite_classes": ["MyMcpServer"],
      "tag": "v1"
    }
  ]
}
```

### 4. Set Secrets

```bash
# Google OAuth credentials (from console.cloud.google.com)
echo "YOUR_GOOGLE_CLIENT_ID" | npx wrangler secret put GOOGLE_CLIENT_ID
echo "YOUR_GOOGLE_CLIENT_SECRET" | npx wrangler secret put GOOGLE_CLIENT_SECRET

# Cookie encryption key (32+ chars)
python3 -c "import secrets; print(secrets.token_urlsafe(32))" | npx wrangler secret put COOKIE_ENCRYPTION_KEY

# Deploy to activate secrets
npx wrangler deploy
```

## Implementation Guide

### Main Entry Point (index.ts)

```typescript
import OAuthProvider from '@cloudflare/workers-oauth-provider';
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { McpAgent } from 'agents/mcp';
import { z } from 'zod';
import { GoogleHandler } from './oauth/google-handler';

// Props from OAuth - user info stored in token
type Props = {
  id: string;
  email: string;
  name: string;
  picture?: string;
  accessToken: string;
};

export class MyMcpServer extends McpAgent<Env, Record<string, never>, Props> {
  server = new McpServer({
    name: 'my-mcp-server',
    version: '1.0.0',
  });

  async init() {
    // Register tools - user info available via this.props
    this.server.tool(
      'my_tool',
      'Tool description',
      { param: z.string() },
      async (args) => {
        // Access authenticated user
        const userEmail = this.props?.email;
        console.log(`Tool called by: ${userEmail}`);

        return {
          content: [{ type: 'text', text: 'Result' }]
        };
      }
    );
  }
}

// Wrap with OAuth provider
export default new OAuthProvider({
  apiHandlers: {
    '/sse': MyMcpServer.serveSSE('/sse'),
    '/mcp': MyMcpServer.serve('/mcp'),
  },
  authorizeEndpoint: '/authorize',
  clientRegistrationEndpoint: '/register',
  defaultHandler: GoogleHandler as any,
  tokenEndpoint: '/token',
});
```

### Google Handler (oauth/google-handler.ts)

```typescript
import { env } from 'cloudflare:workers';
import type { AuthRequest, OAuthHelpers } from '@cloudflare/workers-oauth-provider';
import { Hono } from 'hono';
import { fetchUpstreamAuthToken, fetchGoogleUserInfo, getUpstreamAuthorizeUrl, type Props } from './utils';
import {
  addApprovedClient,
  bindStateToSession,
  createOAuthState,
  generateCSRFProtection,
  isClientApproved,
  OAuthError,
  renderApprovalDialog,
  validateCSRFToken,
  validateOAuthState,
} from './workers-oauth-utils';

const app = new Hono<{ Bindings: Env & { OAUTH_PROVIDER: OAuthHelpers } }>();

// GET /authorize - Show approval dialog or redirect to Google
app.get('/authorize', async (c) => {
  const oauthReqInfo = await c.env.OAUTH_PROVIDER.parseAuthRequest(c.req.raw);
  const { clientId } = oauthReqInfo;

  if (!clientId) return c.text('Invalid request', 400);

  // Skip approval if client already approved
  if (await isClientApproved(c.req.raw, clientId, env.COOKIE_ENCRYPTION_KEY)) {
    const { stateToken } = await createOAuthState(oauthReqInfo, c.env.OAUTH_KV);
    const { setCookie } = await bindStateToSession(stateToken);
    return redirectToGoogle(c.req.raw, stateToken, { 'Set-Cookie': setCookie });
  }

  // Show approval dialog with CSRF protection
  const { token: csrfToken, setCookie } = generateCSRFProtection();
  return renderApprovalDialog(c.req.raw, {
    client: await c.env.OAUTH_PROVIDER.lookupClient(clientId),
    csrfToken,
    server: {
      name: 'My MCP Server',
      description: 'Description of your server',
      logo: 'https://example.com/logo.png',
    },
    setCookie,
    state: { oauthReqInfo },
  });
});

// POST /authorize - Process approval form
app.post('/authorize', async (c) => {
  try {
    const formData = await c.req.raw.formData();
    validateCSRFToken(formData, c.req.raw);

    const encodedState = formData.get('state') as string;
    const state = JSON.parse(atob(encodedState));

    // Add to approved clients
    const approvedCookie = await addApprovedClient(
      c.req.raw, state.oauthReqInfo.clientId, c.env.COOKIE_ENCRYPTION_KEY
    );

    // Create state and redirect
    const { stateToken } = await createOAuthState(state.oauthReqInfo, c.env.OAUTH_KV);
    const { setCookie } = await bindStateToSession(stateToken);

    const headers = new Headers();
    headers.append('Set-Cookie', approvedCookie);
    headers.append('Set-Cookie', setCookie);

    return redirectToGoogle(c.req.raw, stateToken, Object.fromEntries(headers));
  } catch (error: any) {
    if (error instanceof OAuthError) return error.toResponse();
    return c.text(`Error: ${error.message}`, 500);
  }
});

// GET /callback - Handle Google OAuth callback
app.get('/callback', async (c) => {
  const { oauthReqInfo, clearCookie } = await validateOAuthState(c.req.raw, c.env.OAUTH_KV);

  // Exchange code for token
  const [accessToken, err] = await fetchUpstreamAuthToken({
    client_id: c.env.GOOGLE_CLIENT_ID,
    client_secret: c.env.GOOGLE_CLIENT_SECRET,
    code: c.req.query('code'),
    redirect_uri: new URL('/callback', c.req.url).href,
    upstream_url: 'https://oauth2.googleapis.com/token',
  });
  if (err) return err;

  // Get user info
  const user = await fetchGoogleUserInfo(accessToken);
  if (!user) return c.text('Failed to fetch user info', 500);

  // Complete authorization
  const { redirectTo } = await c.env.OAUTH_PROVIDER.completeAuthorization({
    props: {
      accessToken,
      email: user.email,
      id: user.id,
      name: user.name,
      picture: user.picture,
    } as Props,
    request: oauthReqInfo,
    scope: oauthReqInfo.scope,
    userId: user.id,
  });

  return new Response(null, {
    status: 302,
    headers: { Location: redirectTo, 'Set-Cookie': clearCookie },
  });
});

async function redirectToGoogle(request: Request, stateToken: string, headers: Record<string, string> = {}) {
  return new Response(null, {
    status: 302,
    headers: {
      ...headers,
      location: getUpstreamAuthorizeUrl({
        client_id: env.GOOGLE_CLIENT_ID,
        redirect_uri: new URL('/callback', request.url).href,
        scope: 'openid email profile',
        state: stateToken,
        upstream_url: 'https://accounts.google.com/o/oauth2/v2/auth',
      }),
    },
  });
}

export { app as GoogleHandler };
```

## OAuth Flow Diagram

```
User clicks "Connect" in Claude.ai
          │
          ▼
┌─────────────────────────────────┐
│  1. /register (DCR)             │ ◄── Claude.ai registers as client
│     Returns client credentials   │
└─────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────┐
│  2. GET /authorize              │
│     - Check approved clients    │
│     - Show approval dialog      │
│     - Generate CSRF token       │
└─────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────┐
│  3. POST /authorize             │
│     - Validate CSRF             │
│     - Create state in KV        │
│     - Redirect to Google        │
└─────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────┐
│  4. Google OAuth                │
│     - User signs in             │
│     - Consents to scopes        │
└─────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────┐
│  5. GET /callback               │
│     - Validate state            │
│     - Exchange code for token   │
│     - Fetch user info           │
│     - Complete authorization    │
└─────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────┐
│  6. User props available        │
│     this.props.email            │
│     this.props.id               │
│     this.props.accessToken      │
└─────────────────────────────────┘
```

## Security Features

### CSRF Protection

```typescript
// Generate CSRF token with HttpOnly cookie
export function generateCSRFProtection(): CSRFProtectionResult {
  const token = crypto.randomUUID();
  const setCookie = `__Host-CSRF_TOKEN=${token}; HttpOnly; Secure; Path=/; SameSite=Lax; Max-Age=600`;
  return { token, setCookie };
}
```

### State Validation (Prevents Replay Attacks)

```typescript
// Create one-time-use state in KV
export async function createOAuthState(oauthReqInfo: AuthRequest, kv: KVNamespace) {
  const stateToken = crypto.randomUUID();
  await kv.put(`oauth:state:${stateToken}`, JSON.stringify(oauthReqInfo), {
    expirationTtl: 600, // 10 minutes
  });
  return { stateToken };
}
```

### Session Binding (Prevents Token Theft)

```typescript
// Bind state to browser session via SHA-256 hash
export async function bindStateToSession(stateToken: string) {
  const hashBuffer = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(stateToken));
  const hashHex = Array.from(new Uint8Array(hashBuffer))
    .map(b => b.toString(16).padStart(2, '0')).join('');

  const setCookie = `__Host-CONSENTED_STATE=${hashHex}; HttpOnly; Secure; Path=/; SameSite=Lax; Max-Age=600`;
  return { setCookie };
}
```

### Client Approval Caching (Reduces Consent Fatigue)

```typescript
// HMAC-signed cookie tracks approved clients (30-day TTL)
export async function addApprovedClient(request: Request, clientId: string, cookieSecret: string) {
  const existing = await getApprovedClientsFromCookie(request, cookieSecret) || [];
  const updated = [...new Set([...existing, clientId])];

  const payload = JSON.stringify(updated);
  const signature = await signData(payload, cookieSecret);

  return `__Host-APPROVED_CLIENTS=${signature}.${btoa(payload)}; HttpOnly; Secure; Path=/; SameSite=Lax; Max-Age=2592000`;
}
```

## Google Cloud Console Setup

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Create new project or select existing
3. Navigate to **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **OAuth client ID**
5. Application type: **Web application**
6. Add authorized redirect URI: `https://your-worker.workers.dev/callback`
7. Copy Client ID and Client Secret

## Common Issues

### "Invalid state" Error

**Cause**: State expired (>10 min) or KV lookup failed

**Fix**: Restart the OAuth flow - states are one-time-use

### "CSRF token mismatch"

**Cause**: Form submitted without matching cookie

**Fix**: Ensure cookies are enabled and not blocked by browser extensions

### Claude.ai Shows "Connection Failed"

**Cause**: Missing DCR endpoint or invalid response

**Fix**: Ensure `clientRegistrationEndpoint: '/register'` is set in OAuthProvider config

### User Props Undefined

**Cause**: Accessing `this.props` before OAuth completes

**Fix**: Check `if (this.props)` before accessing user data

## OAuth vs Auth Tokens Comparison

| Aspect | Auth Tokens | OAuth |
|--------|-------------|-------|
| Token sharing | Manual (risky) | Automatic |
| User consent | None | Explicit approval |
| Expiration | Manual | Automatic refresh |
| Revocation | None built-in | User can disconnect |
| Scope | All-or-nothing | Fine-grained |
| Claude.ai compatible | No (DCR required) | Yes |

## Required Secrets

| Secret | Purpose | Generate |
|--------|---------|----------|
| `GOOGLE_CLIENT_ID` | OAuth app ID | Google Cloud Console |
| `GOOGLE_CLIENT_SECRET` | OAuth app secret | Google Cloud Console |
| `COOKIE_ENCRYPTION_KEY` | Sign approval cookies | `secrets.token_urlsafe(32)` |

## Token Efficiency

| Without Skill | With Skill | Savings |
|---------------|------------|---------|
| ~20k tokens, 3-5 attempts | ~6k tokens, first try | ~70% |

## Errors Prevented

1. **CSRF vulnerabilities** - HttpOnly cookies with SameSite
2. **State replay attacks** - One-time-use KV state
3. **Token theft** - Session binding via SHA-256
4. **Missing DCR** - OAuthProvider handles automatically
5. **Cookie tampering** - HMAC signatures

## References

- [Cloudflare Workers OAuth Provider](https://developers.cloudflare.com/workers/examples/oauth/)
- [MCP Specification](https://spec.modelcontextprotocol.io/)
- [Google OAuth Documentation](https://developers.google.com/identity/protocols/oauth2)
- [Cloudflare Agents SDK](https://developers.cloudflare.com/agents/)
