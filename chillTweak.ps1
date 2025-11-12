param([switch]$TestMode)

# chillTweak - Ein modularer Windows Tweaker
# Version: 2.0

# Basis-URL für Module
$baseUrl = "https://raw.githubusercontent.com/einspommes/chillTweak/main"

# Funktion zum Herunterladen von Modulen
function Initialize-Modules {
    # Erstelle Modulverzeichnisse
    $moduleDirs = @(
        "modules/core",
        "modules/ui",
        "modules/system",
        "modules/security"
    )

    foreach ($dir in $moduleDirs) {
        if (-not (Test-Path $dir)) {
            New-Item -Path $dir -ItemType Directory -Force | Out-Null
        }
    }

    # Module herunterladen
    $moduleFiles = @(
        "modules/core/Config.ps1",
        "modules/core/Logging.ps1",
        "modules/ui/Menu.ps1",
        "modules/system/Optimize.ps1",
        "modules/system/Backup.ps1",
        "modules/system/Cleanup.ps1",
        "modules/system/Software.ps1",
        "modules/system/Registry.ps1",
        "modules/system/Network.ps1",
        "modules/system/Disk.ps1",
        "modules/system/SystemInfo.ps1",
        "modules/system/Profiles.ps1",
        "modules/security/Security.ps1"
    )

    foreach ($module in $moduleFiles) {
        $moduleUrl = "$baseUrl/$module"
        $localPath = $module

        try {
            Invoke-WebRequest -Uri $moduleUrl -OutFile $localPath -UseBasicParsing
            Write-Host "[+] Modul heruntergeladen: $module" -ForegroundColor Green
        }
        catch {
            Write-Host "[!] Fehler beim Herunterladen von $module" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            return $false
        }
    }

    return $true
}

# Prüfe ob Module lokal existieren, wenn nicht, lade sie herunter
$modulesExist = $true
$moduleFiles = @(
    "modules/core/Config.ps1",
    "modules/core/Logging.ps1",
    "modules/ui/Menu.ps1",
    "modules/system/Optimize.ps1",
    "modules/system/Backup.ps1",
    "modules/system/Cleanup.ps1",
    "modules/system/Software.ps1",
    "modules/system/Registry.ps1",
    "modules/system/Network.ps1",
    "modules/system/Disk.ps1",
    "modules/system/SystemInfo.ps1",
    "modules/system/Profiles.ps1",
    "modules/security/Security.ps1"
)

foreach ($module in $moduleFiles) {
    if (-not (Test-Path $module)) {
        $modulesExist = $false
        break
    }
}

if (-not $modulesExist) {
    Write-Host "[*] Module werden heruntergeladen..." -ForegroundColor Cyan
    if (-not (Initialize-Modules)) {
        Write-Host "[!] Fehler beim Initialisieren der Module" -ForegroundColor Red
        Exit
    }
}

# Globale Variablen
$script:primaryColor = "Magenta"
$script:secondaryColor = "White"
$script:CurrentLanguage = "de"
$script:ConfigPath = "$env:USERPROFILE\Documents\chillTweak_config.json"

# Module laden
foreach ($module in $moduleFiles) {
    if (-not (Test-Path $module)) {
        Write-Host "[!] Modul nicht gefunden: $module" -ForegroundColor Red
        Exit
    }
    try {
        . $module
        Write-Host "[+] Modul geladen: $module" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler beim Laden von $module" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Exit
    }
}

# Hauptprogramm
try {
    Test-AdminRights
    Initialize-Logging
    Import-Config
    
    Write-LogEntry "ChillTweak gestartet - Version 2.0" -Level "INFO" -Category "System"
    
    do {
        Show-Menu
        $choice = Read-Host "`nWaehle eine Option"
        
        switch ($choice) {
            "1" { Disable-Telemetry; Write-LogEntry "Telemetrie deaktiviert" -Level "SUCCESS" -Category "Privacy" }
            "2" { Optimize-System; Write-LogEntry "System optimiert" -Level "SUCCESS" -Category "Performance" }
            "3" { Show-RegistryTweaksMenu }
            "4" { Optimize-NetworkAdvanced }
            "5" { Optimize-DiskPerformance }
            "6" { Optimize-WindowsServices }
            "7" { Show-ProfilesMenu }
            "8" { Install-CommonSoftware }
            "9" { Clear-SystemFiles; Write-LogEntry "System gereinigt" -Level "SUCCESS" -Category "Cleanup" }
            "10" { Backup-System }
            "11" { Update-Windows }
            "12" { Show-SystemDashboard }
            "13" { Show-Logs }
            "14" { Show-Help }
            "15" { Set-Language; Save-Config }
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