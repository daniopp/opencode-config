---
name: story-craft
description: Write self-contained implementation stories with inlined context, verifiable acceptance criteria, hard constraints and persistent status before dispatching implementation work. Use in /medium and /full lanes before dispatching any fixer task, and for multi-session features that need resumable state. Do not use for /quick trivial single-file edits.
---

# Story Craft

A story is a self-contained work order for an implementing subagent (`fixer`). The subagent receives ONLY the story file path — no chat history, no exploration budget. Everything it needs must be inside the story.

This adapts the BMAD Method story discipline to this config's lanes, without adopting BMAD itself. Rationale and gap analysis: `docs/BMAD-ASSESSMENT.md` in the config repo.

## 1. Where stories live

EVODOC rule (`rules.md`): **no development documents in code repositories.**
Stories are working orders, not repo artifacts.

- Working folder, git-ignored: `.slim/stories/{feature}/`
  (one file per story: `NNN-{kebab-case-slug}.story.md`, NNN = zero-padded
  order; parent index `.slim/stories/{feature}/plan.md`).
- **Persistent, resumable state = GitHub issue.** Mirror story statuses in
  the EVOPLATFORM issue body (append-only via `gh issue edit`): a short
  status section listing each story with `draft | ready | in-progress | done
  | blocked`. A fresh session resumes from the issue, not from chat history.
- `prepare-never-downgrade` applies to the issue mirror too: statuses there
  never regress.
- At squash merge: add one final issue comment with the story summary and
  mark the effort section as completed — then stop updating the issue.

## 2. Story template

### Step 0: Scale check

Decide the ceremony AFTER investigating the change, not before (BMAD v6.12): confirm it, or LOWER it for simple changes. A simple change needs only a reduced story — Goal + Acceptance criteria (the 2-section spec) — and fits in one session. Record the decision in Meta as `Cerimonia: piena | ridotta`. Raising the ceremony requires an explicit justification.

Write stories in the project's documentation language (Italian for EVODOC repos, per `rules.md`). Structure:

```markdown
# Story 001: {titolo}

## Meta
- Feature: .slim/stories/{feature}/plan.md
- Status: draft | ready | in-progress | done | blocked
- Blocked-by: (story IDs o "-")
- Cerimonia: piena | ridotta

## Goal
1–2 frasi: cosa deve essere vero a fine lavoro.

## Contesto (inlined)
- `src/auth/service.cs:40-85` — perché è rilevante (1 riga)
- Inline snippet SOLO se l'implementatore non può dedurlo leggendo quel path.

## Acceptance criteria
- [ ] AC1 — verificabile con un comando o un'osservazione oggettiva
- [ ] AC2

## Hard constraints
- NON modificare: `path/to/file` (motivo)
- Solo diff additivi dove indicato
- NON rinominare proprietà già serializzate su database (regola EVODOC di retrocompatibilità)

## Verification
- Comandi esatti da eseguire: `dotnet test tests/...`
- Evidenza attesa (output, file creati, test verdi)

## Out of scope
- Cosa questa story NON deve toccare.
```

## 3. Sizing and splitting

**Target: ≤ 1500 tokens per story.** A longer story usually hides two stories: split it.

- One story = one coherent, independently verifiable change.
- Hard constraints must be unambiguous: "NON modificare `path`" with a real path and reason, never "fai attenzione".
- If a single story needs more than ~5 inlined snippets, the work package is too big — go back to the plan.

## 4. Lifecycle

1. **draft → ready**: the orchestrator (or planner) writes the story; acceptance criteria are individually checkable; every context path is verified to exist.
2. **in-progress**: set before dispatching. Pass ONLY the story path in the task prompt (plus the standard subagent contract: one final message back).
3. **done / blocked**: after the subagent returns, `verifier` checks each AC against evidence. All ACs green → `done`. Any failure → `blocked` + one-line reason; fix the story (missing context, wrong constraint, oversized scope) before re-dispatching.
4. Status lives in the story file in `.slim/` and is mirrored in the issue
   body (single source of truth for resumption: the issue).
5. **preserve-never-downgrade (BMAD v6.11)**: a status never regresses — `done` never returns to `in-progress`. Unblocking a `blocked` story is allowed only with an explicit note. `done` is immutable: a post-done fix is a new story, not a status change.

## 5. Why (token economics)

- The story replaces exploratory tool-calling: the subagent reads 1 file (+ referenced paths) instead of searching the repo.
- Fresh-context-per-task without state loss: state is on disk, not in the conversation.
- Hard constraints are the anti-regression guard for brownfield work: the implementer cannot rewrite what the story does not allow.

**Complete when:** every dispatched story has status `done` or `blocked`, all ACs are evidence-checked by `verifier`, and the plan index matches the story files.
