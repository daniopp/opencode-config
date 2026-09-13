---
description: Sincronizza la config opencode live con il repo danismeup/opencode-config
---

Sincronizza la configurazione opencode corrente (`~/.config/opencode`) con il repo `~/git/opencode-config`. $ARGUMENTS

Lavora con workdir `/home/daniele/git/opencode-config` per tutti i comandi.

Passi:

1. `scripts/sync.sh status` — mostra lo stato e le divergenze note
2. `scripts/sync.sh push` — copia local → repo (agents, commands, rules, skills, AGENTS.md, tui.json)
3. Se la modifica riguarda `opencode.jsonc`: è divergente DI PROPOSITO (path `instructions` Windows nel repo vs Linux in locale) quindi lo script lo salta — applica il delta A MANO con edit sul file del repo, preservando il path `instructions` Windows e il TIER 5 `dotnet`. NON usare `--force` salvo richiesta esplicita dell'utente.
4. `git status --short` e `git diff --stat` — revisione del delta
5. Commit con messaggio `config: <breve descrizione>` e `git push`

Regole:
- Non modificare MAI la sezione `instructions` del file `opencode.jsonc` nel repo (path Windows della macchina di lavoro)
- Non sincronizzare mai `logs/`, `memory/`, `pilot/`, `node_modules/`, `.gitignore`
- Se `status` mostra divergenze inattese, fermati e segnala prima di procedere
