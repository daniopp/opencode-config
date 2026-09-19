# Story 007: pre-commit hooks (validate-jsonc, markdownlint, detect-private-key)

## Meta
- Feature: plans/roadmap-patterns-wave2/plan.md
- Status: done
- Blocked-by: - (ultima voce pendente di "Prossimi passi" in AGENTS.md)

## Goal
Implementare i pre-commit hooks promessi in `AGENTS.md` → Prossimi passi:
validate-jsonc, detect-private-key, markdownlint (opzionale con skip
graceful), attivabili con un solo comando di setup.

## Contesto (inlined)
- `scripts/validate-jsonc.sh` esiste già (leggerlo prima di usarlo: verificare
  se accetta un file come argomento o legge stdin).
- Repo stile: scripts bash con `set -euo pipefail`, messaggi brevi, italiano
  negli output utente.
- Il hook non è committabile direttamente in `.git/hooks/` (`.git` non è
  versionato): pattern corretto = `scripts/githooks/pre-commit` +
  `git config core.hooksPath scripts/githooks` via script di installazione.

## Acceptance criteria
- [ ] AC1 — `scripts/githooks/pre-commit` (eseguibile, `set -euo pipefail`):
  opera SOLO sui file staged (`git diff --cached --name-only --diff-filter=ACM`):
  1) se ci sono `*.jsonc` staged, esegue `scripts/validate-jsonc.sh` su
  ciascuno (se il script non supporta argomenti, adattarlo o validare con
  `python3 -c 'json.loads'` dopo strip dei commenti — leggere il comportamento
  esistente PRIMA di scegliere); 2) detect-private-key: rifiuta se lo staged
  diff contiene pattern di chiavi private (`BEGIN RSA PRIVATE KEY`,
  `BEGIN PRIVATE KEY`, `BEGIN OPENSSH PRIVATE KEY`, `aws_access_key_id` con
  valore, `slack_webhook` con valore); 3) markdownlint: se `npx markdownlint-cli`
  è invocabile in <5s (o `markdownlint` nel PATH), lint dei `*.md` staged;
  altrimenti stampa "markdownlint non disponibile: skip" e prosegue.
- [ ] AC2 — fallimenti chiari: ogni rifiuto stampa `pre-commit: FAIL <motivo>`
  su stderr ed esce 1; nessun auto-fix silenzioso.
- [ ] AC3 — `scripts/install-hooks.sh`: esegue `git config core.hooksPath
  scripts/githooks` (workdir repo) e stampa istruzioni; il hook dopo l'install
  intercetta davvero i commit (testarlo con un commit di prova fatto e poi
  annullato SOLO se environment pulito — altrimenti verificare con
  `git config core.hooksPath` + dry-run del hook direttamente).
- [ ] AC4 — `AGENTS.md` (repo): sezione "Prossimi passi" aggiornata — item
  pre-commit marcato fatto con i path; l'item agenti custom resta com'è.
- [ ] AC5 — README: una riga su come installare i hook (sezione Tools/Script
  o simile).
- [ ] AC6 — eseguire il hook direttamente su staged reali: `echo test |
  pre-commit` con file staged reali non disponibile → verificare eseguendo
  il hook con il working tree attuale (deve passare senza falsi positivi).

## Hard constraints
- NON modificare: rules/, skills/, agents/, commands/, docs/ (tranne
  AGENTS.md e README.md come da AC4/AC5), opencode.jsonc, tui.json.
- NON committare nulla.
- Nessuna dipendenza npm/pip obbligatoria per il hook (markdownlint è best-effort).
- Chmod +x su entrambi gli script.

## Verification
- `bash -n scripts/githooks/pre-commit scripts/install-hooks.sh` → ok
- `./scripts/install-hooks.sh && git config core.hooksPath` → `scripts/githooks`
- `git stash list` invariato; nessun commit extra creato.

## Out of scope
- pre-commit framework Python, CI workflow, sync live config.
