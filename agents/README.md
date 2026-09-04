# Opencode Agents

Agenti personalizzati (.md con frontmatter YAML).

## Struttura

```
agenti.md
├── description: descrizione breve
├── mode: all | primary | subagent
├── model: nome modello (opzionale, default dal config)
├── temperature: temperatura (opzionale)
└── permission: override permessi per questo agente
```

## Agenti esistenti

oh-my-opencode-slim fornisce:
- `orchestrator` - coordinatore principale
- `oracle` - analisi architetturale
- `designer` - UI/UX
- `fixer` - implementazione rapida
- `explorer` - ricerca codice
- `librarian` - ricerca documentazione
- `council` - discussione multi-agente
- `councillor` - analisi individuale
- `observer` - monitoraggio

## Esempio

```yaml
---
description: "Agente specializzato in TypeScript"
mode: primary
temperature: 0.2
permission:
  read: allow
  edit: allow
  bash: ask
---

## Ruolo
Agente specializzato in TypeScript e Node.js...
```
