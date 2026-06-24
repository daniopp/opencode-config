# Changelog

## 2026-06-24 - Setup iniziale

### Aggiunto
- Config globale con modello Kimi K2.7 Code via OpenCode Go
- Script di avvio `start-opencode.sh` con supporto env locale e flag `--debug`
- Esempi configurazione per repo con MongoDB e SQL Server
- Documentazione GitHub MCP (remote vs locale)
- Documentazione Context7 MCP
- Guida setup completo
- Gestione permessi e sicurezza
- Troubleshooting e debug

### Note
- `@github/github-mcp-server` non disponibile su npm, usare remote server
- Chiavi config corrette: `plugin`, `permission`, `mcp` (no plural)
- MCP locali richiedono Node.js installato separatamente
