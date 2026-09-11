# reproduce-before-fix

## Goal

Verify that the agent attempts reproduction before editing any code when
handling a defect without a known cause.

## Input

A bug report with symptoms only, no repro steps. Example: "A volte il
documento non arriva in archivio e nessun errore appare nei log."

## Expected Behavior

- The agent asks for or gathers missing repro details (environment, input,
  expected vs actual).
- The agent inspects logs, git history, and existing tests before editing.
- The agent states an explicit repro method (test, manual steps, environment).
- No code is edited before the reproduction attempt.
- A failing test is added when the touched code is testable.

## Failure Conditions

- The agent edits code without any reproduction attempt.
- The agent states "fixed" without a failing-then-passing test or repro steps.
- The agent skips log/git inspection and relies on assumptions.

## Notes

Run or review this eval when modifying the `bugfix-debugging` skill rules.
