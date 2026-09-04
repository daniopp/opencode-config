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
   - Criteri di successo

4. **Approval gate** - obbligatoria, chiedi `[y/N/edit]` sul file

5. **Execution** - segui i track nell'ordine

6. **Monitoring** - se test falliscono:
   - `implementation-agent` per fix locali e ovvi
   - `test-fixer-agent` per fallimenti complessi

7. **Wrap-up** - summary e verifica

## Output

- `plans/{feature}/plan.md` - piano obbligatorio
- `plans/{feature}/track-1.md` - eventuali track separati

## Token budget

Max 20k tokens per ciclo. Usa compaction.
