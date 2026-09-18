---
name: spec-archive
description: Maintain a durable delta-spec archive inside an EVODOC brownfield repository (.agents/specs/ with stable capability specs plus proposed/implemented/archived change deltas), adapted from the OpenSpec discipline. Use when an EVODOC brownfield project needs durable specifications whose changes are tracked as deltas instead of living only in story/PR history. Do not use for greenfield one-off spec documents, or when the repo only needs the skill/evals structure covered by project-kb-setup.
---

# Spec Archive

You help an EVODOC brownfield project keep durable, living specifications with
every change tracked as a delta. Mental model:

```text
specs/<capability>/spec.md   = current truth (stable requirements)
changes/<change-id>/         = proposed → implemented delta
                               (proposal.md, tasks.md, spec.md)
changes/archive/<change-id>/ = completed deltas, kept forever
```

**Adaptation vs OpenSpec**: delta-shaped specs only — no OpenSpec CLI, no forced
SDLC pipeline. One change = one capability; change-id doubles as the git branch
name (see `evodoc-pr`). The archive lives under `.agents/specs/` so it
complements — never duplicates — the project knowledge base managed by
`project-kb-setup`.

## Archive Structure

Create/use this layout under `.agents/specs/`:

```text
.agents/specs/
  specs/<capability>/spec.md           # current truth
  changes/<change-id>/proposal.md      # motivation for the change
  changes/<change-id>/tasks.md         # checklist of implementation steps
  changes/<change-id>/spec.md          # delta with markers
  changes/archive/<change-id>/         # merged deltas, never edited
```

### spec.md format

Stable requirements with scenario blocks:

```markdown
#### Requirement: <requirement-name>
- <stable behavior statement, English if the repo is English>

##### Scenario: <scenario-name>
- Given <context>
- When <action>
- Then <observable outcome>
```

### Delta spec.md markers

Use `## ADDED Requirements`, `## MODIFIED Requirements`, `## REMOVED
Requirements` to show what the change alters relative to the current spec.

## Workflow

### 1. Propose

- create `changes/<change-id>/proposal.md` with motivation, impact and the
  affected capabilities;
- `change-id` is kebab-case (e.g. `import-documenti`) and MUST equal the git
  branch name created from the issue (see `evodoc-pr`);
- one change = one capability.

### 2. Implement

- add the delta `changes/<change-id>/spec.md` with `## ADDED/MODIFIED/REMOVED
  Requirements` sections — do not touch `specs/` yet;
- keep a `tasks.md` checklist of the implementation steps;
- dispatch the actual work with one skill/story per unit of work (see
  `story-craft`).

### 3. Archive

- after implementation and review, merge the delta into
  `specs/<capability>/spec.md`;
- move the change folder to `changes/archive/<change-id>/`;
- never delete a change folder: archived deltas are the project's history.

## Guardrails

- change-id is the branch name: keep both in sync (`evodoc-pr`);
- one change = one capability; split cross-capability work into separate
  changes;
- docs in Italian (EVODOC `rules.md`); requirement statements in English when
  the repository code is English;
- never modify archived `changes/archive/` content — write-only;
- the spec describes WHAT (behavior), not HOW (implementation);
- never edit `specs/` outside the archive workflow.

## Relationship with other skills

- `project-kb-setup` — spec-archive is the durable-spec layer of the project
  KB; keep skills/evals there and specs here, referencing each other.
- `story-craft` — stories carry the implementation work for a change; reference
  the change-id in the story so the delta and the work stay linked.
- `evodoc-pr` — the change-id doubles as the branch name and the PR flow
  (branch → PR → squash merge on dev) is the delivery vehicle for a change.
- `docs-sync` — after a change ships, keep user-facing docs truthful; the
  archived delta is the source of truth for what changed.