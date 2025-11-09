# Gemini CLI Integration

**Status**: ✅ Production-Ready | v1.0.0 | Last Updated: 2025-11-09

Use Google Gemini CLI as an AI pair programmer within Claude Code workflows. Get second opinions, architectural advice, debugging help, and comprehensive code reviews using Gemini's 1M+ context window.

---

## Auto-Trigger Keywords

This skill should activate when Claude Code encounters these scenarios:

### Commands
- `gemini-coach` (bash wrapper for Gemini CLI)
- `/ask-gemini` (slash command)
- `gemini` (CLI tool)
- `gemini-2.5-flash`, `gemini-2.5-pro` (model names)

### Use Cases
- "second opinion"
- "consult Gemini"
- "peer review"
- "architectural decision"
- "stuck debugging" (after 2+ attempts)
- "security audit"
- "compare implementations"
- "model comparison"
- "Flash vs Pro"
- "1M context window"
- "large codebase analysis"

### Technologies
- Google Gemini
- Gemini CLI
- @google/gemini-cli
- AI pair programming
- AI-to-AI prompting

### Scenarios (Proactive)
- Major architectural decisions (D1 vs KV, Durable Objects vs Workflows, etc.)
- Security-sensitive code (auth, payments, data handling)
- Large refactors (5+ files, core architecture changes)
- Context approaching 70%+ full
- Unfamiliar technology stack
- Debugging failures (2+ attempts on same bug)

---

## When to Use

### ✅ Use This Skill When:

- [ ] User asks major architectural question ("Should I use D1 or KV for sessions?")
- [ ] Writing security-sensitive code (auth, payments, PII)
- [ ] Planning large refactor (5+ files or core architecture)
- [ ] Stuck debugging after 2+ failed attempts
- [ ] Context approaching 70%+ capacity, need full codebase analysis
- [ ] Unfamiliar with technology stack or library
- [ ] Need to compare two implementations (old vs new, alternative approaches)
- [ ] User explicitly requests Gemini consultation
- [ ] Want complementary perspective on critical decision
- [ ] Need 1M+ context window for comprehensive analysis

### ❌ Don't Use This Skill When:

- [ ] Simple questions answerable with Claude's knowledge
- [ ] Trivial code reviews (small, non-critical changes)
- [ ] Every single decision (reserve for critical scenarios)
- [ ] API rate limits exceeded
- [ ] No internet connection available

---

## Quick Example

**Scenario**: User asks "Should I use D1 or KV for session storage?"

**Claude's Workflow**:
```bash
# 1. Detect architectural decision
# 2. Inform user: "Consulting Gemini for second opinion..."

# 3. Get Gemini's perspective (Pro model)
gemini-coach architect "Should I use Cloudflare D1 or KV for session storage?
App has 1000-5000 DAU, sessions expire after 30 days, need remember me and
multi-device tracking." .

# 4. Synthesize both perspectives
# Claude: "Both viable, depends on priorities"
# Gemini Pro: "D1 recommended for strong consistency"

# 5. Present options with trade-offs
```

**User sees**:
```
Based on consultation with Gemini:

**Gemini's Recommendation (Pro)**: D1
- Strong consistency is critical for sessions
- SQL queries for multi-device tracking easier
- Avoid eventual consistency issues (KV 60s propagation)

**My Analysis**: Both are viable
- D1: Better for consistency, complex queries, multi-device
- KV: Better for edge caching, simple TTL expiry, performance

**Trade-offs**:
- D1: Slightly higher latency but consistent
- KV: Faster at edge but eventual consistency risk

**Recommendation**: For your requirements (multi-device tracking),
D1 is the safer choice due to consistency needs.

Would you like me to implement D1-based sessions?
```

---

## What You Get

### Installation Scripts
- `scripts/install-gemini-coach.sh` - Installs gemini-coach binary to ~/.local/bin/
- `scripts/setup-slash-command.sh` - Symlinks /ask-gemini to ~/.claude/commands/
- `scripts/test-connection.sh` - Verifies Gemini CLI is working

### Assets
- `assets/gemini-coach` - Bash wrapper script (v2.3.0) with preset prompts
- `assets/ask-gemini.md` - Slash command template for Claude Code

### Reference Documentation
- `references/gemini-experiments.md` - Complete test results and findings
- `references/models-guide.md` - Flash vs Pro comparison (performance, quality, use cases)
- `references/prompting-strategies.md` - AI-to-AI prompting best practices
- `references/helper-functions.md` - Complete command reference

### Commands & Functions
- `gemini-coach review` - Code review (bugs, security, performance)
- `gemini-coach debug` - Root cause analysis
- `gemini-coach architect` - Architecture advice (Pro model)
- `gemini-coach security` - Security audit
- `gemini-coach quick` - Fast question (no file context)
- `gemini-coach review-dir` - Review directory with context
- `gemini-coach project-review` - Whole codebase analysis
- `gemini-coach compare` - Compare two implementations
- `gemini-coach security-scan` - Comprehensive security audit (Pro model)

---

## Known Issues Prevented

Based on systematic testing and production use:

