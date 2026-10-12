#!/usr/bin/env bash
# set-models.sh — switch giornaliero dei modelli opencode
# Repo: https://github.com/danismeup/opencode-config
#
# Uso:
#   scripts/set-models.sh                                     stato corrente (nessuna modifica)
#   scripts/set-models.sh [--dry-run] [--no-sync] [PRIMARY [SPECIALISTS [SMALL]]]
#
#   PRIMARY      = modello dell'agente orchestrator + campo "model" in opencode.jsonc
#   SPECIALISTS  = modello di tutti gli agenti in agents/*.md TRANNE orchestrator (default: = PRIMARY)
#   SMALL        = campo "small_model" in opencode.jsonc (default: = SPECIALISTS)
#   --dry-run    mostra la tabella what-would-change senza applicare nulla
#   --no-sync    salta la sincronizzazione verso la config live
#
# Verifica: aggiorna opencode.jsonc e il frontmatter di agents/*.md, valida il
# JSONC con scripts/validate-jsonc.sh (se presente) e allinea la config live
# con sync.sh pull. La config live (~/.config/opencode) si aggiorna via
# scripts/sync.sh pull (o --no-sync per saltarla). Riavvia opencode dopo il cambio.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ---------------------------------------------------------------------------
# Alias dei modelli del giorno — aggiungi qui gli alias del giorno
# (es. MODELS[nome]="provider/modello")
# ---------------------------------------------------------------------------
declare -A MODELS=(
  [haiku]="opencode-go/claude-haiku-5-5"                  # Claude Haiku 5.5 (primario + fixer/reviewer/verifier/looker)
  [mimo]="opencode-go/mimo-v2.6-flash"                 # MiMo-V2.6-Flash su Go (lento: non usato dai recon)
  [dsv4]="opencode-go/deepseek-v4-flash"                  # DeepSeek V4 Flash (small_model)
  [glm]="openrouter/z-ai/glm-5.3-flash"                   # GLM 5.3 Flash (fallback OpenRouter)
  [dsv41]="openrouter/deepseek/deepseek-v4.1-flash"       # DeepSeek V4.1 Flash (fallback OpenRouter)
)

BLU='\033[1;36m'; YLW='\033[1;33m'; GRN='\033[1;32m'; RST='\033[0m'
log()  { printf "%b▸ %s%b\n" "$BLU" "$*" "$RST"; }
ok()   { printf "%b✓ %s%b\n" "$GRN" "$*" "$RST"; }
warn() { printf "%b⚠ %s%b\n" "$YLW" "$*" "$RST"; }
die()  { printf "ERRORE: %s\n" "$*" >&2; exit 1; }

# --- parsing flag ---
DRY_RUN=0
NO_SYNC=0
POSITIONAL=()
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --no-sync) NO_SYNC=1 ;;
    --*) die "opzione '$arg' non riconosciuta (usa --dry-run | --no-sync)" ;;
    *) POSITIONAL+=("$arg") ;;
  esac
done
[[ "${#POSITIONAL[@]}" -le 3 ]] || die "troppi argomenti posizionali (max: PRIMARY SPECIALISTS SMALL)"

# --- risoluzione modello: alias oppure formato provider/modello ---
resolve_model() {
  local token="$1"
  [[ -n "$token" ]] || die "modello vuoto"
  if [[ -n "${MODELS[$token]:-}" ]]; then
    printf '%s\n' "${MODELS[$token]}"
  elif [[ "$token" =~ ^[a-z0-9-]+/[a-z0-9._/-]+$ ]]; then
    printf '%s\n' "$token"
  else
    die "modello '$token' non valido — alias disponibili: ${!MODELS[*]} (oppure un formato provider/modello)"
  fi
}

# --- valori correnti ---
jsonc_model() { grep '^\s*"model"' "$REPO/opencode.jsonc" | head -1 | sed -nE 's|^[[:space:]]*"model":[[:space:]]*"([^"]+)".*|\1|p'; }
jsonc_small() { grep '^\s*"small_model"' "$REPO/opencode.jsonc" | head -1 | sed -nE 's|^[[:space:]]*"small_model":[[:space:]]*"([^"]+)".*|\1|p'; }
agent_model() { grep -m1 '^model: ' "$REPO/agents/$1.md" | sed -E 's|^model:[[:space:]]*([^[:space:]]+).*|\1|'; }

