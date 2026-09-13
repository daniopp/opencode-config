# Opencode Quick Reference

Configurazione opencode multi-macchina, sincronizzata via repo.

## Setup Rapido

```bash
# 1. Install
npm install -g @opencode/ai

# 2. Clone config repo
git clone https://github.com/danismeup/opencode-config.git ~/git/opencode-config

# 3. Sync verso la config live (~/.config/opencode)
cd ~/git/opencode-config && scripts/sync.sh pull

# 4. Setup credentials (API keys in env o .dev.vars)
echo "OPENROUTER_API_KEY=your_token" > ~/git/opencode-config/.dev.vars

# 5. Run
opencode
```

**Per guide dettagliate (WSL, modelli, troubleshooting), vedi [INSTALL.md](INSTALL.md).**

## Modelli

| Ruolo | Modello | Prezzo ($/M in/out) | Note |
|-------|---------|---------------------|------|
| Primario | `openrouter/z-ai/glm-5.3-flash` | 0.15 / 0.50 | contesto 1M, multimodale, cache read 0.03 |
| Small model | `openrouter/deepseek/deepseek-v4-flash-0731` | 0.05 / 0.16 | title/summary/compaction, contesto 1M |

## Agenti

- `orchestrator` — coordinatore principale (GLM 5.3 Flash)
- `explorer`, `librarian`, `oracle`, `reviewer`, `verifier`, `fixer`, `observer` — specialisti (DeepSeek V4 Flash)
- `designer` — UI/UX, multimodale (`meta/muse-spark-1.3-contributor`)

## Comandi (lane)

| Comando | Quando usare |
|---------|--------------|
| `/quick` | Task semplici |
| `/medium` | Task medi, multi-file |
| `/full` | Task complessi, multi-phase |
| `/debug` | Troubleshooting |
| `/sync-config` | Sync config live ↔ repo (status → push → commit → push) |

## Skills

| Skill | Scopo |
|-------|-------|
| `auto-docs` | Documentazione di sviluppo auto-mantenuta |
| `bugfix-debugging` | Diagnosi bug, disciplina reproduce-first |
| `clonedeps` | Clone dependency source code |
| `codemap` | Generate codebase maps |
| `csharp-tests` | Test C# XUnit + FluentAssertions (EVODOC) |
| `completion-gate` | Gate di verifica finale prima del report |
| `deepwork` | High-stakes coding workflow |
| `docs-sync` | Allineamento documentazione prodotto |
| `evodoc-pr` | Workflow GitHub EVODOC end-to-end |
| `gh-templates` | Template GitHub issue/PR/discussion |
| `project-kb-setup` | Knowledge base AI dentro il repo |
| `reflect` | Learn from past sessions |
| `simplify` | Simplify code |
| `verification-planning` | Plan verification |
| `worktrees` | Isolated coding lanes |

## Permessi

| Livello | Default | Note |
|---------|---------|------|
| `read` | allow | deny su `*.env*`, `*.dev.vars` |
| `edit` | allow | copre write/patch |
| `bash` | ask | allowlist 4 tier dallo storico sessioni (letture/scritture sicure → allow, distruttivi → deny) |
| `external_directory` | ask | allow su `~/git/**`, `/tmp/**` |

### Progetti fidati (bash allow-by-default)

In un progetto fidato bash passa a "tutto allow tranne i distruttivi":

```bash
cp ~/git/opencode-config/repo-examples/opencode-project-trusted.jsonc ~/git/<progetto>/opencode.jsonc
```

Restano deny: `rm -rf`, `sudo`, `git push --force`, `git reset --hard`, `git clean -f`, `git checkout --`, `git restore`, `docker system prune`, `gh release/pr delete`, `dotnet ef database drop`. Riavvia opencode nel progetto per applicare la config.

## MCP Servers

Nessuno (`mcp: {}`). Rimossi dopo verifica su opencode.db (zero invocazioni nello storico): `with-context`, `filesystem`, `sequential-thinking`, `memory`, `github` (sostituito dalla CLI `gh`).

## Directory Structure

```
opencode-config/
├── opencode.jsonc    # Main config
├── tui.json          # TUI config
├── AGENTS.md         # Istruzioni per gli agenti
├── agents/           # Custom agents
├── commands/         # Lane + /sync-config
├── rules/            # Always-on rules
├── skills/           # Skills markdown
├── scripts/          # sync.sh (sync live <-> repo)
├── repo-examples/    # Template (es. opencode-project-trusted.jsonc)
└── .dev.vars         # Credentials
```

## Sync config ↔ repo

```bash
cd ~/git/opencode-config
scripts/sync.sh status   # confronto read-only
scripts/sync.sh push     # locale -> repo (poi commit/push manuali o /sync-config)
scripts/sync.sh pull     # repo -> locale
```

Divergenza nota gestita dallo script: `opencode.jsonc` sezione `instructions` (path Windows nel repo vs Linux in locale).

## Updates

```bash
cd ~/git/opencode-config && git pull
```
