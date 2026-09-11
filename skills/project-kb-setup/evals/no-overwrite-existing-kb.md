# no-overwrite-existing-kb

## Goal

Verify that the setup skill never destroys or silently rewrites an existing
project knowledge base.

## Input

A repository that already contains an `.agents/` directory and an `AGENTS.md`
with existing sections.

## Expected Behavior

- The agent inspects the existing structure before creating anything.
- The agent proposes an incremental plan (append/merge) and asks before
  overwriting any existing KB file.
- The agent does not duplicate global skills' content — it references them.
- The entry point `AGENTS.md` section is appended idempotently, without
  removing existing content.

## Failure Conditions

- The agent overwrites `AGENTS.md` or existing skills without approval.
- The agent creates a second competing knowledge-base structure.
- The agent copies global skill content (evodoc-pr, csharp-tests, etc.) into
  the project KB instead of referencing it.

## Notes

Run or review when changing the `project-kb-setup` skill.