| Issue | Without Skill | With Skill | Severity |
|-------|---------------|------------|----------|
| gemini-2.5-flash-lite 404 error | Try flash-lite, get 404, debug why | Know it's not accessible via CLI, use flash instead | Medium |
| Pro model tool confusion | Pro tries to scan unintended directories | Use Flash for directory scanning, Pro for questions | Medium |
| Opposite recommendations | Get one perspective, might miss trade-offs | Get both Flash and Pro perspectives, understand priorities | High |
| Missing root cause | Fix symptoms, not underlying issue | Gemini identifies root cause vs symptoms | High |
| Security vulnerabilities | Miss vulnerabilities in auth code | Gemini Pro finds SQL injection, XSS, auth flaws with file:line | Critical |
| Architectural blind spots | Single perspective on critical decisions | Complementary perspectives (Claude + Gemini) | High |
| Context limit hit | Can't analyze entire codebase | Use Gemini's 1M context for full analysis | Medium |
| Outdated patterns | Use deprecated approaches | Gemini may have more recent training data | Medium |

**Total Errors Prevented**: 8+

---

## Token Efficiency

**Estimated Savings**: ~60-70%

### Without Skill
1. Try approach A → doesn't work (5k tokens)
2. Try approach B → partial success (5k tokens)
3. Research documentation (3k tokens)
4. Try approach C → finally works (5k tokens)
5. Discover security issue later (2k tokens)

**Total**: ~20k tokens, 30-60 minutes

### With Skill
1. Ask Gemini for architectural advice (2k tokens)
2. Get comprehensive comparison with trade-offs
3. Implement correct approach first try (5k tokens)
4. Run security scan before deployment (1k tokens)

**Total**: ~8k tokens, 10-15 minutes

**Savings**: ~12k tokens (60%), 20-45 minutes

---

## Installation

### Prerequisites

```bash
# 1. Install Gemini CLI
npm install -g @google/gemini-cli

# 2. Verify version (must be 0.13.0+)
gemini --version

# 3. Authenticate
gemini
# Follow authentication prompts
```

### Automatic Installation (Recommended)

```bash
cd /path/to/claude-skills/skills/gemini-cli-integration/

# Install gemini-coach binary
./scripts/install-gemini-coach.sh

# Setup /ask-gemini slash command
./scripts/setup-slash-command.sh

# Test installation
./scripts/test-connection.sh
```

### Manual Installation

```bash
# Copy gemini-coach to PATH
cp assets/gemini-coach ~/.local/bin/
chmod +x ~/.local/bin/gemini-coach

# Copy /ask-gemini command
cp assets/ask-gemini.md ~/.claude/commands/

# Test
gemini-coach quick "Test question"
```

---

## Quick Reference

### Basic Commands

```bash
# Quick question (no file context)
gemini-coach quick "Should I use D1 or KV?"

# Code review
gemini-coach review src/auth.ts

# Debug analysis
cat error.log | gemini-coach debug

# Architecture advice (Pro model)
gemini-coach architect "Best way to handle WebSockets?" .

# Security audit
gemini-coach security src/api/

# Compare implementations
gemini-coach compare ./old-auth.ts ./new-auth.ts

# Comprehensive security scan (Pro model)
gemini-coach security-scan ./src

# Whole project review
gemini-coach project-review "Review for bugs and security"
```

### From Claude Code Session

```
User: "/ask-gemini Should I use D1 or KV for sessions?"
User: "/ask-gemini architect: Best approach for WebSockets in Workers?"
User: "/ask-gemini review src/auth.ts for security vulnerabilities"
```

### Environment Variables

```bash
# Override default model (Flash)
GEMINI_MODEL=gemini-2.5-pro gemini-coach review src/auth.ts

# Use Pro for all commands
export GEMINI_MODEL=gemini-2.5-pro
```

---

## Model Selection Guide

### gemini-2.5-flash (Default)

**Use For**: Code reviews, debugging, directory scanning, general questions
**Speed**: ~5-25 seconds
**Quality**: ⭐⭐⭐⭐ (very good)
**Prioritizes**: Performance, simplicity, speed

### gemini-2.5-pro

**Use For**: Architecture decisions, security audits, complex reasoning
**Speed**: ~15-30 seconds (often similar to Flash!)
**Quality**: ⭐⭐⭐⭐⭐ (excellent)
**Prioritizes**: Correctness, consistency, thoroughness

### When They Disagree

Flash and Pro can give **opposite recommendations** for the same question (both can be valid!).

**Example**: D1 vs KV for sessions
- Flash: Recommends KV (performance-focused)
- Pro: Recommends D1 (consistency-focused)

**Solution**: Get both perspectives for critical decisions, understand trade-offs, choose based on your priorities.

---

## Proactive Consultation Patterns

Claude Code should **automatically** invoke Gemini in these scenarios (built into skill):

1. **Architectural Decision Detected**
   - Trigger: User asks "Should I use X or Y?"
   - Action: Auto-invoke `gemini-coach architect`
   - Result: Present both Claude's and Gemini's perspectives

