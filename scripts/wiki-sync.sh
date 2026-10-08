#!/bin/bash
# wiki-sync.sh - clona/aggiorna il mirror locale della wiki ZD_evoDoc2 (Linux)
# Mirror: <repo>/wiki-mirror/ (git-ignored; MAI commit-ato: pagine con credenziali)
# Uso: scripts/wiki-sync.sh [--status]
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MIRROR="$REPO_DIR/wiki-mirror"
WIKIURL="https://github.com/smeup/ZD_evoDoc2.wiki.git"

head_info() {
    git -C "$MIRROR" log -1 --format='HEAD %h del %cs'
}

if [[ "${1:-}" == "--status" ]]; then
    if [[ -d "$MIRROR/.git" ]]; then
        echo "Mirror: $MIRROR ($(head_info))"
    else
        echo "Mirror assente: $MIRROR"
    fi
    exit 0
fi

if [[ ! -d "$MIRROR/.git" ]]; then
    git clone --depth 1 "$WIKIURL" "$MIRROR"
else
    git -C "$MIRROR" fetch --depth 1 origin master
    git -C "$MIRROR" reset --hard FETCH_HEAD
fi

PAGES=$(find "$MIRROR" -maxdepth 1 -name '*.md' | wc -l)
echo "OK - mirror aggiornato: $(head_info), $PAGES pagine"
