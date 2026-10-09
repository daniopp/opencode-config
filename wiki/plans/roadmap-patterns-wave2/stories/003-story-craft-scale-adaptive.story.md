# Story 003: story-craft — scale-adaptive + preserve-never-downgrade

## Meta
- Feature: plans/roadmap-patterns-wave2/plan.md
- Status: in-progress
- Blocked-by: -

## Goal
Aggiornare `skills/story-craft/SKILL.md` con: (a) step 0 "scale check"
della cerimonia decisa DOPO l'investigazione (pattern BMAD v6.12 "Build
decides how much ceremony a change needs after investigating it, not
before"), e (b) regola preserve-never-downgrade sugli stati.

## Contesto (inlined)
- `skills/story-craft/SKILL.md` (75 righe): sezioni 1 Where stories live,
  2 Story template, 3 Sizing and splitting, 4 Lifecycle, 5 Why.
  Lifecycle attuale: draft → ready → in-progress → done/blocked.
  Template story ha Meta (Feature/Status/Blocked-by), Goal, Contesto,
  Acceptance criteria, Hard constraints, Verification, Out of scope.
- Pattern BMAD v6.12: cerimonia confermata/abbassata post-investigazione;
  cambi semplici = spec a 2 sezioni, una sessione.
- Pattern BMAD v6.11 sprint-status: preserve-never-downgrade — uno stato
  non regredisce mai (done non torna in-progress); le transizioni a monte
  ammesse solo con nota esplicita.

## Acceptance criteria
- [ ] AC1 — nuova sotto-sezione `Step 0: Scale check` nel workflow (prima
  del template): dopo l'investigazione, conferma o ABBASSA la cerimonia;
  cambi semplici → story ridotta con solo Goal + Acceptance criteria (spec
  a 2 sezioni); la decisione va in Meta come `Cerimonia: piena | ridotta`;
  alzare la cerimonia richiede giustificazione.
- [ ] AC2 — template della story (sezione 2) aggiornato: riga
  `- Cerimonia: piena | ridotta` nel blocco Meta.
- [ ] AC3 — sezione 4 Lifecycle: regola preserve-never-downgrade esplicita —
  mai degradare uno status (done → in-progress vietato); unblocked di una
  `blocked` ammesso solo con nota; done immutabile (fix post-done = nuova
  story).
- [ ] AC4 — Solo `skills/story-craft/SKILL.md` modificato; lingua inglese
  e stile esistente mantenuti.

## Hard constraints
- NON modificare: nessun altro file, frontmatter description invariato.
- Non allungare oltre ~95 righe totali.

## Verification
- `grep -c 'Cerimonia\|Scale check\|downgrade' skills/story-craft/SKILL.md` ≥ 4
- `wc -l skills/story-craft/SKILL.md` ≤ 95

## Out of scope
- Altre skill, comandi, lane.
