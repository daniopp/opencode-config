# Story 004: reflect evidence-based + cleanup OMO residui

## Meta
- Feature: plans/roadmap-patterns-wave2/plan.md
- Status: in-progress
- Blocked-by: -

## Goal
Estendere `skills/reflect/SKILL.md` con la disciplina retro evidence-based
(pattern BMAD v6.11 `bmad-retrospective`: evidenze git, verdetto,
follow-through degli action item) e ripulire i riferimenti stantii al
plugin rimosso `oh-my-opencode-slim`.

## Contesto (inlined)
- `skills/reflect/SKILL.md` (326 righe): workflow in 5 passi (Inventory,
  Find patterns, Score, Smallest form, Propose). Già evidence-driven ma
  senza: fase di raccoglimento evidenze git strutturata, action item con
  stato tracciati su file, follow-through al giro successivo.
- Pattern BMAD v6.11 (PR #2612): retro a 5 fasi Gather → Analyze → Discuss
  opt-in → Decide → Close; ogni finding con source reference (diff range,
  churn); verdetto `accepted | accepted-with-open-items | rejected`
  (rejected se c'è lavoro incompleto); fase 1 di ogni retro = follow-through
  degli action item precedenti (✅/⏳/❌).
- Riferimenti OMO stantii da rimuovere (plugin disinstallato a giugno 2026):
  riga 23 ("improve their oh-my-opencode-slim setup..."), riga 87 (storage
  `~/.config/opencode/oh-my-opencode-slim/reflections/`), riga 182
  ("oh-my-opencode-slim configuration"), riga 216 ("active oh-my-opencode-slim
  preset, model routing..."). Sostituire con wording neutro (skills/config
  attuali; storage `~/.config/opencode/reflections/`).

## Acceptance criteria
- [ ] AC1 — nuova sezione `## Retrospective Mode` con le 5 fasi Gather →
  Analyze → Discuss opt-in → Decide → Close; evidenze git reali (diff range
  dei commit del periodo, file toccati) oltre alle fonti attuali; ogni
  finding con source-ref; verdetto finale `accepted | accepted-with-open-items |
  rejected` (rejected obbligatorio se ci sono task incompleti).
- [ ] AC2 — action item tracciati: ogni azione decisa finisce in un file
  con stato `✅ done | ⏳ open | ❌ dropped` — `plans/{feature}/retro.md`
  per retro di progetto, `~/.config/opencode/reflections/retro.md` per
  retro globale; follow-through: la prima fase di ogni retro verifica gli
  action item del giro precedente.
- [ ] AC3 — `grep -ci 'oh-my-opencode-slim' skills/reflect/SKILL.md` == 0,
  con i punti citati riformulati in modo neutro (niente perdita di senso).
- [ ] AC4 — Solo `skills/reflect/SKILL.md` modificato; la struttura esistente
  (Session Mode, Workflow, Guardrails) resta intatta.

## Hard constraints
- NON modificare: nessun altro file.
- NON toccare le query bun/sqlite esistenti (corrette e in uso).
- Lingua inglese (stile del file).

## Verification
- `grep -ci 'oh-my-opencode-slim' skills/reflect/SKILL.md` → 0
- `grep -c 'accepted-with-open-items\|follow-through\|retro.md' skills/reflect/SKILL.md` ≥ 3
- `wc -l skills/reflect/SKILL.md` ≤ 400

## Out of scope
- Altre skill, memory/user-prefs.md (già pulito), comandi.
