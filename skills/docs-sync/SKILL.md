---
name: docs-sync
description: Keep product documentation truthful after user-facing changes. Use when a task adds, changes, or removes a user-facing feature, endpoint, public API or SDK method, configuration option, or setup step. Do not use for internal refactors or bug fixes with no documentation impact, or for changes to agent/skill files themselves.
---

# Documentation Sync

You keep product documentation in sync with the product. A feature-affecting
change includes its documentation update in the same task — never "docs
later".

## When to Use

A task:

- adds a user-facing feature, public endpoint, or public SDK method;
- changes the behavior, inputs, outputs, or contract of something already
  documented;
- removes a feature, endpoint, method, configuration option, or setup step
  that documentation still describes;
- adds or changes a configuration key or a build/run/deploy step meant for a
  human reader.

## When Not to Use

- internal refactor or bug fix with no impact on anything documented;
- changes only to agent/skill files (`AGENTS.md`, `.agents/`, skill folders) —
  those belong to knowledge-base maintenance;
- development documentation is prohibited in code repositories per
  `rules.md`; the only development artifact is `CHANGELOG.md`, handled by
  `auto-docs`;
- purely local or experimental work never intended for delivery.

## Destination Selection (EVODOC)

Determine the destination **before** editing:

1. **Repo `README.md`** (+ `README/documents/` when present) — repo-level
   behavior, setup steps, public contracts/tables of the repo itself.
2. **Component READMEs** — when the change is scoped to one component
   (e.g. an SDK subproject).
3. **Project wiki** (e.g. `https://github.com/smeup/ZD_evoDoc2/wiki`) —
   cross-repo process and product documentation.
4. **If unclear which destination applies → ask the user.** Do not guess for
   cross-repo documentation.

## Rules

- **Language**: documentation is written in **Italian** (EVODOC rule); code
  identifiers, APIs, and paths stay in English;
- read the existing structure and heading style before writing, so new
  content matches it;
- update every table, example, and flow the change affects; **delete stale
  content** rather than leaving contradictions;
- do not use private or sensitive material (credentials, internal URLs, personal
  data) in examples;
- docs edits are normal implementation work — they belong to the same PR as
  the code (see `evodoc-pr`), not to a separate "docs cleanup" task.

## Relation to Other Skills

- `evodoc-pr` — docs changes travel in the same PR as the code change;
- `auto-docs` — boundary: `docs-sync` covers product documentation only;
  `CHANGELOG.md` belongs to `auto-docs`; no other development artifacts
  exist (`rules.md`);
- `completion-gate` — the touched-files check must confirm docs were updated
  when this skill triggered.
