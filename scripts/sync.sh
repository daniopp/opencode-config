#!/usr/bin/env bash
# sync.sh — sincronizza la config live di opencode con il repo danismeup/opencode-config
# Repo: https://github.com/danismeup/opencode-config
#
# Uso:
#   scripts/sync.sh status        confronto read-only (default)
#   scripts/sync.sh diff          diff riassunto per ogni elemento diverso
#   scripts/sync.sh push          locale -> repo (poi commit/push manuali)
#   scripts/sync.sh pull          repo -> locale (dopo: riavvia opencode)
#   scripts/sync.sh push --force  forza anche gli elementi divergenti (sovrascrive la destinazione)
#
# Override del percorso locale: OPENCODE_CONFIG_DIR=/percorso scripts/sync.sh status
#
# Non sincronizzati mai (macchina-specifici): logs/, memory/, pilot/, node_modules/, .gitignore
# agents/, commands/, rules/  -> mirror esatto (--delete se rsync disponibile)
# skills/                     -> copia senza cancellazioni
# file singoli                -> copia piana

set -euo pipefail

LOCAL="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

MODE="${1:-status}"
FORCE="${2:-}"

MIRROR=(agents commands rules)          # mirror esatto (--delete)
COPY=(opencode.jsonc tui.json AGENTS.md package.json package-lock.json skills)

# Divergenze note e intenzionali repo<->locale: sync saltato senza --force
declare -A DIVERGENT=(
  ["opencode.jsonc"]="instructions: path Windows (repo) vs path Linux (locale)"
  ["tui.json"]="plugin: oh-my-opencode-slim (repo) vs vuoto (locale)"
)

BLU='\033[1;36m'; YLW='\033[1;33m'; GRN='\033[1;32m'; RST='\033[0m'
log()  { printf "%b▸ %s%b\n" "$BLU" "$*" "$RST"; }
ok()   { printf "%b✓ %s%b\n" "$GRN" "$*" "$RST"; }
warn() { printf "%b⚠ %s%b\n" "$YLW" "$*" "$RST"; }
die()  { printf "ERRORE: %s\n" "$*" >&2; exit 1; }

case "$MODE" in
  status|diff|push|pull) ;;
  *) die "modalità '$MODE' non valida (usa status|diff|push|pull)" ;;
esac
[[ -z "$FORCE" || "$FORCE" == "--force" ]] || die "secondo argomento: solo --force"
command -v rsync >/dev/null 2>&1 || warn "rsync assente: mirror senza --delete (possibili file obsoleti residui)"

if [[ "$MODE" == "push" ]]; then
  SRC="$LOCAL"; DST="$REPO"
  [[ -d "$LOCAL" ]] || die "config locale non trovata: $LOCAL (override: OPENCODE_CONFIG_DIR=...)"
else
  SRC="$REPO"; DST="$LOCAL"
  mkdir -p "$DST"
fi

ALL=("${MIRROR[@]}" "${COPY[@]}")
is_mirror() { [[ " ${MIRROR[*]} " == *" $1 "* ]]; }

sync_one() {  # $1 = item
  local item="$1"
  [[ -e "$SRC/$item" ]] || return 0

  if [[ -n "${DIVERGENT[$item]:-}" && "$FORCE" != "--force" ]]; then
    warn "$item SALTATO — divergenza nota: ${DIVERGENT[$item]}"
    warn "  per modifiche parziali (es. blocco modelli) aggiorna a mano '$item' sul lato destinazione;"
    warn "  altrimenti forza con: scripts/sync.sh $MODE --force (sovrascrive la divergenza)"
    return 0
  fi

  if command -v rsync >/dev/null 2>&1; then
    if is_mirror "$item"; then
      rsync -a --delete "$SRC/$item/" "$DST/$item/"
    else
      rsync -a "$SRC/$item" "$DST/"
    fi
  else
    cp -a "$SRC/$item" "$DST/$item"
  fi
  ok "$item sincronizzato"
}

case "$MODE" in
  status)
    log "locale: $LOCAL"
    log "repo:   $REPO"
    for item in "${ALL[@]}"; do
      if [[ ! -e "$LOCAL/$item" && ! -e "$REPO/$item" ]]; then
        warn "$item assente in entrambi"
      elif [[ ! -e "$REPO/$item" ]]; then
        warn "$item SOLO LOCALE (nuovo per il repo)"
      elif [[ ! -e "$LOCAL/$item" ]]; then
        warn "$item SOLO REPO (manca in locale)"
      elif diff -rq "$LOCAL/$item" "$REPO/$item" >/dev/null 2>&1; then
        ok "$item identici"
      elif [[ -n "${DIVERGENT[$item]:-}" ]]; then
        warn "$item DIVERGENZA NOTA — ${DIVERGENT[$item]}"
      else
        warn "$item differisce (dettagli: scripts/sync.sh diff)"
      fi
    done
    ;;

  diff)
    for item in "${ALL[@]}"; do
      [[ -e "$LOCAL/$item" && -e "$REPO/$item" ]] || continue
      git --no-pager diff --no-index --stat "$REPO/$item" "$LOCAL/$item" || true
    done
    ;;

  push|pull)
    log "$MODE: $SRC -> $DST"
    for item in "${ALL[@]}"; do
      [[ -e "$SRC/$item" ]] || { warn "$item assente in $SRC, saltato"; continue; }
      sync_one "$item"
    done
    if [[ "$MODE" == "push" ]]; then
      log "verifica con 'git status' nel repo, poi:"
      log "  git add -A && git commit -m \"config: sync da \$(hostname)\" && git push"
    else
      warn "pull completato: riavvia opencode per caricare la nuova config"
    fi
    ;;
esac
