# Opencode Quick Reference

## Setup Rapido

```bash
# 1. Install
npm install -g @opencode/ai

# 2. Clone config
git clone https://github.com/your-org/opencode-config.git ~/opencode-config

# 3. Setup credentials
echo "GITHUB_TOKEN=..." > ~/opencode-config/.dev.vars

# 4. Run
cd ~/opencode-config && opencode
```

## Agenti

- `orchestrator` - Coordina workflow
- `explorer` - Search codice
- `librarian` - Search docs
- `oracle` - Architecture analysis
- `designer` - UI/UX
- `fixer` - Rapid implementation
- `observer` - Status check

## Lanes

| Comando | Quando usare |
|---------|--------------|
| `/quick` | Task semplici |
| `/medium` | Task medi, multi-file |
| `/full` | Task complessi, multi-phase |
| `/debug` | Troubleshooting |

## Skills

| Skill | Scopo |
|-------|-------|
| `clonedeps` | Clone dependency source code |
| `codemap` | Generate codebase maps |
| `deepwork` | High-stakes coding workflow |
| `oh-my-opencode-slim` | Tune config |
| `reflect` | Learn from past sessions |
| `simplify` | Simplify code |
| `verification-planning` | Plan verification |
| `worktrees` | Isolated coding lanes |

## MCP Servers

- `with-context` - Session tracking
- `github` - GitHub API
- `filesystem` - File access
- `sequential-thinking` - Reasoning
- `memory` - Knowledge graph

## Directory Structure

```
opencode-config/
├── opencode.jsonc    # Main config
├── tui.json          # Theme/keybindings
├── agents/           # Custom agents
├── commands/         # Lanes
├── skills/           # npm skills
├── rules/            # Always-on rules
└── .dev.vars         # Credentials
```

## Updates

```bash
cd ~/opencode-config && git pull
```
