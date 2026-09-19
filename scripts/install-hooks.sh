#!/usr/bin/env bash
# install-hooks.sh — attiva i pre-commit hook del repo
# Uso:
#   scripts/install-hooks.sh
# Disattivazione: git config --unset core.hooksPath
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

if [ ! -f "scripts/githooks/pre-commit" ]; then
    echo "ERRORE: scripts/githooks/pre-commit non trovato" >&2
    exit 1
fi

chmod +x "scripts/githooks/pre-commit"

git config core.hooksPath scripts/githooks

echo "✓ Pre-commit hook attivati (core.hooksPath = scripts/githooks)"
echo ""
echo "  scripts/githooks/pre-commit esegue:"
echo "    1. validate-jsonc     — valida i file *.jsonc staged"
echo "    2. detect-private-key — rifiuta commit con chiavi private o credenziali nel diff staged"
echo "    3. markdownlint       — best-effort: se disponibile, lint dei *.md staged (altrimenti skip)"
echo ""
echo "Per disattivare: git config --unset core.hooksPath"