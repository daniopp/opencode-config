---
description: Sincronizza la config opencode live con il repo danismeup/opencode-config
---

Sincronizza la configurazione opencode corrente (`~/.config/opencode`) con il repo `~/git/opencode-config`. $ARGUMENTS

Lavora con workdir `/home/daniele/git/opencode-config` per tutti i comandi.

Passi:

1. `scripts/sync.sh status` — mostra lo stato e le eventuali divergenze
2. `scripts/sync.sh push` — copia local → repo (agents, commands, rules, skills, AGENTS.md, tui.json, opencode.jsonc)
3. `git status --short` e `git diff --stat` — revisione del delta
4. Commit con messaggio `config: <breve descrizione>` e `git push`

Regole:
- `opencode.jsonc` è identico su tutte le macchine: `instructions` usa il formato `~/` (`~/.config/opencode/rules/rules.md`, espanso da opencode con `os.homedir()` su Linux e Windows). NON reintrodurre path assoluti macchina-specifici né path relativi (risolti dalla cwd del progetto).
- Non sincronizzare mai `logs/`, `memory/`, `pilot/`, `node_modules/`, `.gitignore`
- Se `status` mostra divergenze inattese, fermati e segnala prima di procedere
