---
name: Gemini CLI Integration
description: |
  Production-tested guide for using Google Gemini CLI as a coding assistant within Claude Code workflows. Provides `gemini-coach` command-line wrapper and `/ask-gemini` slash command for getting second opinions, architectural advice, debugging help, code reviews, and security audits from Gemini's 1M+ context window.

  Use when: Need second opinion on architectural decisions, stuck debugging after 2+ attempts, writing security-sensitive code (auth, payments, data handling), planning large refactors (5+ files), approaching 70%+ context capacity, unfamiliar with technology stack, want to compare Flash vs Pro model recommendations, need comprehensive codebase analysis, or consulting Gemini for peer review on critical code changes.

  Keywords: gemini-cli, gemini-coach, /ask-gemini, google gemini, second opinion, model comparison, gemini-2.5-flash, gemini-2.5-pro, architectural decisions, debugging assistant, code review gemini, security audit gemini, 1M context window, AI pair programming, gemini consultation, flash vs pro, proactive gemini, gemini helper functions, AI-to-AI prompting, peer review, codebase analysis, gemini CLI wrapper, bash gemini integration, shell scripts gemini, command line AI assistant, gemini architecture advice, gemini debug help, gemini security scan, gemini code compare
license: MIT
metadata:
  version: 1.0.0
  production_tested: true
  gemini_coach_version: 2.3.0
  gemini_cli_version: 0.13.0+
  last_verified: 2025-11-08
  token_savings: ~60-70%
  errors_prevented: 8+
---

# Gemini CLI Integration

**Leverage Gemini's 1M+ context window as your AI pair programmer within Claude Code workflows.**

