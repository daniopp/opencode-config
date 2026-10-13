# Opencode Config

Configurazione globale opencode.

## File principali

- `opencode.jsonc` — config principale (questa)
- `cli.json` (live in `~/.config/opencode/`, fuori dal repo) — config terminale V2; `tui.json` rimosso con la migrazione V2 (non più presente né nel repo né in live)
- `agents/` — agenti .md personalizzati
- `commands/` — lane (/quick, /medium, /full, /debug)
- `rules/` — regole always-on su due file, caricate via `instructions`: `rules.md` v2.2.0 = invarianti universali per tutti i progetti; `evodoc.md` v1.1.0 = perimetro EVODOC (repo `ZD_*` o con `evodoc`/`zerod` nel nome; limite 64 caratteri versione prerelease/50 caratteri nome branch), fonte wiki ZD_evoDoc2
- `scripts/wiki-sync.ps1|.sh` — mirror wiki ZD_evoDoc2 in `wiki-mirror/` (git-ignored); `-InstallTask` crea task pianificata Windows giornaliera
- `skills/` — skill npm

## Permessi

Matrice permessi (`opencode.jsonc`), pattern elithrar:

| Livello | Default | Note |
|---|---|---|
| `doom_loop` | ask | Conferma prima di ripetere |
| `read` | allow | deny su `*.env*`, `*.dev.vars` |
| `edit` | allow | copre anche write/patch |
| `bash` | ask | allowlist a 4 tier calibrata sullo storico sessioni (letture/scritture sicure → allow, distruttivi → deny) |
| `external_directory` | ask | solo `~/git/**`, `/tmp/**` |

## Plugin

Nessuno (`plugin: []` in entrambi i config).

## GitHub

Uso esclusivo della CLI `gh` (autenticata su tutte le macchine, allowlistata nei permessi bash). Nessun MCP server github: il token `GITHUB_TOKEN` era invalido e il server duplicava le funzioni di `gh`.

## Agenti (nativi, `agents/*.md`)

- `orchestrator` — coordinatore principale (primary, `opencode-go/claude-haiku-5-5`)

- `fixer`, `reviewer`, `verifier`, `looker`, `explorer`, `librarian`, `observer` — specialisti su `opencode-go/claude-haiku-5-5`
- `designer` — UI/UX (`opencode-go/muse-spark-1.3-contributor`)
- `oracle` — advisor strategico (`openrouter/anthropic/claude-sonnet-5.5`)

I subagent non spawnano altri subagent (`subagent_depth: 1`); l'orchestrator
delega via `task` tool con allowlist su 9 specialisti (explorer, librarian, oracle, designer, fixer, observer, reviewer, verifier, looker).

## Lane disponibili

Usa `/quick`, `/medium`, `/full`, `/debug` nel TUI.

## Sync con il repo

Config live `~/.config/opencode` ↔ repo `~/git/opencode-config` (`danismeup/opencode-config`):

- `scripts/sync.sh status|diff|push|pull` nel repo (allowlistato in bash). Nessuna divergenza nota: `opencode.jsonc` è identico su tutte le macchine — `instructions` usa il formato `~/` (`~/.config/opencode/rules/rules.md`), che opencode espande con `os.homedir()` su Linux e Windows
- Comando `/sync-config` — l'orchestrator esegue status → push → commit → push
- Progetti fidati: copiare `repo-examples/opencode-project-trusted.jsonc` nella root del progetto come `opencode.jsonc` — bash passa a allow-by-default con deny sui distruttivi (`rm -rf`, `sudo`, `push --force`, `reset --hard`, `clean -f`, `restore`, `prune`). Attivi su: `~/git/proloco-workspace`, `~/git/proloco-workspace/eco-system`, `/opt/proloco/proloco-workspace`, `/opt/proloco/proloco-workspace/eco-system`

## MCP servers

Nessuno (`mcp: {}`). Rimossi dopo verifica su opencode.db (zero invocazioni nello storico sessioni):
`with-context` (33 tool), `filesystem` (duplica i tool nativi), `sequential-thinking`, `memory`,
`github` (sostituito da CLI `gh`). I tool `memory_*` usati in sessione sono built-in di opencode.

## Prossimi passi

1. [ ] Aggiungere agenti custom in `agents/` (opzionale)
2. [x] Aggiungere pre-commit: validate-jsonc, markdownlint, detect-private-key (attivi da `scripts/githooks/pre-commit`; markdownlint config in `.markdownlint.jsonc`)