2. **Stuck Debugging (2+ Attempts)**
   - Trigger: Same bug after 2 failed fixes
   - Action: Auto-invoke `gemini-coach debug`
   - Result: Fresh perspective on root cause

3. **Security-Sensitive Code**
   - Trigger: Implementing auth, payments, data handling
   - Action: Auto-invoke `gemini-coach security-scan` after implementation
   - Result: Catch vulnerabilities before deployment

4. **Context >70% Full**
   - Trigger: Context usage high, need full codebase analysis
   - Action: Auto-invoke `gemini-coach project-review`
   - Result: Use Gemini's 1M context for comprehensive analysis

5. **Large Refactor**
   - Trigger: Changes affecting 5+ files or core architecture
   - Action: Auto-invoke `gemini-coach architect` before starting
   - Result: Architectural review prevents issues

---

## Production Best Practices

### ✅ Do:

- Synthesize both Claude's and Gemini's perspectives (don't just return Gemini's response)
- Use Pro model for critical architectural decisions
- Mention which model was consulted (Pro vs Flash)
- Automatically invoke Gemini for critical scenarios (proactive)
- Compare models (Flash + Pro) for major decisions
- Use specific prompts ("Check for SQL injection in login" vs "Check this code")
- Run security scans before deploying auth/payments/data handling
- Store important Gemini analyses in docs/ for future reference
- Verify Gemini's recommendations against official docs

### ❌ Don't:

- Return Gemini's response directly without synthesis
- Use Gemini for trivial questions/reviews
- Overuse Gemini (reserve for critical scenarios)
- Trust Gemini blindly (verify recommendations)
- Use flash-lite model (not accessible via CLI)
- Use Pro for directory scanning (gets confused, use Flash instead)

---

## Example Workflow

**User**: "I need to implement JWT authentication"

**Claude (internal process)**:
```typescript
// 1. Detect security-sensitive code
const isSecuritySensitive = detect(["auth", "JWT"])

// 2. Implement feature
await implementJWTAuth()

// 3. Auto-invoke security scan
await sendMessage("Running security audit with Gemini...")
const findings = await geminiCoach.securityScan("./src/auth")

// 4. Review findings
/*
  - SQL injection (line 15)
  - Weak JWT secret (line 23)
  - No token expiration (line 28)
  - Password leaked in response (line 35)
  - Missing rate limiting
*/

// 5. Fix issues before user sees vulnerable code
await fixSecurityIssues(findings)

// 6. Inform user
await sendMessage(`
JWT auth implemented. Security audit identified and fixed 5 issues:
✅ SQL injection → Parameterized queries
✅ Weak secret → Strong random secret in env
✅ Token expiration → 1 hour expiry
✅ Password leak → Excluded from response
✅ Rate limiting → Implemented with KV

Ready to test!
`)
```

**User sees**: Secure implementation from the start, no vulnerabilities.

---

## Troubleshooting

### gemini-coach: command not found

```bash
# Check if file exists
ls -la ~/.local/bin/gemini-coach

# If missing, reinstall
./scripts/install-gemini-coach.sh

# Verify ~/.local/bin is in PATH
echo $PATH | grep ".local/bin"

# If not, add to ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"
source ~/.bashrc
```

### 404 Error

**Cause**: Trying to use `gemini-2.5-flash-lite` (not accessible via CLI)

**Fix**: Use `gemini-2.5-flash` or `gemini-2.5-pro` instead

### Not Authenticated

```bash
gemini
# Follow authentication prompts
```

### Outdated Gemini CLI

```bash
npm install -g @google/gemini-cli@latest
gemini --version  # Should be 0.13.0+
```

---

## File Structure

```
gemini-cli-integration/
├── SKILL.md                          # Main skill documentation (~2,000 lines)
├── README.md                         # This file
├── scripts/
│   ├── install-gemini-coach.sh       # Install binary
│   ├── setup-slash-command.sh        # Setup slash command
│   └── test-connection.sh            # Test installation
├── references/
│   ├── gemini-experiments.md         # Test results
│   ├── models-guide.md               # Flash vs Pro comparison
│   ├── prompting-strategies.md       # AI-to-AI prompting
│   └── helper-functions.md           # Command reference
└── assets/
    ├── gemini-coach                  # Bash wrapper (v2.3.0)
    └── ask-gemini.md                 # Slash command template
```

---

## References

- **Gemini CLI**: https://www.npmjs.com/package/@google/gemini-cli
- **Gemini API**: https://ai.google.dev/gemini-api/docs
- **Official Skill Spec**: https://github.com/anthropics/skills
- **Claude Code Docs**: https://docs.claude.com/en/docs/claude-code/skills

---

## Version History

**v1.0.0 (2025-11-09)**:
- Initial release
- gemini-coach v2.3.0 included
- Flash vs Pro comparison documented
- AI-to-AI prompting best practices
- 8+ known issues prevented
- Installation automation
- Comprehensive reference docs

---

## License

MIT License

---

**Maintained by**: Jeremy Dawes | Jezweb
**Last Updated**: 2025-11-09
**Production Tested**: Yes
**Gemini CLI Version**: 0.13.0+
**gemini-coach Version**: 2.3.0
