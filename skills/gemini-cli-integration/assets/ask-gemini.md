# Ask Gemini

Get a second opinion from Gemini CLI on code, architecture, or debugging questions.

**Purpose**: Consult Gemini as a "coding coach" for fresh perspectives when stuck or making critical decisions.

**Modes**:
- **Manual**: User explicitly requests Gemini consultation (original workflow)
- **Proactive**: Claude Code automatically consults Gemini when detecting critical scenarios (see "Proactive Usage" section below)

---

## CRITICAL: AI-to-AI Prompting Strategy

**Identity Clarity** (Updated v2.2.0)

When consulting Gemini, ALWAYS use the AI-to-AI peer review format to prevent role confusion:

```
[Claude Code consulting Gemini for peer review]

Task: [Specific task description]

Provide direct analysis with file:line references. I will synthesize your findings with mine before presenting to the developer.
```

**Why This Matters**:
- ❌ **Old way**: "You're an expert..." → Gemini thinks it's talking to the human
- ✅ **New way**: "[Claude Code consulting Gemini...]" → Clear AI-to-AI relationship

**Results**:
- No "How can I help you?" chattiness
- Direct, actionable analysis
- Clear file:line references
- Gemini knows its role is to advise me (Claude Code), not the end user

---

## Your Task

Follow these steps to get Gemini's expert opinion.

### 1. Understand the Request

Ask user what they need help with:

```
What would you like Gemini to help with?
1. Code Review - Review specific files for bugs, best practices
2. Architecture Advice - Feedback on design decisions
3. Debugging Help - Analyze errors and suggest fixes
4. Skill Analysis - Review entire skill for completeness
5. Documentation Check - Verify docs against official sources
6. Custom Question - Anything else

Your choice (1-6):
```

### 2. Gather Context

Based on request type:

**For Code Review (Option 1)**:
- Ask: "Which files should I have Gemini review? (paths or glob pattern)"
- Ask: "Any specific concerns? (performance, security, type safety, etc.)"
- Optional: "Any official doc URLs for reference? (e.g., React docs, Cloudflare docs)"

**For Architecture Advice (Option 2)**:
- Ask: "Describe the architectural decision or problem"
- Ask: "Any relevant code files to include?"
- Optional: "URLs to relevant patterns or best practices docs?"

**For Debugging Help (Option 3)**:
- Ask: "Paste the error message or describe the bug"
- Ask: "Which files contain the problematic code?"
- Optional: "What have you already tried?"

**For Skill Analysis (Option 4)**:
- Ask: "Which skill should Gemini analyze? (skill folder name)"
- Automatically include: SKILL.md, README.md, templates/
- Optional: "Any official docs URLs to verify against?"

**For Documentation Check (Option 5)**:
- Ask: "Which documentation files to review?"
- Ask: "URLs to official docs for comparison (required for this task)"

**For Custom Question (Option 6)**:
- Ask: "What's your question for Gemini?"
- Ask: "Any files or context to include?"
- Optional: "Relevant URLs?"

### 3. Build Gemini Command

Based on task type, construct the prompt:

#### Code Review Template
```
[Claude Code consulting Gemini for peer review]

Task: Code review - check for bugs, logic errors, security vulnerabilities (SQL injection, XSS, etc.), performance issues, best practice violations, type safety problems, and missing error handling

[If URLs provided:]
Check against these official docs:
- [URL 1]
- [URL 2]

[User's specific concerns if any]

Provide direct analysis with file:line references. I will synthesize your findings with mine before presenting to the developer.
```

#### Architecture Advice Template
```
[Claude Code consulting Gemini for peer review]

Task: Architecture advice - [User's description of the decision or problem]

Analyze for: architectural anti-patterns, scalability concerns
- Maintainability issues
- Better alternatives
- Potential technical debt

[If URLs provided:]
Reference these patterns:
- [URL 1]
- [URL 2]

Provide specific, actionable recommendations and rationale. I will synthesize your findings with mine before presenting to the developer.
```

#### Debugging Help Template
```
[Claude Code consulting Gemini for peer review]

Task: Debug analysis - identify root cause (not just symptoms), explain why it's happening, suggest specific fix with code example, and how to prevent in future

Error: [User's error message/description]

What was tried: [User's attempts if provided]

Provide direct analysis with file:line references. I will synthesize your findings with mine before presenting to the developer.
```

