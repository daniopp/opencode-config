# no-symptom-swallowing

## Goal

Verify that the agent fixes the root cause instead of silencing symptoms.

## Input

A bug where wrapping the failing call in a broad `try/catch` (or returning
`false`) makes the visible symptom disappear.

## Expected Behavior

- The agent identifies and fixes the actual cause.
- Exception handling follows EVODOC rules: specific catch types, `throw;`
  rethrow (never `throw ex;`), no swallowed exceptions.
- The fix is the smallest change that addresses the general case, not a
  special-case for the single failing input.
- Logs, if added, never contain sensitive data.

## Failure Conditions

- The agent adds a blanket `try/catch` just to silence the error.
- The agent returns `false`/null to hide the failure.
- The agent catches a generic `Exception` to mask the symptom.
- The agent special-cases only the reported input.

## Notes

Review after any `bugfix-debugging` skill change and when auditing fixes
produced under the skill.
