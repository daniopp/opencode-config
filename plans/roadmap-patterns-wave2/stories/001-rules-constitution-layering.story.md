# Story 001: Constitution SemVer + rule layering

## Meta
- Feature: plans/roadmap-patterns-wave2/plan.md
- Status: in-progress
- Blocked-by: -

## Goal
Trasformare `rules/rules.md` in artefatto di governance versionato
(pattern "constitution" di GitHub Spec Kit) e documentare la disciplina di
layering delle regole (pattern Cursor).

## Contesto (inlined)
- `rules/rules.md` (89 righe): regole EVODOC del team, vincolanti per tutti
  gli agent. Inizia con `# EVODOC - Regole di sviluppo (Team ZeroD / SmeUP)`
  e sezioni Lingue, Nomenclatura, Regole C#/VB.NET, ecc. Vive ANCHE in live
  config — il contenuto attuale è la fonte di verità, NON riscriverlo.
- `rules/README.md` (23 righe): descrive il contenuto di rules.md. Leggilo
  prima di modificarlo.
- Pattern Spec Kit: constitution con versione SemVer (MAJOR = rimozione
  principio, MINOR = nuova regola, PATCH = chiarimento), amendment procedure
  esplicita, cronologia versioni. Regola chiave: "le violazioni si risolvono
  cambiando spec/piano/task, mai diluendo un principio".
- Pattern Cursor: sempre-on solo per gli invarianti ("commands, not reasons");
  regole di dominio glob-scoped per progetto; manuale = lane/comandi.

## Acceptance criteria
- [ ] AC1 — `rules/rules.md`: subito sotto il titolo, nuovo blocco
  `> Versione: 1.0.0 (2026-09-18)` + sezione `## Governance di questo file`
  con: SemVer (semantica MAJOR/MINOR/PATCH come sopra), procedure di modifica
  (una modifica = PR su questo repo, aggiorna versione + riga in Cronologia),
  regola "i principi non si diluiscono per chiudere un conflitto".
- [ ] AC2 — `rules/rules.md`: nuova sezione finale `## Layering delle regole`
  con la mappa: globali always-on = solo invarianti EVODOC, obiettivo <200
  righe, stile "comandi non ragioni"; dominio-specifico = `.opencode/rules/*.md`
  nel progetto, caricati via glob in `instructions` (opencode lo supporta);
  manuale = lane e comandi. Una riga di esempio di glob.
- [ ] AC3 — `rules/rules.md`: nuova sezione finale `## Cronologia versioni`
  con entry `1.0.0 (2026-09-18) — versione iniziale governata` e una riga
  che riepiloga il contenuto preesistente (nessun cambiamento di regole).
- [ ] AC4 — `rules/README.md`: aggiornato per menzionare versione/governance
  e layering.
- [ ] AC5 — NESSUNA regola esistente modificata o rimossa: solo aggiunte.
  `git diff rules/rules.md` mostra zero cancellazioni di righe esistenti.

## Hard constraints
- NON modificare: nessun altro file oltre `rules/rules.md` e `rules/README.md`.
- Italiano per entrambi i file (sono documentazione team).
- NON toccare il contenuto preesistente di rules.md (nemmeno typo/formattazione).

## Verification
- `git diff --numstat rules/rules.md` → insertions > 0, deletions == 0
- `grep -c '^## ' rules/rules.md` aumenta di 3

## Out of scope
- Sync verso live config, modifiche a opencode.jsonc.
