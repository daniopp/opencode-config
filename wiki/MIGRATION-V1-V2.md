# Migrazione da OpenCode V1 a V2

Guida per portare una macchina dalla configurazione V1 alla V2. Il repo `daniopp/opencode-config`
è la fonte di verità: la config nel repo è già nativa V2, quindi su ogni macchina basta aggiornare
il repo e lanciare lo script `scripts/migrate-v2.sh`.

Riferimento ufficiale: <https://opencode.ai/v2/docs/migrate-v1>. Questa guida descrive il caso
specifico di questo repo.

## 1. Cosa cambia

| Area | V1 | V2 (nel repo) |
|---|---|---|
| Permessi | `permission` oggetto per tool, `bash` | `permissions` array ordinato di `{action, resource, effect}`, azione `shell` |
| Subagent in commands | `subtask: true` | `subagent: true` |
| Agenti | `agent`, `prompt`, `disable` | `agents`, `system`, `disabled` (frontmatter `permission:` ancora tradotto automaticamente) |
| Modello title | `small_model` | `agents.title.model` |
| Plugin | `plugin: []` | `plugins: []` |
| Snapshot | `snapshot` | `snapshots` |
| Provider | `provider` | `providers` (cache costs in `cache.read`/`cache.write`) |
| Compaction | `compaction.prune` | rimosso (ignorato con warning) |
| Config terminale | `tui.json` | `cli.json` globale in `~/.config/opencode/`, fuori dal repo; migrato automaticamente al primo avvio |
| `doom_loop` | permesso | non più un'azione V2: non c'è equivalente nella config |

Il dettaglio delle chiavi è in `wiki/ARCHITECTURE.md` e `wiki/PERMISSIONS.md`.

## 2. Prerequisiti

1. **Installa OpenCode V2.** Il metodo di installazione non è verificato in questa guida: segui
   <https://opencode.ai/v2/docs/cli>. Il curl installer V2 sostituisce il binario V1.
2. **Verifica la versione:** `opencode --version` deve riportare `2.x`. Se risponde `1.x`, il binario
   in PATH è ancora V1: `which -a opencode` mostra i candidati.
3. **Rimuovi il binario V1 gestito da package manager** prima di installare V2, se presente.
4. **Git pulito sul repo:** lo script rifiuta di migrare con modifiche locali non committate
   quando usi `--pull`.

Lo script non installa V2 e non modifica il PATH: se V2 manca, si ferma con exit code 2.

## 3. Migrazione automatica (consigliata)

Esegui dalla radice del repo, su qualsiasi macchina con `bash`, `node` e `git` (Linux, macOS, WSL):

```bash
# 1. Anteprima: nessuna modifica
scripts/migrate-v2.sh --dry-run

# 2. Migrazione interattiva (chiede conferma)
git pull --ff-only
scripts/migrate-v2.sh

# 3. Migrazione non interattiva (per agent o cron)
scripts/migrate-v2.sh --yes --pull --json
```

### Cosa fa lo script

1. **Preflight:** controlla che `opencode` sia 2.x, che il repo contenga una config nativa V2 e
   (con `--pull`) che il repo sia pulito.
2. **Detect:** elenca le chiavi V1 ancora presenti nella config locale e conta i file `commands/`
   e `agents/` con forme legacy.
3. **Backup** in `~/.local/state/opencode-migration/<timestamp>/`:
   - copia della config (`config/`), esclusi `node_modules`, `logs`, `pilot`;
   - backup del database `~/.local/share/opencode/opencode.db` (con `sqlite3 .backup` se disponibile);
   - manifest con commit del repo.
4. **Binario V1:** se trova `~/.opencode/bin/opencode` con versione `1.x`, lo sposta nel backup.
5. **Sync:** copia la config dal repo a `~/.config/opencode/` tramite `scripts/sync.sh pull`.
   Rimuove `tui.json` (già nel backup).
6. **Riavvio e verifica:** `opencode service restart`, poi `opencode api get /api/info` deve
   riportare `2.x`. Conta i warning `configuration normalization diagnostic` e gli `ERROR` comparsi
   nel log dopo il riavvio.
7. **Passi manuali:** stampa la checklist in fondo.

Lo script non cancella mai file: ogni cosa sostituita o spostata finisce nel backup.

