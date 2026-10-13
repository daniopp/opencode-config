# Opencode Architecture

Documentazione della configurazione opencode.

## Panoramica

Questo repo contiene la configurazione globale opencode, strutturata per essere:

- **Replicabile** su diverse macchine
- **Versionabile** tramite git
- **Manutenibile** tramite documentazione chiara

## Struttura delle directory

```text
~/.config/opencode/
├── opencode.jsonc         # Config globale V2 con permessi granulari
├── AGENTS.md              # Documentazione e regole globali
├── oh-my-opencode-slim.jsonc  # (inattivo) preset modelli ex-plugin, solo riferimento
├── agents/                # Agenti nativi (.md con frontmatter YAML)
│   ├── README.md
│   ├── orchestrator.md
│   ├── explorer.md
│   ├── librarian.md
│   ├── oracle.md
│   ├── fixer.md
│   ├── designer.md
│   └── observer.md
├── commands/              # Lane di lavoro
│   ├── README.md
│   ├── quick.md           # Cambiamenti isolati
│   ├── medium.md          # Lavoro scoped
│   ├── full.md            # Alto rischio
│   └── debug.md           # Triage e fix
├── rules/                 # Regole always-on
│   └── README.md
├── skills/                # Skill npm
└── scripts/               # Utility di validazione
    └── validate-jsonc.sh
```

La config terminale V2 `cli.json` sta in `~/.config/opencode/cli.json`, fuori dal repo (vedi sotto).

## File di configurazione

### opencode.jsonc

JSONC nativo V2. Chiavi principali:

- **$schema**, **model** - Schema e modello primario
- **default_agent** - Agente di default
- **providers** - Provider (era `provider` in V1)
- **plugins** - Plugin (era `plugin` in V1); attualmente `[]`
- **permissions** - Array ordinato di regole `{ action, resource, effect }`; vince l'ultima che matcha (era `permission` in V1)
- **agents** - Agenti (era `agent`): disabilitazione built-in `explore`, `general`, `scout`; **agents.title.model** sostituisce `small_model`
- **instructions** - File di regole caricati all'avvio
- **experimental.subagent_depth** - Profondità nesting subagent (1 = nessun nesting)
- **lsp**, **compaction** (`{ auto }`), **watcher**, **snapshots** (era `snapshot`), **share**, **mcp** (`{}`)

Chiavi V1 non più valide: `small_model`, `snapshot`, `plugin`, `provider`, `permission`, `agent`, `compaction.prune` (rimosso in V2). Il warning `configuration normalization diagnostic` nel log indica chiavi legacy ignorate.

### cli.json

Config del client terminale V2, globale, in `~/.config/opencode/cli.json`. È posseduta dal client terminale: il servizio in background non la carica. Sostituisce i file `tui.json` / `tui.jsonc` layerati di V1. Non fa parte del repo e non viene sincronizzata da `scripts/sync.sh`. Se `cli.json` manca, al primo avvio del client terminale V2 vengono migrate le impostazioni globali di `tui.json`; i file V1 restano invariati. Contenuto e chiavi: da verificare con [CLI](https://opencode.ai/v2/docs/cli).

## Permessi

Matrice permessi V2 (default quando nessuna regola matcha: `ask`):

| Azione | Default | Note |
|---|---|---|
| read | allow | deny su *.env*, *.dev.vars |
| edit | allow | Copre edit, write e patch |
| shell | ask | Era `bash` in V1. Allowlist granulare a 4 tier |
| subagent | ask | Era `task` in V1. Allowlist sugli specialisti (vedi sotto) |
| external_directory | ask | Sandbox: ~/git/**, /tmp/** |

`doom_loop` non è più un'azione V2: la protezione non è presente nella config. Dettagli in [PERMISSIONS.md](../PERMISSIONS.md).

## Lane (Comandi)

| Lane | Caso d'uso | Gate |
|---|---|---|
| /quick | 1 file, meccanico | Skippabile |
| /medium | Lavoro scoped, piano salvato | Obbligatorio |
| /full | Alto rischio, adversarial review | Obbligatorio |
| /debug | Triage + hypothesis-driven | Obbligatorio |

## Agenti

Nativi, definiti in `agents/*.md` (nessun plugin di terzi):

- **orchestrator** - Coordinatore (primary, 100 steps)
- **oracle** - Analisi architetturale (read-only, 25 steps)
- **designer** - UI/UX (100 steps)
- **fixer** - Implementazione (80 steps)
- **explorer** - Ricerca codice (read-only, 25 steps)
- **librarian** - Documentazione (read-only, 25 steps)
- **observer** - Monitoraggio (read-only, 20 steps)
- **reviewer** - Review avversariale (read-only, 20 steps)
- **verifier** - Verifica completion (read-only, 20 steps)
- **looker** - Media PDF/immagini (read-only, 15 steps)

Gerarchia: `experimental.subagent_depth: 1` in `opencode.jsonc` + allowlist
`subagent` nei permessi (era `permission.task`) — solo l'orchestrator può
delegare, i subagent non spawnano altri subagent.
I preset modelli dell'ex-plugin sono in `oh-my-opencode-slim.jsonc`
(riferimento storico, inattivo).

## Scripts

### validate-jsonc.sh

Valida la sintassi JSONC:

```bash
./scripts/validate-jsonc.sh
```

## Installazione su nuova macchina

1. Clona il repo
2. Copia in `~/.config/opencode/`
3. Installa OpenCode V2 (vedi [INSTALL.md](INSTALL.md)); nessuna dipendenza npm (`plugins: []`)
4. Modifica `opencode.jsonc` se necessario (modelli, percorsi)

## Versionamento

- Usa `git commit` per ogni modifica significativa
- I pre-commit hooks (da aggiungere) validano:
  - Syntax JSONC
  - Markdown lint
  - Detection di secret/private keys

## Best practices

1. **Non modificare node_modules** - sempre reinstallato
2. **Non commitare credenziali** - usa .gitignore
3. **Usa permissions granulari** - più sicuro
4. **Documenta modifiche** - AGENTS.md
5. **Testa prima di deploy** - usa validate-jsonc.sh
