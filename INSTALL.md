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

### Lanes (comandi)

| Lane | Uso |
|------|-----|
| `/quick` | Task semplici, rapide iterazioni |
| `/medium` | Task medi, multi-file |
| `/full` | Task complessi, multi-fase |
| `/debug` | Debug e troubleshooting |

### Skills

Available npm skills in `skills/`:

- `clonedeps` - Clona dipendenze per inspect source code
- `codemap` - Genera mappe gerarchiche del codebase
- `deepwork` - Workflow ad alto costo per task complessi
- `oh-my-opencode-slim` - Tunning configurazione opencode
- `reflect` - Review e improvement workflow
- `simplify` - Simplificazione codice
- `verification-planning` - Planning verifica per task non-triviali
- `worktrees` - Gestione Git worktrees per coding isolate

### MCP Servers

Configurati in `opencode.jsonc`:

| Server | Scopo |
|--------|-------|
| `with-context` | Session management e tracking |
| `github` | GitHub API access |
| `filesystem` | File system access |
| `sequential-thinking` | Complex reasoning |
| `memory` | Persistent knowledge graph |

### Perm



Configurati in `opencode.jsonc`:

| Categoria | Default | Note |
|-----------|---------|------|
| `read` | allow | Deny su `*.env*`, `*.dev.vars` |
| `edit` | allow | Copre write e patch |
| `bash` | ask | Allowlist granulare (git, ls, rg, ecc.) |
| `external_directory` | ask | Allow su `~/git/**`, `/tmp/**` |

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
