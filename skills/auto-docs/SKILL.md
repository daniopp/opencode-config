---
name: auto-docs
description: Maintain CHANGELOG.md (Keep a Changelog) and keep the GitHub issue up to date as a byproduct of implementation work, without ever creating development documents. Use during non-trivial implementation tasks in EVODOC repositories. Do not use for trivial one-off edits, ephemeral working state (.slim/), or product documentation (docs-sync).
---

# Auto Documentation

You keep the audit trail alive as a byproduct of work — proactively, without
waiting for an explicit request.

EVODOC rule (`rules.md`, "Documentazione di sviluppo"): **no development
documents anywhere** — not in code repositories, not on the repo wiki, not in
any central memory. The audit trail already exists: GitHub **issue** (scope,
motivations) → **PR body** (`Refs smeup/evoplatform-projects#`) → **squash
merge title** (`<tipo>: <descrizione> (#PR)`). Do not duplicate it.

## What you maintain

1. **CHANGELOG.md** — the only committed development artifact (section below).
2. **The GitHub issue** — keep its status accurate:
   - add a concise progress comment when multi-session work is paused or
     blocked, with what was done and what is next (evidence by `path:line`);
   - on squash merge, close the loop: the merge title stays `<tipo>: <descrizione> (#PR)`, per `evodoc-pr`.

## What you must NOT create

- `docs/dev/` of any kind: master-plan, blueprint, `decisions/*.md`, ADR files;
- wiki pages documenting the development process (product wiki is `docs-sync`);
- any file duplicating what the issue or PR body already records.

Exception: if the user explicitly requests a development document — create it
where they ask, then **report the conflict with `rules.md`** and suggest
recording the deviation in the PR description or an issue comment.

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

## Deliverable vs Working State

- `CHANGELOG.md` is a **committed deliverable** (it travels in the same PR as
  the code, see `evodoc-pr`);
- ephemeral session/progress state stays in `.slim/` (git-ignored, see
  `deepwork`) — never confuse the two;
- product-facing documentation (README, wiki) is handled by `docs-sync`;
- on `/full` lanes, the resumable story state lives in the **issue body**
  (see `story-craft`): never as a file in the repo.

## Relation to Other Skills

- `evodoc-pr` — CHANGELOG updates travel in the same PR; mental but no new
  files;
- `docs-sync` — product documentation (README, wiki) boundary;
- `deepwork` — ephemeral plan state (`.slim/`) vs durable state on the issue;
- `story-craft` — story files in `.slim/` + persistent state on the issue body; never committed dev docs;
- `completion-gate` — the gate verifies the changelog entry exists and no
  development documents were introduced.
