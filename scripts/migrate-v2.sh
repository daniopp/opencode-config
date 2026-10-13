#!/usr/bin/env bash
# migrate-v2.sh — migra questa macchina dalla config OpenCode V1 alla V2.
#
# Fonte di verità: il repo (daniopp/opencode-config). La config nel repo è già
# nativa V2; lo script copia il repo nella config locale dopo aver fatto backup.
#
# Uso (umano):   scripts/migrate-v2.sh --dry-run      # mostra cosa farebbe
#                scripts/migrate-v2.sh                # chiede conferma
# Uso (agent):   scripts/migrate-v2.sh --yes --pull --json
#
# Opzioni:
#   --dry-run     nessuna modifica: solo preflight e piano
#   --yes, -y     non chiedere conferma (obbligatorio se stdin non è un TTY)
#   --pull        esegue prima `git pull --ff-only` nel repo (repo pulito richiesto)
#   --no-restart  non riavvia il servizio V2 (utile in test)
#   --json        output finale machine-readable (una sola riga JSON su stdout)
#   -h, --help    questo messaggio
#
# Variabili: OPENCODE_CONFIG_DIR (default ~/.config/opencode),
#            OPENCODE_DATA_DIR   (default ~/.local/share/opencode),
#            OPENCODE_MIGRATION_STATE (default ~/.local/state/opencode-migration)
#
# Exit code: 0 ok (o già migrato) · 1 errore · 2 precondizione mancante
#            (V2 non installata, repo non convertito, repo sporco) · 3 azione manuale richiesta
#
# Mai cancellato: ogni file sostituito/spostato finisce nel backup della run.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCAL="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
DATA_DIR="${OPENCODE_DATA_DIR:-$HOME/.local/share/opencode}"
STATE_DIR="${OPENCODE_MIGRATION_STATE:-$HOME/.local/state/opencode-migration}"

DRY=0; YES=0; PULL=0; NORESTART=0; JSON=0
TS="$(date +%Y%m%dT%H%M%S)"
BK="$STATE_DIR/$TS"
STATUS="ok"; EXIT_CODE=0
STEPS=()
MANUAL=()

usage() { sed -n '2,25p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY=1 ;;
    --yes|-y) YES=1 ;;
    --pull) PULL=1 ;;
    --no-restart) NORESTART=1 ;;
    --json) JSON=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "argomento sconosciuto: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

# --- output -------------------------------------------------------------
say()  { [[ $JSON == 1 ]] || printf '%s\n' "$*"; }
step() { STEPS+=("$1|$2|$3"); say "[$2] $1${3:+ — $3}"; }
die()  { STATUS="error"; say "ERRORE: $1"; finish "$2"; }
finish() {
  EXIT_CODE="${1:-0}"
  if [[ $JSON == 1 ]]; then
    local steps_json="" s name st detail
    for s in "${STEPS[@]}"; do
      IFS='|' read -r name st detail <<<"$s"
      steps_json+="{\"name\":\"$name\",\"status\":\"$st\",\"detail\":\"${detail//\"/\\\"}\"},"
    done
    local manual_json="" m
    for m in "${MANUAL[@]:-}"; do [[ -n "$m" ]] && manual_json+="\"${m//\"/\\\"}\","; done
    printf '{"status":"%s","exit":%s,"dry_run":%s,"backup":"%s","steps":[%s],"manual":[%s]}\n' \
      "$STATUS" "$EXIT_CODE" "$([[ $DRY == 1 ]] && echo true || echo false)" \
      "$([[ -d $BK ]] && echo "$BK" || echo "")" "${steps_json%,}" "${manual_json%,}"
  fi
  exit "$EXIT_CODE"
}

