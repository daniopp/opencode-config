---
name: auto-docs
description: Proactively maintain development documentation during analyses and implementations without waiting to be asked - docs/dev/ master plans and blueprints, plus CHANGELOG.md entries for every change. Use during any non-trivial analysis or implementation task in an EVODOC repository. Do not use for trivial one-off edits, ephemeral working state (deepwork keeps .slim/), or when the user explicitly opts out for the task.
---

# Auto Documentation

You keep development documentation alive as a byproduct of work —
proactively, without waiting for an explicit request. Two deliverables belong
to every non-trivial task: `docs/dev/` artifacts and `CHANGELOG.md` entries.

## Deliverable vs Working State

- `docs/dev/` and `CHANGELOG.md` are **committed deliverables** (they travel
  in the same PR as the code, see `evodoc-pr`);
- ephemeral session/progress state stays in `.slim/` (git-ignored, see
  `deepwork`) — never confuse the two;
- product-facing documentation (README, wiki) is handled by `docs-sync`;
  `docs/dev/` documents the **work**, not the product.

## docs/dev/ Structure

Create only what the work needs; keep names stable across the repo:

```text
docs/dev/
  master-plan.md              # current effort: goal, scope, phases, status
  blueprints/<slug>.md        # technical blueprint per feature/subsystem
  decisions/NNNN-<slug>.md    # optional ADR for significant choices
```

- **master-plan.md** — goal, scope in/out, phase list with status
  (pending / in progress / done), links to blueprints, issues, and key files.
  Update the status at every phase completion.
- **blueprints/<slug>.md** — one per feature or subsystem under work: context
  and problem, chosen design, interfaces and data flow, risks, open
  questions. Start it during the analysis phase, keep it current during
  implementation.
- **decisions/NNNN-<slug>.md** — architecture decision record when a
  meaningful choice is made: context, options considered, decision,
  consequences.

Language: Italian prose, English identifiers (EVODOC rule).

## CHANGELOG.md

Maintain a Keep a Changelog style file at the repository root:

```markdown
# Changelog

## [Unreleased]

### Added
- <una riga concisa> (#123)

### Changed

### Fixed

### Removed
```

Rules:

- every material change gets an entry **in the same task**: one concise line
  per change, referencing the issue or PR number (`(#123)`);
- categories: `Added / Changed / Fixed / Removed / Deprecated / Security`;
  skip empty categories;
- work lands in `[Unreleased]`; promote to a version section only when the
  user asks or on release;
- do not duplicate the commit history — entries describe changes relevant to
  readers, not every commit.

## Proactivity Rules

- default is **proactive**: create/update the artifacts without being asked;
- first creation in a repo that has neither `docs/dev/` nor `CHANGELOG.md`:
  proceed and clearly report the new files — do not block on permission;
- skip only when the repo has an explicit rule against dev docs or the user
  opts out for the task;
- keep files lean: stale content is updated or removed, never left to rot.

## Relation to Other Skills

- `evodoc-pr` — docs/dev and CHANGELOG updates travel in the same PR;
- `docs-sync` — product documentation (README, wiki) boundary;
- `deepwork` — ephemeral plan state (`.slim/`) vs committed master plan;
- `completion-gate` — the gate verifies changelog entries and docs/dev status
  updates actually happened.
