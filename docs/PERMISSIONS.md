# Gestione permessi e sicurezza

## Modello least-privilege

La configurazione usa un approccio conservativo: tutto richiede conferma esplicita, salvo operazioni di sola lettura.

## Chiavi di permission

| Chiave | Descrizione | Valore consigliato |
|---|---|---|
| `edit` | Modifiche a file nel progetto | `ask` |
| `bash` | Esecuzione comandi shell | `ask` |
| `webfetch` | Lettura URL esterni | `allow` |

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
