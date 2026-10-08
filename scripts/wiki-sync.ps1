# wiki-sync.ps1 - clona/aggiorna il mirror locale della wiki ZD_evoDoc2
# Wiki: https://github.com/smeup/ZD_evoDoc2/wiki (repo git: ZD_evoDoc2.wiki.git)
# Mirror: <repo>/wiki-mirror/ (git-ignored; richiede credenziali git/gh sui repo smeup)
#
# Uso:
#   scripts/wiki-sync.ps1              clone se assente, poi pull --ff-only (default)
#   scripts/wiki-sync.ps1 -Status      mostra solo lo stato del mirror, senza toccarlo
#   scripts/wiki-sync.ps1 -InstallTask registra un'attivita pianificata Windows
#                                      ("OpenCode Wiki Sync", giornaliera ore 07:30,
#                                      utente corrente, nessun privilegio admin richiesto)
#
# Nota: le pagine wiki contengono materiale operativo e (almeno una pagina)
# credenziali in chiaro: NON committare mai il contenuto del mirror nel repo.

[CmdletBinding()]
param(
    [switch]$Status,
    [switch]$InstallTask
)

$ErrorActionPreference = 'Stop'

$REPO    = Split-Path -Path $PSScriptRoot -Parent
$MIRROR  = Join-Path $REPO 'wiki-mirror'
$WIKIURL = 'https://github.com/smeup/ZD_evoDoc2.wiki.git'

function Get-MirrorHead {
    if (-not (Test-Path -LiteralPath (Join-Path $MIRROR '.git'))) { return $null }
    $hash = git -C $MIRROR rev-parse --short HEAD
    $date = git -C $MIRROR log -1 --format=%cs
    return [pscustomobject]@{ Hash = $hash; Date = $date }
}

if ($InstallTask) {
    $pwsh  = (Get-Command pwsh).Source
    $action = New-ScheduledTaskAction -Execute $pwsh -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$PSScriptRoot\wiki-sync.ps1`""
    $trigger = New-ScheduledTaskTrigger -Daily -At 07:30
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable
    Register-ScheduledTask -TaskName 'OpenCode Wiki Sync' -Action $action -Trigger $trigger -Settings $settings -Description "Aggiorna il mirror della wiki ZD_evoDoc2 per opencode" | Out-Null
    Write-Host "OK - task pianificata 'OpenCode Wiki Sync' creata (giornaliera 07:30)." -ForegroundColor Green
    exit 0
}

if ($Status) {
    $head = Get-MirrorHead
    if ($null -eq $head) {
        Write-Host "Mirror assente: $MIRROR"
    } else {
        Write-Host ("Mirror: {0} (HEAD {1} del {2})" -f $MIRROR, $head.Hash, $head.Date)
    }
    exit 0
}

if (-not (Test-Path -LiteralPath (Join-Path $MIRROR '.git'))) {
    git clone --depth 1 $WIKIURL $MIRROR
} else {
    git -C $MIRROR fetch --depth 1 origin master
    git -C $MIRROR reset --hard FETCH_HEAD
}

$head = Get-MirrorHead
$pages = Get-ChildItem -LiteralPath $MIRROR -Filter *.md
Write-Host ("OK - mirror aggiornato: HEAD {0} del {1}, {2} pagine" -f $head.Hash, $head.Date, $pages.Count)
