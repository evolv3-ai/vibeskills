/**
 * Google OAuth Handler for MCP Server
 *
 * Routes:
 * - GET /authorize  - Show approval dialog or redirect to Google
 * - POST /authorize - Process approval form submission
 * - GET /callback   - Handle Google OAuth callback
 *
 * TEMPLATE: Customize server name, description, and logo in GET /authorize
 */

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

/**
 * GET /authorize - Initial authorization request
 * Shows approval dialog or redirects to Google if already approved
 */
app.get('/authorize', async (c) => {
  const oauthReqInfo = await c.env.OAUTH_PROVIDER.parseAuthRequest(c.req.raw);
  const { clientId } = oauthReqInfo;

  if (!clientId) {
    return c.text('Invalid request', 400);
  }

  // Check if client is already approved (skip consent screen)
  if (await isClientApproved(c.req.raw, clientId, env.COOKIE_ENCRYPTION_KEY)) {
    const { stateToken } = await createOAuthState(oauthReqInfo, c.env.OAUTH_KV);
    const { setCookie: sessionBindingCookie } = await bindStateToSession(stateToken);
    return redirectToGoogle(c.req.raw, stateToken, { 'Set-Cookie': sessionBindingCookie });
  }

  // Generate CSRF protection for approval form
  const { token: csrfToken, setCookie } = generateCSRFProtection();

  // TEMPLATE: Customize these values for your MCP server
  return renderApprovalDialog(c.req.raw, {
    client: await c.env.OAUTH_PROVIDER.lookupClient(clientId),
    csrfToken,
    server: {
      name: 'My MCP Server',           // TODO: Change this
      description: 'Description here', // TODO: Change this
      logo: 'https://example.com/logo.png', // TODO: Change this (optional)
    },
    setCookie,
    state: { oauthReqInfo },
  });
});

/**
 * POST /authorize - Handle approval form submission
 */
app.post('/authorize', async (c) => {
  try {
    const formData = await c.req.raw.formData();

    // Validate CSRF token
    validateCSRFToken(formData, c.req.raw);

    // Extract state from form data
    const encodedState = formData.get('state');
    if (!encodedState || typeof encodedState !== 'string') {
      return c.text('Missing state in form data', 400);
    }

    let state: { oauthReqInfo?: AuthRequest };
    try {
      state = JSON.parse(atob(encodedState));
    } catch {
      return c.text('Invalid state data', 400);
    }

    if (!state.oauthReqInfo || !state.oauthReqInfo.clientId) {
      return c.text('Invalid request', 400);
    }

    // Add client to approved list (won't show consent again for 30 days)
    const approvedClientCookie = await addApprovedClient(
      c.req.raw,
      state.oauthReqInfo.clientId,
      c.env.COOKIE_ENCRYPTION_KEY
    );

    // Create OAuth state and bind to session
    const { stateToken } = await createOAuthState(state.oauthReqInfo, c.env.OAUTH_KV);
    const { setCookie: sessionBindingCookie } = await bindStateToSession(stateToken);

    // Set both cookies
    const headers = new Headers();
    headers.append('Set-Cookie', approvedClientCookie);
    headers.append('Set-Cookie', sessionBindingCookie);

    return redirectToGoogle(c.req.raw, stateToken, Object.fromEntries(headers));
  } catch (error: any) {
    console.error('POST /authorize error:', error);
    if (error instanceof OAuthError) {
      return error.toResponse();
    }
    return c.text(`Internal server error: ${error.message}`, 500);
  }
});

/**
 * Redirect to Google OAuth
 */
async function redirectToGoogle(
  request: Request,
  stateToken: string,
  headers: Record<string, string> = {}
) {
  return new Response(null, {
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
    status: 302,
  });
}

/**
 * GET /callback - Handle Google OAuth callback
 */
app.get('/callback', async (c) => {
  let oauthReqInfo: AuthRequest;
  let clearSessionCookie: string;

  try {
    const result = await validateOAuthState(c.req.raw, c.env.OAUTH_KV);
    oauthReqInfo = result.oauthReqInfo;
    clearSessionCookie = result.clearCookie;
  } catch (error: any) {
    if (error instanceof OAuthError) {
      return error.toResponse();
    }
    return c.text('Internal server error', 500);
  }

  if (!oauthReqInfo.clientId) {
    return c.text('Invalid OAuth request data', 400);
  }

  // Exchange code for access token
  const [accessToken, errResponse] = await fetchUpstreamAuthToken({
    client_id: c.env.GOOGLE_CLIENT_ID,
    client_secret: c.env.GOOGLE_CLIENT_SECRET,
    code: c.req.query('code'),
    redirect_uri: new URL('/callback', c.req.url).href,
    upstream_url: 'https://oauth2.googleapis.com/token',
  });

  if (errResponse) return errResponse;

  // Fetch user info from Google
  const user = await fetchGoogleUserInfo(accessToken);
  if (!user) {
    return c.text('Failed to fetch user info', 500);
  }

  const { id, email, name, picture } = user;

  // Complete authorization and return token to MCP client
  const { redirectTo } = await c.env.OAUTH_PROVIDER.completeAuthorization({
    metadata: {
      label: name || email,
    },
    props: {
      accessToken,
      email,
      id,
      name,
      picture,
    } as Props,
    request: oauthReqInfo,
    scope: oauthReqInfo.scope,
    userId: id,
  });

  // Clear session binding cookie and redirect
  const headers = new Headers({ Location: redirectTo });
  if (clearSessionCookie) {
    headers.set('Set-Cookie', clearSessionCookie);
  }

  return new Response(null, {
    status: 302,
    headers,
  });
});

export { app as GoogleHandler };
