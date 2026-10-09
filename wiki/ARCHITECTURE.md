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
├── opencode.jsonc         # Config principale con permessi granulari
├── tui.json               # Tema e keybinds
├── AGENTS.md              # Documentazione e regole globali
├── oh-my-opencode-slim.jsonc  # (inattivo) preset modelli ex-plugin, solo riferimento
├── package.json           # Dipendenze plugin npm
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

## File di configurazione

### opencode.jsonc

Contiene:

- **model** - Modello primario
- **small_model** - Modello economico per task leggeri
- **plugin** - Plugin npm
- **permission** - Matrice permessi granulari (elithrar pattern)
- **agent** - Disabilitazione agenti built-in (sostituiti da agents/*.md)
- **subagent_depth** - Profondità nesting subagent (1 = disabilitato)
- **compaction** - Compattazione automatica context
- **watcher** - Ignorare file/directories

### tui.json

Contiene:

- **theme** - Tema UI
- **keybinds** - Keybindings personalizzati

## Permessi

Matrice permessi con pattern elithrar:

| Tool | Default | Note |
|---|---|---|
| doom_loop | ask | Conferma loop infinito |
| read | allow | deny su *.env*, *.dev.vars |
| edit | allow | Copre write e patch |
| bash | ask | Allowlist granulare a 4 tier |
| external_directory | ask | Sandbox: ~/git/**, /tmp/** |

## Lane (Comandi)

| Lane | Caso d'uso | Gate |
|---|---|---|
| /quick | 1 file, meccanico | Skippabile |
| /medium | Lavoro scoped, piano salvato | Obbligatorio |
| /full | Alto rischio, adversarial review | Obbligatorio |
| /debug | Triage + hypothesis-driven | Obbligatorio |

## Agenti

Nativi, definiti in `agents/*.md` (nessun plugin di terzi):

- **orchestrator** - Coordinatore (primary, 250 steps)
- **oracle** - Analisi architetturale (read-only, 60 steps)
- **designer** - UI/UX (100 steps)
- **fixer** - Implementazione (120 steps)
- **explorer** - Ricerca codice (read-only, 40 steps)
- **librarian** - Documentazione (read-only, 50 steps)
- **observer** - Monitoraggio (read-only, 30 steps)

Gerarchia: `subagent_depth: 1` + `permission.task` allowlist — solo
l'orchestrator può delegare, i subagent non spawnano altri subagent.
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
3. Installa dipendenze: `npm install`
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
3. **Usa permission granulari** - più sicuro
4. **Documenta modifiche** - AGENTS.md
5. **Testa prima di deploy** - usa validate-jsonc.sh
