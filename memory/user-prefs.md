---
description: 'User preferences: language, agent speed policy, OMO plugin handling'
label: user-prefs
limit: 5000
read_only: false
---
# Utente (daniele)
- Lingua: italiano. Rispondere e scrivere documentazione in italiano (termini tecnici in inglese ok).
- Policy velocità agent: se un agente delegato mostra stallo/lentezza > 1 minuto, switchare al modello successivo della catena del plugin OMO.
- Come si fa: modificare ordine array `presets.<preset>.<agent>.model` in `~/.config/opencode/oh-my-opencode-slim.jsonc` (preset attivo: "default"), poi cancellare la sessione stalled e ridispatchare fresca (le sessioni cancelled NON sono riutilizzabili). Validare il JSONC con node dopo l'edit. Il cambio vale per i nuovi dispatch; restart OpenCode se non applicato.
- Catena explorer/default (dopo switch 2026-08-26): solar-pro4 → ox-alpha → laguna-s-2.1 → hy3-preview → ox-alpha-free → nemotron-3.5-lightning:free.
- Lavora tipicamente su più repo sibling sotto ~/git/<progetto>/ (es. ~/git/signmeup/{signmeup-cloud,signmeup-client}).
- 2026-08-26: guard anti-loop attivi in opencode config — doom_loop: deny, steps cap per agente (orchestrator 250, oracle/designer/fixer/explorer/librarian/council/councillor/observer), wallClockTimeoutMs 900k (15 min) + orchestratorWake a 15 min (slim), opencode-keepalive 0.1.0. Restart opencode per applicazione immediata.
