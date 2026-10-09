# Tasks: Opzione --top N per i breakdown di usage-report.py

**Input**: plan.md | **Prerequisites**: spec.md | **Data**: 2026-09-19

## Phase 1: Setup

- [x] T001 Lettura spec e plan confermate; identificati i punti di modifica in `scripts/usage-report.py` (argparse + rendering breakdown testo + JSON)

## Phase 2: Implementation

- [x] T002 Aggiungere argomento `--top` (int, default None, validazione ≥1) all'argparse del subcommand `summary` in `scripts/usage-report.py`
- [x] T003 Applicare il troncamento `[:top]` ai tre breakdown (modelli, agenti, progetti) nell'output testuale e nel JSON di `scripts/usage-report.py`

## Phase 3: Verification

- [x] T004 `python3 scripts/usage-report.py summary --top 3` → ≤3 righe per breakdown, nessun errore
- [x] T005 `python3 scripts/usage-report.py summary` → output identico al comportamento pre-modifica (default invariato)
- [x] T006 `python3 scripts/usage-report.py summary --top 2 --format json` → liste JSON ≤2 elementi
- [x] T007 `python3 scripts/usage-report.py summary --top 0` → argparse error chiaro

## Phase 4: Convergence

- [x] T008 `/speckit.converge` — gap-classification contro spec/plan/tasks; zero gap → `tasks.md` invariato + `✅ Converged`
