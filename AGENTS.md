# Opencode Config

Configurazione globale opencode.

## File principali

- `opencode.jsonc` — config principale (questa)
- `tui.json` — tema e keybinds
- `agents/` — agenti .md personalizzati
- `commands/` — lane (/quick, /medium, /full, /debug)
- `skills/` — skill npm
- `rules/` — regole always-on

## Permessi

Matrice permessi (`opencode.jsonc`), pattern elithrar:

| Livello | Default | Note |
|---|---|---|
| `doom_loop` | ask | Conferma prima di ripetere |
| `read` | allow | deny su `*.env*`, `*.dev.vars` |
| `edit` | allow | copre anche write/patch |
| `bash` | ask | allowlist per sottocomando, deny su `rm -rf`, `git push --force` |
| `external_directory` | ask | solo `~/git/**`, `/tmp/**` |

## Plugin

- `opencode-keepalive` — keepalive

## Agenti (nativi, `agents/*.md`)

- `orchestrator` — coordinatore principale (primary)
- `explorer` — ricerca codice (read-only)
- `librarian` — ricerca documentazione (read-only)
- `oracle` — analisi architetturale (read-only)
- `fixer` — implementazione rapida
- `designer` — UI/UX
- `observer` — monitoraggio (read-only)

I subagent non spawnano altri subagent (`subagent_depth: 1`); l'orchestrator
delega via `task` tool con allowlist su questi 6 specialisti.

## Lane disponibili

Usa `/quick`, `/medium`, `/full`, `/debug` nel TUI.

## Prossimi passi

1. [ ] Aggiungere agenti custom in `agents/` (opzionale)
2. [ ] Creare `AGENTS.md` con regole globali (< 10 righe)
3. [ ] Aggiungere pre-commit: validate-jsonc, markdownlint, detect-private-key
4. [ ] Documentare MCP servers aggiuntivi
5. [ ] Migrare skills npm → markdown (.opzionale)