# --- rilevazione legacy (JSONC-aware, senza dipendenze) ------------------
# Stampa JSON: {"legacy":[...],"keys":N}. Exit 1 se il file non è parsabile.
JS_DETECT='
const fs = require("fs");
const src = fs.readFileSync(process.argv[1], "utf8");
let out = "", i = 0, ins = false, q = "";
while (i < src.length) {
  const c = src[i];
  if (ins) {
    out += c;
    if (c === "\\") { out += src[i + 1] || ""; i += 2; continue; }
    if (c === q) ins = false;
    i++; continue;
  }
  if (c === "\"") { ins = true; q = c; out += c; i++; continue; }
  if (c === "/" && src[i + 1] === "/") { while (i < src.length && src[i] !== "\n") i++; continue; }
  if (c === "/" && src[i + 1] === "*") { const e = src.indexOf("*/", i + 2); i = e < 0 ? src.length : e + 2; continue; }
  out += c; i++;
}
let j;
try { j = JSON.parse(out.replace(/,(\s*[}\]])/g, "$1")); }
catch (e) { console.error("parse: " + e.message); process.exit(1); }
const legacy = [];
for (const k of ["permission", "agent", "mode", "small_model", "snapshot", "tui", "provider", "command", "reference", "plugin", "subagent_depth"]) {
  if (k in j) legacy.push(k);
}
if (j.compaction && typeof j.compaction === "object" && "prune" in j.compaction) legacy.push("compaction.prune");
console.log(JSON.stringify({ legacy, keys: Object.keys(j).length }));
'

detect() { node -e "$JS_DETECT" "$1"; }

legacy_list() { node -e 'const r=JSON.parse(process.argv[1]);console.log(r.legacy.join(" "))' "$1"; }

# --- 1. preflight -------------------------------------------------------
say "== migrate-v2 (repo: $REPO, config: $LOCAL, dry-run: $DRY)"

command -v node >/dev/null 2>&1 || die "node non trovato (necessario per leggere il JSONC)" 2
command -v opencode >/dev/null 2>&1 || {
  step "preflight.opencode" "fail" "opencode non in PATH"
  MANUAL+=("Installa OpenCode V2 (vedi https://github.com/daniopp/opencode-config/wiki/MIGRATION-V1-V2, sezione 2), poi riesegui.")
  die "opencode non trovato" 2
}

VER="$(opencode --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)"
if [[ -z "$VER" || "${VER%%.*}" != "2" ]]; then
  step "preflight.version" "fail" "opencode in PATH è ${VER:-sconosciuta}, serve 2.x"
  MANUAL+=("Il binario in PATH non è V2: 'which -a opencode'. Installa/attiva V2 e riesegui.")
  die "OpenCode V2 non attivo (versione ${VER:-?})" 2
fi
step "preflight.version" "ok" "opencode $VER"

ALL_BIN="$(which -a opencode 2>/dev/null | sort -u | wc -l || true)"
if [[ "${ALL_BIN:-0}" -gt 1 ]]; then
  MANUAL+=("Più binari 'opencode' nel PATH ($(which -a opencode | sort -u | tr '\n' ' ')): verifica quale è attivo.")
fi

[[ -f "$REPO/opencode.jsonc" ]] || die "repo senza opencode.jsonc: $REPO" 2

if [[ $PULL == 1 ]]; then
  if [[ -n "$(git -C "$REPO" status --porcelain)" ]]; then
    step "preflight.pull" "fail" "repo con modifiche locali"
    die "repo non pulito: committa o stasha prima di --pull" 2
  fi
  if [[ $DRY == 1 ]]; then
    step "preflight.pull" "dry" "git pull --ff-only"
  else
    git -C "$REPO" pull --ff-only --quiet
    step "preflight.pull" "ok" "$(git -C "$REPO" rev-parse --short HEAD)"
  fi
fi

REPO_DETECT="$(detect "$REPO/opencode.jsonc")" || die "opencode.jsonc del repo non parsabile" 2
if [[ -n "$(legacy_list "$REPO_DETECT")" ]]; then
  step "preflight.repo" "fail" "repo ancora V1: $(legacy_list "$REPO_DETECT")"
  die "il repo non è ancora convertito a V2: correggi il repo prima di migrare" 2
