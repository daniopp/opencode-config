# Plan: Roadmap BMAD + Usage Tracking

Fonte roadmap: `docs/BMAD-ASSESSMENT.md` (righe 50-51). Secondo obiettivo:
tracciare consumi token e costo con registrazione persistente e report.

## Stories

| ID | Titolo | Target file | Status |
|---|---|---|---|
| 001 | kb-setup: verified context block + standards | `skills/project-kb-setup/SKILL.md` | done |
| 002 | Nuova skill spec-archive (delta-spec brownfield) | `skills/spec-archive/SKILL.md` | done |
| 003 | Valutazione Spec Kit `--skills` (ricerca) | nota in `docs/BMAD-ASSESSMENT.md` (edit orchestrator) | done |
| 004 | Script usage-report.py (token/cost reporting) | `scripts/usage-report.py` | done |
| 005 | Comando /usage + README + CHANGELOG | `commands/usage.md`, `README.md`, `docs/CHANGELOG.md` | done |

## Regole di parallismo
- 001, 002, 004, 003 in parallelo (file disgiunti, 003 read-only).
- 005 SOLO dopo che 003/004 sono done (tocca file condivisi).

## Decisioni chiave
- Fonte dati: `~/.local/share/opencode/opencode.db`, tabella `session` —
  `cost` (REAL, calcolato da opencode), `tokens_input/output/reasoning/cache_read/cache_write`,
  `model` (stringa JSON), `agent`, `project_id` → join `project.worktree`.
- Nessuna pricing table: usiamo `session.cost` come fonte di verità (nota
  caveat: i modelli "free"/opencode-provider possono avere costi stimati).
- Ledger persistente: CSV upsert per session_id, default
  `~/.local/share/opencode/usage/ledger.csv` (fuori dal repo: dati macchina-specifici).
- DB access SEMPRE read-only (`?mode=ro`).
