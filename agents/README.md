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
| `orchestrator` | primary | `opencode-go/glm-5.3-flash` (dal config globale, nessun override) | task allowlist sugli 8 specialisti |
| `explorer` | subagent | `openrouter/deepseek/deepseek-v4.1-flash` | read-only (solo read/grep/glob, niente bash) |
| `librarian` | subagent | `openrouter/deepseek/deepseek-v4.1-flash` | webfetch/websearch, niente shell |
| `oracle` | subagent | `openrouter/deepseek/deepseek-v4-pro` | read-only, advisor strategico |
| `fixer` | subagent | `openrouter/deepseek/deepseek-v4.1-flash` | edit allow, bash solo test runner + git status/diff |
| `reviewer` | subagent | `openrouter/deepseek/deepseek-v4.1-flash` | read-only, review avversariale con evidenze |
| `verifier` | subagent | `openrouter/deepseek/deepseek-v4.1-flash` | read-only, verifica completion con evidenze |
| `observer` | subagent | `openrouter/deepseek/deepseek-v4.1-flash` | read-only, monitoraggio |
| `designer` | subagent | `openrouter/meta/muse-spark-1.3-contributor` | edit allow, eredita matrice bash globale |

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
  # read/edit sempre a mappa: la scalar "allow" è un override che by-passa
  # le deny globali sui percorsi sensibili (.env*, .ssh, secrets, credentials)
  read:
    "*": allow
    "**/.env*": deny
    "**/*.env": deny
    "**/.dev.vars": deny
    "**/.ssh/**": deny
    "**/secrets/**": deny
    "**/credentials*": deny
  edit: deny
  bash: ask
---

## Ruolo
Agente specializzato in TypeScript e Node.js...
```

## Nota storica

Prima di questa migrazione gli agenti erano forniti dal plugin
`oh-my-opencode-slim`, successivamente rimosso (`plugin: []` in entrambi i
config).
