# Regole di sviluppo (Team ZeroD / SmeUP)

> Versione: 1.3.0 (2026-10-04)

Fonte: wiki <https://github.com/smeup/ZD_evoDoc2/wiki>
Queste regole sono vincolanti per tutti gli agent su **tutti i progetti**;
le sezioni marcate **[solo EVODOC]** si applicano ai soli progetti del perimetro
EVODOC (Team ZeroD / SmeUP) — vedi sezione "Ambito".

## Governance di questo file

Questo file è un artefatto di governance versionato (pattern "constitution").
Le modifiche seguono la semantica SemVer:

- **MAJOR** — rimozione o indebolimento di un principio esistente
- **MINOR** — aggiunta di una nuova regola
- **PATCH** — chiarimento o correzione redazionale senza cambio di regola

Procedura di modifica: una modifica = una PR su questo repo; la PR aggiorna la
versione nel blocco `> Versione:` in testa al file e aggiunge una riga nella
sezione `## Cronologia versioni`.

Regola chiave: le violazioni si risolvono cambiando spec/piano/task, mai
diluendo un principio. I principi non si diluiscono per chiudere un conflitto.

## Ambito

Le regole valgono per **tutti i progetti**, EVODOC e non. Le sezioni marcate
**[solo EVODOC]** si applicano esclusivamente ai progetti EVODOC (naming dei
repository, workflow di sviluppo EVOPLATFORM, branching legacy/Jenkins,
commesse SmeUP).

Nei progetti fuori dal perimetro EVODOC restano validi gli invarianti di questo
file con le seguenti differenze:

- **audit trail**: issue/epic nel tracker del progetto (GitHub Projects del
  progetto, non EVOPLATFORM); PR con `Refs <owner>/<repo>#<issue>`; messaggio
  di squash merge `<tipo>: <descrizione> (#PR)` come in EVODOC.
- **branch tipi**: `feature/`, `fix/`, `tech-debt/`, `chore/`, `spike/`,
  `hotfix/` + breve descrizione kebab-case; base branch `main` (default) o
  `dev` se previsto dal progetto.
- **versioning**: `MAJOR.MINOR.PATCH` (SemVer) di default; override nel repo.
- **CHANGELOG.md** resta l'unico artefatto di sviluppo commitato.

## Lingue

| Categoria | Lingua |
|---|---|
| Documentazione | Italiano |
| Nomi di funzioni e variabili | Inglese |
| Messaggi di eccezione | Italiano |
| Log | Italiano |

## Nomenclatura

- Variabili pubbliche: `PascalCase`
- Variabili private: `camelCase`
- Campi privati readonly: prefisso `_` + `camelCase` (es. `_readOnlyField`)
- Costanti: `UPPER_SNAKE_CASE` (es. `MAX_VALUE`)
- Evitare notazione ungherese
- Repository **[solo EVODOC]**: `_evodoc_-cosa-tecnologia-funzione` (es. `evodoc-library-dotnet-algorithm`);
  mondo DATA: `_kokos_-cosa-tecnologia-_evodoc_-funzione` (es. `kokos-me-dotnet-evodoc-evoengine`)

> **ATTENZIONE (reteopsibilità dati):** NON rinominare proprietà di oggetti già
> serializzati nel database e in rilascio: rendono i dati non retrocompatibili.
> Le nuove variabili seguono sempre le regole sopra.

## Regole C# / VB.NET

- **Sempre `List<T>`, mai `Collection<T>`** (problemi di serializzazione/deserializzazione con JSON.NET).
- Creazione `JObject` preferita:

  ```csharp
  var obj = new JObject() {
      new JProperty("XXX", "XXX"),
      new JProperty("YYY", "YYY")
  };
  ```

- Seguire le linee guida di codifica Microsoft per .NET.
- Graffe `{}` sempre su righe separate (stile Allman).
- Indentazione coerente; una riga vuota tra metodi; **niente righe vuote casuali** all'interno dei blocchi.
- Preferire `var` quando il tipo è evidente dal contesto.
- Preferire LINQ (`.Where(...)`, `.Select(...)`, `.ToList()`) ai loop manuali.

## Gestione delle eccezioni

