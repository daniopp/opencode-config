# Story 005: allineamento agentskills.io frontmatter

## Meta
- Feature: plans/roadmap-patterns-wave2/plan.md
- Status: in-progress
- Blocked-by: 003, 004 (le skill story-craft e reflect devono essere
  consolidate prima della sweep su tutte le frontmatter)

## Goal
Allineare il frontmatter di tutte le skill globali alla spec
agentskills.io (standard adottato da opencode): validare i campi obbligatori
e aggiungere `compatibility` dove ci sono dipendenze esterne dure.

## Contesto (inlined)
- Skill in `skills/*/SKILL.md` (17 skill). Frontmatter opencode riconosciuto:
  `name`, `description` (obbligatori), `license`, `compatibility`,
  `metadata` (opzionali). Campi sconosciuti ignorati con degrado graceful.
  Progressive disclosure: name+description ~100 token → body → resources.
- Spec agentskills.io: name minuscolo+hyphen ≤64 char, description ≤1024
  char; `compatibility` = stringa con requisiti (es. "requires: gh CLI,
  git").
- Dipendenze esterne dure per skill (da documentare in `compatibility`):
  `evodoc-pr` → `gh` CLI + git; `csharp-tests` → .NET SDK (dotnet);
  `clonedeps` → npm/nuggrep o git+dotnet; `usage`/nessuna per le altre.
  Valutare caso per caso leggendo ogni SKILL.md: aggiungi `compatibility`
  SOLO se c'è una dipendenza esterna dura; altrimenti lascia il frontmatter
  com'è.

## Acceptance criteria
- [ ] AC1 — tutte le `skills/*/SKILL.md` hanno frontmatter con `name` e
  `description` validi (name minuscolo+hyphen, description ≤1024 char).
- [ ] AC2 — `compatibility` aggiunto (una riga) SOLO alle skill con
  dipendenze esterne dure; per ognuna la stringa elenca gli strumenti.
- [ ] AC3 — NESSUN cambiamento al body (solo frontmatter): `git diff` sulle
  skill mostra solo righe dentro i primi delimitatori `---`.
- [ ] AC4 — report finale: lista delle skill toccate con la compatibility
  aggiunta e delle skill lasciate invariate con motivo.

## Hard constraints
- NON modificare: body delle skill, agent/, commands/, rules/.
- Non aggiungere `metadata` decorativi né `license` (repo senza LICENSE
  esplicita): solo `compatibility` dove serve.

## Verification
- Script: per ogni `skills/*/SKILL.md` verificare che il file inizi con
  `---`, contenga `name:` e `description:` nei primi 6 lin, e che description
  sia ≤1024 char (python3 one-liner va bene).
- `git diff --stat` mostra solo file in `skills/`.

## Out of scope
- Creazione/rimozione skill, cambiamenti di contenuto.
