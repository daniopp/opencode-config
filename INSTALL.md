# Opencode Setup

Guida per installare e configurare opencode.

## Prerequisites

- **Node.js** >= 18 (consigliato: `nvm`)
- **Git**
- **GitHub CLI** (`gh`) per PR functionality

## Installation

### 1. Install Opencode CLI

```bash
# Via npm (globale)
npm install -g @opencode/ai

# Oppure via npx (usa diretto)
npx @opencode/ai

### 2. Clone questa Configuration Repo

```bash
git clone https://github.com/your-org/opencode-config.git ~/opencode-config
cd ~/opencode-config
```

### 3. Setup Environment Variables

Crea `.dev.vars` nel repo:

```bash
GITHUB_TOKEN=your_github_personal_access_token
```

### 4. Activate the Configuration

```bash
# Lancial opencode dalla directory di config
cd ~/opencode-config
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
```

### Setup Opencode in WSL

```bash
# 1. Install opencode CLI
npm install -g @opencode/ai

# 2. Clone config
git clone https://github.com/danismeup/opencode-config.git ~/opencode-config
cd ~/opencode-config

# 3. Setup credentials (GITHUB_TOKEN)
echo "GITHUB_TOKEN=your_token" > .dev.vars

# 4. Run
opencode
```

### Note WSL

- I path di config (`~/opencode-config`) funzionano nativamente in WSL
- MCP servers funzionano senza modifiche
- Se usi Windows Terminal, apri direttamente una sessione WSL
- Per accedere da client Windows, usa il TUI nella terminale WSL

## Model Providers e API Keys

Questa configurazione usa `inception/mercury-2.5-preview` come modello primario. Ecco come configurare diversi provider:

### Opencode Mercury (default)

Nessuna API key richiesta - il modello è già incluso nella CLI.

### OpenRouter

1. Ottieni la tua API key da [openrouter.ai](https://openrouter.ai/keys)
2. Aggiorna `opencode.jsonc`:

```json
{
  "model": "openrouter/inception/mercury-2.5-preview",
  "small_model": "openrouter/inclusionai/ling-3.0-flash"
}
```

3. Aggiungi la key in `.dev.vars`:

```bash
OPENROUTER_API_KEY=your_api_key_here
```

### Opencode Zen/Go

1. Registrati su [opencode.ai](https://opencode.ai)
2. Ottieni la tua API key dal dashboard
3. Aggiungi in `.dev.vars`:

```bash
OPENCODE_API_KEY=your_api_key_here
```

4. La CLI userà automaticamente il provider configurato.

## Configuration Overview

### Agenti

Questa configurazione usa agenti custom in `agents/*.md` invece di quelli built-in:

| Agente | Scopo |
|--------|-------|
| `orchestrator` | Coordinatore principale, gestione workflow |
| `explorer` | Ricerca codice read-only |
| `librarian` | Ricerca documentazione read-only |
| `oracle` | Analisi architetturale read-only |
| `designer` | UI/UX design e implementation |
| `fixer` | Implementazione rapida e scope |
| `observer` | Monitoring read-only |

**Per dettagli su ciascun agente, vedi [`agents/README.md`](agents/README.md).**

### Lanes (comandi)

Le lanes definiscono il workflow di lavoro:

| Lane | Uso | Budget token |
|------|-----|--------------|
| `/quick` | Task semplici, rapide iterazioni | ~8K |
| `/medium` | Task medi, multi-file | ~16K |
| `/full` | Task complessi, multi-fase | ~32K |
| `/debug` | Troubleshooting e analisi errori | ~16K |

**Per dettagli su ciascuna lane, vedi [`commands/README.md`](commands/README.md).**

### Skills

Available npm skills in `skills/`:

| Skill | Scopo |
|-------|-------|
| `clonedeps` | Clone dependency source code per inspection |
| `codemap` | Generate codebase maps |
| `deepwork` | High-stakes coding workflow |
| `oh-my-opencode-slim` | Tune configuration |
| `reflect` | Learn from past sessions |
| `simplify` | Simplify code for clarity |
| `verification-planning` | Plan verification for non-trivial tasks |
| `worktrees` | Isolated coding lanes with Git worktrees |

**Per dettagli su ciascuna skill, vedi [`skills/README.md`](skills/README.md).**

### MCP Servers

Configurati in `opencode.jsonc`:

| Server | Scopo |
|--------|-------|
| `with-context` | Session management e tracking |
| `github` | GitHub API access |
| `filesystem` | File system access |
| `sequential-thinking` | Complex reasoning |
| `memory` | Persistent knowledge graph |

**Per dettagli su ciascun MCP server, vedi [`README.md`](README.md).**

### Perm

Configurati in `opencode.jsonc`:

| Categoria | Default | Note |
|-----------|---------|------|
| `read` | allow | Deny su `*.env*`, `*.dev.vars` |
| `edit` | allow | Copre write e patch |
| `bash` | ask | Allowlist granulare (git, ls, rg, ecc.) |
| `external_directory` | ask | Allow su `~/git/**`, `/tmp/**` |

### Opencode Documentation

Per informazioni più dettagliate su opencode CLI:

- **Documentazione ufficiale:** [opencode.ai/docs](https://opencode.ai/docs)
- **Configurazione:** [opencode.ai/config](https://opencode.ai/config)
- **Model Provider:** [opencode.ai/models](https://opencode.ai/models)

## Updating

```bash
cd ~/opencode-config
git pull
```

## Troubleshooting

### MCP servers non startano

```bash
# Check se node è installato
node --version

# Reinstall MCP servers
npx with-context-mcp
npx @modelcontextprotocol/server-github
```

### Configuration non carica

```bash
# Verifica struttura directory
ls -la ~/opencode-config/

# Check file config
cat ~/opencode-config/opencode.jsonc
```
