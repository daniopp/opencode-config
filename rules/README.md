# Opencode Rules

Regole always-on caricate via `instructions` in `opencode.jsonc` e applicate
a tutti gli agenti. Struttura su due file:

| File | Versione | Perimetro |
|---|---|---|
| `rules.md` | 2.1.1 | **Universale**: tutti i progetti (smeup, daniopp, danifx) |
| `evodoc.md` | 1.1.0 | **Solo perimetro EVODOC**: repo `ZD_*` o con `evodoc`/`zerod` nel nome |

## Perimetro EVODOC

Il perimetro si riconosce dal nome del repository (case-insensitive): inizia
con `ZD_` (legacy), oppure contiene `evodoc`, oppure contiene `zerod`
(es. `kokos-me-dotnet-evodoc-evocache`, `kokos-me-dotnet-zerod-evocache`).
I repo `kokos_*` senza questi termini sono di altri team: solo regole
universali.

## Contenuto universale (rules.md)

- **Lingue**: documentazione in italiano, funzioni/variabili in inglese, eccezioni e log in italiano
- **Nomenclatura**: PascalCase/camelCase, `_` + camelCase per readonly, costanti PascalCase (Microsoft), niente ungherese
- **C# / VB.NET**: `List<T>` mai `Collection<T>`, `JObject` con `JProperty`, Allman, LINQ, `var`, `string.Empty`, commenti brevi senza riferimenti a doc di sviluppo
- **Eccezioni**: `throw;` mai `throw ex;`, catch specifici, mai log di dati sensibili
- **Segreti**: mai nei repo; un solo meccanismo di lettura, stesso nome variabile in tutti gli ambienti
- **Test**: XUnit + Fluent Assertions, AAA, naming `Metodo_StateUnderTest_ExpectedBehavior`
- **Workflow GitHub generico**: issue → branch `<tipo>/<descrizione>` → PR `<tipo>: <descrizione>` + `Refs` → squash merge → SemVer
- **Documentazione di sviluppo**: fuori dai repo; unico artefatto `CHANGELOG.md`

## Contenuto EVODOC (evodoc.md)

Fonte: wiki <https://github.com/smeup/ZD_evoDoc2/wiki> ("Bibbia dello
sviluppatore"). Include: elenco legacy ufficiale, workflow EVOPLATFORM
(issue → branch da `dev` → PR `Refs smeup/evoplatform-projects#` → squash),
versioning legacy `YYYY.MM.DD.X` (Jenkins) e microservizi (SemVer +
prerelease `feature.X`/`dev.X` manuali), struttura repo microservizio
(microservizio+SDK+Shared stessa versione), flusso misto legacy+micro,
rilascio fine sprint, commesse SmeUP. Le pagine operative della wiki
(installazione, IIS, porte, helper…) sono riferimenti, non regole.

## Mirror wiki e aggiornamento

`scripts/wiki-sync.ps1` clona/aggiorna la wiki in `wiki-mirror/`
(git-ignored, mai commit-ata: alcune pagine contengono credenziali):

```powershell
scripts/wiki-sync.ps1              # clone o aggiornamento
scripts/wiki-sync.ps1 -Status      # stato del mirror
scripts/wiki-sync.ps1 -InstallTask # task pianificata Windows giornaliera 07:30
```

Su Linux: `scripts/wiki-sync.sh` oppure cron
`30 7 * * * <repo>/scripts/wiki-sync.sh`.

## Governance e versioning

Entrambi i file sono artefatti di governance versionati (SemVer nel blocco
`> Versione:` e `## Cronologia versioni`): una modifica = una PR su questo
repo. MAJOR = principio rimosso/indebolito, MINOR = nuova regola, PATCH =
redazionale. I principi non si diluiscono per chiudere un conflitto.

## Layering delle regole

Tre livelli: globali always-on (`rules.md` + `evodoc.md`, sotto le 200 righe,
"comandi non ragioni"), dominio-specifico (`.opencode/rules/*.md` nel
progetto, caricati via glob in `instructions`), manuale (lane e comandi).
