#!/bin/bash
# ============================================================
# OpenCode Launcher - Linux/Bash
# Avvia OpenCode Web su 0.0.0.0:80 con supporto env locale
# ============================================================
# Uso:
#   ./start-opencode.sh                     -> avvia nella directory corrente
#   ./start-opencode.sh ~/git/mio-repo      -> avvia nel repo specificato
#   ./start-opencode.sh --debug ~/git/repo  -> avvia con log DEBUG

set -e

# ============================================================
# VARIABILI GLOBALI - MODIFICA QUI
# ============================================================
export GITHUB_PERSONAL_ACCESS_TOKEN="${GITHUB_PERSONAL_ACCESS_TOKEN:-ghp_xxx}"
export OPENCODE_SERVER_PASSWORD="${OPENCODE_SERVER_PASSWORD:-changeme}"
# export OPENCODE_API_KEY="${OPENCODE_API_KEY:-opencode-xxx}"

# ============================================================
# PARSING ARGOMENTI
# ============================================================
DEBUG_FLAGS=""
REPO_ARG="."

for arg in "$@"; do
  case "$arg" in
    --debug) DEBUG_FLAGS="--log-level DEBUG --print-logs" ;;
    *) REPO_ARG="$arg" ;;
  esac
done

# ============================================================
# TROVA OPENCODE (funziona anche con nvm o installazioni utente)
# ============================================================
OPENCODE_BIN=$(which opencode 2>/dev/null || true)

if [ -z "$OPENCODE_BIN" ] && [ -n "$SUDO_USER" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    for p in "$USER_HOME/.local/bin" "$USER_HOME/.opencode/bin" "$USER_HOME/.npm/bin" "/usr/local/bin"; do
        if [ -x "$p/opencode" ]; then
            OPENCODE_BIN="$p/opencode"
            break
        fi
    done
fi

if [ -z "$OPENCODE_BIN" ] && [ -d "$HOME/.opencode/bin" ]; then
    OPENCODE_BIN="$HOME/.opencode/bin/opencode"
fi

if [ -z "$OPENCODE_BIN" ] || [ ! -x "$OPENCODE_BIN" ]; then
    echo "Errore: opencode non trovato nel PATH."
    echo "Prova: export PATH=\"\$HOME/.opencode/bin:\$PATH\""
    exit 1
fi

# ============================================================
# RISOLUZIONE PERCORSO REPO
# ============================================================
REPO_PATH="$(cd "$REPO_ARG" && pwd)"

echo "=============================================="
echo "OpenCode Launcher"
echo "=============================================="
echo "Repo:   $REPO_PATH"
echo "Binary: $OPENCODE_BIN"
[ -n "$DEBUG_FLAGS" ] && echo "Mode:   DEBUG"
echo ""

# ============================================================
# CARICAMENTO VARIABILI REPO-SPECIFIC
# ============================================================
ENV_FILE="$REPO_PATH/.opencode/env.sh"
ENV_LOCAL_FILE="$REPO_PATH/.env.local"

if [ -f "$ENV_FILE" ]; then
    echo "[✓] Caricamento .opencode/env.sh"
    set -a; source "$ENV_FILE"; set +a
elif [ -f "$ENV_LOCAL_FILE" ]; then
    echo "[✓] Caricamento .env.local"
    set -a; source "$ENV_LOCAL_FILE"; set +a
else
    echo "[i] Nessun env locale trovato (.opencode/env.sh o .env.local)"
    echo "    Usa solo variabili globali."
fi

# ============================================================
# STATO CREDENZIALI
# ============================================================
echo ""
echo "--- Stato credenziali ---"
[ -n "$GITHUB_PERSONAL_ACCESS_TOKEN" ] && echo "[✓] GitHub PAT" || echo "[✗] GitHub PAT mancante"
[ -n "$MDB_MCP_CONNECTION_STRING" ]    && echo "[✓] MongoDB configurato" || echo "[ ] MongoDB non configurato"
[ -n "$MSSQL_SERVER" ]                 && echo "[✓] SQL Server configurato" || echo "[ ] SQL Server non configurato"
[ -n "$OPENCODE_SERVER_PASSWORD" ]     && echo "[✓] Server password impostata" || echo "[✗] Server password mancante - server non sicuro!"
echo "=========================="
echo ""

# ============================================================
# AVVIO
# ============================================================
cd "$REPO_PATH"
LOCAL_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "localhost")
echo "Avvio OpenCode Web su 0.0.0.0:80..."
echo "URL locale:  http://localhost:80"
echo "URL rete:    http://${LOCAL_IP}:80"
echo ""
exec "$OPENCODE_BIN" web --hostname 0.0.0.0 --port 80 $DEBUG_FLAGS
