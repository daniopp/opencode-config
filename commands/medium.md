---
description: "Medium lane per lavoro scoped con piano"
agent: orchestrator
subtask: true
---

# Medium Lane

Per lavoro scoped con piano documentato.

## Flusso

1. **Intake** - chiarisci il goal e i vincoli

2. **Lightweight discovery** - esplora il contesto necessario

3. **Scoped plan** - salva come `plans/{feature-name}/plan.md`:
    - Obiettivo chiaro
    - Scope definito
    - Track di implementazione
    - Criteri di successo verificabili: ogni criterio con la sua evidenza concreta (test da passare, lint, `path:line`, output atteso)

4. **Pre-flight review** - manda il piano a `reviewer` solo se ≥ 2 track o si toccano file condivisi; incorpora solo obiezioni supportate da evidenze

5. **Approval gate** - obbligatoria, chiedi `[y/N/edit]` sul file

6. **Execution** - segui i track nell'ordine

7. **Monitoring** - se test falliscono:
   - `fixer` per fix locali e ovvi
   - `oracle` per fallimenti complessi

8. **Wrap-up** - summary e verifica

## Output

- `plans/{feature}/plan.md` - piano obbligatorio
- `plans/{feature}/track-1.md` - eventuali track separati

## Token budget

Max 20k tokens per ciclo. Usa compaction.
