# Gestione permessi e sicurezza

## Modello least-privilege

La configurazione usa un approccio conservativo: tutto richiede conferma esplicita, salvo operazioni di sola lettura.

## Chiavi di permission

| Chiave | Descrizione | Valore consigliato |
|---|---|---|
| `edit` | Modifiche a file nel progetto | `ask` |
| `bash` | Esecuzione comandi shell | `ask` |
| `webfetch` | Lettura URL esterni | `allow` |

## Allowlist bash (opencode.jsonc)

Il matcher valuta l'**ultima** regola che matcha il comando: `"*": "ask"` sta
prima, le eccezioni specifiche dopo. Su Windows opencode esegue via pwsh, quindi
l'allowlist include anche i cmdlet PowerShell (TIER 6).

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
- `"Get-Content *.env*": "deny"` mantiene il deny dei segreti anche da shell
  (allineato al deny `*.env*` della chiave `read`).
- `Invoke-WebRequest` è `allow` per coerenza con `webfetch: allow`, ma può fare
  POST verso host arbitrari (rischio esfiltrazione): passa a `ask` se serve
  massima sicurezza.

## Override per repo

Nel `.opencode/opencode.jsonc` del repo puoi allentare i permessi per agenti specifici:

```jsonc
{
  "agents": {
    "java-refactor": {
      "permission": {
        "edit": "allow",
        "bash": "ask"
      }
    },
    "readonly-analyst": {
      "permission": {
        "edit": "deny",
        "bash": "deny"
      }
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