- Incapsulare in try-catch solo il codice soggetto a errori reali; non catturare per ignorare.
- Rilanciare con `throw;` (mai `throw ex;` che perde lo stack trace).
- Preferire catch **specifici** (`ArgumentNullException`, ecc.); il catch generico `Exception` solo in servizi top-level o log centralizzato.
- Loggare sempre le eccezioni non gestite localmente: stack trace completo, parametri, stato rilevante.
- **Mai loggare dati sensibili** (password, token, dati personali).
- Non usare eccezioni per il controllo del flusso; eccezioni custom solo se aggiungono contesto.

## Gestione dei segreti

- Mai segreti nei repository: niente password, token, API key, chiavi, connection string nel codice, nei file versionati o nella cronologia git.
- I segreti vivono fuori dal repo, a seconda dell'ambiente: `.env` locale (sempre in `.gitignore`), variabili d'ambiente (server/CI), GitHub Secrets (GitHub Actions).
- Il codice li legge sempre allo stesso modo, indipendentemente dall'ambiente: **un unico meccanismo di accesso** (variabili d'ambiente / `IConfiguration`) con lo **stesso nome di variabile** in tutti gli ambienti.
- Nomi in `UPPER_SNAKE_CASE`, senza suffissi d'ambiente (es. `API_KEY`, `CONNECTION_STRING`): cambia solo dove il valore è definito, mai come il codice lo legge.

## Documentazione di sviluppo

- **Nessun documento di sviluppo nei repository di codice**: niente `docs/dev/`,
  master-plan, blueprint, note di analisi o `decisions/`. Non vanno né nei repo,
  né sulla wiki del repo, né su alcuna "memory" centrale.
- L'audit trail è già garantito dal workflow: **issue** (scope e motivazioni),
  **PR body** (`Refs <owner>/<repo>#<issue>`) e **messaggio di squash merge**
  (`<tipo>: <descrizione> (#PR)`).
- Decisioni architetturali significative: registrale nella **descrizione della PR**.
- Unico artefatto di sviluppo commitato: `CHANGELOG.md` (stile Keep a Changelog).
- Lane `/full` (feature multi-sessione): lo stato riassumibile della story vive nel
  **body dell'epic di riferimento** (aggiornamenti append-only via `gh`); a squash
  merge chiuderla con un commento finale. Niente file della story nel repo.
- Stato effimero di sessione: solo in `.slim/` (git-ignored), muore a fine lavoro.

## Test

- Framework: **XUnit**; assertion con **Fluent Assertions**.
- Progetto di test: `<nomeprogetto>.Tests`.
- Struttura: pattern **AAA** (Arrange – Act – Assert) con i tre commenti espliciti.
- Naming test: `Metodo_StateUnderTest_ExpectedBehavior` (es. `Add_EmptyString_ReturnsZero`).
- `[Fact]` per test singoli, `[Theory]` + `[InlineData]`/`[MemberData]` per test parametrici.
- Test isolati (mock/stub/DI), deterministici, rapidi, senza logica replicata.
- Coprire happy path, casi di errore/edge case, comportamenti eccezionali.

## Workflow di sviluppo (GitHub) [solo EVODOC]

