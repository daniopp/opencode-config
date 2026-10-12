# Regole di sviluppo (Team ZeroD / SmeUP)

> Versione: 2.1.1 (2026-10-12)

Regole **universali**: vincolanti per tutti gli agent su **tutti i progetti**
(organization smeup e account daniopp/danifx), perimetro EVODOC incluso.
Le regole **aggiuntive o sostitutive** del perimetro EVODOC (repo legacy `ZD_*`
e repo con `evodoc` o `zerod` nel nome) stanno nel file `evodoc.md`, caricato
insieme a questo.

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

## Ambito e priorità

1. Questo file vale per tutti i progetti.
2. `evodoc.md` si applica ai soli progetti del perimetro EVODOC, riconosciuti
   dal nome del repository; dove indicato, sostituisce o integra le regole
   generali. Fonte primaria del perimetro: la wiki di sviluppo del team
   <https://github.com/smeup/ZD_evoDoc2/wiki>.
3. Progetti fuori perimetro: solo le regole generali di questo file, più le
   best practice ufficiali del linguaggio/framework in uso.
4. Regole conflittuali o dubbie: fermarsi e **chiedere** quale livello si
   applica; le regole non si adattano al caso singolo senza conferma.

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
- Costanti: `PascalCase` (es. `MaxValue`), come da linee guida Microsoft.
  `UPPER_SNAKE_CASE` solo dove la convenzione del linguaggio lo prevede
  (`enum` in Python, costanti C-like). La wiki EVODOC indica ancora
  `UPPERCASE`: vedi nota in `evodoc.md`.
- Evitare notazione ungherese

> **ATTENZIONE (retrocompatibilità dati):** NON rinominare proprietà di oggetti già
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
- Indentazione coerente; una riga vuota tra metodi e attorno ai blocchi logici.
- **Niente righe vuote casuali** all'interno dei blocchi.
- Preferire `var` quando il tipo è evidente dal contesto.
- Preferire LINQ (`.Where(...)`, `.Select(...)`, `.ToList()`) ai loop manuali.
- Stringhe vuote: usare `string.Empty`, non `""`.

### Commenti

- Breve commento su funzione o classe: sì. Commento prolisso: no.
- Nessun riferimento a documenti temporanei di sviluppo (issue, piani…).
- Nessun commento su casi specifici di errori trovati: solo una breve
  spiegazione dell'algoritmo, dove serve.
- Le spiegazioni di funzionamento vanno nel README, non nel codice.
- I commenti non devono proliferare fino a rendere il codice illeggibile.
- Dopo ogni modifica, verificare i commenti ancora validi e aggiornarli.

## Altri linguaggi

- Seguire le convenzioni ufficiali/consolidate della comunità del linguaggio
  (formattazione, linting, naming, gestione errori, packaging).
- Le regole trasversali del file restano valide (lingue, segreti, eccezioni,
  test, workflow, documentazione).

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

- **Nessun documento di sviluppo nei repository di codice**: niente `docs/dev/`, master-plan, blueprint, note di analisi o `decisions/`. Non vanno né nel tree del codice, né su alcuna "memory" centrale.
- **Tutta la documentazione (di utilizzo e di sviluppo) va nella wiki del repository**:
  - Repo con wiki GitHub nativa (repo smeup o assetti simili): `https://github.com/<owner>/<repo>/wiki`;
  - Repo privati daniopp → cartella `wiki/` nella root del repository, stessa struttura (per-directory subfolder per i temi, `Home.md` come indice) — la wiki GitHub nativa non è disponibile per i privati.
  - Eccezioni: `README.md` e `CONTRIBUTING.md` in root (versionati, review PR); `CHANGELOG.md` in root (unico artefatto di sviluppo commitato).
- L'audit trail è già garantito dal workflow: **issue** (scope e motivazioni),
  **PR body** (`Refs <owner>/<repo>#<issue>`) e **messaggio di squash merge**
  (`<tipo>: <descrizione> (#PR)`).
- Decisioni architetturali significative: registrale nella **descrizione della PR**.
- Unico artefatto di sviluppo commitato: `CHANGELOG.md` (stile Keep a Changelog).
- Stato effimero di sessione: solo in cartelle git-ignored (es. `.slim/`),
  muore a fine lavoro.

## Test

Framework: **XUnit**; assertion con **Fluent Assertions**.
Progetti non .NET: framework di test standard dell'ecosistema, stesse regole
di disciplina.

