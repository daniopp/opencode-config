# Story 002: nuova skill spec-archive (delta-spec brownfield)

## Meta
- Feature: plans/roadmap-bmad-usage/plan.md
- Status: ready
- Blocked-by: -

## Goal
Creare la skill globale `spec-archive` che porta nei progetti la disciplina
"archivio delta-spec" stile OpenSpec: la verità corrente vive in spec
stabile, i cambiamenti sono delta proposti→implementati→archiviati.

## Contesto (inlined)
- Le skill globali vivono in `skills/<slug>/SKILL.md` con frontmatter
  `name` + `description`. Formato di riferimento (stile, lunghezza, tono):
  `skills/project-kb-setup/SKILL.md` (inglese per istruzioni, ~100-120 righe,
  sezioni con heading, mental model in code block, workflow numerato,
  guardrails finali).
- Questa skill complementa `project-kb-setup` (che gestisce skills/evals/
  standards della KB) e `story-craft` (che scrive story per i dispatch).
  Regola: complementare, mai duplicare — fare riferimento, non copiare.

## Acceptance criteria
- [ ] AC1 — esiste `skills/spec-archive/SKILL.md` con frontmatter valido
  (`name: spec-archive`, description in stile delle altre skill che dice
  QUANDO usarla: quando un progetto EVODOC brownfield ha bisogno di
  specifiche durevoli con cambiamenti tracciati come delta).
- [ ] AC2 — la skill definisce questa struttura (dentro `.agents/specs/`):
  `specs/<capability>/spec.md` (verità corrente, requirements stabili con
  scenario "#### Requirement:" + "##### Scenario:"), `changes/<change-id>/`
  (proposal.md, tasks.md, spec.md delta con marker `## ADDED/MODIFIED/REMOVED
  Requirements`), `changes/archive/<change-id>/` (delta completati).
- [ ] AC3 — workflow numerato: 1) Propose (change-id = kebab-case,proposal con
  motivazione), 2) Implement (delta + tasks checklist, una skill/story per il
  lavoro), 3) Archive (merge del delta in spec.md, sposta in archive/, mai
  cancellare la storia).
- [ ] AC4 — guardrails: change-id = nome branch (coerenza con `evodoc-pr`);
  un change = una capability; doc in italiano (regola EVODOC), requirement
  statements in inglese tipo codice se il repo è inglese; mai modificare
  spec.md archiviate; la spec descrive COSA, non COME.
- [ ] AC5 — sezione "Relationship with other skills": riferimenti a
  `project-kb-setup`, `story-craft`, `evodoc-pr`, `docs-sync` con una riga
  ciascuno su come si integrano.

## Hard constraints
- NON modificare: nessun file esistente. Questa story è solo creazione di
  `skills/spec-archive/SKILL.md`.
- NON copiare testuali da OpenSpec: è un adattamento (come story-craft lo è
  di BMAD), citare l'ispirazione in una riga di commento iniziale.
- Lunghezza target: ≤ 130 righe.

## Verification
- `python3 -c "import re; t=open('skills/spec-archive/SKILL.md').read(); assert t.startswith('---') and 'archive' in t"`
- File solo `skills/spec-archive/SKILL.md` in `git status --short` come nuovo.

## Out of scope
- Modifiche a README, CHANGELOG, altre skill (le fa la story 005).
