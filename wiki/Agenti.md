# Opencode Agents

Agenti nativi opencode (.md con frontmatter YAML) — nessun plugin di terzi.

## Struttura

```text
agenti.md
├── description: descrizione breve (guida la delega automatica) [richiesto]
├── mode: all | primary | subagent
├── model: nome modello (opzionale, default dal config)
├── temperature: temperatura (opzionale)
├── steps: max iterazioni agentiche (opzionale)
└── permissions: override permessi per questo agente (forma nativa V2)
```

Il filename diventa il nome dell'agente (`explorer.md` → agente `explorer`).
Il body del markdown è il system prompt.

**Forma delle chiavi:** i frontmatter in `agents/*.md` usano ancora la forma
legacy `permission:` (con `bash`, `task`, `tools:`). In V2 queste chiavi sono
tradotte automaticamente, ma la forma nativa preferita è `permissions` con
azioni `shell`, `subagent`, `edit`, `read`, `webfetch`, `websearch` (vedi
[PERMISSIONS.md](PERMISSIONS.md)). Non è stata fatta migrazione dei file agente.

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
| `orchestrator` | primary | `opencode-go/claude-haiku-5-5` (dal config globale, nessun override) | subagent allowlist sugli 8 specialisti |
| `explorer` | subagent | `opencode-go/claude-haiku-5-5` | read-only (solo read/grep/glob, niente shell) |
| `librarian` | subagent | `opencode-go/claude-haiku-5-5` | webfetch/websearch, niente shell |
| `oracle` | subagent | `openrouter/anthropic/claude-sonnet-5.5` | read-only, advisor strategico |
| `fixer` | subagent | `opencode-go/claude-haiku-5-5` | edit allow, shell solo test runner + git status/diff |
| `reviewer` | subagent | `opencode-go/claude-haiku-5-5` | read-only, review avversariale con evidenze |
| `verifier` | subagent | `opencode-go/claude-haiku-5-5` | read-only, verifica completion con evidenze |
| `observer` | subagent | `opencode-go/claude-haiku-5-5` | read-only, monitoraggio |
| `looker` | subagent | `opencode-go/claude-haiku-5-5` | vision/PDF, read-only |
| `designer` | subagent | `opencode-go/muse-spark-1.3-contributor` | edit allow, eredita matrice shell globale |

I subagent non spawnano altri agenti: `experimental.subagent_depth: 1` in
`opencode.jsonc` impone il limite a livello di config. Il divieto di delega
(in V1 `task: deny`) va espresso con l'azione `subagent` (`deny`); la
traduzione dei frontmatter attuali è da verificare con la doc
[Agents](https://opencode.ai/v2/docs/agents).

## Esempio

Forma nativa V2 (array ordinato, vince l'ultima regola che matcha; le regole
generiche prima, le eccezioni dopo):

```yaml
---
description: "Agente specializzato in TypeScript"
mode: primary
temperature: 0.2
permissions:
  - { action: read, resource: "*", effect: allow }
  - { action: read, resource: "**/.env*", effect: deny }
  - { action: read, resource: "**/*.env", effect: deny }
  - { action: read, resource: "**/.dev.vars", effect: deny }
  - { action: read, resource: "**/.ssh/**", effect: deny }
  - { action: read, resource: "**/secrets/**", effect: deny }
  - { action: read, resource: "**/credentials*", effect: deny }
  - { action: edit, resource: "*", effect: deny }
  - { action: shell, resource: "*", effect: ask }
---

## Ruolo
Agente specializzato in TypeScript e Node.js...
```

Il formato YAML del frontmatter con `permissions` non è stato verificato sulla
doc [Agents](https://opencode.ai/v2/docs/agents): da verificare prima di
usarlo in un file agente reale.

## Nota storica

Prima di questa migrazione gli agenti erano forniti dal plugin
`oh-my-opencode-slim`, successivamente rimosso (`plugin: []` in entrambi i
config).
