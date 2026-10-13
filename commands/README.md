# Opencode Commands (Lane)

Comandi `/` per workflow strutturati.

## Struttura

```yaml
---
description: descrizione del comando
agent: nome-agente
subagent: true|false
---

[Content del command]
```

## Lane disponibili

Creare le lane di rischio:

- `quick.md` - cambiamenti isolati, 1 file
- `medium.md` - lavoro scoped, piano salvato
- `full.md` - alto rischio, adversarial review
- `debug.md` - triage + hypothesis-driven

## Esempio

```yaml
---
description: "Quick lane per piccoli cambiamenti isolati"
agent: orchestrator
subagent: true
---

## Quick Lane

1. Scope check: conferma che il task è sufficientemente piccolo
2. Research minimo (opzionale)
3. Tiny plan: 1 implementation track
4. Approval: skippabile se meccanico/non-distruttivo
5. Implementazione
```
