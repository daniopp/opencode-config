---
name: bugfix-debugging
description: Diagnose, reproduce, and fix bugs with a reproduce-first, localize-first, root-cause discipline. Use when a reported defect is not yet localized, crosses subsystem boundaries, or needs investigation before fixing. Do not use for obviously scoped single-file fixes with a known cause, feature work, or knowledge-base maintenance.
---

# Bugfix Debugging

You help diagnose and fix defects. The core discipline: understand before
changing. These rules are binding.

## When to Use

- a reported defect has no known cause and no repro steps yet;
- the defect may cross subsystem boundaries and the owning area is unclear;
- you need to inspect logs, DB state, or git history to understand the problem;
- a regression needs localization before any fix.

## When Not to Use

- the cause is obvious and the fix is a scoped single-file change;
- the request is a new feature (use the owning domain skill instead);
- the task is knowledge-base or documentation maintenance.

## Core Rules (Binding)

1. **Reproduce before fixing.** A bug you cannot reproduce — locally, in a
   test, or through documented steps — is not yet understood. State the
   repro method explicitly (test name, manual steps, environment).
2. **Localize before changing.** Identify the owning subsystem/file before
   opening changes across multiple subsystems. If boundaries are unclear, map
   them first (who calls what, where data crosses).
3. **Failing test first.** When the fix touches testable code, add or extend a
   test that fails before the fix and passes after. For C# follow
   `csharp-tests` conventions.
4. **Fix the root cause.** Never paper over symptoms:
   - no blanket `try/catch` added just to silence an error;
   - no swallowing exceptions; rethrow with `throw;` (never `throw ex;`);
   - no returning `false`/null to make the symptom disappear;
   - no special-casing the single failing input when the general case is wrong.
5. **Evidence over memory.** Inspect logs, DB state, `git log`/`git blame` on
   the suspected file to understand recent intent. Never log sensitive data
   (passwords, tokens, personal data).

## Workflow

1. **Gather**: collect the defect report; ask for missing repro details
   (environment, input, expected vs actual, logs).
2. **Inspect**: read relevant anchors — logs, existing tests, entry points,
   git history of suspected files.
3. **Reproduce**: establish a reproducible scenario and state how.
4. **Localize**: name the owning area; if the bug crosses subsystems, trace
   the boundary crossing first.
5. **Failing test**: add the test that reproduces the bug (where applicable).
6. **Fix**: smallest change that fixes the root cause.
7. **Verify**: failing test now passes; run the suite for regressions.
8. **Close**: run the `completion-gate` checklist before reporting done.

## Relation to Other Skills

- `csharp-tests` — for the failing test and regression coverage;
- `verification-planning` — for complex or uncertain fixes, build the evidence
  path before committing to an approach;
- `completion-gate` — mandatory final gate before reporting the fix as done.