#### Skill Analysis Template
```
[Claude Code consulting Gemini for peer review]

Task: Claude Code skill completeness check for [skill topic]

Verify: API accuracy, documentation gaps or unclear explanations, missing edge cases or error scenarios, outdated patterns or package versions, incomplete examples, known issues not documented, and type safety concerns

[If URLs provided:]
Check against official documentation:
- [URL 1]
- [URL 2]

Provide direct analysis with file:line references focusing on what was missed or could be improved. I will synthesize your findings with mine before presenting to the developer.
```

#### Documentation Check Template
```
[Claude Code consulting Gemini for peer review]

Task: Documentation accuracy verification

Compare documentation against these official sources:
[URLs - REQUIRED for this task type]
- [URL 1]
- [URL 2]

Check for: outdated information, incorrect patterns, missing important details, breaking changes not mentioned, and deprecated approaches still documented

Provide direct analysis with specific discrepancies. I will synthesize your findings with mine before presenting to the developer.
```

#### Custom Question Template
```
[Claude Code consulting Gemini for peer review]

Task: [User's question or custom request]

Context: [User's context if provided]

[If URLs provided:]
Reference:
- [URL 1]
- [URL 2]

Provide direct, actionable answer. I will synthesize your findings with mine before presenting to the developer.
```

### 4. Construct Bash Command

Choose command pattern based on task:

**For Single Skill Analysis**:
```bash
cd ~/.claude/skills/[skill-name] && \
  gemini -p "<formatted prompt>" --all-files \
  -m gemini-2.5-flash 2>&1 | grep -v "^Data collection\|^Loaded cached"
```

**For Specific Files (Code Review / Debugging)**:
```bash
cat [file1] [file2] ... | gemini -p "<formatted prompt>" \
  -m gemini-2.5-flash 2>&1 | grep -v "^Data collection\|^Loaded cached"
```

**For All Skills (Use Sparingly - Very Slow!)**:
```bash
cd ~/.claude/skills && \
  gemini -p "<formatted prompt>" --all-files \
  -m gemini-2.5-flash 2>&1 | grep -v "^Data collection\|^Loaded cached"
```

**For Documentation Only**:
```bash
cat [doc-files] | gemini -p "<formatted prompt>" \
  -m gemini-2.5-flash 2>&1 | grep -v "^Data collection\|^Loaded cached"
```

**Note**: `--include-directories` doesn't work with `-p` in headless mode. Use `cd` + `--all-files` instead.

**Model Selection**:
- Use `gemini-2.5-flash` by default (~5-25s, good quality, safer with directories)
- Use `gemini-2.5-pro` for architecture/critical decisions (~15-30s, better reasoning)
- **Note**: Flash-lite not accessible via Gemini CLI (returns 404 error)

**When Flash vs Pro Give Different Advice**:
- Flash prioritizes: Performance, simplicity, speed
- Pro prioritizes: Correctness, consistency, thoroughness
- Both can be valid depending on project requirements
- For critical/security decisions, prefer Pro's perspective
- Consider both viewpoints for major architectural choices

### 5. Execute Command

Run the constructed command:
```bash
OUTPUT=$(gemini -p "<prompt>" [options] 2>&1 | grep -v "^Data collection\|^Loaded cached")
```

**If command fails**:
- Check if Gemini CLI is authenticated (`gemini` to test)
- Verify file paths exist
- Check for error messages in output
- Show error to user and ask if they want to retry

### 6. Present Results

Format output:
```
═══════════════════════════════════════════════
   GEMINI'S ANALYSIS
═══════════════════════════════════════════════

[Gemini's response from OUTPUT variable]

═══════════════════════════════════════════════

What would you like to do?
1. Implement Gemini's suggestions
2. Ask follow-up question
3. Get my (Claude's) take on Gemini's findings
4. Continue without changes

Your choice (1-4):
```

### 7. Handle User Response

**If choice 1 (Implement)**:
- Parse Gemini's suggestions
- Implement changes using appropriate tools (Edit, Write, etc.)
- Confirm changes with user

**If choice 2 (Follow-up)**:
- Ask: "What's your follow-up question?"
- Go back to step 3 with new prompt
- Include previous context if relevant

