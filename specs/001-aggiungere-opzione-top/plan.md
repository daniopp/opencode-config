# Implementation Plan: Opzione --top N per i breakdown di usage-report.py

**Branch**: `001-aggiungere-opzione-top` | **Spec**: [spec.md](./spec.md) | **Data**: 2026-09-19

## Constitution Check

- I. Regole EVODOC: messaggi/errore in italiano nel nuovo codice, identificatori inglesi → PASS
- II. Homegrown-first: modifica a script esistente, zero engine → PASS
- III. Token economy: modifica puntuale, verificabile con comandi → PASS
- IV. Verifica con evidenza: AC verificabili con comandi diretti → PASS
- V. Cerimonia proporzionata: single-story, spec snella → PASS

## Summary

Estensione del subcommand `summary` di `scripts/usage-report.py`: nuovo
flag `--top N` (int ≥1) che tronca i tre breakdown (modello/agente/progetto)
sia nell'output testuale sia in JSON. Nessun cambiamento a default, a
`sessions` né a `export`.

## Technical Context

- Linguaggio: Python 3 stdlib-only (vincolo esistente dello script)
- Punto di modifica: parsing args (argparse) + funzioni di rendering dei
  breakdown (testo e JSON)
- Testing: esecuzione diretta su DB reale + confronto output pre/post

## Check Simplicity (YAGNI)

- Un solo flag, semantica unica su tutti i breakdown: no per-breakpoint distinti
- Nessuna nuova dipendenza
