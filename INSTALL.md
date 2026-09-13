# Opencode Setup

Guida per installare e configurare opencode.

## Prerequisites

- **Node.js** >= 18 (consigliato: `nvm`)
- **Git**
- **GitHub CLI** (`gh`) per PR functionality
- **rsync** (consigliato, usato da `scripts/sync.sh`)

## Installation

### 1. Install Opencode CLI

```bash
# Via npm (globale)
npm install -g @opencode/ai

# Oppure via npx (uso diretto)
npx @opencode/ai
```

### 2. Clone questa configuration repo

```bash
git clone https://github.com/danismeup/opencode-config.git ~/git/opencode-config
cd ~/git/opencode-config
```

### 3. Setup Environment Variables

Crea `.dev.vars` nel repo:

```bash
OPENROUTER_API_KEY=your_openrouter_api_key
```

### 4. Activate the Configuration

```bash
# Sync repo -> config live (~/.config/opencode)
scripts/sync.sh pull

# Lancia opencode da qualsiasi directory
opencode
```

## Installation su WSL (Windows Subsystem for Linux)

Questi passi sono ottimizzati per WSL su Windows:

### Prerequisites WSL

```bash
# 1. Install Node.js via nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install --lts

# 2. Verifica Node.js
node --version
npm --version

# 3. Install GitHub CLI (se non presente)
sudo apt update && sudo apt install gh
gh auth login

# 4. Install rsync (per scripts/sync.sh)
sudo apt install rsync
```

### Setup Opencode in WSL

```bash
# 1. Install opencode CLI
npm install -g @opencode/ai

# 2. Clone config
git clone https://github.com/danismeup/opencode-config.git ~/git/opencode-config
cd ~/git/opencode-config

# 3. Setup credentials (OPENROUTER_API_KEY)
echo "OPENROUTER_API_KEY=your_token" > .dev.vars

# 4. Sync verso la config live e run
scripts/sync.sh pull
opencode
```

### Note WSL

- I path di config (`~/git/opencode-config`) funzionano nativamente in WSL
- Se usi Windows Terminal, apri direttamente una sessione WSL
- Per accedere da client Windows, usa il TUI nella terminale WSL

## Model Providers e API Keys

Modelli correnti, via OpenRouter (prezzi di listino $/M token):

| Ruolo | Modello | in | out | cache read |
|-------|---------|----|----|------------|
| Primario | `z-ai/glm-5.3-flash` | 0.15 | 0.50 | 0.03 |
| Small model | `deepseek/deepseek-v4-flash-0731` | 0.05 | 0.16 | 0.013 |

Config in `opencode.jsonc`:

```json
{
  "model": "openrouter/z-ai/glm-5.3-flash",
  "small_model": "openrouter/deepseek/deepseek-v4-flash-0731"
}
```

### OpenRouter

