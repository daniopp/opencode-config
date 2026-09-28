---
name: completion-gate
description: Final verification gate to run when an implementation task is considered done, before reporting to the user. Verifies touched-file scope, runs or honestly reports diagnostics, and surfaces residual risks. Use at task completion. Do not use for pre-implementation planning (use verification-planning) or research-only tasks.
---

# Completion Gate

Run this gate every time an implementation task is considered done. It is a
verification gate: it does not replace tests, does not redo the task, and does
not silently modify config or knowledge-base files.

## 1. Touched Files Check

- list every file created, modified, or deleted during the task;
- verify each touched file belongs to the intended scope;
- if unrelated files were changed, explain why or revert them — ask the user
  when unsure. Never leave unexplained edits.

## 2. Diagnostics Check (Honesty Rule)

Run the available checks for every touched file:

- C#/.NET: `dotnet build` + `dotnet test` on the relevant projects;
- TypeScript/JS: typecheck, test suite, linter as the project requires;
- anything the project's release instructions mandate.

Binding honesty rules:

- if no suitable check exists, **say so explicitly**;
- **never claim a check was run if it was not run**;
- report exactly what ran, what passed, what was skipped, and why it was
  skipped. A skipped check is a declared gap, not a hidden one.

## 3. Skill Checklist Check

- re-read the validation/checklist section of the primary skill used for the
  task (e.g. `csharp-tests` coverage checklist, `evodoc-pr` completion
  checklist, `docs-sync` destination check, `auto-docs` changelog entry);
- confirm each item is satisfied; report any gap instead of glossing over it;
- confirm **no development documents** were introduced in the repo
  (`docs/dev/`, master plans, blueprints, ADR files, repo-wiki working-doc
  pages) — prohibited by `rules.md`; the only allowed artifact is
  `CHANGELOG.md`.

## 4. Evidence Check

- if an evidence path was planned with `verification-planning`, follow it to
  closure: report whether the original claim was **established, limited, or
  refuted**;
- distinguish known facts (verified outputs) from remaining uncertainty.

## 5. Residual Risks & Follow-ups

List explicitly:

- residual risks introduced or still open;
- deferred or manual steps the user must perform (e.g. restart OpenCode after
  config changes, run a migration, update project fields in the GitHub UI);
- anything a future session needs to know to pick this work up.

## Report

Close the task with the orchestrator output format: summary of what was done,
verification map with evidence (files, checks run), and notes with residual
risks. The gate is "passed" only when sections 1–5 have explicit answers —
"not applicable" is an acceptable answer, silence is not.

The report MUST close with an explicit verdict line:

- `GATE: PASS | CONCERNS | FAIL` - one word, followed by the motivation in a
  single sentence;
- `CONCERNS` = the work is complete but residual risks or non-blocking gaps
  remain; `FAIL` = a check failed or an item is unverified without declared
  evidence.

Every residual risk listed in section 5 MUST carry concrete evidence
(`path:line` or command output); an unlocatable risk is not a closed gate.
