# Opencode Rules

Regole always-on caricate via `instructions` in `opencode.jsonc` e applicate
a tutti gli agenti.

## Regole attuali

`rules.md` contiene le regole di sviluppo EVODOC (Team ZeroD / SmeUP):

- **Lingue**: documentazione in italiano, funzioni/variabili in inglese, messaggi di eccezione e log in italiano
- **Nomenclatura**: PascalCase/camelCase, campi readonly `_` + camelCase, costanti UPPER_SNAKE_CASE, niente notazione ungherese
- **C# / VB.NET**: sempre `List<T>` (mai `Collection<T>`), graffe stile Allman, preferire LINQ, pattern di creazione `JObject`
- **Eccezioni**: rilancio con `throw;` (mai `throw ex;`), catch specifici, mai log di dati sensibili
- **Test**: XUnit + Fluent Assertions, pattern AAA, naming `Metodo_StateUnderTest_ExpectedBehavior`
- **Workflow GitHub EVODOC**: issue → branch da `dev` → PR → squash merge su `dev`, convenzioni titoli
- **Branching/versioning**: SemVer per i microservizi, `YYYY.MM.DD.X` per i servizi legacy
- **Commesse**: codici agenda SmeUP (EVO.006–010, DS-S709, GRN.OR1.02)

## Linee guida per nuove regole

- Solo regole sempre-applicabili, non contestuali a un singolo progetto
- Niente segreti o credenziali
- Le regole sono vincolanti per tutti gli agenti (orchestrator e subagent)

## Governance e versioning

`rules.md` è un artefatto di governance versionato: la versione SemVer è nel
blocco `> Versione:` in testa al file; semantica MAJOR/MINOR/PATCH e procedura
di modifica (una modifica = PR su questo repo con aggiornamento di versione e
cronologia) sono in `## Governance di questo file`; lo storico in
`## Cronologia versioni`. I principi non si diluiscono per chiudere un conflitto.

## Layering delle regole

Le regole sono organizzate su tre livelli: globali always-on (solo invarianti
EVODOC, sotto le 200 righe, "comandi non ragioni"), dominio-specifico
(`.opencode/rules/*.md` nel progetto, caricati via glob in `instructions`) e
manuale (lane e comandi).
