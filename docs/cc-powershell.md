You *can* run Claude Code natively on Windows and still lean on PowerShell – but there are a couple of “gotchas” around shells and tools. Here’s the current state of the world and a concrete way to set it up.

---

## 1. What “native on Windows” means now

Claude Code started as “Linux-only via WSL,” but in 2025 Anthropic added **official native Windows support**:

* It runs directly in **PowerShell / CMD / Windows Terminal** – no WSL required. ([SmartScope][1])
* Under the hood it still expects a **POSIX-style shell**, so Anthropic’s docs *strongly* recommend **Git Bash** as the default shell on Windows. ([Claude Code][2])
* From that bash environment you can call **PowerShell 7 (`pwsh`)** to run real Windows/PowerShell commands and talk to the Windows API. ([reddit.com][3])

So the usual pattern is:

> Launch Claude Code from **PowerShell**, it internally uses **Git Bash** as its shell, and then calls **`pwsh`** whenever it needs PowerShell.

---

## 2. Install Claude Code natively (no WSL)

### Step 1 – Prereqs

1. **Install Git for Windows** (if you don’t already have it) – this gives you Git Bash.
2. **Install Node.js 20+** (LTS is fine).

You can use the Node installer or `winget`, but the important bit is that `node` and `npm` work in a normal PowerShell window.

### Step 2 – Install Claude Code via npm

Anthropic’s official install is just: ([Claude Code][2])

```powershell
npm install -g @anthropic-ai/claude-code
```

Then verify:

```powershell
claude --version
```

If `claude` isn’t recognized, you probably need to add npm’s global bin dir to your PATH. The SmartScope guide shows a typical native-Windows fix: ([SmartScope][1])

```powershell
npm config get prefix           # e.g. C:\Users\<You>\npm-global
$env:PATH -split ';' | Where-Object { $_ -like "*npm*" }

# If needed, permanently add it:
[Environment]::SetEnvironmentVariable(
  "PATH",
  "$env:PATH;C:\Users\<You>\npm-global",
  [EnvironmentVariableTarget]::User
)
```

Open a new PowerShell and test `claude --version` again.

---

## 3. Tell Claude Code to use Git Bash on native Windows

Anthropic’s docs list two main Windows options: ([Claude Code][2])

1. Claude Code in **WSL**
2. Claude Code on **native Windows with Git Bash** (their recommended path)

For the native route, make sure Claude knows where `bash.exe` is. From PowerShell:

```powershell
$env:CLAUDE_CODE_GIT_BASH_PATH = "C:\Program Files\Git\bin\bash.exe"
[Environment]::SetEnvironmentVariable(
  "CLAUDE_CODE_GIT_BASH_PATH",
  "C:\Program Files\Git\bin\bash.exe",
  [EnvironmentVariableTarget]::User
)
```

Now when you run `claude` (even from PowerShell), Claude Code will spin up a bash environment using Git Bash, which gives it all the Unixy tools (`ls`, `grep`, etc.) it expects. ([Anthropic][4])

---

## 4. Actually *using* PowerShell from Claude Code

Even though Claude Code’s shell is bash, you’re still on Windows – and **PowerShell 7 (`pwsh`) is just another CLI tool on PATH**.

A popular Windows-specific tip from the “Things I wish I knew when I first started using Claude Code (Windows users only)” thread: ([reddit.com][3])

> “You are running natively in a windows environment via git bash. You can execute powershell 7 commands and access the windows API through `pwsh`… outside of `ls/find/grep` style commands, you should use PowerShell via `pwsh`.”

In practice that looks like this **inside** Claude Code:

```bash
# Simple sanity check
pwsh -NoLogo -Command "Write-Host 'Hello from PowerShell'"

# Example: services with Docker in the name
pwsh -NoLogo -Command "Get-Service | Where-Object { \$_.DisplayName -like '*Docker*' }"
```

Good patterns:

* In your **CLAUDE.md**, tell it explicitly:

  > On this machine, please use `pwsh` for Windows-specific tasks.
  > Example: `pwsh -NoLogo -Command "Get-Process"`

* Ask it things like:

  > “Use `pwsh` to create a folder `C:\Tools\Logs`, then verify it exists. Show me the commands and output.”

Claude will then generate and run PowerShell commands via `pwsh`, but still keep using bash for `git`, `grep`, etc.

---

## 5. Running Claude Code *from* PowerShell comfortably

Once npm + PATH are set up, you can just:

```powershell
cd C:\path\to\project
claude
```

If you want a dedicated function (handy in custom profiles), you can stick something like this in `$PROFILE`:

