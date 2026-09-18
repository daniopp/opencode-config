---
name: project-kb-setup
description: Scaffold or update a project-level AI knowledge base inside an EVODOC repository (.agents/ skills, evals, standards, thin AGENTS.md entry point with a verified context block), adapted from the evohub pattern for opencode. Use when a repository team wants in-repo agent skills or project standards, or when asked to set up or evolve a project knowledge base. Do not use for global opencode config (use customize-opencode) or when no project-level knowledge is needed.
---

# Project Knowledge Base Setup

You help set up or update an **in-repository** AI knowledge base. Mental
model:

```text
skills     = project runtime guidance (domain rules)
references = deeper stable knowledge, loaded only when needed
evals      = validation artifacts for the knowledge base itself
AGENTS.md  = thin entry point that points agents to the KB
```

**Adaptation vs the evohub/Claude pattern**: no `router` skill and no
`agent-completion`/`skill-maintenance` clones. OpenCode routes via skill
descriptions and auto-loads `AGENTS.md`; the final gate lives in the global
`completion-gate` skill; knowledge-base evolution governance lives in global
`reflect`. A project KB must **complement, never duplicate**, the global
skills (`evodoc-pr`, `csharp-tests`, `bugfix-debugging`, `completion-gate`,
`docs-sync`, `verification-planning`).

**Loading model**: project KB files under `.agents/` are **not** registered as
OpenCode skills. Agents reach them because `AGENTS.md` (auto-loaded) points to
them and instructs when to read which file. Keep the entry point precise.

## Base Structure

```text
.agents/
  skills/<skill-slug>/SKILL.md
  skills/<skill-slug>/references/chapter.md   (optional, stable depth only)
  standards/<domain>.md                       (optional, per-domain)
  evals/<area>/<eval-name>.md
AGENTS.md
```

## Workflow

### 1. Inspect First

- check for an existing `.agents/`, existing `AGENTS.md` sections, and any
  competing convention in the repo;
- never overwrite existing KB files without explicit user approval.

### 2. Design the Skill Set

- derive skills from the repo's **recurring, stable workflows** (e.g. "adding
  a service method with tag dispatch", "extending the SDK for legacy
  consumers") — not from one-off tasks;
- one skill per domain, no overlaps; if boundaries cross, document precedence
  explicitly in each affected skill;
- keep each `SKILL.md` concise: routing-level guidance only; push deep stable
  knowledge (schemas, flow diagrams, checklists) into `references/`;
- include a **validation checklist** section in each domain skill.

### 3. Write the Entry Point

Create or append a thin `AGENTS.md` section:

```markdown
# AI Knowledge Base

<!-- kb:context:v1 -->
intent: setup
- <verified fact about the repo>
- <verified fact about the repo>
<!-- /kb:context -->

Before domain work, read the relevant skill under `.agents/skills/`.

- `<skill-slug>` — <one-line purpose>
- `<skill-slug-2>` — <one-line purpose>

Rules:
- read the domain skill before editing code in its domain;
- finish implementation tasks with the global completion-gate discipline
  (touched files, diagnostics honesty, residual risks);
- do not modify canonical `.agents/` files during implementation tasks;
  propose a separate maintenance change instead;
- evals under `.agents/evals/` are reviewed after knowledge-base changes.
```

### 4. Write Evals

One eval per critical behavior, in this exact format:

```markdown
# <eval-name>

## Goal
## Input
## Expected Behavior
## Failure Conditions
## Notes
```

Review/run evals after any KB change; a failed eval is a KB bug — fix the KB,
not the eval, unless the expectation itself was wrong.

### 5. Register and Confirm

- summarize the created structure to the user with file paths;
- note that the KB applies from the next agent session (AGENTS.md auto-load);
- suggest keeping the KB in the same PR discipline as code
  (see global `evodoc-pr`).

## Verified Context Block

`AGENTS.md` may carry a **verified context block**: a short fact-only
summary of the repository delimited by HTML markers.

```markdown
<!-- kb:context:v1 -->
intent: setup
- the build command is `dotnet build src/App.sln`
- unit tests run with `dotnet test`
<!-- /kb:context -->
```

- the block opens with `<!-- kb:context:v1 -->` and closes with
  `<!-- /kb:context -->`; the first line inside declares the intent;
- intents are `setup` (first write), `adopt` (re-express existing project
  context in this format), `refresh` (update), and `audit` (check only);
- the block holds **only facts verified on the repository**: verify every
  line with a real command before writing it;
- `refresh` re-verifies the block line by line — never bulk-copy old facts;
- `audit` reports lines that are no longer true and leaves the block
  untouched.

## Standards per-progetto

Project standards (coding conventions, API rules, security constraints)
live in `.agents/standards/*.md` — for example `coding.md`, `api.md`,
`security.md`. They are **discovered from the repo, not imposed**:

1. Discover — infer the standard from evidence in the repository
   (existing code, config, docs);
2. Propose — draft the standard file and show it to the user;
3. Approve — write the file only after explicit user approval;
4. Write — save it as `.agents/standards/<domain>.md`.

`AGENTS.md` injects **thin pointers** only — one line per standard naming
the domain and the file. Do NOT auto-load every standard: the agent reads
the relevant one only when it touches that domain.

## Guardrails

- do not create files outside the base structure without explicit approval;
- do not duplicate global skills' content — reference them;
- do not put project KB content that applies to all repos into the global
  skills directory;
- never write into the `kb:context` block facts that were not verified
  against the repository with real commands;
- project standards live in `.agents/standards/`, never in the global
  config or global skills directory;
- keep Italian for user-facing docs; skill instructions may follow the
  repository's existing language convention.