- Progetto di test: `<nomeprogetto>.Tests`.
- Struttura: pattern **AAA** (Arrange – Act – Assert) con i tre commenti espliciti.
- Naming test: `Metodo_StateUnderTest_ExpectedBehavior` (es. `Add_EmptyString_ReturnsZero`).
- `[Fact]` per test singoli, `[Theory]` + `[InlineData]`/`[MemberData]` per test parametrici.
- Test isolati (mock/stub/DI), deterministici, rapidi, senza logica replicata.
- Coprire happy path, casi di errore/edge case, comportamenti eccezionali.

## Workflow di sviluppo (GitHub)

1. **Task**: issue nel tracker del progetto (GitHub Issues/Projects del repo)
   portata da backlog ad "in corso".
2. **Branch**: `<tipo>/<breve-descrizione-kebab-case>` dal branch base del
   progetto (`main` di default, o `dev` se previsto). Tipi: `feature/`, `fix/`,
   `tech-debt/`, `chore/`, `spike/`, `hotfix/`.
3. **Sviluppo**: commit e push sul branch; test automatici a ogni commit/PR.
4. **Pull Request**: una per repository modificato. Nel body
   `Refs <owner>/<repo>#<issue>`. Titolo: `<tipo>: <breve descrizione>` con
   tipi `feat | fix | tech-debt | refactor | chore | docs | test`.
5. **Merge**: Squash and Merge; il messaggio del commit squash deve essere
   `<tipo>: <breve descrizione> (#numeroPR)`.
6. **Versioning**: `MAJOR.MINOR.PATCH` (SemVer) di default; override nel repo.
   Breaking → MAJOR, funzionalità compatibili → MINOR, bugfix → PATCH.

I progetti del perimetro EVODOC seguono la variante completa in `evodoc.md`
(EVOPLATFORM, branch e prerelease da `dev`, versioning legacy/microservizi).

## Layering delle regole

Le regole si organizzano su tre livelli (pattern Cursor):

1. **Globali always-on** — solo gli invarianti (questo file + `evodoc.md`):
   obiettivo sotto le 200 righe, stile "comandi non ragioni" (cosa fare, non il perché).
2. **Dominio-specifico** — regole del singolo progetto in
   `.opencode/rules/*.md`, caricate via glob in `instructions` (opencode lo
   supporta), es.:

   ```jsonc
   "instructions": ["~/.config/opencode/rules/rules.md", "~/.config/opencode/rules/evodoc.md", ".opencode/rules/*.md"]
   ```

3. **Manuale** — lane e comandi (`.opencode/commands/*.md`), non always-on.

## Cronologia versioni

- `2.1.1 (2026-10-12)` — **PATCH**: correzione redazionale: il nome dell'account privato passa da `danismeup` a `daniopp` (account e repo privati). Nessun cambio di regola.
- `2.1.0 (2026-10-09)` — **MINOR**: nuova regola "Tutta la documentazione nella wiki del repository": utilizzo e sviluppo vanno nella wiki (nativa GitHub per i repo smeup; cartella `wiki/` versionata nel repo per i privati danismeup, che non possono abilitarla). Unico eccezioni in root: `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md` — niente `docs/`, `plans/`, `specs/`, `mcp/` nel tree. Nessun principio indebolito: il divieto di `docs/dev/` e master-plan nel tree resta.
- `2.0.0 (2026-10-07)` — **MAJOR**: ristrutturazione su due file. Le regole
  specifiche EVODOC (workflow EVOPLATFORM, versioning legacy/microservizi,
  prerelease NuGet, flusso misto legacy+micro, commesse) migrano in
  `rules/evodoc.md`, che individua il perimetro dal nome del repository
  (`ZD_*` o contiene `evodoc`/`zerod`); i kokos_* di altri team e tutti i
  progetti smeup/daniopp/danifx fuori perimetro seguono solo le regole
  universali. Il file universale integra dal wiki (Stile e best practice):
  regole sui commenti e `string.Empty`. Nessun principio indebolito: il
  contenuto EVODOC conserva la stessa forza normativa nel file dedicato.
- `1.4.0 (2026-10-05)` — **MINOR**: le costanti passano da `UPPER_SNAKE_CASE` a
  `PascalCase`, eliminando una contraddizione interna: la sezione "Regole
  C# / VB.NET" imponeva già di seguire le linee guida Microsoft, che in C#
  prescrivono `PascalCase` anche per le costanti. `UPPER_SNAKE_CASE` resta
  indicato per i linguaggi la cui convenzione lo prevede (`enum` in Python,
  costanti C-like). Nessun principio indebolito; decisione presa in
  AutoDiario.it, che adottava `PascalCase` in contrasto con la regola.
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
