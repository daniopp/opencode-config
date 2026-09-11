# EVODOC - Regole di sviluppo (Team ZeroD / SmeUP)

Fonte: wiki https://github.com/smeup/ZD_evoDoc2/wiki
Queste regole sono vincolanti per tutti gli agent che lavorano sui progetti EVODOC.

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
- Repository: `_evodoc_-cosa-tecnologia-funzione` (es. `evodoc-library-dotnet-algorithm`);
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

## Test
- Framework: **XUnit**; assertion con **Fluent Assertions**.
- Progetto di test: `<nomeprogetto>.Tests`.
- Struttura: pattern **AAA** (Arrange – Act – Assert) con i tre commenti espliciti.
- Naming test: `Metodo_StateUnderTest_ExpectedBehavior` (es. `Add_EmptyString_ReturnsZero`).
- `[Fact]` per test singoli, `[Theory]` + `[InlineData]`/`[MemberData]` per test parametrici.
- Test isolati (mock/stub/DI), deterministici, rapidi, senza logica replicata.
- Coprire happy path, casi di errore/edge case, comportamenti eccezionali.

## Workflow di sviluppo (GitHub)
1. **Task**: GitHub Project [EVOPLATFORM](https://github.com/orgs/smeup/projects/25) → issue assegnata da `Planned` a `In Progress`.
2. **Branch**: creato **sempre da `dev`** via "Create branch" della issue.
   Formato: `<tipo>/<numero-issue>-<breve-descrizione-kebab-case>`.
   Tipi: `feature/`, `fix/`, `tech-debt/`, `chore/`, `spike/`, `hotfix/`.
   Esempi: `feature/125-import-documenti`, `fix/238-errore-login`.
   Se la issue tocca più repository: **un branch per repository**, stesso nome in tutti, dalla stessa issue.
3. **Sviluppo**: commit e push sul branch; i test automatici girano a ogni commit/PR.
4. **Pull Request**: una per repository modificato. Nel corpo **aggiungere il numero issue** a:
   ```
   Refs smeup/evoplatform-projects#
   ```
   Titolo PR: `<tipo>: <breve descrizione>` con tipi `feat | fix | tech-debt | refactor | chore | docs | test`.
   Esempio: `feat: aggiunta gestione PEC`. Vietati titoli generici (`fix`, `update`, `modifiche`).
5. **Review**: a PR pronta → issue `Review Status = Waiting Review`; collegare tutte le PR nella sezione Development della issue. Con modifiche richieste → `Changes Requested`.
6. **Merge**: **Squash and Merge** su `dev`; il messaggio del commit squash deve essere `<tipo>: <breve descrizione> (#numeroPR)` (es. `fix: gestione errore durante l'upload (#245)`).
7. **Dopo review approvata**: issue → `Ready to Test`, `Review Status = Approved`.

## Branching e versioning
- Branch: `main` (produzione stabile), `dev` (testato, pronto per main), feature branch da `dev`.
- Servizi legacy (repo: `ZD_evoDoc2`, `ZD_ClientUnico`, `ZD_Zerod.evoPortal`, `ZD_Zerod.evoServer.Connector`, `ZD_Zerod.evoENGINE`): versione `YYYY.MM.DD.X` impostata da Jenkins (non manuale).
- Microservizi: **SemVer** `MAJOR.MINOR.PATCH`; breaking → MAJOR, nuove funzionalità compatibili → MINOR, bugfix → PATCH.
  - Branch feature: `MAJOR.MINOR.PATCH-feature.NOME_BRANCH.X`
  - Branch dev: `MAJOR.MINOR.PATCH-dev.X`
- Prerelease NuGet: workflow CI/CD manuale da GitHub Actions sul branch di lavoro (non più automatico per commit).
- Sviluppi misti legacy+microservizio: sviluppare **prima** il microservizio/SDK, referenziare la prerelease feature nel legacy; **prima della PR del legacy rimuovere il riferimento feature** e puntare alla versione dev/stabile.

## Commesse (ore su agenda SmeUP)
- `EVO.006` nuove funzionalità · `EVO.007` integrazione smeup · `EVO.008` int. plain doc
- `EVO.009` bugfix · `EVO.010` software testing
- `DS-S709` solo riunioni interne · `GRN.OR1.02` smeup lab
