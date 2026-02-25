# Tutorial Module Reference Data

Below is the reference content for each module. Use it as source material — do NOT output it directly.

<!-- MODULE 1 -->
TOPIC: Welcome & First Steps
DOCS: https://opencode.ai/docs/
KEY POINTS:
- Launch with `opencode` or `opencode /path/to/project`
- First-time: run `/connect` to add an LLM provider
- Easiest option: OpenCode Zen — select `opencode` provider, visit opencode.ai/auth, sign in, copy API key, paste back
- 75+ other providers available (Anthropic, OpenAI, GitHub Copilot, etc.)
- Run `/models` to pick a model after connecting
CHALLENGE: Run `/help` to see all available commands. Report back when ready.
QUIZ: What command adds a new LLM provider?
- /models
- /connect
- /init
- /new
ANSWER: /connect

<!-- MODULE 2 -->
TOPIC: Talking to the Agent
DOCS: https://opencode.ai/docs/tui/
KEY POINTS:
- `@file` — fuzzy-search and inject file contents into prompt (e.g., `How does @src/auth.ts work?`)
- `!command` — run shell command, add output to context (e.g., `!git log --oneline -5`)
- Images — drag and drop into terminal, gets scanned and added to prompt
- Multi-line input — Shift+Enter (or Ctrl+Enter / Alt+Enter)
CHALLENGE: Type `@` in a message and try the fuzzy file search. Share what you see.
QUIZ: How do you run a shell command from the prompt?
- Start with $
- Use /bash
- Start with !
- Press Ctrl+B
ANSWER: Start with !

<!-- MODULE 3 -->
TOPIC: Plan vs Build Mode
DOCS: https://opencode.ai/docs/agents/
KEY POINTS:
- Two agents, switch with Tab key
- Build (default): full development, writes code, runs commands, edits files
- Plan: analysis and planning only, no file changes
- Workflow: Tab to Plan → describe goal → review plan → Tab to Build → "go ahead"
- ctrl+t cycles model variants (standard vs extended thinking)
- @general / @explore invoke subagents for focused tasks
CHALLENGE: Press Tab to switch to Plan mode — watch the indicator change. Press Tab again to switch back.
QUIZ: What key switches between Build and Plan mode?
- Escape
- Tab
- Ctrl+T
- Ctrl+P
ANSWER: Tab

<!-- MODULE 4 -->
TOPIC: Essential Commands
DOCS: https://opencode.ai/docs/tui/#commands
KEY POINTS:
- Type `/` to see all commands
- /init — generate project rules (AGENTS.md) — ctrl+x i
- /undo — revert last message + file changes — ctrl+x u
- /redo — restore undone changes — ctrl+x r
- /new — fresh session — ctrl+x n
- /sessions — switch between sessions — ctrl+x l
- /compact — summarize context to save tokens — ctrl+x c
- /models — switch model mid-conversation — ctrl+x m
- /editor — open $EDITOR for long prompts — ctrl+x e
- /undo reverts file changes too (project must be a git repo)
- /share exists but requires OpenCode Zen or share config — don't teach as essential
CHALLENGE: Type `/` and browse the commands. Try `/sessions`. Share what you find.
QUIZ: You don't like a refactor OpenCode made. Which command reverts it?
- /revert
- /rollback
- /undo
- /reset
ANSWER: /undo

<!-- MODULE 5 -->
TOPIC: Keybinds
DOCS: https://opencode.ai/docs/keybinds/
KEY POINTS:
- Leader key pattern: default leader is ctrl+x. Press ctrl+x, release, then action key.
- ctrl+p — command palette (shows all actions + keybinds)
- ctrl+x n — new session
- ctrl+x l — session list
- ctrl+x m — switch model
- ctrl+t — cycle model variant
- Tab — switch agent
- ctrl+x u / r — undo / redo
- Escape — interrupt response
- ctrl+c — exit
- All keybinds customizable in opencode.json, set to "none" to disable
CHALLENGE: Press ctrl+p to open the command palette — your keybind cheat sheet.
QUIZ: What is the default leader key?
- ctrl+space
- ctrl+a
- ctrl+x
- ctrl+l
ANSWER: ctrl+x

<!-- MODULE 6 -->
TOPIC: Rules & Project Setup
DOCS: https://opencode.ai/docs/rules/
KEY POINTS:
- Rules tell OpenCode how to behave in your project
- /init scans project and generates AGENTS.md — commit it for the whole team
- Rule locations (priority): 1) AGENTS.md in project root, 2) ~/.config/opencode/AGENTS.md (global), 3) ~/.claude/CLAUDE.md (compat fallback)
- Rules should include: project description, structure, conventions, test commands
- Can reference extra files via "instructions": ["CONTRIBUTING.md"] in opencode.json
CHALLENGE: Run `/init` in a project directory and review the generated AGENTS.md.
QUIZ: Where does OpenCode look for project-specific rules?
- .opencode/rules.yaml
- package.json
- AGENTS.md in project root
- opencode.rules
ANSWER: AGENTS.md in project root

