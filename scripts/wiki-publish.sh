#!/usr/bin/env bash
# wiki-publish.sh — pubblica le pagine di wiki/ nella wiki GitHub del repo.
#
# Fonte: <repo>/wiki/ (versionata). Destinazione: <repo>.wiki.git (wiki GitHub).
# La wiki GitHub va inizializzata una volta dalla UI (crea una prima pagina),
# altrimenti il repo wiki non esiste e lo script si ferma.
#
# Uso:
#   scripts/wiki-publish.sh            # dry-run: prepara il contenuto, non pusha
#   scripts/wiki-publish.sh --push     # committa e pusha sulla wiki
#
# Variabili:
#   WIKI_REMOTE   override dell'URL del repo wiki (test con repo locale)
#
# Regole: sono pubblicate solo le pagine in PAGES. Le pagine precedenti non
# più in PAGES vengono rimosse dalla wiki (commit).

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WIKI_REMOTE="${WIKI_REMOTE:-https://github.com/daniopp/opencode-config.wiki.git}"
PUSH=0

for arg in "$@"; do
  case "$arg" in
    --push) PUSH=1 ;;
    -h|--help) sed -n '2,15p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "argomento sconosciuto: $arg" >&2; exit 1 ;;
  esac
done

# Pagine pubblicate (nome file = nome pagina wiki). Esclusi di proposito:
# plans/, specs/, mcp/ (server MCP rimossi), BMAD-ASSESSMENT.md (documento di lavoro).
PAGES=(
  Home.md
  INSTALL.md
  MIGRATION-V1-V2.md
  SETUP.md
  PERMISSIONS.md
  DEBUG.md
  ARCHITECTURE.md
  Agenti.md
)

mkdir -p /tmp/opencode/wiki-publish
WORK="$(mktemp -d /tmp/opencode/wiki-publish/run.XXXXXX)"
CLONE="$WORK/wiki"

echo "== wiki-publish (remote: $WIKI_REMOTE, push: $PUSH)"

if ! git clone --quiet "$WIKI_REMOTE" "$CLONE" 2>"$WORK/clone.err"; then
  echo "ERRORE: impossibile clonare la wiki ($WIKI_REMOTE)." >&2
  echo "Se la wiki GitHub non è mai stata creata: apri https://github.com/daniopp/opencode-config/wiki" >&2
  echo "e crea una prima pagina dalla UI, poi riesegui lo script." >&2
  cat "$WORK/clone.err" >&2
  exit 2
fi

# Riproduci esattamente l'insieme PAGES: rimuovi le *.md presenti, copia quelle attese.
find "$CLONE" -maxdepth 1 -name '*.md' -exec git -C "$CLONE" rm -q -f -- {} + 2>/dev/null || true
for page in "${PAGES[@]}"; do
  [[ -f "$REPO/wiki/$page" ]] || { echo "ERRORE: pagina mancante in wiki/: $page" >&2; exit 1; }
  cp "$REPO/wiki/$page" "$CLONE/$page"
done
git -C "$CLONE" add -A

if git -C "$CLONE" diff --cached --quiet; then
  echo "Nessuna modifica: la wiki è già allineata a wiki/."
  exit 0
fi

echo "Modifiche previste sulla wiki:"
git -C "$CLONE" diff --cached --stat | sed 's/^/  /'

if [[ $PUSH == 0 ]]; then
  echo "Dry-run: contenuto preparato in $CLONE (nessun push). Riesegui con --push per pubblicare."
  exit 0
fi

SHA="$(git -C "$REPO" rev-parse --short HEAD)"
git -C "$CLONE" commit -q -m "docs: sync da wiki/ del repo (@$SHA)"
git -C "$CLONE" push -q origin HEAD
echo "Pubblicato sulla wiki: $(git -C "$CLONE" rev-parse --short HEAD)"
