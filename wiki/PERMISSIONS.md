# Gestione permessi e sicurezza

Fonte: [Permissions (V2)](https://opencode.ai/v2/docs/permissions).

## Modello least-privilege

La configurazione usa un approccio conservativo: tutto richiede conferma esplicita, salvo operazioni di sola lettura.

## Forma V2

In V2 i permessi sono un **array ordinato** `permissions` in `opencode.jsonc`. Ogni regola ha tre campi stringa:

| Campo | Significato |
|---|---|
| `action` | Tipo di permesso (vedi tabella sotto) |
| `resource` | Valore su cui agire: percorso, comando shell, URL, query, ID skill o agente |
| `effect` | `allow`, `deny` oppure `ask` |

Regole di valutazione:

- **Vince l'ultima regola che matcha.** Le regole generiche vanno prima, le eccezioni dopo.
- **Nessun match = `ask`.**
- Wildcard: `*` = zero o più caratteri (anche `/`), `?` = un carattere. Il pattern deve coprire l'intero valore normalizzato.
- Un pattern shell che termina con spazio e `*` matcha anche il comando senza argomenti: `git status *` matcha sia `git status` sia `git status --short`.

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "permissions": [
    { "action": "read", "resource": "*", "effect": "allow" },
    { "action": "read", "resource": "*.env", "effect": "deny" }
  ]
}
```

## Azioni

| Azione | Descrizione | Valore consigliato |
|---|---|---|
| `read` | Lettura file | `allow`, con deny su `*.env*`, `*.dev.vars` |
| `edit` | Modifiche a file (copre edit, write, patch) | `allow` |
| `shell` | Esecuzione comandi shell (era `bash` in V1) | `ask` |
| `subagent` | Delega a un agente (era `task` in V1) | secondo agente |
| `webfetch` | Lettura URL esterni | `allow` |
| `websearch` | Ricerche web | `allow` o `ask` |
| `external_directory` | Accesso fuori dal progetto | `ask`, allow su `~/git/**`, `/tmp/**` |

Altre azioni supportate dalla doc V2 (`question`, `skill`, `execute`, tool MCP `<server>_<tool>`) sono descritte in [Permissions](https://opencode.ai/v2/docs/permissions).

Migrazione da V1: `bash` → `shell`, `task` → `subagent`, `write`/`patch` → `edit`. `doom_loop` non è più un'azione V2: la sua protezione non è presente nella config.

## Allowlist shell (opencode.jsonc)

Regole `action: shell`, in ordine: prima il default generico, poi le eccezioni. Su Windows opencode esegue via pwsh, quindi l'allowlist include anche i cmdlet PowerShell (TIER 6).

```jsonc
{
  "permissions": [
    { "action": "shell", "resource": "*", "effect": "ask" },
    { "action": "shell", "resource": "git status *", "effect": "allow" },
    { "action": "shell", "resource": "git push --force*", "effect": "deny" }
  ]
}
```

| Tier | Categoria | Esempi | Azione |
|---|---|---|---|
| 1 | Letture | `git status/diff/log`, `rg`, `jq`, `gh pr view`, `Get-Content`, `Select-String`, `ConvertFrom/To-Json` | `allow` |
| 2 | Scritture sicure | `git add/commit`, `mkdir`, `cp`, `mv`, `Out-File`, `Set-Content`, `New-Item` | `allow` |
| 3 | Irreversibili | `Remove-Item` semplice, `git push`, tutto il resto | `ask` (default) |
| 4 | Distruttivi | `rm -rf`, `git push --force`, `Remove-Item -Recurse/-Force` | `deny` |
| 5 | Esecuzioni | `dotnet` | `allow` |
| 6 | PowerShell | `Get-Content`, `Get-Item`, `Select-*`, `Convert*Json`, `Out-File`, `Invoke-WebRequest` | `allow` |

### Note PowerShell (Windows)

Restano volutamente su `ask` (default):

- `Where-Object` / `ForEach-Object` — eseguono script block arbitrari (`{ Remove-Item ... }`)
- `Invoke-Expression` / `Invoke-Command` / `Start-Process` — esecuzione codice arbitrario
- Alias pwsh (`gc`, `gci`, `sls`, `iwr`, `rm`, ...) — usare i nomi completi dei cmdlet

Altri dettagli:

- I cmdlet di pipeline hanno anche la forma bare (`"ConvertTo-Json"` oltre a
  `"ConvertTo-Json *"`), perché il pattern `X *` non matcha `X` senza argomenti.
- `{ "action": "shell", "resource": "Get-Content *.env*", "effect": "deny" }` mantiene il deny dei segreti anche da shell (allineato al deny `*.env*` dell'azione `read`).
- `Invoke-WebRequest` è `allow` per coerenza con `webfetch: allow`, ma può fare
  POST verso host arbitrari (rischio esfiltrazione): passa a `ask` se serve
  massima sicurezza.
- Il riconoscimento dei comandi PowerShell dipende dallo scanner shell di V2 (opzione sperimentale `experimental.portable_shell_scanner`): da verificare con la doc [Permissions](https://opencode.ai/v2/docs/permissions) prima di fare affidamento sui tier 6 su Windows.

## Override per agente

Un agente può avere regole proprie in `agents.<nome>.permissions` (forma V2, vedi [migrazione](https://opencode.ai/v2/docs/migrate-v1)). Le chiavi `permission` dei frontmatter in `agents/*.md` sono tradotte automaticamente, ma la forma nativa è `permissions`.

```jsonc
{
  "agents": {
    "java-refactor": {
      "permissions": [
        { "action": "edit", "resource": "*", "effect": "allow" },
        { "action": "shell", "resource": "*", "effect": "ask" }
      ]
    },
    "readonly-analyst": {
      "permissions": [
        { "action": "edit", "resource": "*", "effect": "deny" },
        { "action": "shell", "resource": "*", "effect": "deny" }
      ]
    }
  }
}
```

## Sicurezza credenziali

- Non inserire mai secret in `opencode.jsonc` (finisce nel repo)
- Usa sempre `.opencode/env.sh` per le credenziali repo-specific
- Aggiungi `.opencode/env.sh` al `.gitignore`
- Imposta sempre `OPENCODE_SERVER_PASSWORD` se usi la web UI su rete
- Usa token GitHub con scope minimi (`repo`, `read:user`)
- Per MongoDB: preferisci utenti `db_datareader` o usa `--readOnly`
- Per SQL Server: usa utenti con soli permessi `SELECT`
