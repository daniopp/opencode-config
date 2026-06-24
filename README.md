# opencode-config

Configurazione OpenCode per sviluppo enterprise: MCP, LSP, plugin, sicurezza e script di avvio.

Stack di riferimento: Java/Kotlin, .NET/C#, Go · MongoDB, SQL Server · GCP Cloud Run, Firebase · GitHub Actions, Docker

---

## Struttura del repo

```
opencode-config/
├── global/
│   └── opencode.jsonc         # Config globale (~/.config/opencode/opencode.jsonc)
├── scripts/
│   └── start-opencode.sh      # Script di avvio Linux/Bash
├── repo-examples/
│   ├── mongo/
│   │   ├── opencode.jsonc     # Config repo con MongoDB MCP
│   │   └── env.sh.example     # Variabili d'ambiente MongoDB
│   └── sqlserver/
│       ├── opencode.jsonc     # Config repo con SQL Server MCP
│       └── env.sh.example     # Variabili d'ambiente SQL Server
├── mcp/
│   ├── GITHUB_MCP.md          # Come configurare GitHub MCP (remote vs locale)
│   └── CONTEXT7.md            # Come configurare Context7
└── docs/
    ├── SETUP.md               # Guida setup completo
    ├── PERMISSIONS.md         # Gestione permessi e sicurezza
    ├── DEBUG.md               # Troubleshooting e debug MCP
    └── CHANGELOG.md           # Storico modifiche configurazione
```

---

## Installazione rapida

### 1. Copia la config globale

```bash
mkdir -p ~/.config/opencode
cp global/opencode.jsonc ~/.config/opencode/opencode.jsonc
```

### 2. Installa lo script di avvio

```bash
cp scripts/start-opencode.sh ~/start-opencode.sh
chmod +x ~/start-opencode.sh
```

### 3. Configura le variabili d'ambiente

Modifica `~/start-opencode.sh` e inserisci il tuo GitHub PAT e password server:

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_xxx"
export OPENCODE_SERVER_PASSWORD="tua-password"
```

### 4. Per un repo specifico con database

```bash
mkdir -p /path/to/repo/.opencode

# MongoDB
cp repo-examples/mongo/opencode.jsonc /path/to/repo/.opencode/opencode.jsonc
cp repo-examples/mongo/env.sh.example /path/to/repo/.opencode/env.sh
# Modifica env.sh con la tua connection string

# SQL Server
cp repo-examples/sqlserver/opencode.jsonc /path/to/repo/.opencode/opencode.jsonc
cp repo-examples/sqlserver/env.sh.example /path/to/repo/.opencode/env.sh
# Modifica env.sh con le tue credenziali
```

### 5. Avvio

```bash
# Avvia nella directory corrente
~/start-opencode.sh

# Avvia su un repo specifico
~/start-opencode.sh ~/git/mio-repo
```

---

## Note importanti

- Aggiungi `.opencode/env.sh` al `.gitignore` di ogni repo per non committare le credenziali
- Il server web OpenCode ascolta su `0.0.0.0:80` — imposta sempre `OPENCODE_SERVER_PASSWORD`
- I server MCP locali richiedono Node.js installato sulla macchina
- Per GitHub MCP si consiglia la modalità **remote** (vedi `mcp/GITHUB_MCP.md`)
