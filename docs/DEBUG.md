# Troubleshooting e debug

## Log in tempo reale

```bash
# Avvio con debug
~/start-opencode.sh --debug

# Oppure direttamente
opencode web --hostname 0.0.0.0 --port 80 --log-level DEBUG --print-logs
```

## File di log

```bash
# Lista log disponibili
ls -lt ~/.local/share/opencode/log/

# Segui l'ultimo log in tempo reale
tail -f ~/.local/share/opencode/log/$(ls -t ~/.local/share/opencode/log/ | head -1)
```

## Debug MCP locali

I comandi `opencode mcp debug/auth/logout` funzionano solo per server **remoti** (OAuth).
Per i server locali (stdio), testa il comando direttamente:

```bash
# Test manuale del server MCP locale
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_xxx /usr/local/bin/github-mcp-server stdio

# Verifica che npx sia nel PATH
which npx
npx --version
```

## Problemi comuni

### Errore: `Unrecognized keys: plugins, permissions, mcpServers`

Chiavi errate. Usa:
- `plugin` (non `plugins`)
- `permission` (non `permissions`)
- `mcp` (non `mcpServers`)

### Errore: `opencode: not found`

OpenCode non e' nel PATH. Soluzioni:
```bash
# Aggiungi al PATH permanentemente
echo 'export PATH="$HOME/.opencode/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Oppure usa il percorso assoluto nello script
OPENCODE_BIN="$HOME/.opencode/bin/opencode"
```

### MCP con pallino rosso nella UI

1. Verifica che Node.js sia installato: `node --version`
2. Usa percorsi assoluti per `npx`: `which npx`
3. Prova il comando manualmente dalla shell
4. Controlla i log con `--debug`

### Errore: `OPENCODE_SERVER_PASSWORD is not set`

```bash
export OPENCODE_SERVER_PASSWORD="tua-password"
~/start-opencode.sh
```

### npm E404 su pacchetti MCP

`@github/github-mcp-server` NON esiste su npm.
Usa il remote server o compila da Go. Vedi `mcp/GITHUB_MCP.md`.