1. Ottieni la tua API key da [openrouter.ai](https://openrouter.ai/keys)
2. Aggiungi la key in `.dev.vars`:

```bash
OPENROUTER_API_KEY=your_api_key_here
```

Nota: il primario ha override espliciti in `opencode.jsonc` (limit 1M context / 131K output, cost di listino, sampling `temperature: 1.0 / top_p: 1.0` consigliato Z.ai per coding agentico).

## Configuration Overview

### Agenti

Questa configurazione usa agenti custom in `agents/*.md` invece di quelli built-in:

| Agente | Scopo | Modello |
|--------|-------|---------|
| `orchestrator` | Coordinatore principale, gestione workflow | `z-ai/glm-5.3-flash` |
| `explorer` | Ricerca codice read-only | `deepseek-v4-flash-0731` |
| `librarian` | Ricerca documentazione read-only | `deepseek-v4-flash-0731` |
| `oracle` | Analisi architetturale read-only | `deepseek-v4-flash-0731` |
| `reviewer` | Review avversariale di piani e codice | `deepseek-v4-flash-0731` |
| `verifier` | Verifica completamento con evidenze | `deepseek-v4-flash-0731` |
| `fixer` | Implementazione rapida e scoped | `deepseek-v4-flash-0731` |
| `observer` | Monitoring read-only | `deepseek-v4-flash-0731` |
| `designer` | UI/UX design e implementation | `meta/muse-spark-1.3-contributor` |

**Per dettagli su ciascun agente, vedi [`agents/README.md`](agents/README.md).**

### Lanes (comandi)

Le lanes definiscono il workflow di lavoro:

| Lane | Uso |
|------|-----|
| `/quick` | Task semplici, rapide iterazioni |
| `/medium` | Task medi, multi-file |
| `/full` | Task complessi, multi-fase |
| `/debug` | Troubleshooting e analisi errori |
| `/sync-config` | Sync config live ↔ repo |

**Per dettagli su ciascuna lane, vedi [`commands/README.md`](commands/README.md).**

### Skills

Skills markdown in `skills/`:

| Skill | Scopo |
|-------|-------|
| `auto-docs` | Documentazione di sviluppo auto-mantenuta |
| `bugfix-debugging` | Diagnosi bug, disciplina reproduce-first |
| `clonedeps` | Clone dependency source code per inspection |
| `codemap` | Generate codebase maps |
| `csharp-tests` | Test C# XUnit + FluentAssertions (EVODOC) |
| `completion-gate` | Gate di verifica finale prima del report |
| `deepwork` | High-stakes coding workflow |
| `docs-sync` | Allineamento documentazione prodotto |
| `evodoc-pr` | Workflow GitHub EVODOC end-to-end |
| `gh-templates` | Template GitHub issue/PR/discussion |
| `project-kb-setup` | Knowledge base AI dentro il repo |
| `reflect` | Learn from past sessions |
| `simplify` | Simplify code for clarity |
| `verification-planning` | Plan verification for non-trivial tasks |
| `worktrees` | Isolated coding lanes with Git worktrees |

**Per dettagli su ciascuna skill, vedi [`skills/README.md`](skills/README.md).**

### MCP Servers

Nessuno (`mcp: {}`). Rimossi dopo verifica su opencode.db (zero invocazioni nello storico sessioni): `with-context`, `filesystem`, `sequential-thinking`, `memory`, `github` (sostituito dalla CLI `gh` autenticata).

### Permessi

Configurati in `opencode.jsonc`:

| Categoria | Default | Note |
|-----------|---------|------|
| `read` | allow | Deny su `*.env*`, `*.dev.vars` |
| `edit` | allow | Copre write e patch |
| `bash` | ask | Allowlist 4 tier dallo storico sessioni (ls, grep, find, git, docker ps... → allow; distruttivi → deny) |
| `external_directory` | ask | Allow su `~/git/**`, `/tmp/**` |

### Progetti fidati (bash allow-by-default)

In un progetto fidato bash passa a "tutto allow tranne i distruttivi" senza conferme continue:

```bash
cp ~/git/opencode-config/repo-examples/opencode-project-trusted.jsonc ~/git/<progetto>/opencode.jsonc
```

Restano deny: `rm -rf`, `sudo`, `git push --force` (anche via `git -C`), `git reset --hard`, `git clean -f`, `git checkout --`, `git restore`, `docker system prune`, `docker volume rm`, `gh release/pr delete`, `dotnet ef database drop`.

Riavvia opencode nella directory del progetto per caricare la config (le config progetto si fondono con quella globale e la sovrascrivono).

### Sync config ↔ repo

```bash
cd ~/git/opencode-config
scripts/sync.sh status   # confronto read-only
scripts/sync.sh diff     # dettaglio differenze
scripts/sync.sh push     # locale -> repo (poi commit/push)
scripts/sync.sh pull     # repo -> locale
```

Divergenza nota (sync saltato di proposito): `opencode.jsonc` sezione `instructions` — path Windows nel repo vs Linux in locale. Il comando `/sync-config` esegue il flusso completo via orchestrator.

### Opencode Documentation

Per informazioni più dettagliate su opencode CLI:

- **Documentazione ufficiale:** [opencode.ai/docs](https://opencode.ai/docs)
- **Configurazione:** [opencode.ai/config](https://opencode.ai/config)
- **Model Provider:** [opencode.ai/models](https://opencode.ai/models)

## Updating

```bash
cd ~/git/opencode-config
git pull
scripts/sync.sh pull
```

## Troubleshooting

### Configuration non carica

```bash
# Verifica struttura directory
ls -la ~/.config/opencode/

# Check file config
cat ~/git/opencode-config/opencode.jsonc

# Escape hatch: avvia senza la config di progetto per correggerla
OPENCODE_DISABLE_PROJECT_CONFIG=1 opencode
```

### Sync.sh segnala divergenze inattese

```bash
# Dettaglio delle differenze
scripts/sync.sh diff
```

Le divergenze note sono mappate in `scripts/sync.sh` (chiave `DIVERGENT`); tutto il resto dovrebbe essere identico dopo un push/pull.
