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

- `oh-my-opencode-slim` — preset modelli per agente
- `opencode-keepalive` — keepalive

## Agenzi forniti da oh-my-opencode-slim

- `orchestrator` — coordinatore principale
- `oracle` — analisi architetturale
- `designer` — UI/UX
- `fixer` — implementazione rapida
- `explorer` — ricerca codice
- `librarian` — ricerca documentazione
- `council` — discussione multi-agente
- `councillor` — analisi individuale
- `observer` — monitoraggio

## Lane disponibili

Usa `/quick`, `/medium`, `/full`, `/debug` nel TUI.

## Prossimi passi

1. [ ] Aggiungere agenti custom in `agents/` (opzionale)
2. [ ] Creare `AGENTS.md` con regole globali (< 10 righe)
3. [ ] Aggiungere pre-commit: validate-jsonc, markdownlint, detect-private-key
4. [ ] Documentare MCP servers aggiuntivi
5. [ ] Migrare skills npm → markdown (.opzionale)
