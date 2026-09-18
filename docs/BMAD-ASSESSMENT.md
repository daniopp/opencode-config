# Valutazione BMAD v6 e framework spec-driven

> Data: 2026-09-18 · Status: **decisione presa** — non adottare BMAD integrale; riutilizzare i pattern vincenti (skill `story-craft` e `spec-archive`, `project-kb-setup` estesa; roadmap completata)

## Domanda di partenza

Conviene integrare BMAD (BMad Method) nella nostra config opencode? In alternativa, possiamo costruire in casa i pezzi mancanti per un "BMAD equivalente o migliore"? Esiste qualcosa di meglio di BMAD?

## BMAD v6 — stato reale (settembre 2026)

- **Versione**: v6.12.0 (2026-09-04); v6 stabile da v6.0.0 (2026-02-17). Da v6.1 architettura "everything is a skill": **non genera subagenti nativi opencode** — le persone-agente girano come skill nel contesto primario (issue #1976).
- **Claim "−90% token"**: marketing di BMad (README, document sharding), **non benchmark indipendente**. Misure della community: issue #1343 → agenti BMAD al 67%+ della finestra 200K (fino all'86% per TEA); issue #1235 → 80–100K token/step su PRD corpose. Risparmio reale: significativo ma molto più basso del claim, dipendente da dimensioni dei documenti e disciplina fresh-context.
- **Brownfield**: `bmad-project-context` (v6.11+) scrive un blocco verificato tra marker `<!-- bmad:context -->` nell'`AGENTS.md` del repo (intents: setup / adopt / refresh / record / audit). `bmad-build` indaga il repo esistente prima di produrre la spec. OpenCode legge `AGENTS.md` nativamente.
- **Requisiti duri**: Node ≥ 20.12; `uv` + Python 3.11+ obbligatori da v6.11 (`bmad-build` si ferma senza).
- **OpenCode non è piattaforma "preferred"** (lo sono Claude Code, Cursor, Copilot, Codex): i fix OpenCode-specifici arrivano reattivamente, con storia di breakage (path `workflow.md` relativi, directory errate pre-v6.5).
- **Install (project-level)**: `npx bmad-method install --yes --modules bmm --tools opencode` → `.agents/skills/`, `.opencode/commands/`, `opencode.json`, `_bmad/`, `_bmad-output/`. Non tocca `~/.config/opencode`.

## Panorama alternative (settembre 2026)

| Framework | Stato | OpenCode | Brownfield | Peso | Forza unica | Debolezza |
|---|---|---|---|---|---|---|
| **GitHub Spec Kit** | v1.0.x (2026-08-21), attivissimo | nativo (commands; `--skills` opt-in) | sì (docs dedicate + case study reale) | medio | artefatti versionati CLI-managed + converge loop, zero lock-in | cerimonia e rigidezza di fase per piccoli cambi |
| **OpenSpec** | v1.3–1.5, attivo | nativo (`/opsx:*`) | brownfield-first (delta specs) | leggero | archivio delta-spec minimo (ADDED/MODIFIED/REMOVED) | enforcement soffice, ecosystem piccolo |
| **AWS Kiro** | GA 2026-05 | no (Bedrock lock-in) | sì | medio | requirements EARS con analisi contraddizioni | harness sbagliato per noi (modelli solo Bedrock) |
| **task-master-ai** | 0.43.1, maturo | via MCP + rules profile | sì | pesante (~21k token MCP; profilo `core` ≈ −70%) | task graph con dipendenze e complessità | duplica le lane; dipendenza MCP |
| **Agent OS v3** | gen 2026 (−70% framework) | no | sì | leggero | standards discovery/injection (`index.yml`) | solo layer standards, single-author |
| **Backlog.md** | attivo | generico (AGENTS.md) | sì | leggero | ledger markdown task/kanban | solo task/PM, niente spec |
| **Codev** | v3.2.2, community piccola | no (builder Claude/Gemini/Codex) | sì | medio | protocollo SPIR + review multi-modello | harness proprio, adozione ridotta |

Note: Vibe Kanban in sunset (2026-04) — non adottare. Tessl: pivot verso governance, engine ancora beta.

## Gap analysis: BMAD v6 vs nostra config

| Pezzo BMAD | Nostro equivalente | Stato |
|---|---|---|
| Pipeline ruoli (analyst→PM→architect→dev→QA) | `orchestrator` + 8 subagent read-only | ✅ **meglio di BMAD**: subagent nativi con contesto isolato vs skill nel primary |
| Disciplina token | cap per lane (`/quick` 10k, `/medium` 20k, `/full` 40k, `/debug` 30k) + compaction | ✅ |
| Review gates | `reviewer`/`oracle` avversariali + `completion-gate` + `verifier` | ✅ più forti |
| **Story format con contesto inline + hard constraints** | `fixer` riceve file espliciti ma nessun formato standard | ❌ **GAP** → skill `story-craft` (creata) |
| Contesto brownfield verificato in AGENTS.md | `project-kb-setup` (verified context block `kb:context`) | ✅ fatto |
| Delta-spec archive (pattern OpenSpec) | skill `spec-archive` | ✅ fatto |
| Standards per-progetto (pattern Agent OS) | `project-kb-setup` (standards per-progetto) | ✅ fatto |
| Stato persistente tra sessioni (sprint-status.yaml) | `plans/{feature}/execution.md` | ⚠️ parziale (lo status nella story lo copre) |

## Verdict

1. **Non adottare BMAD integrale**: creerebbe due motori paralleli (skill BMAD nel primary vs orchestrator/subagent nativi), peso sul contesto primario, e conflitti concreti: artefatti EN di default vs regola EVODOC "documentazione = italiano"; `opencode.json` generato vs pattern `opencode-project-trusted.jsonc`; doppio sistema di review.
2. **Esiste di meglio di BMAD su dimensioni specifiche**: GitHub Spec Kit per artefatti durevoli + converge loop (nativo opencode, case study brownfield pubblicato), OpenSpec per leggerezza brownfield-first. Nessuno però batte la nostra combo per il nostro contesto: subagent nativi, cap token, regole EVODOC già integrate.
3. **Strategia scelta — homegrown + prestito mirato dei pattern**:
   - ✅ **Fatto**: skill `story-craft` (formato story BMAD: contesto inline, acceptance criteria, hard constraints, stato persistente) — si aggancia a `/medium` e `/full`.
   - **Roadmap** (completata 2026-09-18):
     - ✅ (a) esteso `project-kb-setup` con la disciplina "blocco di contesto verificato" (marker `kb:context`, intents setup/adopt/refresh/audit, ispirata a `bmad-project-context`)
     - ✅ (b) skill `spec-archive` — archivio delta-spec stile OpenSpec per il brownfield
     - ✅ (c) esteso `project-kb-setup` con standards per-progetto stile Agent OS v3 (discover → injection)
     - ✅ (d) risolta con l'esito della valutazione 003: pilota SÌ su GitHub Spec Kit, ma sulla modalità ufficiale `commands` (`.opencode/commands/`), NON su `--skills` (supporto opencode proposto in PR #2494, mai mergiata, stale dal 2026-09-11; v1.0.8 del 2026-09-17 è commands-based). Sintassi attuale `specify init --integration opencode` (i flag `--ai*` rimossi dalla v0.10.0 del 2026-06-09). Criterio pilota ≤1 giorno: 1 issue end-to-end `/speckit.specify → plan → tasks → implement → converge` con costituzione localizzata alle regole EVODOC. Rischio monitorato: PR #2494 per il passaggio futuro a `.opencode/skills/`.

## Misura (invece di fidarsi dei claim altrui)

`logs/token-tracker/tokens.jsonl` traccia già i consumi. Protocollo A/B consigliato prima di estendere l'adozione: stesso task reale su `/medium` con e senza `story-craft`; confrontare token/ciclo, numero di letture file ed eventuali loop.

## Fonti principali

- github.com/bmad-code-org/BMAD-METHOD (v6.12.0) · releases · issues #1343, #1235, #1976
- docs.bmad-method.org (install, existing-codebases, customize)
- github.com/github/spec-kit (v1.0.0 del 2026-08-21; PR #2453, #3539 per opencode)
- openspec.dev/docs/existing-projects · github.com/Fission-AI/OpenSpec
- kiro.dev/docs · docs.task-master.dev · buildermethods.com/agent-os
- github.com/MrLesk/Backlog.md · github.com/cluesmith/codev
