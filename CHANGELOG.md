# Changelog

## 2026-10-12 - override provider opencode-go per claude-haiku-5-5

### Modificato

- `opencode.jsonc` — blocco `provider.opencode-go.models.claude-haiku-5-5` con `name`, `limit` (context 1M, output 128k) e `cost` ($0.10/$0.50, cache read $0.01, cache write $0.125) allineati a models.dev; tier di prezzo oltre 100k token omesso

## 2026-10-11 (2) - fix modello oracle

### Modificato

- `agents/oracle.md`, `agents/README.md`, `AGENTS.md`, `README.md`, `wiki/INSTALL.md` — `opencode-go/claude-sonnet-5-5` sostituito con `openrouter/anthropic/claude-sonnet-5.5`: il primo non esiste nel catalogo OpenCode Go (`ProviderModelNotFoundError`), il secondo risponde

## 2026-10-11 - riallocazione modelli su OpenCode Go (analisi costi/qualità Go + OpenRouter)

### Modificato

- `opencode.jsonc` — primario da `opencode-go/glm-5.3-flash` a `opencode-go/claude-haiku-5-5` ($0.10/$0.50, cache read $0.01 vs $0.15/$0.50/$0.03; τ²-Bench Airline 75.3% vs 75.7%, ctx 1M, vision); `small_model` da `openrouter/deepseek/deepseek-v4-flash-0731` a `opencode-go/deepseek-v4-flash` ($0.14/$0.28)
- `agents/{fixer,reviewer,verifier}.md` — da `openrouter/deepseek/deepseek-v4.1-flash` a `opencode-go/claude-haiku-5-5` (output 4× più economico del V4.1 Flash su Go, qualità agentic pari)
- `agents/looker.md` — da `openrouter/google/gemini-2.5-flash-lite` (retirement segnalato 20-10-2026) a `opencode-go/claude-haiku-5-5` (vision nativa)
- `agents/{explorer,librarian,observer}.md` — da `openrouter/deepseek/deepseek-v4.1-flash` a `opencode/mimo-v2.6-flash-free` (free tier Zen, τ² tool-call 79.7% — #2 assoluto)
- `agents/designer.md` — da `openrouter/meta/muse-spark-1.3-contributor` ($0.10/$0.20) a `opencode/muse-spark-1.3-contributor-free` ($0)
- `agents/oracle.md` — da `openrouter/deepseek/deepseek-v4-pro` (elenco volatile, Go $1.74/$3.84 = tier più caro) a `opencode-go/claude-sonnet-5-5` (τ² 78.0% #7, AA Intelligence #2)
- `agents/orchestrator.md`, `agents/README.md`, `AGENTS.md`, `README.md`, `wiki/INSTALL.md`, `scripts/set-models.sh` — allineati alla nuova mappa (alias `haiku`/`mimo`/`dsv4`)

### Note

- Fonte: listino modelli OpenCode Go (piano abbonato) + OpenRouter models/rankings/τ²-Bench ai 10-11 ottobre 2026; prezzi OpenRouter e Go combaciano per Haiku 5.5
- Prime prove su free tiers (mimo/muse contributor) da fare in sessione reale: rate-limit e latency da monitorare
- Cambio effettivo al riavvio di opencode (config non hot-reload)

## 2026-10-07 (2) - skill gh-pr-windows — fix gh pr create su Windows

### Aggiunto

- `skills/gh-pr-windows/SKILL.md` — skill on-demand per i fallimenti di `gh` (e subcommand che shellano git) su Windows: causa documentata `C:\src\depot_tools\git.bat` prima di `C:\Program Files\Git\cmd\git.exe` nel PATH (gh risolve il wrapper depot_tools, le chiamate git interne falliscono con `"merge" non è riconosciuto`); escalation PATH guard (`$env:PATH = "C:\Program Files\Git\cmd;$env:PATH"`) poi fallback REST `gh api repos/OWNER/REPO/pulls` (zero git locale)
- `.gitattributes` — `*.sh text eol=lf`: gli script shell restano LF nel working tree Windows

### Modificato

- `scripts/sync.sh` — normalizzato a LF nel working tree: ora eseguibile dal bash tool Windows (WSL `/mnt/c` e Git Bash), prima bocciato da bash con `$'\r': command not found`

### Note

- Root cause riprodotta con `gh pr create --dry-run` (errore riproducibile, niente PR spurie); fix PATH verificato empiricamente (dry-run verde dopo il guard); sync locale↔repo verificata per hash SHA-256
- Skill attiva al prossimo restart di opencode (le skill si caricano all'avvio)

## 2026-10-07 - rules v2.0.0 su due file — invarianti universali + perimetro EVODOC

### Aggiunto

- `rules/evodoc.md` — 1.0.0: regole del perimetro EVODOC (repo `ZD_*` o con `evodoc`/`zerod` nel nome), fonte wiki ZD_evoDoc2 — workflow EVOPLATFORM, branching/versioning (legacy `YYYY.MM.DD.X` da Jenkins, SemVer microservizi), prerelease NuGet manuali, flusso misto legacy+micro, rilascio fine sprint, commesse SmeUP
- `scripts/wiki-sync.ps1|.sh` — mirror wiki ZD_evoDoc2 in `wiki-mirror/` (git-ignored); `-InstallTask` crea task pianificata Windows giornaliera
- `docs/CHANGELOG.md` — entry release precedenti allineate

### Modificato

- `rules/rules.md` → 2.0.0 (MAJOR): ristrutturazione su due file — invarianti universali per tutti i progetti smeup/danismeup/danifx; contenuti EVODOC migrati in `rules/evodoc.md`; dal wiki "Stile e best practice": regole sui commenti e `string.Empty`
- `rules/README.md`, `AGENTS.md`, `README.md` — allineati alla struttura due-file e alla fonte wiki
- `.gitignore` — `wiki-mirror/` escluso

### Note

- Nessun principio indebolito: il contenuto EVODOC conserva la stessa forza normativa nel file dedicato; MAJOR per la ristrutturazione documentale, non per indebolimento di regole

## 2026-10-05 (2) - looker: modello PDF-capable (gemini-2.5-flash-lite)

### Modificato

- `agents/looker.md` — modello da `openrouter/minimax/minimax-m3` (no input `file`, causa errore "Cannot read pdf") a `google/gemini-2.5-flash-lite`: input PDF+immagine nativi, ctx 1M, $0.10/M in e $0.40/M out (tier low-cost, scelta dopo scan di 466 modelli del catalogo OpenRouter)
- `AGENTS.md` — inventario agenti allineato

### Note

- Modifica applicata sia al repo sia alla config live `~/.config/opencode/agents/looker.md` (i due file erano identici prima e dopo); richiede restart opencode per prendere effetto

## 2026-10-05 - rules.md v1.4.0 — costanti in PascalCase

### Modificato

- `rules/rules.md` → 1.4.0 (MINOR): le costanti passano da `UPPER_SNAKE_CASE` a `PascalCase` (`MaxValue`), eliminando la contraddizione interna con "Seguire le linee guida Microsoft" che in C# prescrive `PascalCase` anche per le costanti; `UPPER_SNAKE_CASE` resta indicato per i linguaggi la cui convenzione lo prevede (`enum` in Python, costanti C-like)
- `AGENTS.md`, `README.md`, `rules/README.md` — mention della versione allineate a 1.4.0

### Note

- Nessun principio indebolito: le regole "Documentazione di sviluppo", "Segreti", "Gestione delle eccezioni" e l'audit trail restano invariati; la modifica riguarda una sola convenzione di nomenclatura
- Decisione nata in `AutoDiario.it`, dove il codice aveva adottato `PascalCase` in contrasto con la regola: il codice è stato lasciato com'è, la regola allineata al codice

## 2026-10-04 (2) - rules.md v1.3.0 — regole valide anche fuori dal perimetro EVODOC

### Modificato

- `rules/rules.md` → 1.3.0 (MINOR): titolo generico "Regole di sviluppo"; nuova sezione "Ambito" con i default per i progetti fuori perimetro (issue nel tracker di progetto, nessun blocco `Refs smeup/evoplatform-projects#`, feature branch da `main`, SemVer di default); tag `[solo EVODOC]` su Workflow EVOPLATFORM, naming repository, Branching e Commesse
- `rules/README.md` — "Regole attuali" riscritte con l'ambito applicativo e i tag `[solo EVODOC]`; `AGENTS.md`, `README.md` — mention allineate

### Note

- Invariante `Universal+` confermato senza rimozioni di regole: audit trail issue/PR/squash resta universale (per i progetti esterni vale il tracker del repo); "Documentazione di sviluppo" (CHANGELOG unico), "Segreti" ed "Eccezioni" restano intatti
- Il titolo perde il prefisso `EVODOC -` perché il documento ora copre due perimetri; la fonte wiki e il team SmeUP restano citati in testata e nella sezione "Ambito"

## 2026-10-04 - v1.3.0 — agente looker, OpenCode Go, permission gating segreti (PR #8)

### Aggiunto

- `agents/looker.md` — nuovo agente multimodale (vision su `minimax-m3`): PDF/screenshot/diagrammi → fatti testuali, risparmio contesto orchestrator
- `scripts/set-models.sh` — switch modelli orchestrator/specialisti/small_model con dry-run e deploy live
- `scripts/sync.ps1` — equivalente Windows di `sync.sh` (rsync → robocopy)
- `.markdownlint.jsonc` — markdownlint attivo (MD013/MD060 off, MD024 siblings-only)
- `docs/PERMISSIONS.md` — documentazione matrice permessi

### Modificato

- `opencode.jsonc` — modello primario su `opencode-go/glm-5.3-flash`, `default_agent: orchestrator`; orchestrator senza override `model:` (fonte unica = config globale); permission gating `env`/`.ssh`, decision gate, pre-flight review
- `agents/{explorer,fixer,librarian,observer,oracle,reviewer,verifier}.md` — expert su varianti `:exacto` / `deepseek-v4-pro`; read/edit sempre a mappa con deny segreti speculari (`.env*`, `.dev.vars`, `.ssh/**`, `secrets/**`, `credentials*`) — permesso scalar `read: allow` rimosso (bypass deny globali)
- `rules/rules.md` → 1.2.2 (PATCH: fence `instructions` corretto); `AGENTS.md` — inventario agenti + pre-commit aggiornati

### Review

- Copilot code review: 6 findings (2 high di tipo permessi sui segreti, 2 medium config, 1 medium, 1 low) tutti risolti e thread risolti (commit `a0ee657`)

## 2026-09-28 - chore: specialisti su DeepSeek V4.1 Flash, alias dsv41

### Modificato

- `agents/{explorer,fixer,librarian,observer,oracle,reviewer,verifier}.md` — `model:` da `openrouter/deepseek/deepseek-v4-flash-0731` a `openrouter/deepseek/deepseek-v4.1-flash`; `orchestrator` resta su `z-ai/glm-5.3-flash` e `small_model` resta su V4 Flash 0731
- `AGENTS.md`, `INSTALL.md`, `agents/README.md` — tabelle dei modelli degli specialisti allineate a V4.1 Flash

### Aggiunto

- `scripts/set-models.sh` — alias `dsv41` (DeepSeek V4.1 Flash) accanto ad `dsv4`, che resta l'alias del `small_model`

## 2026-09-25 - tooling: script set-models.sh, switch modelli in un comando

### Aggiunto

- `scripts/set-models.sh` — switch dei modelli opencode in un unico comando: aggiorna `model`/`small_model` in `opencode.jsonc` e il frontmatter `model:` di `agents/*.md` (orchestrator = PRIMARY, specialisti = SPECIALISTS, small_model = SMALL); risolve alias (`glm`, `dsv4`) oppure accetta direttamente `provider/modello`; `--dry-run` mostra la tabella what-would-change senza applicare nulla, `--no-sync` salta il deploy; valida con `validate-jsonc.sh` (se presente) e allinea la config live via `sync.sh pull` (PR #3)

## 2026-09-19 (2) - Completamenti: pre-commit hooks, pilota Spec Kit, sync live

### Aggiunto

- `scripts/githooks/pre-commit` + `scripts/install-hooks.sh` — hook pre-commit (validate-jsonc con supporto argomenti, detect-private-key, markdownlint best-effort); attivazione con `./scripts/install-hooks.sh` (`core.hooksPath = scripts/githooks`). Fix post-verifica: `REPO_ROOT` via `git rev-parse --show-toplevel` (il `/..` originale era off-by-one e rendeva inerte il check)
- `plans/roadmap-patterns-wave2/stories/007-pre-commit-hooks.story.md` — story completata
- Pilota Spec Kit su `spike/speckit-pilot` (commit `446685e`): `specify init . --integration opencode`, constitution EVODOC v1.0.0, ciclo end-to-end su feature reale (`--top N` per `usage-report.py`) con converged zero gap

### Aggiornato

- `docs/BMAD-ASSESSMENT.md` — esito pilota nella roadmap (d), sezione Misura aggiornata a `usage-report.py` (sostituisce il vecchio `logs/token-tracker`)
- Live config sincronizzata (`scripts/sync.sh pull`): wave 1+2 attive dal riavvio opencode

## 2026-09-19 - Wave 2: pattern adottati (rules, verifier, story-craft, reflect, frontmatter)

### Aggiunto

- `rules/rules.md` — v1.0.0 con sezioni Governance SemVer, Layering e Cronologia (+39/-0)
- `rules/README.md` — sezioni Governance e Layering (+15/-0)
- `agents/verifier.md` — passo 5 "Three-Dimensional Check (Graceful Degradation)", Verdict `PASS | CONCERNS | FAIL | UNVERIFIED` con source-ref obbligatoria, sezione `### Convergence Tasks` append-only (`T{NNN} <desc> per <source-ref> (<gap-type>)`)
- `skills/completion-gate/SKILL.md` — chiusura `GATE: PASS | CONCERNS | FAIL` + residual risk con evidenza
- `commands/full.md` — passo 8 con dual-review (reviewer + oracle modelli diversi), rebuttal fixer, disaccordo → escalazione umana, no self-approval
- `skills/story-craft/SKILL.md` — Step 0 Scale check, Meta con `Cerimonia: piena | ridotta`, preserve-never-downgrade nel Lifecycle
- `skills/reflect/SKILL.md` — sezione Retrospective Mode (5 fasi Gather→Analyze→Discuss→Decide→Close, evidenze git, verdetto accepted/accepted-with-open-items/rejected, action item con follow-through in `plans/{feature}/retro.md` o `~/.config/opencode/reflections/retro.md`)
- Frontmatter agentskills.io — `compatibility` aggiunto a 3 skill (`evodoc-pr`: gh CLI+git; `csharp-tests`: .NET SDK; `clonedeps`: git, npm, dotnet); 17/17 skill validate
- `docs/BMAD-ASSESSMENT.md` — sezione finale `## Wave 2 — pattern adottati (2026-09-18)` con 7 item, verdetto e fonti

### Modificato

- `skills/reflect/SKILL.md` — rimossi 5 riferimenti stantii a oh-my-opencode-slim

## 2026-09-18 (3) - usage reporting, comando /usage, roadmap BMAD completata

### Aggiunto

- `scripts/usage-report.py` — report consumi token e costo dalle sessioni opencode (DB read-only): subcomandi `summary|export|sessions`, filtri `--days/--since/--until/--project/--model/--agent`, `--format json`, ledger CSV upsert
- `commands/usage.md` — comando TUI `/usage` per il report consumi token e costo
- Skill `spec-archive` — archivio delta-spec duraturo nel brownfield (pattern OpenSpec)
- Estensione skill `project-kb-setup` — verified context block (`kb:context`) + standards per-progetto

### Aggiornato

- `docs/BMAD-ASSESSMENT.md` — roadmap completata (a)-(d): `project-kb-setup` estesa, skill `spec-archive`, valutazione Spec Kit risolta (pilota SÌ su modalità `commands`, non `--skills`)

## 2026-09-18 (2) - opencode.jsonc cross-platform, risolta divergenza instructions

### Modificato

- `opencode.jsonc` (repo + live, ora byte-identici): `instructions` in formato `~/` → `~/.config/opencode/rules/rules.md`. Eliminata la divergenza nota repo↔live (prima: path Windows `C:/Users/...` nel repo vs path Linux `/home/daniele/...` in locale).
- `scripts/sync.sh` — svuotata la mappa `DIVERGENT` (il meccanismo resta disponibile per divergenze future)
- `commands/sync-config.md` — rimossa la gestione manuale del path `instructions`
- `AGENTS.md` (repo + live), `README.md` — note sulla divergenza aggiornate

### Note tecniche

- Verificato sul sorgente opencode (`packages/opencode/src/session/instruction.ts`): `~` è espanso con `os.homedir()` (→ `/home/daniele` su Linux, `C:\Users\<user>` su Windows); i path mancanti sono ignorati in silenzio (fail-safe); i path relativi sono risolti dalla cwd del progetto — mai usarli nella config globale.
- La config globale di opencode è `~/.config/opencode` su TUTTE le piattaforme (opencode pinna `xdg-basedir`, che non ha branch `%APPDATA%` su Windows).
- OpenCode 2.0 (beta): il campo `instructions` diventa inerte — in V2 le regole globali vanno in `~/.config/opencode/AGENTS.md`. Da tenere a mente alla migrazione.

## 2026-09-18 - Valutazione BMAD, skill story-craft, pulizie documentazione

### Aggiunto

- `docs/BMAD-ASSESSMENT.md` — valutazione BMAD v6 e framework spec-driven (GitHub Spec Kit, OpenSpec, Kiro, task-master-ai, Agent OS, Backlog.md, Codev), gap analysis vs config, decisione: homegrown + pattern presi in prestito
- Skill `story-craft` — story self-contained con contesto inline, acceptance criteria e hard constraints per i dispatch a `fixer` in `/medium` e `/full` (adattamento del formato story BMAD)

### Corretto

- `agents/README.md` — tabella agenti allineata ai modelli reali (GLM 5.3 Flash primario, DeepSeek V4 Flash specialisti, muse-spark-1.3 designer), aggiunti `reviewer` e `verifier`, nota storica plugin OMO aggiornata (repo + live)
- `rules/README.md` — sostituito il placeholder con la descrizione reale del contenuto di `rules.md` (repo + live)
- `memory/user-prefs.md` — rimosse le policy del plugin rimosso `oh-my-opencode-slim` (catene modelli, guard slim) (repo + live, fuori sync)
- `README.md` — riga skill `story-craft`, nuova sezione Documenti, directory tree aggiornata

## 2026-06-24 - Setup iniziale

### Aggiunto

- Config globale con modello Kimi K2.7 Code via OpenCode Go
- Script di avvio `start-opencode.sh` con supporto env locale e flag `--debug`
- Esempi configurazione per repo con MongoDB e SQL Server
- Documentazione GitHub MCP (remote vs locale)
- Documentazione Context7 MCP
- Guida setup completo
- Gestione permessi e sicurezza
- Troubleshooting e debug

### Note

- `@github/github-mcp-server` non disponibile su npm, usare remote server
- Chiavi config corrette: `plugin`, `permission`, `mcp` (no plural)
- MCP locali richiedono Node.js installato separatamente
