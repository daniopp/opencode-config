# Opencode Agents

Agenti nativi opencode (.md con frontmatter YAML) — nessun plugin di terzi.

## Struttura

```
agenti.md
├── description: descrizione breve (guida la delega automatica) [richiesto]
├── mode: all | primary | subagent
├── model: nome modello (opzionale, default dal config)
├── temperature: temperatura (opzionale)
├── steps: max iterazioni agentiche (opzionale)
└── permission: override permessi per questo agente
```

Il filename diventa il nome dell'agente (`explorer.md` → agente `explorer`).
Il body del markdown è il system prompt.

## Regole di comunicazione

- Il subagent riceve **solo il prompt** del task (child session isolata) e
  restituisce **un solo messaggio finale**: i prompt esplicitano questo
  contratto.
- Il resume di una sessione subagent avviene passando `task_id` (= child
  session ID).
- Per task complessi il brief viene scritto in
  `/tmp/opencode/tasks/<task-name>.md` e referenziato nel prompt.

## Agenti esistenti

| Agente | Mode | Modello | Permessi chiave |
|---|---|---|---|
| `orchestrator` | primary | mercury-2.5-preview | task allowlist sui 6 specialisti |
| `explorer` | subagent | solar-pro4 | read-only, bash solo letture |
| `librarian` | subagent | glm-5.3-flash | webfetch/websearch, niente shell |
| `oracle` | subagent | muse-spark-1.2-contributor | read-only, bash solo letture |
| `fixer` | subagent | granite-4.2-8b | edit allow, eredita matrice bash globale |
| `designer` | subagent | muse-spark-1.2-contributor | edit allow, eredita matrice bash globale |
| `observer` | subagent | mercury-2.5-preview | read-only, bash solo letture |

I subagent hanno `task: deny` (non spawnano altri agenti);
`subagent_depth: 1` in `opencode.jsonc` impone il limite anche a livello di
config.

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

## Nota storica

Prima di questa migrazione gli agenti erano forniti dal plugin
`oh-my-opencode-slim` (vedi `oh-my-opencode-slim.jsonc`, ora inattivo, tenuto
solo come riferimento per i preset modelli).