# Story 002: Verifier 3D + triage evidenza + converge + dual-review

## Meta
- Feature: plans/roadmap-patterns-wave2/plan.md
- Status: in-progress
- Blocked-by: -

## Goal
Arricchire la pipeline di verifica con 3 pattern fusi: verifica a 3
dimensioni con graceful degradation (OpenSpec `/opsx:verify`), verdetto
esplicito con evidenza per ogni finding (BMAD TEA v6.12), converge loop
append-only (Spec Kit); e introdurre il dual-review su /full (Codev).

## Contesto (inlined)
- `agents/verifier.md` (49 righe): subagent read-only. Metodo attuale in 4
  passi (Criteria Decomposition, Evidence Gathering, Regression Scan, Honest
  Failure con stato `UNVERIFIED`). Output Contract: Verdict `PASS | FAIL |
  UNVERIFIED`, Criteria Checklist con evidenza `path:line`, Anomalies.
- `skills/completion-gate/SKILL.md` (62 righe): gate a 5 sezioni + Report
  finale. Il Report non ha un verdetto esplicito.
- `commands/full.md` (38 righe): lane /full, flusso 9 passi; passo 8 è
  "Verifier"; step 4 ha già "second review opzionale (anche a oracle)".
- Pattern OpenSpec: 3 dimensioni (Completeness/Correctness/Coherence),
  severità, graceful degradation (solo task → completeness; +spec →
  correctness; full → coherence).
- Pattern BMAD TEA: ogni finding ha verdetto + evidenza, niente viene
  scartato in silenzio; gate PASS/CONCERNS/FAIL.
- Pattern Spec Kit converge: gap classificati `missing | partial |
  contradicts | unrequested`; i gap diventano task tracciabili APPEND-only:
  formato `T{NNN} <desc> per <source-ref> (<gap-type>)`; zero gap = nessuna
  modifica ai file.
- Pattern Codev: review da 2 modelli indipendenti, rebuttal consentito,
  disaccordo → escalazione umana (mai media), self-approval vietato.

## Acceptance criteria
- [ ] AC1 — `agents/verifier.md`: Verification Method estesa con le 3
  dimensioni e la regola di graceful degradation (check solo ciò che gli
  artefatti disponibili permettono, dichiarandolo).
- [ ] AC2 — `agents/verifier.md`: Output Contract — Verdict diventa
  `PASS | CONCERNS | FAIL | UNVERIFIED` (CONCERNS = completo ma con gap/
  anomalie non bloccanti); ogni finding DEVE avere source-ref `path:line`
  o commit; nuova sezione `### Convergence Tasks` opzionale: gap classificati
  come task append-only nel formato sopra, mai riscritture.
- [ ] AC3 — `skills/completion-gate/SKILL.md`: sezione Report aggiornata —
  il gate si chiude con una riga `GATE: PASS | CONCERNS | FAIL` più motivazione
  in una frase; ogni residual risk con evidenza (`path:line`).
- [ ] AC4 — `commands/full.md`: passo 8 (Verifier) esteso con dual-review:
  per diff ad alto rischio, seconda review indipendente con modello diverso
  (es. `reviewer` + `oracle`); il `fixer` può fare rebuttal motivato;
  disaccordo tra reviewer → escalazione all'utente, mai media; self-approval
  vietato (chi implementa non verifica se stesso).
- [ ] AC5 — Solo i 3 file target modificati; stili di ciascun file rispettati
  (verifier in inglese, full.md in italiano, completion-gate in inglese).

## Hard constraints
- NON modificare: nessun altro file. NON toccare i frontmatter degli agent
  (solo corpo markdown di verifier.md).
- Edizioni additive: non riscrivere passi esistenti, integrarli.

## Verification
- `grep -c 'CONCERNS' agents/verifier.md skills/completion-gate/SKILL.md` ≥ 1 ciascuno
- `grep -c 'missing\|partial\|contradicts\|unrequested' agents/verifier.md` ≥ 1
- `git diff --stat` filtrato ai 3 file target

## Out of scope
- Modifiche ad altri agent, orchestrator, altre skill o lane.
