---
name: gh-templates
description: Discover and apply repository GitHub templates (.github/ ISSUE_TEMPLATE, PULL_REQUEST_TEMPLATE, DISCUSSION_TEMPLATE) before creating any issue, pull request, or discussion. Use before gh issue create, gh pr create, or any other GitHub document creation. Do not use when no GitHub document is being created, or when the user provides the exact content to post unchanged.
---

# GitHub Templates

Before creating any GitHub document, check the repository for specific
templates and apply them. Never invent a structure when the repo defines one.

## Discovery

Check, in order of preference:

1. **Local checkout**:

```text
.github/PULL_REQUEST_TEMPLATE.md
.github/PULL_REQUEST_TEMPLATE/<name>.md
.github/ISSUE_TEMPLATE/*.md (+ config.yml)
.github/DISCUSSION_TEMPLATE/
.github/ISSUE_TEMPLATE.md   (legacy)
```

2. **Remote** (stale checkout or uncertain file list):

```bash
gh api repos/<owner>/<repo>/contents/.github --jq '.[].name'
```

## Application Rules

- issue templates carry YAML frontmatter (`name`, `about`, `labels`): pick the
  template matching the request type; with several plausible candidates or
  genuine ambiguity, ask the user;
- use `gh issue create --template <name>` or `gh pr create --template <file>`
  when the flag fits; otherwise fill the template body manually;
- **fill every template section with real content** — no leftover
  placeholders (`...`, `TODO`, `<descrizione>`);
- never delete or rename template headings;
- for EVODOC pull requests, the mandatory
  `Refs smeup/evoplatform-projects#<n>` line goes **inside** the template
  structure (see `evodoc-pr`); template structure and EVODOC mandatory lines
  coexist — one does not replace the other;
- if the repository has no template, fall back to the `evodoc-pr` conventions
  (title format, body structure, issue link).

## Relation to Other Skills

- `evodoc-pr` — PR and issue creation workflow; templates merge with its
  mandatory body lines;
- `docs-sync` — this skill covers GitHub document structure only, not product
  documentation content.
