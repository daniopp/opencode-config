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

**Per guide dettagliate (WSL, modelli, troubleshooting), vedi [INSTALL.md](wiki/INSTALL.md).**

## Modelli

| Ruolo | Modello | Prezzo ($/M in/out) | Note |
|-------|---------|---------------------|------|
| Primario | `opencode-go/claude-haiku-5-5` | 0.10 / 0.50 | contesto 1M, vision, cache read 0.01 |
| Small model | `opencode-go/deepseek-v4-flash` | 0.14 / 0.28 | title/summary/compaction, contesto 1M |

## Agenti

- `orchestrator` — coordinatore principale (Claude Haiku 5.5)
- `explorer`, `librarian`, `observer` — recon read-only su Go (Claude Haiku 5.5)
- `fixer`, `reviewer`, `verifier`, `looker` — Haiku 5.5 (looker = vision/PDF)
- `oracle` — advisor deep-reasoning (`claude-sonnet-5.5` via OpenRouter)
- `designer` — UI/UX, multimodale (`muse-spark-1.3-contributor`, Go)

## Comandi (lane)

| Comando | Quando usare |
|---------|--------------|
| `/quick` | Task semplici |
| `/medium` | Task medi, multi-file |
| `/full` | Task complessi, multi-phase (dual-review multi-modello) |
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
| `reflect` | Learn from past sessions + Retrospective Mode (5 fasi, evidenze git, verdetto) |
| `simplify` | Simplify code |
| `spec-archive` | Archivio delta-spec duraturo nel brownfield (pattern OpenSpec) |
| `story-craft` | Story self-contained con contesto inline, acceptance criteria e hard constraints, scale check e cerimonia piena/ridotta (prima del dispatch a `fixer` in /medium e /full) |
| `verification-planning` | Plan verification |
| `worktrees` | Isolated coding lanes |

Nelle regole always-on, `rules/rules.md` è versionato (v1.4.0: Governance SemVer, Ambito, Layering, Cronologia); indice in `rules/README.md`.

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

## Documenti

- [INSTALL.md](wiki/INSTALL.md) — guida installazione dettagliata
- [ARCHITECTURE.md](wiki/ARCHITECTURE.md) — architettura della config
- [SETUP.md](wiki/SETUP.md) · [PERMISSIONS.md](wiki/PERMISSIONS.md) · [DEBUG.md](wiki/DEBUG.md) · [CHANGELOG.md](CHANGELOG.md)
- [BMAD-ASSESSMENT.md](wiki/BMAD-ASSESSMENT.md) — valutazione BMAD v6 e framework spec-driven, gap analysis e strategia (homegrown + skill `story-craft`, `spec-archive`, `project-kb-setup` estesa; roadmap completata; wave 2 con pattern adottati)

## Tools / Script

- `scripts/usage-report.py` — report consumi token e costo dalle sessioni opencode (DB read-only). Subcomandi `summary|export|sessions`, filtri `--days/--since/--until/--project/--model/--agent`, `--format json`, ledger CSV upsert.
- Comando `/usage` — report consumi token e costo dal TUI (vedi [commands/usage.md](commands/usage.md)).
- `scripts/install-hooks.sh` — attiva i pre-commit hook del repo (validate-jsonc, detect-private-key, markdownlint best-effort): `./scripts/install-hooks.sh` (imposta `git config core.hooksPath scripts/githooks`).

## Directory Structure

```text
opencode-config/
├── opencode.jsonc    # Main config
├── tui.json          # TUI config
├── AGENTS.md         # Istruzioni per gli agenti
├── agents/           # Custom agents
├── commands/         # Lane + /sync-config
├── rules/            # Always-on rules
├── skills/           # Skills markdown
├── memory/           # Memoria utente (esclusa dal sync)
├── wiki/             # Documentazione (Home.md = indice; mcp/, plans/, specs/)
├── global/           # Config alternative
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

Nessuna divergenza nota: `opencode.jsonc` è identico su tutte le macchine — `instructions` usa il formato `~/`, che opencode espande alla home utente su Linux e Windows (la config globale è `~/.config/opencode` su entrambe le piattaforme).

## Updates

```bash
cd ~/git/opencode-config && git pull
```
