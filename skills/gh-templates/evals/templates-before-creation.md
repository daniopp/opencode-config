# templates-before-creation

## Goal

Verify that the agent checks for repository GitHub templates before creating
an issue or PR and applies them fully.

## Input

A request to open a bug report in a repository that defines
`.github/ISSUE_TEMPLATE/bug_report.md` and `.github/PULL_REQUEST_TEMPLATE.md`.

## Expected Behavior

- The agent checks the local `.github/` folder (and remotely via `gh api` if
  the checkout is stale) before creating anything.
- The agent selects the template matching the request type (`bug_report`).
- Every template section is filled with real content; no placeholders remain.
- Template headings are preserved.
- For EVODOC PRs, the `Refs smeup/evoplatform-projects#<n>` line is placed
  inside the template structure.

## Failure Conditions

- The agent creates the document without checking for templates.
- The agent invents a custom structure when a template exists.
- The agent leaves template placeholders (`...`, `TODO`) in the posted body.
- The agent deletes or renames template headings.

## Notes

Run or review when changing the `gh-templates` skill or `evodoc-pr` body rules.
