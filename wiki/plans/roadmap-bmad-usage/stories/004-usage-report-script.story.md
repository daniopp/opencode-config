# Story 004: script usage-report.py (token/cost reporting)

## Meta
- Feature: plans/roadmap-bmad-usage/plan.md
- Status: ready
- Blocked-by: -

## Goal
Creare `scripts/usage-report.py` (Python 3 stdlib only) che legga
`~/.local/share/opencode/opencode.db` e produca report di consumi token e
costo, con export persistente (ledger CSV) per analisi storiche.

## Contesto (inlined)
Schema verificato del DB (SQLite, epoch ms):
- `session`: `id, project_id, cost REAL, tokens_input, tokens_output,
  tokens_reasoning, tokens_cache_read, tokens_cache_write, model, agent,
  time_created, time_updated, time_archived`
- `model` è una stringa JSON: `{"id":"z-ai/glm-5.3-flash","providerID":"openrouter",...}`
  → normalizzare in `openrouter/z-ai/glm-5.3-flash`; fallback alla stringa
  raw se il JSON non parsea.
- `project(id, worktree)` → join per il nome progetto.
- DB attuale: 396 sessioni, ~$93 totali. Valori `cost` già calcolati da opencode.
Query di prova già eseguita con successo:
`sqlite3.connect('file:<db>?mode=ro', uri=True)`.

## Acceptance criteria
- [ ] AC1 — `python3 scripts/usage-report.py summary` stampa: totali globali
  (sessioni, token per categoria, costo USD) + breakdown per modello, per
  agente e per progetto (ordinati per costo desc), allineati in colonne.
- [ ] AC2 — filtri: `--days N` (default: tutto), `--since YYYY-MM-DD`,
  `--until YYYY-MM-DD`, `--project substring`, `--model substring`,
  `--agent substring` (match case-insensitive su model/agent normalizzati).
- [ ] AC3 — `python3 scripts/usage-report.py export` scrive/upserta un CSV
  (default `~/.local/share/opencode/usage/ledger.csv`, override `--out`)
  con colonne: `session_id,time_created_iso,time_updated_iso,project,model,
  agent,tokens_input,tokens_output,tokens_reasoning,tokens_cache_read,
  tokens_cache_write,cost_usd`. Re-run = idempotente (stesso numero righe,
  nessun duplicato: upsert per session_id, ultima versione vince).
- [ ] AC4 — `python3 scripts/usage-report.py sessions --limit 10` elenca le
  sessioni recenti (id corto, data, progetto, modello, agente, token, costo).
- [ ] AC5 — `--format json` (solo per summary) stampa JSON con le stesse
  aggregazioni. `--db PATH` override del DB (default
  `~/.local/share/opencode/opencode.db`).
- [ ] AC6 — accesso DB SOLO read-only (`?mode=ro`); lo script non scrive mai
  nel DB; crea la directory del ledger se manca.

## Hard constraints
- NON modificare: nessun altro file. Solo creazione `scripts/usage-report.py`.
- Python 3 stdlib only (sqlite3, argparse, csv, json, datetime, pathlib, os).
- NON toccare `opencode.db`, `opencode.db-wal`, `opencode.db-shm` in scrittura.
- Gestire `cost`/`tokens` NULL come 0; `agent` NULL come `unknown`.
- Numeri di costo con 2 decimali nei report; token con separatore migliaia.

## Verification
- `python3 scripts/usage-report.py summary --days 7` → output senza errori,
  totali coerenti con:
  `python3 -c "import sqlite3; db=sqlite3.connect('file:$HOME/.local/share/opencode/opencode.db?mode=ro',uri=True); print(db.execute('select count(*), round(sum(cost),2) from session').fetchone())"`
  filtrato sugli stessi giorni.
- `python3 scripts/usage-report.py export && wc -l ~/.local/share/opencode/usage/ledger.csv`
  → righe = sessioni + 1 header; secondo run invariato.
- `python3 scripts/usage-report.py summary --format json | python3 -m json.tool` valido.

## Out of scope
- Comando `/usage`, README, CHANGELOG (story 005). Any pricing table.
