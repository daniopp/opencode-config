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

# Log V2 principale
tail -f ~/.local/share/opencode/log/opencode.log
```

Warning da cercare nel log: `configuration normalization diagnostic` indica chiavi legacy V1 ignorate (vedi [MIGRATION-V1-V2.md](MIGRATION-V1-V2.md)).

## Servizio e API V2

```bash
opencode service status
opencode service restart
opencode api get /api/info     # check che il servizio risponda
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

### Errore con config V1 in V2 (`Unrecognized keys: plugins, permissions, mcpServers`)

Errore di config V1 letta da V2, oppure config V2 scritta con chiavi errate.
Verifica:

- nel log, cerca il warning `configuration normalization diagnostic`: indica le chiavi legacy ignorate;
- chiavi V2 corrette: `plugins`, `permissions` (array di `{ action, resource, effect }`), `mcp`, `agents`, `providers`, `snapshots`;
- chiavi V1 da sostituire: `plugin`, `permission`, `agent`, `provider`, `snapshot`, `small_model` (→ `agents.title.model`), `compaction.prune`.

Guida completa: [MIGRATION-V1-V2.md](MIGRATION-V1-V2.md) e [Migrate from V1](https://opencode.ai/v2/docs/migrate-v1).

### Errore: `opencode: not found` o binario sbagliato

Verifica quale binario viene eseguito e la versione:

```bash
which -a opencode
opencode --version     # deve essere 2.x
```

Se `which -a` mostra più installazioni, rimuovi quella V1 gestita da package manager (vedi [INSTALL.md](INSTALL.md)). Il path `~/.opencode/bin` non è più il riferimento: il binario V1 è stato sostituito dall'installer V2.

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
Usa il remote server o compila da Go. Vedi `wiki/mcp/GITHUB_MCP.md`.
