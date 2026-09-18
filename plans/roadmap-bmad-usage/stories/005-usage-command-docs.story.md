# Story 005: comando /usage + README + CHANGELOG

## Meta
- Feature: plans/roadmap-bmad-usage/plan.md
- Status: done
- Blocked-by: - (003 e 04 done)

## Esito story 003 (verdetto Spec Kit — da usare per AC2)
Pilota: SÌ, ma sulla modalità ufficiale commands (`.opencode/commands/`),
NON su `--skills` (supporto opencode proposto in PR #2494, mai mergiata,
stale dal 2026-09-11; v1.0.8 del 2026-09-17 è commands-based).
Sintassi attuale: `specify init --integration opencode` (i flag `--ai*` sono
rimossi dalla v0.10.0 del 2026-06-09). Criterio pilota ≤1 giorno: 1 issue
end-to-end `/speckit.specify → plan → tasks → implement → converge` con
costituzione localizzata alle regole EVODOC (italiano/naming/XUnit).
Rischio monitorato: PR #2494 per il passaggio futuro a `.opencode/skills/`.

## Goal
Esportare il reporting usage come comando TUI `/usage` e aggiornare la
documentazione del repo (README, CHANGELOG, assessment roadmap).

## Contesto (inlined)
- Formato comando: vedi `commands/sync-config.md` — frontmatter
  `description:` + corpo in italiano con $ARGUMENTS, passi numerati, regole.
- Script: `scripts/usage-report.py` (story 004) — subcommands
  `summary|export|sessions`, filtri `--days/--since/--until/--project/--model/--agent`,
  `--format json`, `--db`.
- `docs/BMAD-ASSESSMENT.md` righe 50-51: roadmap con item (a)-(d) da
  aggiornare (l'orchestrator fornisce l'esito della 003 in fase di dispatch).
- README sezione skill/docs: aggiungere righe nuove (vedi riga 98 per stile).

## Acceptance criteria
- [ ] AC1 — `commands/usage.md` con frontmatter `description: "Report
  consumi token e costo dalle sessioni opencode"`; passi: 1) `python3
  scripts/usage-report.py summary` con $ARGUMENTS come filtri, 2) presenta
  i risultati in tabella, 3) se l'utente chiede "registra/salva", esegui
  `export` e riporta il path del ledger; regola: script read-only sul DB.
- [ ] AC2 — `docs/BMAD-ASSESSMENT.md`: sezione roadmap aggiornata — (a) e (c)
  marcati fatti (skill `project-kb-setup` estesa), (b) fatta (skill
  `spec-archive`), (d) risolta con l'esito della valutazione 003; status
  header aggiornato se serve.
- [ ] AC3 — `README.md`: nuova riga per skill `spec-archive` nella sezione
  skill, riga per `docs/BMAD-ASSESSMENT.md` aggiornata se necessario, sezione
  Tools/script con `usage-report.py` + comando `/usage`.
- [ ] AC4 — `docs/CHANGELOG.md`: nuova entry `## 2026-09-18 (3)` con Added
  (spec-archive, usage-report.py, /usage, estensione kb-setup) e Aggiornato
  (assessment roadmap).
- [ ] AC5 — solo questi 4 file modificati.

## Hard constraints
- NON modificare: `skills/`, `scripts/`, `opencode.jsonc`, `AGENTS.md`.
- Italiano per i contenuti documentali; identificatori in inglese.
- CHANGELOG: stile voci esistenti (section Added/Modificato, frasi secche).

## Verification
- `git diff --stat` → 4 file come da AC5
- `bash -n scripts/usage-report.py` non applicabile; `python3 scripts/usage-report.py summary --days 1` ok

## Out of scope
- Sync verso live config (lo fa `/sync-config` su richiesta utente).
