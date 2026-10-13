# Setup completo OpenCode

## Prerequisiti

- OpenCode V2 installato (`opencode --version` → `2.x`, vedi [INSTALL.md](INSTALL.md))
- Node.js (opzionale, per MCP locali)

## 1. Installazione config globale

La config live è `~/.config/opencode/` (config globale `opencode.jsonc`, config terminale `cli.json`). Si allinea dal repo con:

```bash
cd ~/git/opencode-config && scripts/sync.sh pull
```

Modifica il modello se necessario, nella forma V2 (`model`):

```jsonc
{
  "model": "anthropic/claude-sonnet-4-5"
}
```

## 2. Script di avvio

```bash
cp scripts/start-opencode.sh ~/start-opencode.sh
chmod +x ~/start-opencode.sh
```

Modifica le variabili all'inizio dello script:

```bash
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_xxx"
export OPENCODE_SERVER_PASSWORD="tua-password-sicura"
```

## 3. MCP

Nessun server MCP configurato (`mcp: {}`). Il GitHub MCP è stato rimosso: GitHub si usa via CLI `gh`.

## 4. Plugin

Chiave V2: `plugins` in `opencode.jsonc` (era `plugin` in V1). Attualmente è vuota (`"plugins": []`): nessun plugin installato.

Il comando `opencode plugin install ...` non è verificato in V2: non usarlo finché non è confermato con la doc [Plugins](https://opencode.ai/v2/docs/plugins) (da verificare). Per aggiungere un plugin, aggiungilo a `plugins` dopo aver verificato la sintassi V2 in quella pagina.

## 5. LSP

Con `lsp: true` OpenCode abilita tutti i server LSP supportati automaticamente.
I binari LSP devono essere presenti nel PATH:

| Linguaggio | Comando richiesto |
|---|---|
| Java | `jdtls` (Java 21+) |
| Go | `gopls` |
| C# | OmniSharp |
| TypeScript | `typescript-language-server` |

## 6. Primo avvio

```bash
# Avvio normale
~/start-opencode.sh

# Avvio con debug (per troubleshooting)
~/start-opencode.sh --debug

# Avvio su repo specifico
~/start-opencode.sh ~/git/mio-repo
```

Apri `http://localhost:80` nel browser.