<!-- MODULE 7 -->
TOPIC: Customization
DOCS: https://opencode.ai/docs/commands/ https://opencode.ai/docs/permissions/
KEY POINTS:
- Custom commands: create .opencode/commands/<name>.md with frontmatter (description) and prompt body. Then /<name> works. Supports $ARGUMENTS, $1/$2, !`cmd`, @file.
- Custom agents: create .opencode/agents/<name>.md with frontmatter (description, mode: subagent, tools config). Then @<name> works as subagent.
- Themes: run /themes to browse and pick
- Permissions in opencode.json: "allow", "ask" (prompt for approval), "deny". Bash supports glob patterns like "git *": "allow".
- All config lives in opencode.json (project root or ~/.config/opencode/)
CHALLENGE: Create .opencode/commands/hello.md with a simple description, then run /hello.
QUIZ: What permission level prompts for approval before running a tool?
- "prompt"
- "confirm"
- "ask"
- "approve"
ANSWER: "ask"

<!-- MODULE 8 -->
TOPIC: Extending OpenCode
DOCS: https://opencode.ai/docs/mcp-servers/ https://opencode.ai/docs/skills/
KEY POINTS:
- MCP Servers: add external tools. Two types: remote (just a URL) and local (runs a process via command array).
- Popular MCP servers: Context7 (docs search), Sentry (error tracking), Grep by Vercel (code examples)
- MCP servers add tokens to context — be selective
- Skills: reusable instruction sets loaded on demand. Place in .opencode/skills/<name>/SKILL.md (project) or ~/.config/opencode/skills/<name>/SKILL.md (global)
- Custom tools: define in opencode.json with description, command array, and permission level
- Plugins: extend programmatically via "plugin": ["my-plugin"] in opencode.json
CHALLENGE: Try adding an MCP server to your opencode.json, or review the examples discussed.
QUIZ: What are the two types of MCP servers?
- HTTP and WebSocket
- Internal and External
- Local and Remote
- Sync and Async
ANSWER: Local and Remote

<!-- MODULE 9 -->
TOPIC: CLI Power Moves
DOCS: https://opencode.ai/docs/cli/
KEY POINTS:
- `opencode -c` — continue your last session instead of starting fresh. Great for picking up where you left off.
- `opencode --prompt "fix the tests"` — pre-fill a prompt so it's ready when the TUI opens
- `opencode -m provider/model` — launch with a specific model (e.g., `opencode -m anthropic/claude-sonnet-4-20250514`)
- `opencode run "explain this error"` — non-interactive mode, outputs answer to stdout. Perfect for scripting and quick questions.
- `opencode run -c "now refactor it"` — continue last session non-interactively
- `opencode run -f src/app.ts "review this file"` — attach files in run mode
- `opencode stats` — see token usage and costs across sessions. Use `--days 7` for last week, `--models` for per-model breakdown.
- `opencode upgrade` — self-update to the latest version
- Pipe-friendly: `opencode run "..." | pbcopy` or chain into other CLI tools
CHALLENGE: Run `opencode stats` in another terminal to see your token usage. Or try `opencode run "what is 2+2"` for a quick non-interactive test.
QUIZ: Which flag continues your last session when launching OpenCode?
- --resume
- -c
- --last
- -s
ANSWER: -c

<!-- MODULE 10 -->
TOPIC: Team Skills — Jira & GitHub at Your Fingertips
DOCS: none
KEY POINTS:
- OpenCode already has skills installed that know how to work with Jira and GitHub. You don't need to learn any CLI syntax — just ask in plain English.
- Skills are like cheat sheets the agent loads on demand. When you ask about Jira tickets or GitHub PRs, OpenCode recognizes the intent, loads the relevant skill, and figures out the right commands itself.
- Things you can just ask:
  - "What Jira tickets are assigned to me right now?"
  - "Show me my in-progress work"
  - "Do I have any PRs waiting for review?"
  - "What open PRs do I have?"
  - "Create a bug ticket for the login timeout issue"
  - "What are the checks on my latest PR?"
- You can even combine them: "What Jira tickets am I working on, and do I have open PRs for any of them?"
- Prerequisites: `gh` and `acli` CLIs need to be installed and authenticated. If you ran `lskt ai setup` during onboarding, you're already good to go.
- This is the real power of skills — they turn OpenCode into a teammate that knows your tools without you having to remember syntax.
CHALLENGE: Try asking OpenCode something like "what Jira tickets am I working on?" or "show my open PRs" right now. Just talk naturally — let the skills do the work.
QUIZ: How does OpenCode know how to query Jira and GitHub for you?
- It has built-in Jira/GitHub support
- Skills are loaded that teach it the right CLI commands
- You need to configure API endpoints in opencode.json
- It reads your browser history
ANSWER: Skills are loaded that teach it the right CLI commands