1. **Task**: GitHub Project [EVOPLATFORM](https://github.com/orgs/smeup/projects/25) → issue assegnata da `Planned` a `In Progress`.
2. **Branch**: creato **sempre da `dev`** via "Create branch" della issue.
   Formato: `<tipo>/<numero-issue>-<breve-descrizione-kebab-case>`.
   Tipi: `feature/`, `fix/`, `tech-debt/`, `chore/`, `spike/`, `hotfix/`.
   Esempi: `feature/125-import-documenti`, `fix/238-errore-login`.
   Se la issue tocca più repository: **un branch per repository**, stesso nome in tutti, dalla stessa issue.
3. **Sviluppo**: commit e push sul branch; i test automatici girano a ogni commit/PR.
4. **Pull Request**: una per repository modificato. Nel corpo **aggiungere il numero issue** a:

   ```text
   Refs smeup/evoplatform-projects#
   ```

   Titolo PR: `<tipo>: <breve descrizione>` con tipi `feat | fix | tech-debt | refactor | chore | docs | test`.
   Esempio: `feat: aggiunta gestione PEC`. Vietati titoli generici (`fix`, `update`, `modifiche`).
5. **Review**: a PR pronta → issue `Review Status = Waiting Review`; collegare tutte le PR nella sezione Development della issue. Con modifiche richieste → `Changes Requested`.
6. **Merge**: **Squash and Merge** su `dev`; il messaggio del commit squash deve essere `<tipo>: <breve descrizione> (#numeroPR)` (es. `fix: gestione errore durante l'upload (#245)`).
7. **Dopo review approvata**: issue → `Ready to Test`, `Review Status = Approved`.

## Branching e versioning [solo EVODOC]

- Branch: `main` (produzione stabile), `dev` (testato, pronto per main), feature branch da `dev`.
- Servizi legacy (repo: `ZD_evoDoc2`, `ZD_ClientUnico`, `ZD_Zerod.evoPortal`, `ZD_Zerod.evoServer.Connector`, `ZD_Zerod.evoENGINE`): versione `YYYY.MM.DD.X` impostata da Jenkins (non manuale).
- Microservizi: **SemVer** `MAJOR.MINOR.PATCH`; breaking → MAJOR, nuove funzionalità compatibili → MINOR, bugfix → PATCH.
  - Branch feature: `MAJOR.MINOR.PATCH-feature.NOME_BRANCH.X`
  - Branch dev: `MAJOR.MINOR.PATCH-dev.X`
- Prerelease NuGet: workflow CI/CD manuale da GitHub Actions sul branch di lavoro (non più automatico per commit).
- Sviluppi misti legacy+microservizio: sviluppare **prima** il microservizio/SDK, referenziare la prerelease feature nel legacy; **prima della PR del legacy rimuovere il riferimento feature** e puntare alla versione dev/stabile.

## Commesse (ore su agenda SmeUP) [solo EVODOC]

- `EVO.006` nuove funzionalità · `EVO.007` integrazione smeup · `EVO.008` int. plain doc
- `EVO.009` bugfix · `EVO.010` software testing
- `DS-S709` solo riunioni interne · `GRN.OR1.02` smeup lab

## Layering delle regole

Le regole si organizzano su tre livelli (pattern Cursor):

1. **Globali always-on** — solo gli invarianti (questo file): obiettivo
   sotto le 200 righe, stile "comandi non ragioni" (cosa fare, non il perché).
2. **Dominio-specifico** — regole del singolo progetto in
   `.opencode/rules/*.md`, caricate via glob in `instructions` (opencode lo
   supporta), es.:

   ```jsonc
   "instructions": ["~/.config/opencode/rules/rules.md", ".opencode/rules/*.md"]
   ```

3. **Manuale** — lane e comandi (`.opencode/commands/*.md`), non always-on.

## Cronologia versioni

- `1.3.0 (2026-10-04)` — **MINOR**: perimetro esteso: le regole coprono
  **tutti i progetti**, non solo EVODOC. Nuova sezione "Ambito" con le
  differenze per i progetti fuori perimetro (issue nel tracker del progetto,
  nessun blocco `Refs smeup/evoplatform-projects#`, SemVer di default,
  `dev` facoltativo); tag **[solo EVODOC]** su Workflow EVOPLATFORM, naming
  repository, Branching e Commesse; titolo generico. Nessun principio
  indebolito sui progetti EVODOC.
- `1.2.2 (2026-10-04)` — **PATCH**: correzione redazionale del fence di chiusura
  errato nell'esempio `instructions` (apriva un blocco spurio rendendo il resto
  del documento come codice); nessun cambio di regola.
- `1.2.1 (2026-10-03)` — **PATCH**: correzione redazionale (linguaggio esplicito sul fence del blocco `Refs smeup/evoplatform-projects#`); nessun cambio di regola.
- `1.2.0 (2026-09-28)` — **MINOR**: nuova sezione "Documentazione di sviluppo"
  (nessun documento di sviluppo nei repo di codice — niente `docs/dev/`,
  master-plan, blueprint, wiki, memory centrali; audit trail = issue + PR +
  squash merge; decisioni nella descrizione della PR; unico artefatto di
  sviluppo commitato `CHANGELOG.md`; story multi-sessione nel body dell'issue).
- `1.1.0 (2026-09-22)` — **MINOR**: nuova sezione "Gestione dei segreti"
  (segreti mai nei repository, archiviati fuori dal repo a seconda
  dell'ambiente — `.env`, variabili d'ambiente, GitHub Secrets — e letti dal
  codice sempre con lo stesso meccanismo e lo stesso nome di variabile).
- `1.0.0 (2026-09-18)` — versione iniziale governata: riepiloga il contenuto
  preesistente (Lingue, Nomenclatura, Regole C#/VB.NET, Gestione delle
  eccezioni, Test, Workflow di sviluppo GitHub, Branching e versioning,
  Commesse) senza alcun cambiamento di regole.