# --- stato corrente + istruzioni d'uso ---
show_status() {
  local f base
  log "stato corrente dei modelli"
  log "opencode.jsonc"
  ok "  model        = $(jsonc_model)"
  ok "  small_model  = $(jsonc_small)"
  log "agents/orchestrator.md"
  ok "  model        = $(agent_model orchestrator)"
  log "altri agenti (agents/*.md)"
  for f in "$REPO"/agents/*.md; do
    base="$(basename "$f")"
    [[ "$base" == "README.md" || "$base" == "orchestrator.md" ]] && continue
    grep -q '^model: ' "$f" || continue
    ok "  ${base%.md} = $(agent_model "${base%.md}")"
  done
  log "uso: scripts/set-models.sh [--dry-run] [--no-sync] [PRIMARY [SPECIALISTS [SMALL]]]"
  log "alias disponibili: ${!MODELS[*]} — altri alias si aggiungono in testa allo script"
  exit 0
}

if [[ "${#POSITIONAL[@]}" -eq 0 ]]; then
  show_status
fi

PRIMARY="$(resolve_model "${POSITIONAL[0]}")"
SPECIALISTS="$(resolve_model "${POSITIONAL[1]:-$PRIMARY}")"
SMALL="$(resolve_model "${POSITIONAL[2]:-$SPECIALISTS}")"

print_row() { printf "  %-42s %-46s %s\n" "$1" "$2" "$3"; }

if [[ "$DRY_RUN" -eq 1 ]]; then
  warn "dry-run: nessuna modifica applicata — tabella what-would-change:"
  print_row "FILE" "VALORE VECCHIO" "VALORE NUOVO"
  print_row "opencode.jsonc (model)" "$(jsonc_model)" "$PRIMARY"
  print_row "opencode.jsonc (small_model)" "$(jsonc_small)" "$SMALL"
  print_row "agents/orchestrator.md" "$(agent_model orchestrator)" "$PRIMARY"
  for f in "$REPO"/agents/*.md; do
    base="$(basename "$f")"
    [[ "$base" == "README.md" || "$base" == "orchestrator.md" ]] && continue
    grep -q '^model: ' "$f" || continue
    print_row "agents/$base" "$(agent_model "${base%.md}")" "$SPECIALISTS"
  done
  exit 0
fi

log "applico i modelli: primary → $PRIMARY, specialists → $SPECIALISTS, small_model → $SMALL"

# --- opencode.jsonc: campi model e small_model (pattern ancorati, commenti intatti) ---
sed -i -E "s|^([[:space:]]*)\"model\":[[:space:]]*\"[^\"]*\"|\1\"model\": \"$PRIMARY\"|" "$REPO/opencode.jsonc"
sed -i -E "s|^([[:space:]]*)\"small_model\":[[:space:]]*\"[^\"]*\"|\1\"small_model\": \"$SMALL\"|" "$REPO/opencode.jsonc"
ok "opencode.jsonc aggiornato (model + small_model)"

# --- agents/*.md: riscrive SOLO la prima riga "model:" dentro il frontmatter ---
set_agent_model() {  # $1 = file, $2 = nuovo modello
  local f="$1" new="$2" tmp
  tmp="$(mktemp "$f.XXXXXX")"
  awk -v new="$new" '
    BEGIN { in_fm = 0; done = 0 }
    /^---[[:space:]]*$/ {
      if (!in_fm) { in_fm = 1 } else { in_fm = 0 }
      print; next
    }
    in_fm && !done && /^model:[[:space:]]/ {
      print "model: " new
      done = 1
      next
    }
    { print }
  ' "$f" > "$tmp"
  if cmp -s "$f" "$tmp"; then
    rm -f "$tmp"
  else
    chmod --reference="$f" "$tmp"
    mv "$tmp" "$f"
  fi
}

set_agent_model "$REPO/agents/orchestrator.md" "$PRIMARY"
ok "agents/orchestrator.md aggiornato"
for f in "$REPO"/agents/*.md; do
  base="$(basename "$f")"
  [[ "$base" == "README.md" || "$base" == "orchestrator.md" ]] && continue
  grep -q '^model: ' "$f" || continue
  set_agent_model "$f" "$SPECIALISTS"
  ok "agents/$base aggiornato"
done

# --- verifica JSONC (se disponibile) ---
if [[ -x "$REPO/scripts/validate-jsonc.sh" ]]; then
  "$REPO/scripts/validate-jsonc.sh" "$REPO/opencode.jsonc" || die "validate-jsonc.sh: validazione fallita"
  ok "opencode.jsonc valido"
fi

# --- deploy verso la config live ---
if [[ "$NO_SYNC" -eq 1 ]]; then
  warn "riepilogo: primary → $PRIMARY, specialists → $SPECIALISTS, small_model → $SMALL (--no-sync: esegui scripts/sync.sh pull per il deploy)"
else
  "$REPO/scripts/sync.sh" pull || die "sync.sh pull fallito"
  ok "riepilogo: primary → $PRIMARY, specialists → $SPECIALISTS, small_model → $SMALL, deploy ok"
fi
warn "riavvia opencode per caricare i nuovi modelli"