```powershell
function claude {
    # Just call the shim that npm installed
    & "claude" @Args
}
```

Nick Gommans’ write-up shows a similar pattern (originally for WSL) where a PowerShell function wraps the actual Claude Code invocation so you type `claude` like it’s a native command. ([Medium][5])

With native Windows support you don’t need the `wsl ... claude` dance anymore – the function is just sugar.

---

## 6. Deep integration: persistent PowerShell via MCP

If you want Claude to live **inside** a real PowerShell REPL (preserving modules, variables, and state), there are now **PowerShell-focused MCP servers**:

* **PowerShell.MCP** – “enables AI assistants (such as Claude Desktop) to execute any PowerShell commands and CLI tools within a PowerShell console… while preserving the state of imported modules, functions and variables.” ([GitHub][6])
* LobeHub’s **PowerShell REPL MCP** does something similar: a persistent PowerShell execution environment exposed via MCP. ([LobeHub][7])

The flow is:

1. Run the PowerShell MCP server (`pwsh` script or exe) on your Windows box.

2. In Claude Code, add it as a tool:

   ```bash
   claude mcp add powershell pwsh path/to/start-powershell-mcp.ps1
   ```

3. Then in a Claude Code session you can say:

   > “Use the `powershell` MCP server to run this script and show me the output…”

This gives you *true* PowerShell-first automation (persistent session, modules loaded once, etc.), instead of just shelling out via `pwsh` each time.

Anthropic’s MCP docs cover the general pattern for adding MCP servers: ([Claude Code][8])

---

## 7. Third-party helpers (optional)

Before official native support, people built wrappers like **`win-claude-code`**:

```bash
npm install -g anthropic-ai/claude-code --ignore-scripts
npx win-claude-code@latest
```

That wrapper makes Claude Code work from PowerShell/CMD by providing the POSIX bits it expects. ([reddit.com][9])

Now that the official native Windows path exists and Git Bash is recommended, I’d treat `win-claude-code` as a fallback/experiment rather than the primary approach.

---

## 8. Recommended setup for you

Given everything above (and that you’re already comfortable with PowerShell):

1. **Install Git for Windows + Node 20+** (if not already).
2. **Install Claude Code** globally with npm.
3. **Set `CLAUDE_CODE_GIT_BASH_PATH`** to your Git Bash `bash.exe`.
4. **Use PowerShell as your “entrypoint”** – open Windows Terminal → PowerShell → `cd` into your project → `claude`.
5. Inside Claude Code, **standardize on `pwsh`** for anything Windows-specific and capture that in `CLAUDE.md`.
6. If you want *serious* PowerShell automation, layer in **PowerShell.MCP** or the LobeHub PowerShell REPL server and add it as an MCP server.

If you tell me which of these you want to prioritize (simple `pwsh` usage vs. full MCP PowerShell REPL), I can write you concrete config snippets and a `CLAUDE.md` block tailored to your machine.

[1]: https://smartscope.blog/en/generative-ai/claude/claude-code-windows-native-installation/ "Claude Code Windows Install: No WSL Required (3min PowerShell Setup) - SmartScope"
[2]: https://code.claude.com/docs/en/setup?utm_source=chatgpt.com "Set up Claude Code - Claude Code Docs"
[3]: https://www.reddit.com/r/ClaudeCode/comments/1munnas/things_i_wish_i_knew_when_i_first_started_using/?utm_source=chatgpt.com "Things I wish I knew when I first started using CLAUDE CODE ..."
[4]: https://www.anthropic.com/engineering/claude-code-best-practices?utm_source=chatgpt.com "Claude Code: Best practices for agentic coding"
[5]: https://gommans.co.uk/claude-code-on-powershell-355cc5490431 "Claude code on PowerShell. How to type “claude” in PowerShell to… | by Nick Gommans | Medium"
[6]: https://github.com/yotsuda/PowerShell.MCP?utm_source=chatgpt.com "yotsuda/PowerShell.MCP"
[7]: https://lobechat.com/discover/mcp/jacksonhunter-powershell-repl-mcp-server?utm_source=chatgpt.com "PowerShell Persistent MCP Server - LobeHub: Your personal AI ..."
[8]: https://code.claude.com/docs/en/mcp?utm_source=chatgpt.com "Connect Claude Code to tools via MCP"
[9]: https://www.reddit.com/r/ClaudeAI/comments/1ltm943/made_claude_code_work_natively_on_windows/ "Made Claude Code work natively on Windows : r/ClaudeAI"
