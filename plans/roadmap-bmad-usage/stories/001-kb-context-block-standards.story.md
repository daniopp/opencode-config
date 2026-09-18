# Story 001: kb-setup — verified context block + standards per-progetto

## Meta
- Feature: plans/roadmap-bmad-usage/plan.md
- Status: ready
- Blocked-by: -

## Goal
Estendere `skills/project-kb-setup/SKILL.md` con due nuove sezioni che
completano la roadmap BMAD: (a) disciplina "verified context block"
(ispirata a `bmad-project-context` v6.11+) e (c) standards per-progetto
(stile Agent OS v3: discover → injection).

## Contesto (inlined)
- `skills/project-kb-setup/SKILL.md` (111 righe, intero file rilevante):
  skill esistente che scaffalda `.agents/` KB nei progetti. Ha sezioni:
  Base Structure, Workflow (1.Inspect, 2.Design, 3.Entry point, 4.Evals,
  5.Register), Guardrails.
- I due aggiunti si innestano NEL workflow esistente: la Base Structure si
  estende con `.agents/standards/` + blocco marker in AGENTS.md; il workflow
  guadagna due step numerati coerenti con lo stile attuale.

## Acceptance criteria
- [ ] AC1 — `skills/project-kb-setup/SKILL.md` contiene una sezione
  `## Verified Context Block` che definisce: marker HTML `<!-- kb:context:v1 -->`
  con blocco chiuso `<!-- /kb:context -->`, intents `setup | adopt | refresh | audit`,
  regola "solo fatti verificati sul repo" (ogni riga deve essere verificata con
  comandi reali prima della scrittura), refresh = ri-verifica riga per riga,
  audit = segnala righe non più vere senza modificarle.
- [ ] AC2 — contiene una sezione `## Standards per-progetto` che definisce:
  directory `.agents/standards/*.md` (es. coding.md, api.md, security.md),
  workflow discover (inferisci standard da evidenze nel repo → proponi →
  approvazione utente → scrivi), injection via puntatori thin in AGENTS.md
  (maiuscolo: NON auto-load di tutto, l'agente legge lo standard rilevante
  solo quando tocca quel dominio).
- [ ] AC3 — Base Structure aggiornata: `.agents/standards/` appare nell'albero;
  il blocco context marker appare nel template AGENTS.md della sezione
  "Write the Entry Point".
- [ ] AC4 — Guardrails aggiornate con: mai scrivere nel context block fatti non
  verificati; standards vivono nel progetto, non nella config globale.
- [ ] AC5 — Nessun altro file modificato.

## Hard constraints
- NON modificare: nessun altro file oltre `skills/project-kb-setup/SKILL.md`.
- Stile del file esistente: inglese per istruzioni, righe ~72-76 col,
  salti di riga tra sezioni come nel file attuale.
- NON riscrivere/riorganizzare le sezioni esistenti: solo aggiunte puntinate
  e aggiornamenti minimi a Base Structure/Guardrails dove richiesto dagli AC.
- Mantieni il frontmatter `description` esistente (puoi estenderlo con
  "verified context block" e "project standards" solo se utile).

## Verification
- `grep -c 'kb:context' skills/project-kb-setup/SKILL.md` ≥ 2
- `grep -c 'standards' skills/project-kb-setup/SKILL.md` ≥ 4
- `git diff --stat` mostra solo `skills/project-kb-setup/SKILL.md`

## Out of scope
- Creazione di nuove skill, modifiche ad altre skill, sync verso live config.
