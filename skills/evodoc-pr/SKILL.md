---
name: evodoc-pr
description: End-to-end EVODOC GitHub workflow from issue to squash merge on dev. Use when starting work on an EVODOC/SmeUP GitHub issue, creating a feature/fix branch, opening or updating a PR, or merging to dev. Encodes the binding workflow rules. Do not use for repositories outside the EVODOC workflow, personal projects, or local-only experiments.
compatibility: "requires: gh CLI, git"
---

# EVODOC PR Workflow

You help execute the standard EVODOC development workflow. All steps are
binding rules from the EVODOC development rules. Use the `gh` CLI (already
authenticated and allowlisted); never use a GitHub MCP server.

## Step 1: Verify the Issue

Work only on an issue assigned in the GitHub Project
[EVOPLATFORM](https://github.com/orgs/smeup/projects/25).

1. Confirm the issue number and repository with the user.
2. The issue must be moved from `Planned` to `In Progress` before starting.
   If `gh project` commands cannot update the custom project fields, tell the
   user which state change to perform manually in the project UI.
3. If the issue touches multiple repositories: plan one branch per repository,
   all with the same name, all originating from the same issue.

## Step 2: Create the Branch (always from `dev`)

Branch format:

```text
<tipo>/<numero-issue>-<breve-descrizione-kebab-case>
```

Allowed `tipo` values:

- `feature/`, `fix/`, `tech-debt/`, `chore/`, `spike/`, `hotfix/`

Example: `feature/125-import-documenti`, `fix/238-errore-login`.

Procedure (ask confirmation before pushing):

```bash
git fetch origin dev
git switch -c <branch-name> origin/dev
git push -u origin <branch-name>
```

Prefer the issue's "Create branch" button in the GitHub UI when the user does
it manually: it also links the branch in the issue's Development section.

Pre-flight: verify the branch name does not already exist locally or on remote
(`git branch -a --list '*<name>*'`) and that the working tree state is safe.

## Step 3: Develop on the Branch

- commits and pushes go to the branch only; never commit directly on `dev`;
- CI test runs happen on every commit and PR — fix failures before review;
- commit messages follow the same `<tipo>: <breve descrizione>` convention.

## Step 4: Open the Pull Request (one per modified repo)

PR title format:

```text
<tipo>: <breve descrizione>
```

- `tipo` values for titles: `feat | fix | tech-debt | refactor | chore | docs | test`
- generic titles are forbidden (`fix`, `update`, `modifiche`).
- Example: `feat: aggiunta gestione PEC`.

PR body must contain the issue reference:

```text
Refs smeup/evoplatform-projects#<numero-issue>
```

Create with:

```bash
gh pr create --base dev --title "<tipo>: <breve descrizione>" --body "Refs smeup/evoplatform-projects#<numero-issue>"
```

Before creating, verify: base branch is `dev`, title matches the pattern, body
contains the `Refs` line. If the repository defines PR templates, apply them
(see `gh-templates`), keeping the `Refs` line inside the template structure.
Link every PR in the issue's Development section.

## Step 5: Review States

- PR ready for review → issue `Review Status = Waiting Review`; link all PRs in
  the issue Development section;
- changes requested → issue `Review Status = Changes Requested`; address
  feedback on the same branch;
- review approved → issue `Ready to Test`, `Review Status = Approved`.

These are custom project fields; if `gh project` cannot set them, list the
exact field/value changes for the user to apply in the project UI.

## Step 6: Merge

- merge only via **Squash and Merge** onto `dev`;
- squash commit message format:

```text
<tipo>: <breve descrizione> (#<numero-PR>)
```

- Example: `fix: gestione errore durante l'upload (#245)`;
- merging requires explicit user confirmation.

## Completion Checklist

Before declaring the workflow done, verify:

- [ ] branch created from `dev` with correct name format;
- [ ] PR title and body follow the patterns (one PR per repo);
- [ ] `Refs smeup/evoplatform-projects#<n>` present in PR body;
- [ ] all PRs linked in the issue Development section;
- [ ] issue states updated (`In Progress` → `Waiting Review` → `Ready to Test`);
- [ ] squash merge message follows `<tipo>: <desc> (#<PR>)`.

## Related Skills

- Use `csharp-tests` when the work includes test code for C# projects.
- Use `gh-templates` before creating the issue or PR: apply repository
  templates and keep the mandatory `Refs` line inside the template structure.
- Use `auto-docs` so `docs/dev/` and `CHANGELOG.md` updates travel in the same
  PR as the code.
- Use `worktrees` only when the user explicitly wants isolated lanes; the
  branch naming must still follow this skill's EVODOC convention.
