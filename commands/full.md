---
description: "Full lane per lavoro ad alto rischio"
agent: orchestrator
subtask: true
---

# Full Lane

Per lavoro complesso ad alto rischio.

## Flusso

1. **Intake** - chiarisci goal, vincoli, e stakeholder

2. **Discovery completo** - esplora il contesto necessario

3. **Plan** - salva come `plans/{feature-name}/plan.md`

4. **Adversarial review** - manda il piano a `reviewer-agent`:
   - Se complesso, second review opzionale
   - Incorpora solo obiezioni supportate da evidenze

5. **Execution plan** - salva come `plans/{feature}/execution.md`:
   - Step dettagliato
   - Criteri di validazione
   - Rollback plan

6. **Approval gate** - obbligatoria, chiedi `[y/N/edit]` sul file

7. **Execution** - segui l'execution plan track-by-track

8. **Verifier** - `verifier-agent` conferma il completamento

9. **Wrap-up** - full summary

## Token budget

Max 40k tokens per ciclo. Usa compaction aggressiva.