fi
step "preflight.repo" "ok" "config del repo nativa V2"

# --- 2. stato attuale della config locale --------------------------------
LOCAL_LEGACY=""
if [[ -f "$LOCAL/opencode.jsonc" ]]; then
  LOCAL_DETECT="$(detect "$LOCAL/opencode.jsonc" 2>/dev/null)" || LOCAL_DETECT='{"legacy":["unparsable"],"keys":0}'
  LOCAL_LEGACY="$(legacy_list "$LOCAL_DETECT")"
fi
[[ -f "$LOCAL/tui.json" ]] && LOCAL_LEGACY="$LOCAL_LEGACY tui.json"
CMD_LEGACY="$(grep -l '^subtask:' "$LOCAL"/commands/*.md 2>/dev/null | wc -l || true)"
AGENT_LEGACY="$(grep -l '^permission:' "$LOCAL"/agents/*.md 2>/dev/null | wc -l || true)"
step "detect.local" "info" "legacy config: ${LOCAL_LEGACY:-nessuna}; command subtask=$CMD_LEGACY agent permission=$AGENT_LEGACY"

OLD_BIN="$HOME/.opencode/bin/opencode"
if [[ -x "$OLD_BIN" ]] && "$OLD_BIN" --version 2>/dev/null | grep -q '^1\.'; then
  step "detect.v1binary" "todo" "$OLD_BIN (v1)"
  HAS_V1_BIN=1
else
  HAS_V1_BIN=0
  step "detect.v1binary" "ok" "nessun binario V1 installato in ~/.opencode"
fi

# --- 3. piano e conferma -------------------------------------------------
if [[ $DRY == 0 && $YES == 0 ]]; then
  if [[ -t 0 ]]; then
    read -r -p "Procedere con la migrazione? [y/N] " ans
    [[ "$ans" =~ ^[yY]$ ]] || { STATUS="aborted"; say "annullato"; finish 0; }
  else
    die "stdin non interattivo: usa --yes (o --dry-run)" 2
  fi
fi

# --- 4. backup (sempre prima di qualunque modifica) ----------------------
if [[ $DRY == 1 ]]; then
  step "backup" "dry" "$BK"
else
  mkdir -p "$BK/config"
  tar -C "$LOCAL" --exclude=./node_modules --exclude=./logs --exclude=./pilot -cf - . | tar -C "$BK/config" -xf -
  DB="$DATA_DIR/opencode.db"
  if [[ -f "$DB" ]]; then
    if command -v sqlite3 >/dev/null 2>&1; then
      sqlite3 "$DB" ".backup '$BK/opencode.db'"
      step "backup.db" "ok" "sqlite3 .backup"
    else
      cp -a "$DB" "$BK/opencode.db"
      [[ -f "$DB-wal" ]] && cp -a "$DB-wal" "$BK/opencode.db-wal"
      [[ -f "$DB-shm" ]] && cp -a "$DB-shm" "$BK/opencode.db-shm"
      step "backup.db" "warn" "copia file (sqlite3 assente): meglio chiudere opencode prima"
      MANUAL+=("sqlite3 non installato: il backup DB è una copia a caldo, verificane l'integrità.")
    fi
  else
    step "backup.db" "info" "nessun DB in $DATA_DIR"
  fi
  {
    echo "timestamp=$TS"
    echo "repo_head=$(git -C "$REPO" rev-parse HEAD 2>/dev/null || echo unknown)"
    echo "local=$LOCAL"
  } > "$BK/manifest.txt"
  step "backup" "ok" "$BK"
fi

# --- 5. binario V1 -------------------------------------------------------
if [[ $HAS_V1_BIN == 1 ]]; then
  if [[ $DRY == 1 ]]; then
    step "v1binary.move" "dry" "$OLD_BIN -> $BK/bin/"
  else
    mkdir -p "$BK/bin"
    mv "$OLD_BIN" "$BK/bin/opencode-v1"
    step "v1binary.move" "ok" "spostato in $BK/bin/opencode-v1"
  fi
