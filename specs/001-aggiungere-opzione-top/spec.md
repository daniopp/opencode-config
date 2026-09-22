# Feature Specification: Opzione --top N per i breakdown di usage-report.py

**Feature Branch**: `001-aggiungere-opzione-top`

**Created**: 2026-09-19

**Status**: Draft

**Input**: User description: "aggiungere opzione --top N ai breakdown del summary di usage-report"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Limitare le righe dei breakdown (Priority: P1)

Chi usa `usage-report.py summary` su many modelli/agenti/progetti vuole
vedere solo i primi N elementi per costo, senza scorrere tabelle lunghe.

**Why this priority**: unico caso d'uso della feature; i breakdown sono le
uniche sezioni affette.

**Independent Test**: `python3 scripts/usage-report.py summary --top 3`
mostra al massimo 3 righe per ogni breakdown (modello/agente/progetto).

**Acceptance Scenarios**:

1. **Given** uno storico con ≥5 modelli, **When** eseguo `summary --top 3`,
   **Then** ogni breakdown mostra ≤3 righe, ordinate per costo desc (ordinamento invariato).
2. **Given** l'assenza di `--top`, **When** eseguo `summary`, **Then** il
   comportamento è identico all'attuale (default: tutte le righe).
3. **Given** `--top 0` o negativo, **When** eseguo `summary`, **Then**
   argparse rifiuta con errore chiaro (valore deve essere ≥1).

### Edge Cases

- `--top N` con N ≥ numero di righe disponibili → tutte le righe (nessun errore).
- `--top` con `--format json` → le liste JSON sono limitate allo stesso modo.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `summary` MUST accettare `--top N` (int ≥1) applicato ai tre
  breakdown (modello, agente, progetto).
- **FR-002**: `summary` MUST comportarsi come oggi quando `--top` è assente.
- **FR-003**: L'output JSON (`--format json`) MUST rispettare lo stesso limite.
- **FR-004**: `sessions` ed `export` MUST rimanere invariati.

### Key Entities *(include if feature involves data)*

- Nessuna entità nuova: solo filtro di presentazione sulle aggregazioni esistenti.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `summary --top 3` su DB reale produce breakdown ≤3 righe ciascuno.
- **SC-002**: Nessuna regressione sui comandi esistenti (`sessions`, `export`, `--format json`).

## Assumptions

- Solo il subcommand `summary` è interessato.
- Il numero di righe totali (sezione "Totale globale") non è affetto da `--top`.
