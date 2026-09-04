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

5. **Critique** (opzionale, se rischio alto) - review del fix plan

6. **Approval gate** - obbligatoria, chiedi `[y/N/edit]` sul file

7. **Execution** - usa:
   - `implementation-agent` per fix locali
   - `test-fixer-agent` per fallimenti complessi

8. **Verifier** - `verifier-agent` conferma

9. **Wrap-up** - what caused it, how it was fixed

## Token budget

Max 30k tokens per ciclo.
