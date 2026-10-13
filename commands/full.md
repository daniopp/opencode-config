---
description: "Full lane per lavoro ad alto rischio"
agent: orchestrator
subagent: true
---

# Full Lane

Per lavoro complesso ad alto rischio.

## Flusso

1. **Intake** - chiarisci goal, vincoli, e stakeholder

2. **Discovery completo** - esplora il contesto necessario

3. **Plan** - salva come `plans/{feature-name}/plan.md`. Per feature multi-sessione usa lo skill `story-craft`: story self-contained con contesto inline, acceptance criteria verificabili, hard constraints e stato persistente riprendibile.

4. **Adversarial review** - manda il piano a `reviewer`:
   - Se complesso, second review opzionale (anche a `oracle`)
   - Incorpora solo obiezioni supportate da evidenze

5. **Execution plan** - salva come `plans/{feature}/execution.md`:
   - Step dettagliato
   - Criteri di validazione
   - Rollback plan

6. **Approval gate** - obbligatoria, chiedi `[y/N/edit]` sul file

7. **Execution** - segui l'execution plan track-by-track

8. **Verifier** - `verifier` conferma il completamento contro i criteri di validazione:
   - **Dual-review** per diff ad alto rischio: seconda review indipendente con modello diverso (es. `reviewer` + `oracle`)
   - **Rebuttal** consentito: il `fixer` può contestare un finding solo con motivazione ed evidenze
   - **Disaccordo** tra i reviewer: escalazione all'utente, mai media tra verdetti
   - **Self-approval vietato**: chi ha implementato non verifica il proprio lavoro

9. **Wrap-up** - full summary

## Token budget

Max 40k tokens per ciclo. Usa compaction aggressiva.
