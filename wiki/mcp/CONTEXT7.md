# Context7 MCP

Context7 fornisce documentazione aggiornata di librerie e framework direttamente nel contesto dell'agente.

## Installazione

`@upstash/context7-mcp` NON e' pubblicato su npm come pacchetto eseguibile standalone.

### Opzione 1: npx (se Node.js e' installato)

```bash
# Verifica prima che funzioni:
npx -y @upstash/context7-mcp --help
```

Config:
```jsonc
{
  "mcp": {
    "context7": {
      "type": "local",
      "command": ["/percorso/assoluto/a/npx", "-y", "@upstash/context7-mcp"],
      "enabled": true
    }
  }
}
```

Per trovare il percorso assoluto di npx:
```bash
which npx
```

### Opzione 2: Installazione globale

```bash
npm install -g @upstash/context7-mcp
which context7-mcp
```

Config:
```jsonc
{
  "mcp": {
    "context7": {
      "type": "local",
      "command": ["/home/user/.npm/bin/context7-mcp"],
      "enabled": true
    }
  }
}
```

## Prerequisiti

- Node.js installato (verifica: `node --version`)
- Se usi nvm, usa percorsi assoluti nei comandi MCP
