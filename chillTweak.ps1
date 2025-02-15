param([switch]$TestMode)

# chillTweak - Ein modularer Windows Tweaker
# Version: 1.0

# Module importieren
$moduleFiles = @(
    "modules/core/Config.ps1",
    "modules/ui/Menu.ps1",
    "modules/system/Optimize.ps1",
    "modules/system/Backup.ps1",
    "modules/system/Cleanup.ps1",
    "modules/system/Software.ps1",
    "modules/security/Security.ps1"
)

# Module laden
foreach ($module in $moduleFiles) {
    if (-not (Test-Path $module)) {
        Write-Host "[!] Modul nicht gefunden: $module" -ForegroundColor Red
        Exit
    }
    try {
        . $module
        Write-Host "[`u{2713}] Modul geladen: $module" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler beim Laden von $module" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Exit
    }
}

# Globale Variablen
$script:primaryColor = "Magenta"
$script:secondaryColor = "White"
$script:CurrentLanguage = "de"
$script:ConfigPath = "$env:USERPROFILE\Documents\chillTweak_config.json"

# Hauptprogramm
try {
    Test-AdminRights
    Import-Config
    
    do {
        Show-Menu
        $choice = Read-Host "`nWaehle eine Option"
        
        switch ($choice) {
            "1" { Disable-Telemetry }
            "2" { Optimize-System }
            "3" { Install-CommonSoftware }
            "4" { Clear-SystemFiles }
            "5" { Backup-System }
            "6" { Show-Help }
            "7" { Set-Language; Save-Config }
            "8" { Update-Windows }
            "Q" { break }
            default { Write-Host "[!] Ungueltige Eingabe" -ForegroundColor Red }
        }
        
        if ($choice -ne "Q") {
            Write-Host "`nWeiter mit beliebiger Taste..." -ForegroundColor $script:secondaryColor
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    } while ($choice -ne "Q")
    
    Write-Host "Programm beendet." -ForegroundColor $script:primaryColor
}
catch {
    Write-Host "[!] Fehler aufgetreten" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Exit
}