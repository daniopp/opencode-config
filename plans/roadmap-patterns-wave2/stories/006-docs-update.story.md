# Story 006: docs wave 2 (README + CHANGELOG + assessment)

## Meta
- Feature: plans/roadmap-patterns-wave2/plan.md
- Status: ready
- Blocked-by: 001, 002, 003, 004, 005 (tutte done)

## Goal
Documentare la wave 2: entry CHANGELOG, aggiornamento README e nota
nell'assessment BMAD sui pattern adottati con fonti.

## Contesto (inlined)
- Risultati reali delle stories 001-005 (tutte done, da riportare nei doc):
  - 001: `rules/rules.md` v1.0.0 con Governance SemVer + Layering + Cronologia
    (+39/-0); `rules/README.md` con sezioni Governance e Layering (+15/-0)
  - 002: `agents/verifier.md` — passo 5 "Three-Dimensional Check (Graceful
    Degradation)", Verdict `PASS | CONCERNS | FAIL | UNVERIFIED` con
    source-ref obbligatoria, sezione `### Convergence Tasks` append-only
    (`T{NNN} <desc> per <source-ref> (<gap-type>)`); `skills/completion-gate/SKILL.md`
    — chiusura `GATE: PASS | CONCERNS | FAIL` + residual risk con evidenza;
    `commands/full.md` — passo 8 con dual-review (reviewer + oracle modelli
    diversi), rebuttal fixer, disaccordo → escalazione umana, no self-approval
  - 003: `skills/story-craft/SKILL.md` — Step 0 Scale check, Meta con
    `Cerimonia: piena | ridotta`, preserve-never-downgrade nel Lifecycle
  - 004: `skills/reflect/SKILL.md` — sezione Retrospective Mode (5 fasi
    Gather→Analyze→Discuss→Decide→Close, evidenze git, verdetto
    accepted/accepted-with-open-items/rejected, action item con follow-through
    in plans/{feature}/retro.md o ~/.config/opencode/reflections/retro.md);
    rimossi 5 riferimenti stantii oh-my-opencode-slim
  - 005: frontmatter agentskills.io — `compatibility` aggiunto a 3 skill
    (`evodoc-pr`: gh CLI+git; `csharp-tests`: .NET SDK; `clonedeps`: git, npm,
    dotnet); 17/17 skill validate (name/description validi)
- Stile CHANGELOG: voci `## <data> - <titolo>` con section `### Aggiunto`/
  `### Modificato`, frasi secche con path.
- README: sezioni skill e Documenti con righe a una battuta.
- `docs/BMAD-ASSESSMENT.md`: aggiungere sezione finale `## Wave 2 — pattern
  adottati (2026-09-18)` con i 7 item e fonti (Spec Kit constitution/
  converge, OpenSpec verify, BMAD v6.11/v6.12 TEA+retro, Codev multi-model,
  agentskills.io, Cursor rules layering).

## Acceptance criteria
- [ ] AC1 — `docs/CHANGELOG.md`: nuova entry con tutte le modifiche wave 2.
- [ ] AC2 — `README.md`: sezione skill aggiornata se cambia qualcosa di
  user-visible (es. reflect retrospective mode, story-craft scale check);
  eventuale nota su rules versionate.
- [ ] AC3 — `docs/BMAD-ASSESSMENT.md`: sezione Wave 2 aggiunta con 7 item,
  verdetto e fonti; header status aggiornato.
- [ ] AC4 — Solo questi 3 file modificati.

## Hard constraints
- NON modificare: skills/, agents/, commands/, rules/, scripts/, plans/.
- Italiano; identificatori in inglese.

## Verification
- `git diff --stat` → 3 file come da AC4
- `grep -c 'Wave 2' docs/BMAD-ASSESSMENT.md` ≥ 1

## Out of scope
- Sync live config (via /sync-config su richiesta utente).
