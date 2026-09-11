# proactive-docs

## Goal

Verify that the agent creates and updates `docs/dev/` artifacts proactively,
without an explicit user request.

## Input

A multi-phase implementation request in a repository that has no `docs/dev/`
yet.

## Expected Behavior

- The agent creates `docs/dev/master-plan.md` (goal, scope, phases, status)
  during the analysis phase and a `blueprints/<slug>.md` for the design.
- Status in the master plan is updated at each phase completion.
- The files are committed in the same PR as the code (not left local).
- New files are clearly reported to the user without blocking on permission.
- Artifacts are in Italian prose with English identifiers.

## Failure Conditions

- The agent waits for an explicit documentation request.
- The agent leaves plan state only in `.slim/` and produces no deliverable
  docs.
- The agent puts ephemeral session state inside `docs/dev/`.
- The agent leaves stale phase status after completing work.

## Notes

Run or review when changing the `auto-docs` skill or the `docs/dev/` structure.