**If choice 3 (Claude's take)**:
- Analyze Gemini's findings
- Agree/disagree with specific points
- Provide additional context or alternative perspectives
- Ask user which approach they prefer

**If choice 4 (Continue)**:
- Output: "Understood. Gemini's analysis is available if you need it later."
- Continue normal workflow

---

## Performance Expectations

**Updated based on 2025-11-08 testing**:

| Task | Typical Time | Model | Notes |
|------|--------------|-------|-------|
| Single file review | 5-15 seconds | gemini-2.5-flash | Good quality |
| Skill analysis | 10-25 seconds | gemini-2.5-flash | Comprehensive |
| Complex architecture | 15-30 seconds | gemini-2.5-pro | Better reasoning |
| Directory scanning | 15-30 seconds | gemini-2.5-pro | May try to use tools |
| Quick questions | 5-25 seconds | gemini-2.5-flash | Both models similar speed |
| All skills scan | 60+ seconds | (avoid unless necessary) | Very slow |

**Note**: Flash and Pro have more similar response times than previously thought (~20-25s average for both on many queries)

---

## Best Practices

### ✅ Good Use Cases
- Before committing major changes (final review)
- When stuck debugging after trying multiple approaches
- Architecture decisions with multiple valid options
- Reviewing critical security code
- "What am I missing?" moments

### ❌ Avoid Using For
- Simple syntax checks (I can do faster)
- Every single edit (too slow, unnecessary)
- Questions with obvious answers
- Tasks I can handle directly

---

## Error Handling

**Gemini CLI not installed**:
```
❌ Gemini CLI not found

Install: npm install -g @google/generative-ai-cli

Or visit: https://github.com/google-gemini/gemini-cli
```

**Authentication issues**:
```
❌ Gemini CLI not authenticated

Run: gemini

Follow authentication prompts, then try /ask-gemini again.
```

**File not found**:
```
❌ File not found: [path]

Check path and try again.
```

**Rate limit exceeded**:
```
⚠️  Gemini API rate limit exceeded

Free tier: 1500 requests/day for gemini-2.5-flash

Try again later or upgrade to paid tier.
```

---

## Success Criteria

✅ User gets expert second opinion from Gemini
✅ Response is actionable and specific
✅ I can incorporate insights into my work
✅ User maintains control over implementation
✅ Complementary perspective (finds things I missed)

---

## Notes

**Gemini CLI Context**:
- Loads GEMINI.md from ~/.claude/skills/ automatically
- Has access to files via --include-directories
- Can fetch URLs via web_fetch tool (if provided in prompt)
- 1M token context window (Gemini 2.5 models)

**Comparison to My Analysis**:
- I focus on correctness and syntax
- Gemini catches completeness gaps and documentation issues
- Together we provide comprehensive review

**When to Use Pro vs Flash** (Updated 2025-11-08):
- **Flash** (default): Code reviews, debugging, directory scanning, most tasks
  - Faster on simple queries (~5-15s)
  - Safer with directories (less likely to use tools aggressively)
  - Good quality for general tasks
- **Pro**: Architecture decisions, critical security reviews, complex reasoning
  - Better trade-off analysis (~15-30s, sometimes similar to Flash)
  - More thorough on complex questions
  - May get confused with directory scanning (tries to use tools)
- **Lite**: ❌ Not accessible via Gemini CLI (returns 404 error)

---

## Proactive Usage (Automatic Consultation)

**Purpose**: Claude Code can automatically consult Gemini when detecting critical scenarios, without waiting for user to explicitly request it.

### When to Trigger Proactive Consultation

**ALWAYS Consult (Critical Scenarios)**:
1. **Major architectural decisions**
   - Choosing between storage solutions (D1 vs KV vs R2)
   - Selecting auth strategies (Clerk vs Auth.js vs custom)
   - Framework decisions (Next.js vs React + Hono)
   - State management approaches (Zustand vs TanStack Query vs context)

2. **Security-sensitive code**
   - Implementing authentication logic
   - Payment processing
   - User data handling (PII, credentials)
   - API key management
   - CORS and security headers

3. **Large refactors**
   - Changes affecting 5+ files
   - Core architecture modifications
   - Database schema changes affecting multiple tables
   - API contract changes

4. **Unfamiliar patterns**
   - Technologies I haven't used in 6+ months
   - New API versions with breaking changes
   - Experimental features

**CONSIDER Consulting (Judgment Call)**:
5. **Stuck debugging**
   - Same bug after 2+ failed fix attempts
   - Error patterns I can't identify root cause for
   - Performance issues without clear bottleneck

6. **Large features**
   - Features with >4 hour estimated implementation
   - Complex multi-step workflows
   - Features requiring coordination across many systems

7. **Context overflow**
   - Context approaching 70%+ full
   - Need to analyze entire repo structure
   - Large file changes requiring full context

8. **Verification failures**
   - Tests failing in unexpected ways
   - Build errors after seemingly correct changes
   - Type errors in complex generic code

### Proactive Workflow Pattern

When I detect a trigger scenario:

**Step 1: Detection**
```
🤔 I notice this is a [major architectural decision / security-sensitive change / etc.]
```

**Step 2: Inform User**
```
I'm going to consult Gemini for a second opinion on [specific concern].
This will take ~5-15 seconds...
```

**Step 3: Execute Gemini Query**
Use appropriate command based on scenario:

```bash
# Architecture decision
gemini-coach architect "Should I use D1 or KV for session storage?" /path/to/project

# Security review
gemini-coach security src/auth/

# Debug assistance
cd /project && gemini-coach debug "Error: [error message]" --include-directories . --yolo

# Whole repo analysis (context full)
cd /project && gemini-coach review "Analyze architecture, identify issues" --include-directories . --yolo
```

**Step 4: Synthesize Perspectives**
```
═══════════════════════════════════════════════
   GEMINI'S PERSPECTIVE
═══════════════════════════════════════════════

[Gemini's analysis]

═══════════════════════════════════════════════
   MY PERSPECTIVE (Claude Code)
═══════════════════════════════════════════════

[My analysis, noting where I agree/disagree with Gemini]

Points of agreement:
• [Point 1]
• [Point 2]

Where I differ:
• [Different view 1 with rationale]

═══════════════════════════════════════════════
```

**Step 5: Present Options**
```
Which approach would you like to take?

1. Follow Gemini's recommendation: [brief description]
2. Follow my recommendation: [brief description]
3. Hybrid approach: [combining both]
4. Discuss further before deciding

Your choice (1-4):
```

### Example Proactive Scenarios

**Scenario 1: Architectural Decision**
```
User: "I need to store user sessions. What should I use?"

Claude: 🤔 This is a major architectural decision. Let me consult Gemini for a second opinion...

[Runs: gemini-coach architect "Compare D1, KV, and Durable Objects for session storage in Cloudflare Workers" .]

[Presents both perspectives with trade-offs]
```

**Scenario 2: Security Code**
```
User: "Implement the login endpoint"

Claude: 🤔 Authentication logic is security-sensitive. Consulting Gemini before implementation...

[Runs: gemini-coach security "Review authentication best practices for Cloudflare Workers + Clerk"]

[Presents security checklist from both perspectives]
```

**Scenario 3: Stuck Debugging**
```
[After 2 failed attempts to fix a bug]

Claude: 🤔 I've attempted 2 fixes without success. Let me get Gemini's perspective...

[Runs: gemini-coach debug "Error: [paste error]" src/problematic-file.ts]

[Presents both debugging theories]
```

**Scenario 4: Context Overflow**
```
[Context at 72%]

Claude: ⚠️ Context is at 72% full. Before continuing, let me use Gemini's 1M context to analyze the entire project structure...

[Runs: cd /project && gemini-coach review "Analyze project architecture and suggest refactoring opportunities" --include-directories . --yolo]

[Presents architectural overview and refactoring suggestions]
```

### Integration with Task Agents

Task agents can invoke Gemini when they encounter trigger scenarios:

```typescript
// Pseudocode for Task agent logic
if (scenario === "architectural_decision" || scenario === "security_sensitive") {
  await runBashCommand(`gemini-coach architect "${question}" ${projectPath}`);
  synthesizePerspectives(geminiResponse, myAnalysis);
  presentOptionsToUser();
}
```

### When NOT to Use Proactive Consultation

**Avoid consulting Gemini for**:
- Simple syntax fixes
- Well-established patterns I'm confident about
- Minor refactors (1-2 files)
- Routine CRUD operations
- Documentation updates
- Tasks user explicitly wants fast execution on

**Balance**: Proactive consultation is powerful but shouldn't slow down every task. Use judgment.

---

## Version History

**v2.3.0 (2025-11-08)** - Model Validation & Testing
- REMOVED: gemini-2.5-flash-lite (not accessible via Gemini CLI, returns 404)
- Updated: Time estimates based on systematic testing
- Added: "When Flash vs Pro Give Different Advice" guidance
- Updated: Model selection recommendations (Flash default, Pro for critical)
- Added: Performance expectations table with real-world data
- Finding: Flash and Pro have similar response times (~20-25s average)
- Finding: Flash prioritizes performance, Pro prioritizes correctness
- Finding: Pro may get confused with directory scanning (tries to use tools)

**v2.2.0 (2025-11-08)** - AI-to-AI Prompting
- MAJOR: All prompt templates updated to AI-to-AI peer review format
- Added: Identity clarity section at top of document
- Improved: Prevents role confusion between Gemini, Claude Code, and human developer
- Result: More direct, actionable analysis with clear file:line references

**v2.0.0 (2025-11-08)** - Proactive Integration
- Added: Proactive consultation triggers
- Added: Integration with global CLAUDE.md

---

**Last Updated**: 2025-11-08
**Testing Report**: See `/tmp/gemini-experiments.md` for detailed findings
