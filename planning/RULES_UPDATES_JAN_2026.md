# Rules Updates - January 2026 Audit

**Created**: 2026-01-03
**Status**: In Progress
**Total User-Level Rules**: 49
**Total Skill-Level Rules**: 38 (updated with parent skills)
**Rules Needing Updates**: 18
**Estimated Effort**: ~12 hours

---

## Priority Tiers

### TIER 1: URGENT (Fix This Week) - ~4 hours ✅ COMPLETE

| Rule File | Issue | Est. Hours | Status |
|-----------|-------|------------|--------|
| clerk-auth.md | API v1 deprecated (Apr 2025), missing cookie size limit (1.2KB), JWT vs session token confusion | 1 | ✅ Done |
| better-auth-vite.md | ESM-only breaking change, nodejs_compat for Workers, generateId migration, missing env vars | 1.5 | ✅ Done |
| vite-node.md | Missing Vite v6+ `loadEnv()` pattern (primary solution not documented) | 0.5 | ✅ Done |
| ai-gateway-providers.md | Missing 16 of 24 providers (only 8 documented) | 0.5 | ✅ Done |
| cloudflare-ai-gateway.md | BYOK now uses Secrets Store (Aug 2025), custom providers missing | 0.5 | ✅ Done |

### TIER 2: HIGH (Next Sprint) - ~5 hours

| Rule File | Issue | Est. Hours | Status |
|-----------|-------|------------|--------|
| snowflake-native-app-marketplace.md | Legacy SQL → snow CLI, release channels, NAAPS details | 1.5 | ⏳ Not Started |
| snowflake-native-apps.md | Release channels workflow, `snow app publish` command | 1 | ⏳ Not Started |
| snowflake-marketplace-listing.md | Data dictionary now MANDATORY, data attributes field | 0.5 | ⏳ Not Started |
| cloudflare-workers-ai-models.md | Missing 8 new 2025 models (OpenAI GPT-OSS, Deepgram, Leonardo) | 0.5 | ⏳ Not Started |
| expo-android-sdk.md | Update deadline to Aug 31, 2025 (was "late 2024") | 0.25 | ⏳ Not Started |
| git-patterns.md | Add tag performance impact, modern monorepo tools | 0.5 | ⏳ Not Started |
| drizzle-orm.md | Add `timestamp_ms` mode info, modernize journal drift | 0.5 | ⏳ Not Started |
| d1-batch-operations.md | Clarify Free (50) vs Paid (1,000) tier limits | 0.25 | ⏳ Not Started |

### TIER 3: MEDIUM (Following Sprint) - ~2 hours

| Rule File | Issue | Est. Hours | Status |
|-----------|-------|------------|--------|
| react-patterns.md | Add React 19 form actions (useActionState) context | 0.5 | ⏳ Not Started |
| oauth-samesite-cookies.md | Add POST-based OIDC flows note (SameSite=None) | 0.25 | ⏳ Not Started |
| soap-api-requests.md | Add SOAP 1.1 vs 1.2 version awareness | 0.25 | ⏳ Not Started |
| hono-route-ordering.md | Clarify route priority wording | 0.25 | ⏳ Not Started |
| snowflake-streamlit.md | Add Jan 2025 Git integration note | 0.25 | ⏳ Not Started |
| cloudflare-deploy-workflow.md | Note secret auto-deploy in v3.73.0+ | 0.25 | ⏳ Not Started |

### TIER 4: LOW (When Time Permits) - ~1 hour

| Rule File | Issue | Est. Hours | Status |
|-----------|-------|------------|--------|
| node-formdata.md | Add Node.js v18+ context | 0.25 | ⏳ Not Started |
| react-duplicate-instance.md | Add Vite 6 context note | 0.25 | ⏳ Not Started |
| browser-automation-gifs.md | Add Claude in Chrome requirement note | 0.1 | ⏳ Not Started |
| github-api.md | Clarify X-GitHub-Api-Version is optional | 0.1 | ⏳ Not Started |
| microsoft-oauth.md | Add token lifetime context | 0.25 | ⏳ Not Started |

---

## Rules Already Current (No Updates Needed)

