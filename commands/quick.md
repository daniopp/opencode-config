---
description: "Quick lane per piccoli cambiamenti isolati"
agent: orchestrator
subagent: true
---

# Quick Lane

Per piccoli cambiamenti isolati e meccanici.

## Flusso

1. **Scope check** - conferma che il task è sufficientemente piccolo
   - Se più ampio/rischioso, suggerisci `/medium`, `/full`, o `/debug`

2. **Research minimo** (opzionale) - solo se il contesto è incerto

3. **Tiny plan** - 1 implementation track, senza salvataggio su file

4. **Approval gate** - skippabile se:
   - meccanico
   - unambiguous
   - non-distruttivo

5. **Implementazione** - 1 sola track di implementazione

6. **Wrap-up** - summary delle modifiche

## Gate approvazione

Usa `question` per chiedere `[y/N/edit]` solo se:

- Ambiguo
- Distruttivo
- User-visible in modo rischioso

## Token budget

Mantieni basso (max 10k tokens per ciclo).
