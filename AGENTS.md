# Opencode Config

Configurazione globale opencode.

## File principali

- `opencode.jsonc` — config principale (questa)
- `tui.json` — config TUI (attualmente quasi vuota, placeholder)
- `agents/` — agenti .md personalizzati
- `commands/` — lane (/quick, /medium, /full, /debug)
- `rules/` — regole always-on (`rules.md` = regole di sviluppo EVODOC, caricate via `instructions`)
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

- `orchestrator` — coordinatore principale (primary, `openrouter/z-ai/glm-5.3-flash`)
- `explorer`, `fixer`, `librarian`, `looker`, `observer`, `oracle`, `reviewer`, `verifier` — specialisti (`openrouter/deepseek/...`: flash per"rilegatura", `v4-pro` per `oracle`; `looker` = vision su `minimax-m3`)
- `designer` — UI/UX (`openrouter/meta/muse-spark-1.3-contributor`)

I subagent non spawnano altri subagent (`subagent_depth: 1`); l'orchestrator
delega via `task` tool con allowlist su 8 specialisti.

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
