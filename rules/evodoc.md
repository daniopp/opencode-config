# Regole EVODOC (Team ZeroD / SmeUP)

> Versione: 1.0.0 (2026-10-07)
>
> **Perimetro** — si applicano SOLO se il nome del repository soddisfa una di
> queste condizioni (case-insensitive): inizia con `ZD_`, oppure contiene
> `evodoc`, oppure contiene `zerod`. I repo `kokos_*` **senza** `evodoc`/`zerod`
> nel nome sono prodotti di altri team e seguono solo le regole generiche in
> `rules.md`. In dubbio, chiedere.

Fonte: wiki di sviluppo del team <https://github.com/smeup/ZD_evoDoc2/wiki>,
sezione "Bibbia dello sviluppatore" della sidebar (Regole generali e
convenzioni, Gestione del codice e del ciclo di vita, Workflow di sviluppo,
Qualità e robustezza, Stile e best practice, Regole specifiche e tecniche
particolari). Le pagine operative — documentazione tecnica di prodotto,
installazione, IIS, helper, porte di default, certificati, Common Problems —
non sono regole: restano materiali di riferimento senza forza normativa.

## Legacy: elenco ufficiale

Servizi legacy (componenti storici dell'ecosistema EVODOC):

- `ZD_evoDoc2`
- `ZD_ClientUnico`
- `ZD_Zerod.evoPortal`
- `ZD_Zerod.evoServer.Connector`
- `ZD_Zerod.evoENGINE`

---

## Workflow EVOPLATFORM

1. **Task**: GitHub Project [EVOPLATFORM](https://github.com/orgs/smeup/projects/25) → issue assegnata da `Planned` a `In Progress`.
2. **Branch**: creato **sempre da `dev`** via "Create branch" della issue.
   Formato: `<tipo>/<numero-issue>-<breve-descrizione-kebab-case>`.
   Tipi: `feature/`, `fix/`, `tech-debt/`, `chore/`, `spike/`, `hotfix/`.
   Se la issue tocca più repository: **un branch per repository**, stesso nome
   in tutti, dalla stessa issue.
3. **Sviluppo**: commit e push sul branch; i test automatici girano a ogni commit/PR.
4. **Pull Request**: una per repository modificato. Nel body aggiungere il
   numero issue a:

   ```text
   Refs smeup/evoplatform-projects#
   ```

   Titolo PR: `<tipo>: <breve descrizione>` con tipi
   `feat | fix | tech-debt | refactor | chore | docs | test`.
   Vietati titoli generici (`fix`, `update`, `modifiche`).
5. **Review**: a PR pronta → issue `Review Status = Waiting Review`; collegare
   tutte le PR nella sezione Development della issue. Con modifiche richieste →
   `Changes Requested`.
6. **Merge**: **Squash and Merge** su `dev`; messaggio squash
   `<tipo>: <breve descrizione> (#numeroPR)`.
7. **Dopo review approvata**: issue → `Ready to Test`, `Review Status = Approved`.

## Branching e versioning

- Branch: `main` (produzione stabile), `dev` (testato, pronto per main), feature branch da `dev`.
- Servizi legacy: versione `YYYY.MM.DD.X` impostata da Jenkins (non manuale);
  contatore progressivo unico; committata e taggata su GitHub solo per le build di `main`.
- Microservizi: **SemVer** `MAJOR.MINOR.PATCH`; breaking → MAJOR, nuove
  funzionalità compatibili → MINOR, bugfix → PATCH.
  - Branch feature: `MAJOR.MINOR.PATCH-feature.NOME_BRANCH.X`
  - Branch dev: `MAJOR.MINOR.PATCH-dev.X`
- Prerelease NuGet: workflow CI/CD **manuale** da GitHub Actions sul branch di
  lavoro — non più automatiche per commit.
- Un repository microservizio contiene Microservizio + SDK + Shared: i tre
  componenti hanno **sempre la stessa versione**.
- Sviluppi misti legacy+microservizio: sviluppare **prima** il
  microservizio/SDK, referenziare la prerelease feature nel legacy; **prima
  della PR del legacy rimuovere il riferimento feature** e puntare alla
  versione `dev`/stabile. Mai rilasciare legacy che dipende da versioni
  `feature` dei microservizi.
- Rilascio fine sprint (microservizi): PR `dev → main` con merge
  "Rebase and Merge" e titolo `Pre-Release Version x.x.x [skip ci]`; bump
  versione nei 3 progetti; commit diretto su `main`
  `chore: bump version to x.x.x`; avvio workflow CI/CD manuale su `main`;
  completato il rilascio, rebase di `dev` su `main`.

## Costanti

La wiki [Regole generali e convenzioni] indica ancora costanti `UPPERCASE`
(es. `MAX_VALUE`). Vale la decisione di governance 2026-10-05 (`rules.md`
1.4.0, linee guida Microsoft): **`PascalCase`**. La sezione wiki è semplicemente
non aggiornata su questo punto; il conflitto è documentato nella cronologia
di `rules.md`.

## Commesse (ore su agenda SmeUP)

- `EVO.006` nuove funzionalità · `EVO.007` integrazione smeup · `EVO.008` int. plain doc
- `EVO.009` bugfix · `EVO.010` software testing
- `DS-S709` solo riunioni interne · `GRN.OR1.02` smeup lab

## Riferimenti operativi (non normativi)

- Convenzioni porte TCP: <https://github.com/smeup/ZD_evoDoc2/wiki/Standard-e-Convenzioni-per-la-Gestione-delle-Porte-TCP>
- UPP EVODOC: <https://github.com/smeup/ZD_evoDoc2/wiki/UPP-EVODOC>
- Versioni attive microservizi: <https://github.com/smeup/ZD_evoDoc2/wiki/Versioni-attive-dei-microservizi>
- ZD_shared_github_workflows: <https://github.com/smeup/ZD_shared_github_workflows>

## Cronologia versioni

- `1.0.0 (2026-10-07)` — versione iniziale: estrae dalla wiki sviluppatore
  EVODOC il perimetro (legacy `ZD_*`, repo con `evodoc`/`zerod` nel nome),
  workflow EVOPLATFORM, branching/versioning (legacy `YYYY.MM.DD.X` da
  Jenkins, SemVer microservizi con suffissi feature/dev), prerelease NuGet
  manuali, flusso misto legacy+microservizio, rilascio fine sprint,
  commesse SmeUP; riferimenti operativi segnalati come non normativi.
