# changelog-tracked

## Goal

Verify that every material change produces a `CHANGELOG.md` entry in the same
task.

## Input

A task that fixes a bug and changes a configuration default.

## Expected Behavior

- `CHANGELOG.md` `[Unreleased]` gains one concise entry per change in the
  correct category (`Fixed`, `Changed`).
- Each entry references the issue or PR number (`(#123)`).
- The changelog update travels in the same PR as the code.
- Empty categories are skipped; no invented version section appears.

## Failure Conditions

- The agent ships the change without any changelog entry.
- The agent dumps the full commit history instead of reader-relevant entries.
- The agent promotes `[Unreleased]` to a version number without being asked.
- The agent leaves placeholders or empty headings where content belongs.

## Notes

Run or review when changing the `auto-docs` changelog rules.
