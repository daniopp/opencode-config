# Plan: Roadmap Pattern — Wave 2

Fonte: valutazione librarian 2026-09-18 (2 task, fonti verificate).
7 pattern da adottare, tutti estensioni di file esistenti (zero engine).

## Stories

| ID | Titolo | Target file | Status |
|---|---|---|---|
| 001 | Constitution SemVer + rule layering (Spec Kit + Cursor) | `rules/rules.md`, `rules/README.md` | done |
| 002 | Verifier 3D + triage evidenza + converge append-only + dual-review | `agents/verifier.md`, `skills/completion-gate/SKILL.md`, `commands/full.md` | done |
| 003 | Cerimonia scale-adaptive + preserve-never-downgrade | `skills/story-craft/SKILL.md` | done |
| 004 | Reflect evidence-based + cleanup OMO residui | `skills/reflect/SKILL.md` | done |
| 005 | Allineamento agentskills.io frontmatter | `skills/*/SKILL.md` (solo frontmatter) | done |
| 006 | Docs: README + CHANGELOG + assessment wave 2 | `README.md`, `docs/CHANGELOG.md`, `docs/BMAD-ASSESSMENT.md` | done |

## Regole di parallelismo
- 001, 002, 003, 004 in parallelo (file disgiunti).
- 005 SOLO dopo 003 e 004 (tocca il frontmatter di tutte le skill).
- 006 SOLO per ultima (tocca i doc condivisi).

## Mappatura item → stories
- Item 1 (Constitution) + item 7 (layering) → 001
- Item 2 (verifier arricchito: OpenSpec 3D + BMAD TEA verdict + Codev dual-review) + item 3 (converge append-only) → 002
- Item 4 (scale-adaptive) + monitor preserve-never-downgrade → 003
- Item 5 (retrospective evidence-based) → 004
- Item 6 (agentskills.io) → 005
- Bonus: cleanup riferimenti `oh-my-opencode-slim` rimasti in reflect → 004

## Note
- `rules/rules.md` vive anche in live config (`~/.config/opencode/rules/rules.md`):
  le modifiche repo richiedono sync via `/sync-config` (fuori da queste stories).
- Costo dual-review (story 002) misurabile con `scripts/usage-report.py`.