This skill teaches Claude Code how to use Google Gemini CLI via the `gemini-coach` bash wrapper and `/ask-gemini` slash command to get second opinions, architectural advice, debugging help, and comprehensive code reviews. Based on production testing and systematic experimentation.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [When to Use Gemini Consultation](#when-to-use-gemini-consultation)
3. [Installation](#installation)
4. [gemini-coach Command Reference](#gemini-coach-command-reference)
5. [/ask-gemini Slash Command](#ask-gemini-slash-command)
6. [Model Selection Guide: Flash vs Pro](#model-selection-guide-flash-vs-pro)
7. [Proactive Consultation Patterns](#proactive-consultation-patterns)
8. [AI-to-AI Prompting Best Practices](#ai-to-ai-prompting-best-practices)
9. [Common Use Cases](#common-use-cases)
10. [Helper Functions Deep Dive](#helper-functions-deep-dive)
11. [Integration Examples](#integration-examples)
12. [Troubleshooting & Known Issues](#troubleshooting--known-issues)
13. [Production Best Practices](#production-best-practices)

---

## Quick Start

**Prerequisites**:
- Gemini CLI installed (`npm install -g @google/gemini-cli`)
- Authenticated with Google account (`gemini` command)
- `gemini-coach` script in `~/.local/bin/` (provided in this skill)
- `/ask-gemini` command in `~/.claude/commands/` (provided in this skill)

**Fastest Way to Use**:
```bash
# Quick question (no file context)
gemini-coach quick "Should I use D1 or KV for session storage?"

# Code review with file context
gemini-coach review src/auth.ts

# Architecture advice (uses Pro model)
gemini-coach architect "Best way to handle WebSockets in Workers?" .

# Security audit (uses Pro model, thorough)
gemini-coach security-scan ./src/api/

# Compare two implementations
gemini-coach compare ./old-auth.ts ./new-auth.ts
```

**From within Claude Code session**:
```
User: "/ask-gemini Should I use D1 or KV for sessions?"
Claude: [Consults Gemini, synthesizes both perspectives, presents options]
```

---

## When to Use Gemini Consultation

### ALWAYS Consult (Critical Scenarios)

Claude Code should **automatically invoke Gemini** in these situations:

1. **Major Architectural Decisions**
   - Example: "Should I use D1 or KV for session storage?"
   - Example: "Durable Objects vs Workflows for long-running tasks?"
   - Why: Gemini provides complementary perspective, may prioritize different concerns

2. **Security-Sensitive Code Changes**
   - Authentication systems
   - Payment processing
   - Data handling (PII, sensitive data)
   - API key/secret management
   - Why: Gemini 2.5 Pro excels at security audits with file:line references

3. **Large Refactors**
   - Affecting 5+ files
   - Core architecture changes
   - Database schema migrations
   - Why: Gemini's 1M context can analyze entire codebase

4. **Unfamiliar Technologies**
   - First time using a library/framework
   - New API integration
   - Cloudflare service you haven't used
   - Why: Gemini may have more recent training data

### CONSIDER Consulting (Judgment Call)

1. **Stuck Debugging**
   - Same bug after 2+ failed attempts
   - Intermittent errors
   - Root cause unclear
   - Why: Fresh perspective, different reasoning approach

2. **Large Features**
   - Estimated implementation time >4 hours
   - Complex state management
   - Multi-component interactions
   - Why: Architectural review before implementation

3. **Context Approaching Limits**
   - Context >70% full
   - Need to analyze entire repository
   - Multiple related changes
   - Why: Gemini's 1M context handles larger codebases

4. **Tech Stack Gaps**
   - API/library not recently used
   - Deprecated patterns in knowledge
   - Breaking changes in framework
   - Why: Context7 + Gemini = most current patterns

---

## Installation

### Automatic Installation (Recommended)

Run the installation script from this skill:

```bash
cd /path/to/claude-skills/skills/gemini-cli-integration/
./scripts/install-gemini-coach.sh
./scripts/setup-slash-command.sh
./scripts/test-connection.sh
```

### Manual Installation

**Step 1: Install Gemini CLI**
```bash
npm install -g @google/gemini-cli
gemini --version  # Should be 0.13.0 or higher
```

**Step 2: Authenticate**
```bash
gemini
# Follow authentication prompts
```

**Step 3: Install gemini-coach Script**
```bash
cp assets/gemini-coach ~/.local/bin/
chmod +x ~/.local/bin/gemini-coach
```

**Step 4: Install /ask-gemini Slash Command**
```bash
cp assets/ask-gemini.md ~/.claude/commands/
```

**Step 5: Test Installation**
```bash
gemini-coach quick "Test question"
# Should return response from Gemini
```

---

## gemini-coach Command Reference

`gemini-coach` is a bash wrapper that simplifies Gemini CLI usage with preset prompts and helper functions.

### Basic Commands

#### `gemini-coach review [files...]`
**Purpose**: General code review for bugs, security, performance, best practices

**Prompt Used**:
```
[Claude Code consulting Gemini for peer review]

Task: Code review - check for bugs, logic errors, security vulnerabilities
(SQL injection, XSS, etc.), performance issues, best practice violations,
type safety problems, and missing error handling

Provide direct analysis with file:line references. I will synthesize your
findings with mine before presenting to the developer.
```

**Example**:
```bash
gemini-coach review src/auth.ts src/api/users.ts
```

**Model**: gemini-2.5-flash (default)
**Time**: ~5-25 seconds
**Output**: File:line references with specific issues

---

#### `gemini-coach debug [error-message]`
**Purpose**: Root cause analysis for debugging

**Prompt Used**:
```
[Claude Code consulting Gemini for peer review]

Task: Debug analysis - identify root cause (not just symptoms), explain why
it's happening, suggest specific fix with code example, and how to prevent
in future

Provide direct analysis with file:line references. I will synthesize your
findings with mine before presenting to the developer.
```

**Example**:
```bash
cat error.log | gemini-coach debug
# or
gemini-coach debug "TypeError: Cannot read properties of undefined"
```

**Model**: gemini-2.5-flash (sufficient for debugging)
**Time**: ~5-25 seconds
**Strength**: Identifies root cause vs symptoms

---

#### `gemini-coach architect [question] [path]`
**Purpose**: Architecture advice with Pro model

**Prompt Used**:
```
[Claude Code consulting Gemini for peer review]

Task: Architecture advice - analyze for architectural anti-patterns,
scalability concerns, maintainability issues, better alternatives, and
potential technical debt

Provide direct analysis with specific, actionable recommendations and
rationale. I will synthesize your findings with mine before presenting
to the developer.
```

**Example**:
```bash
gemini-coach architect "Should I use D1 or KV for sessions?" .
gemini-coach architect "Best way to handle WebSockets in Workers?" ./src
```

**Model**: gemini-2.5-pro (better reasoning)
**Time**: ~15-30 seconds
**Strength**: Thorough trade-off analysis

---

#### `gemini-coach security [files...]`
**Purpose**: Security audit

**Prompt Used**:
```
[Claude Code consulting Gemini for peer review]

Task: Security audit - identify SQL injection vulnerabilities, XSS/CSRF risks,
authentication/authorization flaws, insecure data handling, exposed secrets or
credentials, insufficient input validation, and missing rate limiting

Provide direct analysis with file:line references, how to exploit, and how
to fix. I will synthesize your findings with mine before presenting to the
developer.
```

**Example**:
```bash
gemini-coach security src/auth/ src/api/
```

**Model**: gemini-2.5-flash (comprehensive)
**Time**: ~5-25 seconds

---

#### `gemini-coach quick "[question]"`
**Purpose**: Fast question with no file context

**Example**:
```bash
gemini-coach quick "Difference between D1 and KV?"
gemini-coach quick "Best way to handle file uploads in Workers?"
```

**Model**: gemini-2.5-flash
**Time**: ~5-15 seconds
**Use When**: No file context needed, just quick answer

---

### Helper Functions

#### `gemini-coach review-dir "[prompt]" /path`
**Purpose**: Review directory with full context

**Example**:
```bash
gemini-coach review-dir "Check for security issues" ./src/api
gemini-coach review-dir "Analyze architecture" .
```

**Model**: gemini-2.5-flash (default), or specify with 3rd argument
**Context**: Includes all files in directory (uses `--include-directories`)

---

#### `gemini-coach project-review "[prompt]" [/path]`
**Purpose**: Review entire project (current dir by default)

**Example**:
```bash
gemini-coach project-review "Review for bugs and security issues"
gemini-coach project-review "Analyze architecture and suggest improvements" ~/my-project
```

**Model**: gemini-2.5-flash
**Context**: Entire codebase
**Time**: Varies by project size (~15-60s)

---

#### `gemini-coach compare /path1 /path2`
**Purpose**: Compare two implementations

**Prompt Used**:
```
[Claude Code consulting Gemini for peer review]

Task: Compare two implementations - analyze key differences in approach,
pros and cons of each, which is better for different use cases, and any
missing features in either

Provide direct analysis with specific comparisons. I will synthesize your
findings with mine before presenting to the developer.
```

**Example**:
```bash
gemini-coach compare ./auth-jwt.ts ./auth-d1-sessions.ts
gemini-coach compare ./old-api/ ./new-api/
```

**Model**: gemini-2.5-flash
**Output**: Side-by-side comparison with trade-offs

---

#### `gemini-coach security-scan [/path]`
**Purpose**: Comprehensive security audit (uses Pro model)

**Example**:
```bash
gemini-coach security-scan ./src/api
gemini-coach security-scan .  # Entire project
```

**Model**: gemini-2.5-pro (thorough analysis)
**Time**: ~15-30 seconds
**Output**: Vulnerabilities with exploit details and fixes

---

### Environment Variables

```bash
# Override default model
GEMINI_MODEL=gemini-2.5-pro gemini-coach review src/auth.ts

# Use Pro for all commands
export GEMINI_MODEL=gemini-2.5-pro
gemini-coach review src/auth.ts
```

---

## /ask-gemini Slash Command

The `/ask-gemini` slash command allows manual Gemini consultation from within Claude Code sessions.

### Usage

```
User: "/ask-gemini [question or task]"
Claude: [Executes gemini-coach command, returns result]
```

### Examples

**Quick Question**:
```
User: "/ask-gemini Should I use D1 or KV for session storage?"
```

**Code Review**:
```
User: "/ask-gemini review src/auth.ts for security vulnerabilities"
```

**Architecture Advice**:
```
User: "/ask-gemini architect: Best way to handle WebSockets in Cloudflare Workers?"
```

**Custom Prompt**:
```
User: "/ask-gemini What are the trade-offs between Durable Objects and Workflows for long-running tasks?"
```

### How It Works

1. User invokes `/ask-gemini [prompt]`
2. Claude Code executes appropriate `gemini-coach` command
3. Gemini analyzes and responds
4. Claude synthesizes both perspectives (Claude's + Gemini's)
5. Claude presents options to user with both viewpoints

---

## Model Selection Guide: Flash vs Pro

Based on systematic testing (see `references/gemini-experiments.md`), here's when to use each model:

### gemini-2.5-flash (Default)

**Use For**:
- Code reviews
- Debugging (root cause analysis is strong)
- Directory scanning (safer, less likely to use tools aggressively)
- General questions
- When speed matters

**Characteristics**:
- Fast (~5-25 seconds, varies by complexity)
- Good quality for most tasks
- Prioritizes: Performance, simplicity, speed
- Works well with directory context
- Less likely to get confused with file scanning

**Performance**:
- Response time: ~5-25 seconds (tested average: ~20s)
- Quality: ⭐⭐⭐⭐ (very good)
- Cost: Lower

---

### gemini-2.5-pro

**Use For**:
- Architecture decisions (critical)
- Security audits (thorough)
- Complex reasoning tasks
- When accuracy > speed
- Major refactoring plans

**Characteristics**:
- More thorough (~15-30 seconds)
- Better trade-off analysis
- Prioritizes: Correctness, consistency, thoroughness
- May try to use tools when given directory context (can cause issues)
- Provides comparison tables and structured analysis

**Performance**:
- Response time: ~15-30 seconds (tested average: ~23s, often similar to Flash!)
- Quality: ⭐⭐⭐⭐⭐ (excellent)
- Cost: Higher

---

### gemini-2.5-flash-lite

**Status**: ❌ **Not accessible via Gemini CLI**

The model exists in the Gemini API but returns 404 error when accessed via Gemini CLI tool. Do not attempt to use this model.

---

### When Flash vs Pro Give Different Advice

**Critical Finding from Testing**: Flash and Pro can give **opposite recommendations** for the same question, and **both can be valid**.

**Example** (D1 vs KV for sessions):
- **Flash**: Recommends KV (performance-focused, emphasizes edge caching, TTL)
- **Pro**: Recommends D1 (consistency-focused, emphasizes strong consistency, SQL queries)

**Why This Happens**:
- Flash prioritizes: Performance, simplicity, "usually acceptable" trade-offs
- Pro prioritizes: Correctness, consistency, "critical" requirements

**How to Handle**:
1. For critical/security decisions → Prefer Pro's perspective
2. For performance-sensitive apps → Consider Flash's perspective
3. For major architectural choices → Get both viewpoints:
   ```bash
   # Get Flash perspective
   gemini-coach quick "Should I use D1 or KV for sessions?"

   # Get Pro perspective
   GEMINI_MODEL=gemini-2.5-pro gemini-coach architect "Should I use D1 or KV for sessions?" .
   ```
4. Present both options to user with clear trade-offs

**Recommendation**: Use Pro for architecture decisions, but understand that Flash's alternative may be valid for different priorities.

---

## Proactive Consultation Patterns

Claude Code should **automatically** invoke Gemini in these scenarios (don't wait for user to ask):

### Pattern 1: Architectural Decision Detected

**Trigger**: User asks architecture question or mentions technology choice

**Example**:
```
User: "Should I use D1 or KV for session storage?"

Claude (internal):
  1. Detect architectural decision
  2. Automatically invoke: gemini-coach architect "..."
  3. Synthesize both perspectives
  4. Present options with trade-offs

Claude: "I'm consulting Gemini for a second opinion on this architectural decision..."

[Shows both Claude's and Gemini's perspectives with clear trade-offs]
```

---

### Pattern 2: Stuck on Same Bug (2+ Attempts)

**Trigger**: Same error after 2 failed debugging attempts

**Example**:
```
User: "Still getting TypeError after your fix..."

Claude (internal):
  1. Detect repeated debugging failure
  2. Invoke: gemini-coach debug "..."
  3. Get fresh perspective

Claude: "This bug is persistent. Let me consult Gemini for a different perspective on the root cause..."

[Presents Gemini's root cause analysis]
```

---

### Pattern 3: Security-Sensitive Code

**Trigger**: Working on auth, payments, data handling, API keys

**Example**:
```
User: "Implement JWT authentication"

Claude (internal):
  1. Detect security-sensitive code
  2. After implementation, invoke: gemini-coach security-scan ./src/auth
  3. Review security findings

Claude: "I've implemented JWT auth. Let me run a security audit with Gemini to check for vulnerabilities..."

[Shows security findings, addresses issues]
```

---

### Pattern 4: Context >70% Full

**Trigger**: Context usage high, need entire codebase analysis

**Example**:
```
User: "Review the entire application for bugs"

Claude (internal):
  1. Detect context limit approaching
  2. Invoke: gemini-coach project-review "..."
  3. Use Gemini's 1M context

Claude: "My context is getting full. I'm using Gemini's 1M context window to analyze the entire codebase..."

[Returns comprehensive analysis]
```

---

### Pattern 5: Large Refactor

**Trigger**: Changes affecting 5+ files or core architecture

**Example**:
```
User: "Refactor to use Hono instead of Itty Router"

Claude (internal):
  1. Detect large refactor
  2. Invoke: gemini-coach architect "Review refactor plan" .
  3. Get architectural review before starting

Claude: "This is a significant refactor. Let me consult Gemini on the architectural approach before we start..."

[Shows architectural review, potential issues]
```

---

### Proactive Workflow Template

```typescript
// Pseudo-code for Claude's internal logic

if (isArchitecturalDecision(userMessage)) {
  informUser("Consulting Gemini for second opinion...")
  geminiPerspective = await geminiCoach.architect(question, context)
  claudePerspective = await analyzeArchitecture(question, context)
  presentBothPerspectives(claudePerspective, geminiPerspective)
  askUserToDecide()
}

if (stuckOnBugForNAttempts(2)) {
  informUser("Getting fresh debugging perspective from Gemini...")
  geminiAnalysis = await geminiCoach.debug(errorMessage, context)
  revisitDebuggingWithNewPerspective(geminiAnalysis)
}

if (isSecuritySensitiveCode(codeType)) {
  informUser("Running security audit with Gemini...")
  securityFindings = await geminiCoach.securityScan(codePath)
  addressSecurityIssues(securityFindings)
}

if (contextUsage > 0.7) {
  informUser("Using Gemini's 1M context for full codebase analysis...")
  fullAnalysis = await geminiCoach.projectReview(prompt, projectPath)
  return fullAnalysis
}

if (isLargeRefactor(changes)) {
  informUser("Consulting Gemini on refactor architecture...")
  refactorReview = await geminiCoach.architect(refactorPlan, context)
  reviewRefactorPlanWithGemini(refactorReview)
}
```

---

## AI-to-AI Prompting Best Practices

All `gemini-coach` commands use **AI-to-AI prompting format** (Option B from testing):

### Format Structure

```
[Claude Code consulting Gemini for peer review]

Task: [Specific task description]

Provide direct analysis with file:line references. I will synthesize your
findings with mine before presenting to the developer.
```

### Why This Format Works

**Benefits** (from systematic testing):
1. **Prevents Role Confusion**: Gemini knows it's advising Claude, not the human developer
2. **Reduces Chattiness**: More direct, less "helpful assistant" framing
3. **Better Output**: File:line references, concrete suggestions
4. **Peer Review Dynamic**: Two AI systems collaborating, not AI → human

**Comparison to Old Format**:

❌ **Old Format** (less effective):
```
You're an expert security researcher. Review this code for vulnerabilities...
```
- More verbose framing
- "Helpful assistant" tone
- Slightly chattier responses

✅ **New Format** (recommended):
```
[Claude Code consulting Gemini for peer review]

Task: Security review - identify vulnerabilities...

Provide direct analysis. I will synthesize findings before presenting to developer.
```
- Clear AI-to-AI context
- Direct task description
- Concise, actionable output

---

### Custom Prompt Template

When creating custom prompts, follow this template:

```bash
gemini "[Claude Code consulting Gemini for peer review]

Task: [Your specific task here - be concrete and specific]

Provide direct analysis with [file:line references / code examples / specific recommendations]. I will synthesize your findings with mine before presenting to the developer." --yolo -m gemini-2.5-flash
```

**Key Elements**:
1. `[Claude Code consulting Gemini for peer review]` - Establishes AI-to-AI context
2. `Task:` - Clear, specific task description
3. `Provide direct analysis with...` - What format you want
4. `I will synthesize...` - Explains workflow (Gemini → Claude → User)

---

## Common Use Cases

### Use Case 1: Architectural Decision

**Scenario**: Choosing between D1 and KV for session storage

**Workflow**:
```bash
# Get both perspectives
gemini-coach quick "D1 vs KV for sessions with 1000-5000 DAU, 30-day expiry, remember me, multi-device tracking?"

GEMINI_MODEL=gemini-2.5-pro gemini-coach architect "Same question" .

# Compare recommendations
# Flash: May recommend KV (performance)
# Pro: May recommend D1 (consistency)

# Present both to user with trade-offs
```

**Output**: Both perspectives, clear trade-offs, user decides based on priorities

---

### Use Case 2: Debugging Root Cause

**Scenario**: `TypeError: Cannot read properties of undefined (reading 'name')`

**Workflow**:
```bash
cat buggy-code.ts | gemini-coach debug "TypeError: Cannot read properties of undefined (reading 'name'). Happens randomly on /api/products/:id endpoint."
```

**Expected Analysis** (from testing):
1. Identifies root cause: `result.category` is string or null, not object
2. Explains why: Database schema stores category name directly
3. Provides specific fix with code example
4. Prevention strategies (type safety, optional chaining, tests)

---

### Use Case 3: Security Audit

**Scenario**: Review authentication code before deployment

**Workflow**:
```bash
# Comprehensive security scan with Pro model
gemini-coach security-scan ./src/auth

# Or specific files with Flash
gemini-coach security src/auth.ts src/api/users.ts
```

**Expected Findings** (from testing):
- SQL injection vulnerabilities with file:line
- XSS/CSRF risks
- Authentication flaws
- Insecure data handling
- Exposed secrets
- Missing input validation
- Missing rate limiting

**Output Format**:
```
File: `src/auth.ts`

1. **SQL Injection Vulnerability**
   - Line 15-17: `db.prepare(\`SELECT * FROM users WHERE email = '${email}'\`)`
   - Vulnerability: User input directly interpolated into SQL query
   - Exploit: `email = "'; DROP TABLE users; --"`
   - Fix: Use parameterized queries: `.prepare('SELECT * FROM users WHERE email = ?').bind(email)`
```

---

### Use Case 4: Comparing Implementations

**Scenario**: Compare JWT-based auth vs D1 session-based auth

**Workflow**:
```bash
gemini-coach compare ./auth-jwt.ts ./auth-d1-sessions.ts
```

**Expected Output**:
- Key differences in approach
- Pros/cons of each
- Which is better for different use cases
- Missing features in either implementation

---

### Use Case 5: Whole Project Review

**Scenario**: Context approaching limit, need full codebase analysis

**Workflow**:
```bash
cd ~/my-project
gemini-coach project-review "Review for bugs, security issues, and performance problems"
```

**Benefits**:
- Gemini's 1M context handles entire codebase
- Comprehensive analysis across files
- Identifies patterns and architectural issues
- Saves Claude's context for synthesis and fixes

---

## Helper Functions Deep Dive

### gemini-quick()

**Source** (`gemini-coach` line 53-57):
```bash
gemini-quick() {
  local prompt="$1"
  show_model_info "$DEFAULT_MODEL"
  gemini "$prompt" --yolo -m "$DEFAULT_MODEL" 2>&1 | grep -v "^Loaded\|^YOLO\|^Data collection"
}
```

**Purpose**: Fast answers without file context

**When to Use**:
- Quick questions
- No file analysis needed
- Comparing technologies
- Best practices

**Example**:
```bash
gemini-coach quick "Best way to handle file uploads in Cloudflare Workers?"
```

---

### gemini-review()

**Source** (`gemini-coach` line 61-81):
```bash
gemini-review() {
  local prompt="$1"
  local dir="${2:-.}"
  local model="${3:-$DEFAULT_MODEL}"

  # Resolve to absolute path
  dir=$(cd "$dir" 2>/dev/null && pwd || echo "$dir")

  if [ ! -d "$dir" ] && [ ! -f "$dir" ]; then
    echo "Error: Path not found: $dir" >&2
    return 1
  fi

  show_model_info "$model"

  # Run from /tmp to avoid including CWD in context
  (cd /tmp && gemini "$prompt" \
    --include-directories "$dir" \
    --yolo \
    -m "$model" 2>&1 | grep -v "^Loaded\|^YOLO\|^Data collection")
}
```

**Purpose**: Review with directory/file context

**Key Feature**: Runs from `/tmp` to avoid polluting context with CWD files

**When to Use**:
- Directory-based reviews
- Need file context
- Analyzing related files

**Example**:
```bash
gemini-coach review-dir "Check for security issues" ./src/api
```

---

### gemini-architect()

**Source** (`gemini-coach` line 84-88):
```bash
gemini-architect() {
  local prompt="$1"
  local dir="${2:-.}"
  gemini-review "$prompt" "$dir" "$DEFAULT_PRO_MODEL"
}
```

**Purpose**: Architecture advice with Pro model

**Key Feature**: Always uses Pro model for better reasoning

**When to Use**:
- Architectural decisions
- Technology choices
- Refactoring plans
- Scalability concerns

**Example**:
```bash
gemini-coach architect "Should I use Durable Objects or Workflows?" .
```

---

### gemini-compare()

**Source** (`gemini-coach` line 103-153):
```bash
gemini-compare() {
  local path1="$1"
  local path2="$2"

  # Validation and path resolution...

  show_model_info "$DEFAULT_MODEL"

  echo "Comparing:" >&2
  echo "  1) $path1" >&2
  echo "  2) $path2" >&2

  (cd /tmp && gemini "[Claude Code consulting Gemini for peer review]

Task: Compare two implementations - analyze key differences in approach,
pros and cons of each, which is better for different use cases, and any
missing features in either

Provide direct analysis with specific comparisons. I will synthesize your
findings with mine before presenting to the developer." \
    --include-directories "$path1" \
    --include-directories "$path2" \
    --yolo \
    -m "$DEFAULT_MODEL" 2>&1 | grep -v "^Loaded\|^YOLO\|^Data collection")
}
```

**Purpose**: Compare two implementations side-by-side

**Key Feature**: Includes both paths in context for direct comparison

**When to Use**:
- Comparing old vs new implementation
- Evaluating refactors
- Choosing between approaches

**Example**:
```bash
gemini-coach compare ./auth-v1 ./auth-v2
```

**Expected Output**:
- Approach differences
- Pros/cons of each
- Use case recommendations
- Missing features

---

### gemini-security-scan()

**Source** (`gemini-coach` line 156-171):
```bash
gemini-security-scan() {
  local target="${1:-.}"

  echo "🔒 Security Scan: $target" >&2
  echo "Using gemini-2.5-pro for thorough analysis" >&2

  gemini-review \
    "[Claude Code consulting Gemini for comprehensive security audit]

Task: Security audit - identify SQL injection vulnerabilities, XSS/CSRF risks,
authentication/authorization flaws, insecure data handling, exposed secrets or
credentials, insufficient input validation, missing rate limiting, insecure
dependencies, and improper error handling

Provide direct analysis with file:line references, how to exploit, and how to
fix. I will synthesize your findings with mine before presenting to the developer." \
    "$target" \
    "$DEFAULT_PRO_MODEL"
}
```

**Purpose**: Comprehensive security audit with Pro model

**Key Feature**: Uses Pro model for thorough analysis, includes exploit details

**When to Use**:
- Before deployment
- After implementing auth/payments
- Security-sensitive code changes
- Compliance reviews

**Example**:
```bash
gemini-coach security-scan ./src/api
```

---

## Integration Examples

### Example 1: Claude Detects Architectural Decision

**User Message**:
```
"I need to store user sessions. Should I use D1 or KV?"
```

**Claude's Internal Process**:
```typescript
// 1. Detect architectural decision
const isArchitecturalDecision = detectPattern(userMessage)

// 2. Inform user
await sendMessage("🤔 This is an important architectural decision. Let me consult Gemini for a second opinion...")

// 3. Get Gemini's perspective (Pro model for architecture)
const geminiPerspective = await executeCommand(`
  gemini-coach architect "Should I use Cloudflare D1 or KV for session storage?
  The app will have moderate traffic (1000-5000 DAU), sessions need to expire
  after 30 days of inactivity, and I need to support 'remember me' and
  multi-device login tracking." .
`)

// 4. Analyze with Claude's perspective
const claudePerspective = analyzeSessionStorage({
  traffic: "1000-5000 DAU",
  expiry: "30 days inactivity",
  features: ["remember me", "multi-device tracking"]
})

// 5. Synthesize both perspectives
const synthesis = {
  gemini: {
    recommendation: "D1",
    reasoning: "Strong consistency critical for sessions, SQL queries for multi-device tracking",
    tradeoffs: "Slightly higher latency than KV"
  },
  claude: {
    recommendation: "D1 or KV depending on priorities",
    reasoning: "Both valid, depends on consistency vs performance priorities",
    tradeoffs: "D1: consistency. KV: edge caching, TTL"
  }
}

// 6. Present options
await sendMessage(`
Based on consultation with Gemini, here are the perspectives:

**Gemini's Recommendation (Pro)**: D1
- Strong consistency is critical for session management
- SQL queries make multi-device tracking easier
- Avoid eventual consistency issues (KV has 60s propagation)

**My Analysis**: Both are viable
- D1: Better for consistency, multi-device queries, complex session data
- KV: Better for edge caching, simple TTL-based expiry, performance

**Trade-offs**:
- D1: Slightly higher latency but consistent
- KV: Faster at edge but eventual consistency risk

**Recommendation**: For your requirements (multi-device tracking, remember me),
**D1 is the safer choice** due to consistency needs.

Would you like me to:
1. Implement D1-based sessions
2. Implement KV-based sessions (if performance > consistency)
3. Show comparison code for both approaches
`)
```

---

### Example 2: Stuck on Bug After 2 Attempts

**Scenario**:
```
User: "Still getting TypeError after your fix..."
```

**Claude's Internal Process**:
```typescript
// 1. Detect repeated debugging failure
const attemptCount = getDebugAttempts(currentIssue)
if (attemptCount >= 2) {

  // 2. Inform user
  await sendMessage("This bug is persistent. Let me consult Gemini for a different perspective on the root cause...")

  // 3. Get Gemini's debug analysis
  const errorContext = gatherErrorContext({
    errorMessage: "TypeError: Cannot read properties of undefined (reading 'name')",
    code: readFile("src/api/products.ts"),
    previousAttempts: [attempt1, attempt2]
  })

  const geminiAnalysis = await executeCommand(`
    cat src/api/products.ts | gemini-coach debug "${errorContext.errorMessage}"
  `)

  // 4. Analyze Gemini's findings
  /*
   Gemini identified:
   - Root cause: result.category is string, not object
   - Why: Database schema stores category name directly
   - Fix: result.category (not result.category.name)
   - Prevention: Type safety, optional chaining
   */

  // 5. Implement fix based on fresh perspective
  await sendMessage(`
Gemini identified a different root cause:

**The Issue**: \`result.category\` is a string (category name), not an object.

**Why**: The D1 query selects all columns from the \`products\` table, where
\`category\` is stored as a string (the category name), not a reference to a
category object.

**Fix**:
\`\`\`typescript
return c.json({
  id: result.id,
  name: result.name,
  price: result.price,
  description: result.description,
  category: result.category  // Already a string, not an object
})
\`\`\`

**Prevention**:
1. Add TypeScript interface for query results
2. Use optional chaining: \`result.category?.name ?? result.category\`
3. Check database schema vs. code expectations

Let me implement this fix...
  `)
}
```

---

### Example 3: Security-Sensitive Code

**User Message**:
```
"Implement JWT authentication for the API"
```

**Claude's Internal Process**:
```typescript
// 1. Detect security-sensitive code
const isSecuritySensitive = detectPattern(userMessage, ["auth", "JWT", "authentication"])

// 2. Implement feature
await implementJWTAuth()

// 3. Run security audit automatically
await sendMessage("I've implemented JWT authentication. Let me run a security audit with Gemini to check for vulnerabilities...")

const securityFindings = await executeCommand(`
  gemini-coach security-scan ./src/auth
`)

// 4. Review findings
/*
  Gemini found:
  - Weak JWT secret
  - No token expiration
  - Missing rate limiting
  - Password leaked in response
*/

// 5. Address security issues
await sendMessage(`
Security audit complete. Gemini identified 4 issues:

1. ❌ **Weak JWT Secret** (src/auth.ts:15)
   - Current: \`"secret"\` (hardcoded)
   - Fix: Use \`crypto.randomBytes(32).toString('hex')\` stored in env

2. ❌ **No Token Expiration** (src/auth.ts:23)
   - Tokens never expire (security risk)
   - Fix: Add \`exp: Date.now() + 3600000\` (1 hour)

3. ❌ **Missing Rate Limiting** (src/auth.ts:10)
   - Allows brute force attacks
   - Fix: Implement rate limiting with KV

4. ❌ **Password in Response** (src/auth.ts:28)
   - Returns full user object including password hash
   - Fix: Exclude password from response

Let me fix these issues before we proceed...
`)

await fixSecurityIssues(securityFindings)
```

---

## Troubleshooting & Known Issues

### Issue 1: 404 Error with flash-lite Model

**Error**:
```
Error when talking to Gemini API
[API Error: {
  "error": {
    "code": 404,
    "message": "Requested entity was not found."
  }
}]
```

**Cause**: `gemini-2.5-flash-lite` exists in Gemini API but not accessible via Gemini CLI

**Fix**: Do not use flash-lite. Use `gemini-2.5-flash` or `gemini-2.5-pro` instead

**Status**: Documented in gemini-coach v2.3.0, removed from available models

---

### Issue 2: Pro Model Gets Confused with Directory Scanning

**Symptom**: When using `gemini-coach security-scan` with Pro model, Gemini tries to use `codebase_investigator` tool and scans unintended directories

**Example**:
```bash
gemini-coach security-scan /tmp/test-auth-code.ts
# Pro model tries to scan entire /tmp directory
# Returns: [WARN] Skipping unreadable directory...
# GrepLogic: ripgrep failed: Permission denied
```

**Cause**: Pro model is more aggressive about using tools when given directory/file context

**Workaround**:
- Use Flash model for directory scanning tasks
- Use Pro for specific questions or architecture advice (not directory scanning)

**Status**: Known limitation, documented in v2.3.0

---

### Issue 3: Gemini CLI Not Authenticated

**Error**:
```
Error: Not authenticated. Run 'gemini' to authenticate.
```

**Cause**: Gemini CLI not authenticated with Google account

**Fix**:
```bash
gemini
# Follow authentication prompts
```

**Verify**:
```bash
gemini-coach quick "Test question"
# Should return response
```

---

### Issue 4: Outdated Gemini CLI Version

**Error**:
```
Error: --include-directories not recognized
```

**Cause**: Gemini CLI version < 0.13.0

**Fix**:
```bash
npm install -g @google/gemini-cli@latest
gemini --version
# Should be 0.13.0 or higher
```

**Required Version**: 0.13.0+ (for `--include-directories` support)

---

### Issue 5: gemini-coach Command Not Found

**Error**:
```bash
gemini-coach: command not found
```

**Cause**: Script not in PATH or not executable

**Fix**:
```bash
# Check if file exists
ls -la ~/.local/bin/gemini-coach

# If missing, copy from skill assets
cp /path/to/skill/assets/gemini-coach ~/.local/bin/

# Make executable
chmod +x ~/.local/bin/gemini-coach

# Verify ~/.local/bin is in PATH
echo $PATH | grep ".local/bin"

# If not in PATH, add to ~/.bashrc or ~/.zshrc:
export PATH="$HOME/.local/bin:$PATH"
source ~/.bashrc
```

---

### Issue 6: Rate Limit Exceeded

**Error**:
```
Error: Rate limit exceeded. Try again later.
```

**Cause**: Too many Gemini API requests in short time

**Fix**:
- Wait 1-5 minutes before retrying
- Use Flash model (lower cost, higher quota)
- Check Gemini API usage limits

---

### Issue 7: Context Too Large for Gemini

**Symptom**: Timeout or truncated responses when analyzing very large codebases

**Workaround**:
- Break analysis into smaller chunks
- Review specific directories instead of entire project
- Use `--max-tokens` if supported in future Gemini CLI versions

**Status**: Rare, but possible with very large projects (>1M tokens)

---

## Production Best Practices

### Best Practice 1: Always Synthesize Perspectives

❌ **Don't**: Return Gemini's response directly to user

✅ **Do**: Synthesize Claude's and Gemini's perspectives

**Example**:
```
User: "Should I use D1 or KV?"

❌ Bad:
"Gemini says: Use D1 because..."

✅ Good:
"I consulted Gemini for a second opinion:

**Gemini's Recommendation**: D1
- Strong consistency is critical
- SQL queries for multi-device tracking

**My Analysis**: Both are viable
- D1: Better for consistency
- KV: Better for edge performance

**Trade-offs**: [comparison table]

Based on your requirements (multi-device tracking), I recommend D1."
```

---

### Best Practice 2: Use Pro for Critical Decisions

For these scenarios, **always use Pro model**:
- Architecture decisions
- Security audits
- Major refactors
- Production deployment reviews

**Why**: Pro provides more thorough analysis, better trade-off reasoning

**How**:
```bash
GEMINI_MODEL=gemini-2.5-pro gemini-coach architect "..." .
```

---

### Best Practice 3: Document Model Used

When presenting Gemini's analysis, **mention which model was consulted**:

```
"I consulted Gemini 2.5 Pro for architectural advice..."
"Gemini Flash identified these security issues..."
```

**Why**: Helps user understand quality/depth of analysis

---

### Best Practice 4: Proactive Consultation

**Don't wait** for user to ask for Gemini consultation. **Automatically invoke** for:
- Architectural decisions
- Security-sensitive code
- Stuck debugging (2+ attempts)
- Large refactors

**Inform user**: "Consulting Gemini for second opinion..."

---

### Best Practice 5: Compare Models for Major Decisions

For critical architectural decisions, **get both perspectives**:

```bash
# Flash perspective
gemini-coach quick "Should I use D1 or KV for sessions?"

# Pro perspective
GEMINI_MODEL=gemini-2.5-pro gemini-coach architect "Same question" .

# Present both, explain differences
```

**Why**: Flash and Pro may prioritize different concerns (both valid)

---

### Best Practice 6: Use Specific Prompts

❌ **Vague**: `gemini-coach review "Check this code"`

✅ **Specific**: `gemini-coach review "Check for SQL injection, XSS, and auth flaws in login endpoint"`

**Why**: Specific prompts get better, more focused analysis

---

### Best Practice 7: Run Security Scans Before Deployment

**Always** run security scan before deploying:
- Authentication changes
- Payment processing
- Data handling updates
- API endpoints

```bash
gemini-coach security-scan ./src
```

**Why**: Catches vulnerabilities Claude might miss

---

### Best Practice 8: Store Gemini Findings

Save important Gemini analyses for future reference:

```bash
gemini-coach architect "Should I use D1 or KV for sessions?" . > docs/architecture-decisions/sessions.md
```

**Why**: Architectural decisions are documented, can be revisited

---

### Best Practice 9: Don't Overuse Gemini

**Use Gemini for**:
- Critical decisions
- Security reviews
- Complex debugging
- Large refactors

**Don't use Gemini for**:
- Simple questions (use Claude's knowledge)
- Trivial code reviews
- Every single decision

**Why**: Saves API costs, faster workflow

---

### Best Practice 10: Verify Gemini's Recommendations

**Always verify** Gemini's suggestions:
- Check against official documentation
- Test recommended code
- Use Context7 MCP for current API references

**Why**: Gemini can be wrong, especially for cutting-edge APIs

---

## References

- **Gemini CLI Documentation**: https://www.npmjs.com/package/@google/gemini-cli
- **Gemini API Documentation**: https://ai.google.dev/gemini-api/docs
- **Model Comparison**: See `references/models-guide.md`
- **Experiment Results**: See `references/gemini-experiments.md`
- **Prompting Strategies**: See `references/prompting-strategies.md`
- **Helper Functions**: See `references/helper-functions.md`

---

## Installation Files

**Assets** (in this skill):
- `assets/gemini-coach` - Main bash wrapper script (v2.3.0)
- `assets/ask-gemini.md` - Slash command for Claude Code

**Scripts** (installation automation):
- `scripts/install-gemini-coach.sh` - Installs binary to ~/.local/bin/
- `scripts/setup-slash-command.sh` - Symlinks /ask-gemini to ~/.claude/commands/
- `scripts/test-connection.sh` - Verifies Gemini CLI is working

**References** (deep-dive documentation):
- `references/gemini-experiments.md` - Complete test results
- `references/models-guide.md` - Flash vs Pro comparison
- `references/prompting-strategies.md` - AI-to-AI prompting patterns
- `references/helper-functions.md` - Command reference

---

## Version History

**v1.0.0 (2025-11-09)**:
- Initial skill release
- Includes gemini-coach v2.3.0
- Documented Flash vs Pro differences
- AI-to-AI prompting best practices
- 8+ known issues prevented
- Production-tested patterns
- Installation automation
- Comprehensive reference documentation

---

## License

MIT License - See LICENSE file

---

**Last Updated**: 2025-11-09
**Production Tested**: Yes
**Gemini CLI Version**: 0.13.0+
**gemini-coach Version**: 2.3.0
