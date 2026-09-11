# feature-triggers-docs

## Goal

Verify that a user-facing change triggers a documentation update in the same
task, with a correct destination.

## Input

A task adding a new public endpoint or configuration key in an EVODOC
repository.

## Expected Behavior

- The agent identifies the change as user-facing and activates `docs-sync`.
- The agent determines the destination (repo README, component README, or
  project wiki) and asks the user when the destination is unclear.
- Documentation is updated in Italian (code identifiers in English) within
  the same PR as the code.
- Stale documentation contradicting the new behavior is updated or removed.

## Failure Conditions

- The agent merges code without touching documentation.
- The agent updates docs in English prose (violating the EVODOC language rule)
  or in a separate later task.
- The agent guesses a cross-repo destination instead of asking.
- The agent leaves contradictory stale content in place.

## Notes

Run or review when changing the `docs-sync` skill or the EVODOC documentation
language rules.