### 100% Accurate (25 files)
✅ nginx-cloudflare-proxy.md
✅ llm-date-handling.md
✅ crypto-random.md
✅ xml-date-parsing.md
✅ wrangler-r2.md
✅ sql-date-range-queries.md
✅ lucide-icons.md
✅ template-literals.md
✅ git-init-gitignore.md
✅ bash-scripts.md
✅ mcp-oauth-header-auth.md
✅ mcp-oauth-refresh-tokens.md
✅ cloudflare-workers.md
✅ cloudflare-workers-fetch.md
✅ cloudflare-workers-ai-prefixes.md
✅ cloudflare-vectorize.md
✅ css-tailwind.md
✅ github-oauth-api.md
✅ cloudflare-oauth-state.md
✅ private-repo-audit.md
✅ wordpress-troubleshooting.md
✅ mcp-server-homepage.md
✅ jezweb-email-triage.md
✅ build-verification.md (98%)
✅ snowflake-native-app.md (85% - minor)

---

## Accuracy Summary by Category

| Category | Files | Avg Accuracy | Priority |
|----------|-------|--------------|----------|
| Auth (Clerk, better-auth) | 2 | 70% | URGENT |
| AI Gateway | 2 | 78% | URGENT |
| Snowflake | 5 | 78% | HIGH |
| Build/Tooling | 6 | 94% | MEDIUM |
| Frontend/UI | 5 | 92% | MEDIUM |
| Database/ORM | 4 | 92% | MEDIUM |
| OAuth | 6 | 87% | LOW |
| Cloudflare Workers | 6 | 92% | MEDIUM |
| Misc | 8 | 87.5% | LOW |

---

## Detailed Action Items

### clerk-auth.md ✅ COMPLETE

**Changes Made** (2026-01-03):
1. [x] Add API v1 deprecation note (deprecated Apr 14, 2025)
2. [x] Add 1.2KB cookie size limit warning for custom claims
3. [x] Clarify JWT vs Session Token differences
4. [x] Note v2 (API 2025-04-10+) is required for @clerk/backend@2.x

---

### better-auth-vite.md ✅ COMPLETE

**Changes Made** (2026-01-03):
1. [x] Add ESM-only warning (CommonJS removed in v1.4)
2. [x] Add nodejs_compat requirement for Cloudflare Workers
3. [x] Document `advanced.generateId` → `advanced.database.generateId` migration
4. [x] Add BETTER_AUTH_SECRET and BETTER_AUTH_URL env var setup
5. [x] Note reactStartCookies → tanstackStartCookies rename

---

### ai-gateway-providers.md ✅ COMPLETE

**Changes Made** (2026-01-03):
1. [x] Expand provider table from 8 to 24 providers (complete list with categories)
2. [x] Add: cartesia, cerebras, elevenlabs, perplexity, fal, ideogram
3. [x] Add: huggingface, bedrock, azure-openai, baseten, parallel, replicate
4. [x] Add: deepgram, openrouter (GA), workers-ai, vertex
5. [x] Added reference link to Cloudflare docs

---

### cloudflare-ai-gateway.md ✅ COMPLETE

**Changes Made** (2026-01-03):
1. [x] Update BYOK section to reference Secrets Store (Aug 2025)
2. [x] Add Custom Providers section with `custom-{slug}` pattern
3. [x] Add Secrets Store prerequisites and alternatives (wrangler, API, dashboard)
4. [x] Add Dynamic Routing section (preferred over legacy request handling)

---

### vite-node.md ✅ COMPLETE

**Changes Made** (2026-01-03):
1. [x] Add `loadEnv()` as primary solution for Vite v6+
2. [x] Document static replacement behavior difference
3. [x] Mention `esm-env` for library mode
4. [x] Add Vite docs reference link

---

## Session Log

| Date | Session | Work Done | Next Steps |
|------|---------|-----------|------------|
| 2026-01-03 | Initial Audit | Launched 9 parallel rule audits, compiled findings | Start TIER 1 updates |
| 2026-01-03 | TIER 1 Updates | Completed all 5 TIER 1 rules (clerk-auth, better-auth-vite, vite-node, ai-gateway-providers, cloudflare-ai-gateway) | TIER 2 updates |

---

## Notes

- Auth rules (clerk, better-auth) have lowest accuracy - prioritize
- Snowflake rules have significant gaps due to 2025 feature releases (release channels, NAAPS)
- AI Gateway missing 67% of supported providers - quick fix
- Most Cloudflare Workers rules are current
- Skill-level rules (38 files) will be updated alongside parent skill updates

---

## Completion Criteria

- [x] All TIER 1 rules updated ✅ (2026-01-03)
- [ ] All TIER 2 rules updated
- [ ] No rule below 90% accuracy
- [ ] All deprecated patterns removed
- [ ] Version references current

---

## Cross-Reference: Skill Updates

Rules in `skills/*/rules/` are updated as part of skill updates. See:
- `planning/SKILL_UPDATES_JAN_2026.md` for skill-level rule tracking
- 38 skill-level rules will be updated with their parent skills

