# sync.ps1 - sincronizza la config live di opencode con il repo danismeup/opencode-config
# Variante Windows (PowerShell 7+) di scripts/sync.sh: stessa semantica, stesso output.
# Repo: https://github.com/danismeup/opencode-config
#
# Uso:
#   scripts/sync.ps1 status        confronto read-only (default)
#   scripts/sync.ps1 diff          diff riassunto per ogni elemento diverso
#   scripts/sync.ps1 push          locale -> repo (poi commit/push manuali)
#   scripts/sync.ps1 pull          repo -> locale (dopo: riavvia opencode)
#   scripts/sync.ps1 push -Force   forza anche gli elementi divergenti (sovrascrive la destinazione)
#
# Override del percorso locale: $env:OPENCODE_CONFIG_DIR = '<percorso>'; scripts/sync.ps1 status
#
# Non sincronizzati mai (macchina-specifici): logs/, memory/, pilot/, node_modules/, .gitignore
# agents/, commands/, rules/  -> mirror esatto (robocopy /MIR)
# skills/                     -> copia senza cancellazioni
# file singoli                -> copia piana
#
# NON eseguire scripts/sync.sh via il bash del PATH Windows: e' il bash di WSL
# ($HOME linux, es. /home/daniele) e risolverebbe la config sbagliata.

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('status', 'diff', 'push', 'pull')]
    [string]$Mode = 'status',

    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$LOCAL = $env:OPENCODE_CONFIG_DIR
if (-not $LOCAL) { $LOCAL = Join-Path (Join-Path $HOME '.config') 'opencode' }
$REPO = Split-Path -Path $PSScriptRoot -Parent

# mirror esatto (cancella gli estranei): robocopy /MIR
$MIRROR = @('agents', 'commands', 'rules')
# copia senza cancellazioni: robocopy /E
$COPY   = @('opencode.jsonc', 'tui.json', 'AGENTS.md', 'package.json', 'package-lock.json', 'skills')

# Divergenze note e intenzionali repo<->locale: sync saltato senza -Force
# Vuota dal 2026-09-18: opencode.jsonc usa il path `~/` nelle instructions,
# valido su Linux e Windows (meccanismo resta disponibile per divergenze future)
$DIVERGENT = @{}   # es. ('opencode.jsonc', 'motivo della divergenza')

function log  { param($m) Write-Host "> $m" -ForegroundColor Cyan }
function ok   { param($m) Write-Host "  ok $m" -ForegroundColor Green }
function warn { param($m) Write-Host "  !  $m" -ForegroundColor Yellow }
function die  { param($m) Write-Host "ERRORE: $m" -ForegroundColor Red; exit 1 }

if ($Mode -eq 'push') {
    if (-not (Test-Path -LiteralPath $LOCAL)) { die "config locale non trovata: $LOCAL (override: OPENCODE_CONFIG_DIR)" }
    $SRC = $LOCAL; $DST = $REPO
} else {
    if (-not (Test-Path -LiteralPath $LOCAL)) { New-Item -ItemType Directory -Path $LOCAL -Force | Out-Null }
    $SRC = $REPO; $DST = $LOCAL
}

# robocopy exit code: 0-7 OK, 8+ errore
function Invoke-Robocopy {
    param([string[]]$RoboArgs)
    $out = & robocopy @RoboArgs /NJH /NJS /NDL /NFL /NP
    if ($LASTEXITCODE -ge 8) {
        $out | ForEach-Object { Write-Host $_ }
        die "robocopy fallito (exit $LASTEXITCODE) su: $($RoboArgs -join ' ')"
    }
}

# $item: nome in SRC (file o dir). Mirror/copia secondo classificazione.
function Sync-One {
    param([string]$item)

    $srcItem = Join-Path $SRC $item
    if (-not (Test-Path -LiteralPath $srcItem)) {
        warn "$item assente in $SRC, saltato"
        return
    }

    if ($DIVERGENT.ContainsKey($item) -and -not $Force) {
        warn "$item SALTATO - divergenza nota: $($DIVERGENT[$item])"
        warn "  per modifiche parziali (es. blocco modelli) aggiorna a mano '$item' sul lato destinazione;"
        warn "  altrimenti forza con: scripts/sync.ps1 $Mode -Force (sovrascrive la divergenza)"
        return
    }

    if ($item -in $MIRROR) {
        Invoke-Robocopy @((Join-Path $SRC $item), (Join-Path $DST $item), '/MIR')
    }
    elseif (Test-Path -LiteralPath $srcItem -PathType Container) {
        Invoke-Robocopy @((Join-Path $SRC $item), (Join-Path $DST $item), '/E')
    } else {
        # file singolo: robocopy vuole <srcDir> <dstDir> <file>
        $srcDir  = Split-Path -Path $srcItem -Parent
        $leaf    = Split-Path -Path $srcItem -Leaf
        if (-not (Test-Path -LiteralPath $DST)) { New-Item -ItemType Directory -Path $DST -Force | Out-Null }
        Invoke-Robocopy @($srcDir, $DST, $leaf)
    }

    ok "$item sincronizzato"
}

# 'git diff --no-index --quiet' chiude con 0 = identici, 1 = diversi
function Test-ItemIdentical {
    param([string]$a, [string]$b)
    & git --no-pager diff --no-index --quiet -- $a $b *> $null
    return ($LASTEXITCODE -eq 0)
}

switch ($Mode) {
    'status' {
        log "locale: $LOCAL"
        log "repo:   $REPO"
        foreach ($item in ($MIRROR + $COPY)) {
            $inLocal = Test-Path -LiteralPath (Join-Path $LOCAL $item)
            $inRepo  = Test-Path -LiteralPath (Join-Path $REPO  $item)
            if (-not $inLocal -and -not $inRepo) {
                warn "$item assente in entrambi"
            } elseif (-not $inRepo) {
                warn "$item SOLO LOCALE (nuovo per il repo)"
            } elseif (-not $inLocal) {
                warn "$item SOLO REPO (manca in locale)"
            } elseif (Test-ItemIdentical (Join-Path $LOCAL $item) (Join-Path $REPO $item)) {
                ok "$item identici"
            } elseif ($DIVERGENT.ContainsKey($item)) {
                warn "$item DIVERGENZA NOTA - $($DIVERGENT[$item])"
            } else {
                warn "$item differisce (dettagli: scripts/sync.ps1 diff)"
            }
        }
    }

    'diff' {
        foreach ($item in ($MIRROR + $COPY)) {
            $a = Join-Path $REPO $item; $b = Join-Path $LOCAL $item
            if ((Test-Path -LiteralPath $a) -and (Test-Path -LiteralPath $b)) {
                & git --no-pager diff --no-index --stat -- $a $b
            }
        }
    }

    'push' {
        log "push: $SRC -> $DST"
        foreach ($item in ($MIRROR + $COPY)) { Sync-One $item }
        log "verifica con 'git status' nel repo, poi:"
        log '  git add -A && git commit -m "config: sync da $(hostname)" && git push'
    }

    'pull' {
        log "pull: $SRC -> $DST"
        foreach ($item in ($MIRROR + $COPY)) { Sync-One $item }
        warn "pull completato: riavvia opencode per caricare la nuova config"
    }
}
