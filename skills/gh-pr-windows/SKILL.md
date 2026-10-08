---
name: gh-pr-windows
description: Fix gh CLI PR creation failures on Windows caused by PATH resolving depot_tools git.bat or a poisoned environment instead of Git for Windows. Symptom errors include "failed to run git: X is not recognized", git merge-base or merge errors from internal gh calls, "executable not found in %PATH%", or PR creation aborting despite a working local git. Load whenever creating or merging pull requests with gh on Windows, or when any gh subcommand reports a git execution failure. Use the PATH-guard retry first and the REST API gh api fallback second. Do not use on Linux/macOS, or when gh works normally.
compatibility: "requires: gh CLI, git, PowerShell"
---

# gh on Windows: PR creation failures

## Cause (verify, don't assume)

`gh pr create` and related subcommands shell out to local git. When git resolves
to the depot_tools bootstrap `git.bat` or when depot_tools poisons the
environment, gh's internal git calls fail even though plain `git` in the shell
works. This is Windows-specific: Linux/macOS resolve `git` directly and are
unaffected.

Trigger conditions (this repo, gh v2.83.2, 2026-10-07):

```powershell
where.exe git          # C:\src\depot_tools\git.bat listed FIRST = trigger
Get-Command git -All | Select-Object -ExpandProperty Source
```

With `C:\src\depot_tools` before `C:\Program Files\Git\cmd` in PATH, both
plain `gh pr create` and `gh pr create --dry-run` fail:

```text
failed to run git: "merge" non è riconosciuto come comando interno o esterno
```

Adding the real git directory to the front of the process PATH fixes it, proven
by `--dry-run` succeeding afterwards. Do not assume this is the cause on other
machines — re-run the diagnosis commands first.

## Escalation — try in order

### Step 1: PATH guard + standard `gh pr create` (preferred)

Everything gh offers (template detection, upstream push, fork handling) stays
intact. Never write login-less machine-level PATH changes from here; this
guard is session-local.

```powershell
$env:PATH = "C:\Program Files\Git\cmd;$env:PATH"; gh pr create --base <base> --head <head> --title "<tipo>: <desc>" --body "<body>"
```

If `--head`/`--base` are not known, resolve them the normal way first; do not
invent branch names. Then retry creation. If it still fails the same way,
continue.

### Step 2: REST API creation (fallback, zero local git)

Depends only on `gh` auth — immune to any PATH problem.

```bash
# same-repo PR: head = branch name
gh api repos/<OWNER>/<REPO>/pulls -f title="<tipo>: <desc>" -f head="<BRANCH>" -f base="<BASE>" -f body="<body>"

# cross-repo PR (fork): head = "owner:branch"
gh api repos/<OWNER>/<REPO>/pulls -f title="..." -f head="<forkOwner>:<BRANCH>" -f base="<BASE>" -f body="<body>"
```

- `-f` = literal string; `-F` = typed value. `-F body=@file.md` loads the body
  from a file — use it for long bodies instead of breaking shell quoting.
- Literal `OWNER/REPO` in the path: do NOT use `{owner}/{repo}` placeholder
  syntax, which relies on repository detection that itself can hit git.
- The `issue` field is the alternative to title/body but is out of scope here.
- Verify after creation:

```bash
gh pr view <OWNER>/<REPO>/<NUM or URL> --json url,title,baseRefName,headRefName
```

or `gh pr list --head <BRANCH>`.

### Step 3: PR completion without git

```bash
gh pr merge <NUM> --squash --subject "<tipo>: <desc> (#<NUM>)"
gh pr merge <NUM> --delete-branch
gh pr edit <NUM> --title "..." --body "@file.md"
gh issue close <NUM>
```

## Rules

- Explicit `--base`/`--head` do NOT avoid local git — gh still calls
  `git config`, `git remote -v`, and (without explicit `--title`+`--body`)
  computes commit state via `git log --cherry`. Treat them as diagnostic, not a fix.
- Never retry a failed `gh api ... pulls` POST without checking for a 422
  `merge proposal already exists` / "Draft PR already exists" response: a
  first POST may have succeeded. One PR per branch.
- Prefer Step 1 over Step 2 when user-configured PR templates
  (`.github/PULL_REQUEST_TEMPLATE.md`) must be respected; `gh api` creation
  bypasses template auto-fill, so `gh-templates` handling applies manually.
- Do not delete or overwrite depot_tools PATH entries.

## Related Skills

- Use `evodoc-pr` for the EVODOC PR/issue workflow (branch format, `Refs` line,
  squash merge message). `gh-pr-windows` fixes only the Windows PATH/tooling
  failure mode.
- Use `gh-templates` for PR body structure before Step 1 and before manual body
  fill in Step 2.
