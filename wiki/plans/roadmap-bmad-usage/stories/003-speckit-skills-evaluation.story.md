# Story 003: valutazione GitHub Spec Kit `--skills` (ricerca)

## Meta
- Feature: plans/roadmap-bmad-usage/plan.md
- Status: ready
- Blocked-by: -
- Tipo: RICERCA (librarian) — nessun file da scrivere nel repo.

## Goal
Chiarire lo stato attuale (settembre 2026) del flag/integrazione
`--skills` di GitHub Spec Kit e valutare se arruolare un repo pilota EVODOC
per una pipeline spec→plan→tasks più strutturata.

## Domande a cui rispondere
1. Esiste davvero `specify --skills` (o equivalente) nella CLI Spec Kit
   (github/spec-kit)? Da quale versione? Cosa genera esattamente
   (skill native per opencode/claude-code? `.specify/`? scripts?).
2. Compatibilità con opencode: il template supporta agenti opencode
   (`--ai opencode`)? Prova di funzionamento o case study documentato?
3. Requisiti duri (runtime, tooling) e conflitti noti con: regole EVODOC
   (doc in italiano), subagent nativi opencode, skill globali esistenti.
4. Verdetto raccomandato: pilota sì/no, su quale repo, e criterio di
   successo/minimo di sperimentazione (≤ 1 giorno di lavoro).

## Acceptance criteria
- [ ] AC1 — risposta a tutte e 4 le domande, con fonti citate (URL + data
  rilascio/versione dove possibile), incluse le release notes ufficiali
  di github/spec-kit 2026.
- [ ] AC2 — verdetto esplicito e motivato (procedere con pilota o meno),
  max ~10 righe di sintesi finale.

## Hard constraints
- Solo ricerca web/docs ufficiali + issue GitHub; nessuna modifica a file.
- Se `--skills` non esiste o è cambiato di nome, è un risultato valido:
  documentare lo stato reale.

## Verification
- Ogni claim chiave ha una fonte citata nel messaggio finale.