### Exit code

| Code | Significato | Azione |
|---|---|---|
| 0 | completato, nessun passo manuale residuo | — |
| 1 | errore durante la migrazione | leggi il messaggio, usa il backup se serve |
| 2 | precondizione mancante (V2 assente, repo non convertito, repo sporco con `--pull`) | correggi e riesegui |
| 3 | migrazione completata, ma restano verifiche manuali | esegui la checklist |
| — | `dry-run` | nessuna modifica; `--json` riporta `"status":"dry-run"` |

Con `--json` lo script stampa una sola riga JSON su stdout: `status`, `exit`, `dry_run`, `backup`,
`steps` (nome, stato, dettaglio) e `manual`. Un agent può leggere `status` e `manual` senza parsare il testo.

### Variabili d'ambiente

- `OPENCODE_CONFIG_DIR` — default `~/.config/opencode`
- `OPENCODE_DATA_DIR` — default `~/.local/share/opencode`
- `OPENCODE_MIGRATION_STATE` — default `~/.local/state/opencode-migration`

## 4. Migrazione manuale (equivalente)

Se lo script non è disponibile:

1. Backup: `cp -a ~/.config/opencode ~/opencode-v1-backup` e
   `sqlite3 ~/.local/share/opencode/opencode.db ".backup '$HOME/opencode-v1-backup/opencode.db'"`.
2. Installa V2 e verifica `opencode --version`.
3. `scripts/sync.sh pull` dal repo aggiornato.
4. `rm -f ~/.config/opencode/tui.json`.
5. `opencode service restart` e `opencode api get /api/info`.
6. Controlla il log: `grep -a "normalization\|level=ERROR" ~/.local/share/opencode/log/opencode.log | tail`.

## 5. Progetti con `opencode.jsonc` locale

Il repo fornisce la config globale. I progetti che hanno un proprio `opencode.jsonc` (o `.opencode/`)
vanno convertiti separatamente: la config di progetto si somma a quella globale.

- Esempio fidato: `repo-examples/opencode-project-trusted.jsonc` è già nella forma V2 (`permissions`
  array, azione `shell`).
- Per altri file usa la tabella della sezione 1 e la guida ufficiale
  <https://opencode.ai/v2/docs/migrate-v1>. Si può anche chiedere a OpenCode V2 di convertire il file,
  come suggerisce la guida ufficiale.
- Verifica dopo la conversione con `opencode service restart` e il log (sezione 3).

## 6. Verifica dopo la migrazione

- [ ] `opencode --version` → `2.x`
- [ ] `opencode api get /api/info` → risponde con `2.x`
- [ ] Log senza nuovi `normalization` o `ERROR`
- [ ] `/full` e `/debug` in TUI partono come child session
- [ ] Un comando shell distruttivo (es. `rm -rf x`) viene rifiutato
- [ ] `opencode run "OK"` risponde con il modello `claude-haiku-5-5`
- [ ] Costi del modello visibili nella statistica di sessione (se usi il conteggio costi)

## 7. Rollback

Se qualcosa non va, il backup della run (`~/.local/state/opencode-migration/<timestamp>/`) contiene
tutto ciò che è stato modificato:

```bash
BK=~/.local/state/opencode-migration/<timestamp>
cp -a "$BK/config/." ~/.config/opencode/        # ripristina la config V1
cp -a "$BK/opencode.db" ~/.local/share/opencode/opencode.db   # solo se il DB è stato compromesso
cp -a "$BK/bin/opencode-v1" ~/.opencode/bin/opencode           # solo se serve il binario V1
```

Il ripristino del DB va fatto con opencode chiuso. Dopo il rollback, rilancia `opencode service restart`.

## 8. Limiti noti

- Lo script è bash: funziona su Linux, macOS e WSL. Su Windows nativo usa la versione PowerShell
  di `scripts/sync.ps1`, che non è ancora aggiornata alla V2 (da fare).
- Il frontmatter `permission:` dei file `agents/*.md` resta in forma V1: V2 lo traduce
  automaticamente, quindi la conversione è opzionale (da fare con la guida ufficiale).
- Il DB sessioni è condiviso tra V1 e V2: il backup è obbligatorio prima della prima migrazione.
- `doom_loop` (conferma su loop) non esiste più in V2 e non è sostituito.
