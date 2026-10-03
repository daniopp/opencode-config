---
description: Report consumi token e costo dalle sessioni opencode
---
# Usage

Riporta i consumi token e il costo dalle sessioni opencode. $ARGUMENTS

Lavora con workdir `/home/daniele/git/opencode-config` per tutti i comandi.

Passi:

1. `python3 scripts/usage-report.py summary` passando a `$ARGUMENTS` i filtri
   richiesti (es. `--days 7`, `--project <nome>`, `--model <modello>`,
   `--agent <agente>`, `--since YYYY-MM-DD`, `--until YYYY-MM-DD`, `--format json`)
2. Presenta i risultati in una tabella (totale globale + breakdown per modello,
   agente e progetto)
3. Se l'utente chiede di registrare/salvare il report ("registra"/"salva"),
   esegui `python3 scripts/usage-report.py export` e riporta il path del ledger

Regole:

- Lo script accede al DB opencode SOLO in lettura (`?mode=ro`): non scrivere mai
  sul database né eseguire comandi che lo modifichino
