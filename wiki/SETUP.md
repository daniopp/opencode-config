# Setup completo OpenCode

## Prerequisiti

- OpenCode installato (`~/.opencode/bin/opencode`)
- Node.js (opzionale, per MCP locali)
- Go (opzionale, per compilare GitHub MCP server locale)

## 1. Installazione config globale

```bash
mkdir -p ~/.config/opencode
cp global/opencode.jsonc ~/.config/opencode/opencode.jsonc
```

Modifica il modello se necessario (es. per usare Claude invece di Kimi):
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

## 3. Autenticazione GitHub MCP

```bash
# Prima avviata in modalita' interattiva (non web)
opencode mcp auth github
```

## 4. Plugin

I plugin si installano automaticamente al primo avvio se configurati in `plugin`.
Se falliscono, installa manualmente:

```bash
opencode plugin install opencode-mem
opencode plugin install envsitter-guard
```

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
