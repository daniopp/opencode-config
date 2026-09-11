---
description: "Debug lane per triage e fix"
agent: orchestrator
subtask: true
---

# Debug Lane

Per triage e fix guidati da ipotesi.

## Flusso

1. **Triage evidence-first** - raccogli evidenze:
   - Error message completo
   - Stack trace
   - Context (cosa è cambiato?)

2. **Research** - esplora codice rilevante

3. **Hypothesis** - definisci:
   - Causa più probabile
   - Evidenza a supporto
   - Falsification check (evita guesswork)

4. **Fix plan** - salva come `plans/{issue}/fix-plan.md`:
   - Hypothesis
   - Fix steps
   - Verification steps

5. **Critique** (opzionale, se rischio alto) - manda il fix plan a `reviewer`

6. **Approval gate** - obbligatoria, chiedi `[y/N/edit]` sul file

7. **Execution** - usa:
   - `fixer` per fix locali
   - `fixer` per fallimenti complessi (con test output nel prompt)

8. **Verifier** - `verifier` conferma contro i verification steps del fix plan

9. **Wrap-up** - what caused it, how it was fixed

## Token budget

Max 30k tokens per ciclo.