fi

# --- 6. sync repo -> config locale --------------------------------------
if [[ $DRY == 1 ]]; then
  step "sync" "dry" "scripts/sync.sh pull → $LOCAL"
  [[ -f "$LOCAL/tui.json" ]] && step "tui.json.remove" "dry" "rimozione (già in backup)"
else
  OPENCODE_CONFIG_DIR="$LOCAL" "$REPO/scripts/sync.sh" pull >/dev/null
  step "sync" "ok" "repo → $LOCAL"
  if [[ -f "$LOCAL/tui.json" ]]; then
    rm -f "$LOCAL/tui.json"
    step "tui.json.remove" "ok" "sostituito da cli.json"
  fi
fi

# --- 7. riavvio e verifica ----------------------------------------------
if [[ $NORESTART == 1 || $DRY == 1 ]]; then
  step "restart" "skip" "$([[ $DRY == 1 ]] && echo dry-run || echo --no-restart)"
else
  LOG="$DATA_DIR/log/opencode.log"
  BEFORE=$(wc -l < "$LOG" 2>/dev/null || echo 0)
  timeout 60 opencode service restart >/dev/null 2>&1 || true
  sleep 3
  INFO="$(timeout 20 opencode api get /api/info 2>/dev/null || true)"
  if grep -q '"version":"2\.' <<<"$INFO"; then
    step "restart" "ok" "servizio V2 risponde"
  else
    step "restart" "fail" "api/info non risponde come V2"
    MANUAL+=("Il servizio non risponde: 'opencode service status' e 'opencode api get /api/info'.")
    STATUS="error"; EXIT_CODE=1
  fi
  NEW_LOG="$(tail -n +$((BEFORE + 1)) "$LOG" 2>/dev/null || true)"
  WARN_N=$(grep -c 'configuration normalization diagnostic' <<<"$NEW_LOG" || true)
  ERR_N=$(grep -c 'level=ERROR' <<<"$NEW_LOG" || true)
  if [[ "$WARN_N" -gt 0 || "$ERR_N" -gt 0 ]]; then
    step "verify.log" "warn" "normalization=$WARN_N error=$ERR_N (vedi $LOG)"
    MANUAL+=("Il log riporta warning/errori dopo il riavvio: controlla 'grep -a \"normalization\\|level=ERROR\" $LOG | tail'.")
  else
    step "verify.log" "ok" "nessun warning di normalizzazione né errore"
  fi
fi

# --- 8. passi manuali (non automatizzabili) -----------------------------
MANUAL+=("Test in TUI: lancia /full e /debug su un task di prova (devono partire come child session).")
MANUAL+=("Test permessi: un comando shell distruttivo (es. rm -rf x) deve essere rifiutato.")
MANUAL+=("Se usi progetti con opencode.jsonc locale: convertili con la guida V2 (https://github.com/daniopp/opencode-config/wiki/MIGRATION-V1-V2, sezione 5).")

if [[ $DRY == 1 ]]; then
  STATUS="dry-run"; EXIT_CODE=0
  say "dry-run completato: nessuna modifica."
else
  EXIT_CODE=${EXIT_CODE:-0}
  [[ "$STATUS" == "ok" && $HAS_V1_BIN == 0 && -z "$LOCAL_LEGACY" ]] && STATUS="already-migrated"
fi
if [[ $JSON == 0 ]]; then
  say ""
  say "Backup: ${BK}"
  say "Passi manuali:"
  for m in "${MANUAL[@]:-}"; do [[ -n "$m" ]] && say "  - $m"; done
fi
[[ ${#MANUAL[@]} -gt 0 && $EXIT_CODE == 0 && $DRY == 0 ]] && EXIT_CODE=3
finish "$EXIT_CODE"
