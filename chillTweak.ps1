# chillTweak - Ein modularer Windows Tweaker
# Autor: [Jannik/Mika]
# Version: 1.0

# Self-elevate to admin if not already running as admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "& '" + $MyInvocation.MyCommand.Path + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Exit
}

# Überprüfe -> Ueberpruefe ob das Skript direkt ausgeführt wird oder heruntergeladen wurde
$scriptPath = $MyInvocation.MyCommand.Path
if (-not $scriptPath) {
    $tempFile = "$env:TEMP\chillTweak.ps1"
    try {
        # Download das Skript von GitHub 
        $scriptUrl = "https://raw.githubusercontent.com/einspommes/chillTweak/main/chillTweak.ps1"
        Invoke-WebRequest -Uri $scriptUrl -UseBasicParsing -OutFile $tempFile
        & $tempFile
        Remove-Item $tempFile
        Exit
    }
    catch {
        Write-Host "[!] Fehler beim Herunterladen des Skripts: $_" -ForegroundColor Red
        Exit
    }
}

# Farbdefinitionen
$script:primaryColor = "Magenta"  # Pink
$script:secondaryColor = "White"  # Weiß

# Variablen
$script:CurrentLanguage = 'de'  # Standardsprache
$script:CustomSoftware = @()    # Leeres Array für benutzerdefinierte Software
$script:LastBackupPath = ""     # Letzter Backup-Pfad
$script:ConfigPath = "$env:USERPROFILE\Documents\chillTweak_config.json"

# Sprachdateien
$script:Strings = @{
    'de' = @{
        'WelcomeMessage' = "Willkommen bei chillTweak!"
        'SelectOption' = "Wähle eine Option"
        'Success' = "Erfolgreich"
        'Error' = "Fehler"
    }
    'en' = @{
        'WelcomeMessage' = "Welcome to chillTweak!"
        'SelectOption' = "Select an option"
        'Success' = "Success"
        'Error' = "Error"
    }
}

# Funktionen
function Set-Language {
    Write-Host "`nSprache / Language:" -ForegroundColor $primaryColor
    Write-Host "[1]" -ForegroundColor $primaryColor -NoNewline
    Write-Host " Deutsch" -ForegroundColor $secondaryColor
    Write-Host "[2]" -ForegroundColor $primaryColor -NoNewline
    Write-Host " English" -ForegroundColor $secondaryColor
    
    $choice = Read-Host "`nWaehle eine Option / Select an option"
    
    switch ($choice) {
        "1" { $script:CurrentLanguage = 'de' }
        "2" { $script:CurrentLanguage = 'en' }
        default { $script:CurrentLanguage = 'de' }
    }
}

function Get-LocalizedString {
    param (
        [string]$Key
    )
    return $Strings[$script:CurrentLanguage][$Key]
}

function Show-Banner {
    Clear-Host
    $version = "1.0"
    Write-Host @"
    ╔═══════════════════════════════════════╗
    ║           c h i l l T w e a k          ║
    ║              v$version                ║
    ╚═══════════════════════════════════════╝
"@ -ForegroundColor $primaryColor

    # Systeminformationen anzeigen
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor
    $ram = [math]::Round(($os.TotalVisibleMemorySize / 1MB), 2)
    
    Write-Host "`nSystem Info:" -ForegroundColor $secondaryColor
    Write-Host "OS: $($os.Caption)" -ForegroundColor $primaryColor
    Write-Host "CPU: $($cpu.Name)" -ForegroundColor $primaryColor
    Write-Host "RAM: $ram GB" -ForegroundColor $primaryColor
}

function Show-Menu {
    Write-Host "`n[1]" -ForegroundColor $primaryColor -NoNewline
    Write-Host " Windows Telemetrie deaktivieren" -ForegroundColor $secondaryColor
    Write-Host "[2]" -ForegroundColor $primaryColor -NoNewline
    Write-Host " System optimieren" -ForegroundColor $secondaryColor
    Write-Host "[3]" -ForegroundColor $primaryColor -NoNewline
    Write-Host " Software installieren" -ForegroundColor $secondaryColor
    Write-Host "[4]" -ForegroundColor $primaryColor -NoNewline
    Write-Host " System aufraeumen" -ForegroundColor $secondaryColor
    Write-Host "[5]" -ForegroundColor $primaryColor -NoNewline
    Write-Host " Backup erstellen" -ForegroundColor $secondaryColor
    Write-Host "[6]" -ForegroundColor $primaryColor -NoNewline
    Write-Host " Hilfe anzeigen" -ForegroundColor $secondaryColor
    Write-Host "[7]" -ForegroundColor $primaryColor -NoNewline
    Write-Host " Sprache aendern" -ForegroundColor $secondaryColor
    Write-Host "[8]" -ForegroundColor $primaryColor -NoNewline
    Write-Host " Windows Update Manager" -ForegroundColor $secondaryColor
    Write-Host "[Q]" -ForegroundColor $primaryColor -NoNewline
    Write-Host " Beenden" -ForegroundColor $secondaryColor
}

function Show-Progress {
    param (
        [string]$Activity,
        [int]$PercentComplete,
        [string]$Status = "In Bearbeitung..."
    )
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
}

# Hauptfunktionen
function Disable-Telemetry {
    Write-Host "`n[*] Deaktiviere Windows Telemetrie..." -ForegroundColor $primaryColor
    try {
        Stop-Service -Name DiagTrack -Force
        Set-Service -Name DiagTrack -StartupType Disabled
        Write-Host "[✓] Telemetrie erfolgreich deaktiviert" -ForegroundColor $secondaryColor
    }
    catch {
        Write-Host "[!] Fehler beim Deaktivieren der Telemetrie: $_" -ForegroundColor Red
    }
}

function Optimize-System {
    Write-Host "`n[*] Performance-Optimierung wird gestartet..." -ForegroundColor $primaryColor
    try {
        $totalSteps = 5
        $currentStep = 0
        Show-Progress -Activity "System-Optimierung" -PercentComplete (($currentStep++ / $totalSteps) * 100)
        
        Write-Host "`nWaehle eine Performance-Option:" -ForegroundColor $secondaryColor
        Write-Host "[1]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Energieplan optimieren" -ForegroundColor $secondaryColor
        Write-Host "[2]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Autostart-Programme verwalten" -ForegroundColor $secondaryColor
        Write-Host "[3]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Windows-Dienste optimieren" -ForegroundColor $secondaryColor
        Write-Host "[4]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Gaming-Optimierung" -ForegroundColor $secondaryColor
        Write-Host "[5]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " RAM-Optimierung" -ForegroundColor $secondaryColor
        Write-Host "[6]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Alle Optimierungen ausführen" -ForegroundColor $secondaryColor
        Write-Host "[7]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Zurueck zum Hauptmenue" -ForegroundColor $secondaryColor

        $choice = Read-Host "`nWähle eine Option"

        switch ($choice) {
            "1" { Optimize-PowerPlan }
            "2" { Set-Autostart }
            "3" { Optimize-Services }
            "4" { Optimize-Gaming }
            "5" { Optimize-RAM }
            "6" { 
                Optimize-PowerPlan
                Set-Autostart
                Optimize-Services
                Optimize-Gaming
                Optimize-RAM
            }
            "7" { return }
            default { Write-Host "`n[!] Ungültige Eingabe" -ForegroundColor Red }
        }
    }
    catch {
        Write-Host "[!] Fehler bei der Performance-Optimierung: $_" -ForegroundColor Red
    }
}

function Update-Windows {
    Write-Host "`n[*] Windows Update Manager..." -ForegroundColor $primaryColor
    try {
        Write-Host "`nWaehle eine Option:" -ForegroundColor $secondaryColor
        Write-Host "[1]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Updates suchen" -ForegroundColor $secondaryColor
        Write-Host "[2]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Updates installieren" -ForegroundColor $secondaryColor
        Write-Host "[3]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Update-Verlauf anzeigen" -ForegroundColor $secondaryColor
        Write-Host "[4]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Updates pausieren" -ForegroundColor $secondaryColor
        
        $choice = Read-Host "`nWähle eine Option"
        
        switch ($choice) {
            "1" { 
                Write-Host "[*] Suche nach Updates..." -ForegroundColor $primaryColor
                # Update-Logik hier
            }
            "2" {
                Write-Host "[*] Installiere Updates..." -ForegroundColor $primaryColor
                # Update-Logik hier
            }
            "3" {
                Write-Host "[*] Update-Verlauf:" -ForegroundColor $primaryColor
                # Verlauf-Logik hier
            }
            "4" {
                Write-Host "[*] Updates werden pausiert..." -ForegroundColor $primaryColor
                # Pause-Logik hier
            }
            default { Write-Host "`n[!] Ungültige Eingabe" -ForegroundColor Red }
        }
    }
    catch {
        Write-Host "[!] Fehler beim Windows Update: $_" -ForegroundColor Red
    }
}

function Show-Help {
    Write-Host "`n[HILFE] chillTweak Funktionen:" -ForegroundColor $secondaryColor
    Write-Host "`n1. Windows Telemetrie deaktivieren" -ForegroundColor $primaryColor
    Write-Host "   - Stoppt und deaktiviert Telemetrie-Dienste" -ForegroundColor $secondaryColor
    
    Write-Host "`n2. System optimieren" -ForegroundColor $primaryColor
    Write-Host "   - Aktiviert Hoechstleistungs-Energieplan" -ForegroundColor $secondaryColor
    Write-Host "   - Optimiert visuelle Effekte" -ForegroundColor $secondaryColor
    
    Write-Host "`n3. Software installieren" -ForegroundColor $primaryColor
    Write-Host "   - Installiert Programme: 7-Zip, Notepad++, VLC" -ForegroundColor $secondaryColor
    
    Write-Host "`n4. System aufraeumen" -ForegroundColor $primaryColor
    Write-Host "   - Loescht temporaere Dateien" -ForegroundColor $secondaryColor
    Write-Host "   - Leert Papierkorb" -ForegroundColor $secondaryColor

    Write-Host "`n5. Backup erstellen" -ForegroundColor $primaryColor
    Write-Host "   - Sichert wichtige Benutzerordner" -ForegroundColor $secondaryColor
    Write-Host "   - Exportiert Systemeinstellungen" -ForegroundColor $secondaryColor
    Write-Host "   - Erstellt vollstaendige Backups" -ForegroundColor $secondaryColor
}

# Konfigurationsfunktionen
function Save-Config {
    try {
        $config = @{
            Language = $script:CurrentLanguage
            Theme = @{
                Primary = $script:primaryColor
                Secondary = $script:secondaryColor
            }
            CustomSoftware = $script:CustomSoftware
            LastBackupPath = $script:LastBackupPath
        }
        $config | ConvertTo-Json | Out-File $script:ConfigPath -Force
    }
    catch {
        Write-Host "[!] Fehler beim Speichern der Konfiguration: $_" -ForegroundColor Red
    }
}

function Import-Config {
    try {
        if (Test-Path $script:ConfigPath) {
            $config = Get-Content $script:ConfigPath | ConvertFrom-Json
            $script:CurrentLanguage = $config.Language
            $script:primaryColor = $config.Theme.Primary
            $script:secondaryColor = $config.Theme.Secondary
            $script:CustomSoftware = $config.CustomSoftware
            $script:LastBackupPath = $config.LastBackupPath
        }
        else {
            $script:CurrentLanguage = 'de'
            Save-Config
        }
    }
    catch {
        Write-Host "[!] Fehler beim Laden der Konfiguration: $_" -ForegroundColor Red
        $script:CurrentLanguage = 'de'
    }
}

# Hauptprogramm
Import-Config

if (-not $script:CurrentLanguage) {
    Set-Language
    Save-Config
}

$logPath = "$env:USERPROFILE\Documents\chillTweak_log.txt"
Start-Transcript -Path $logPath -Append

# Hauptprogramm-Ende
do {
    Show-Banner
    Show-Menu
    $choice = Read-Host "`nWaehle eine Option"
    
    switch ($choice) {
        "1" { Disable-Telemetry }
        "2" { Optimize-System }
        "3" { Install-CommonSoftware }
        "4" { Clear-SystemFiles }
        "5" { Backup-System }
        "6" { Show-Help }
        "7" { 
            Set-Language
            Save-Config 
        }
        "8" { Update-Windows }
        "Q" { break }
        default { Write-Host "`n[!] Ungueltige Eingabe" -ForegroundColor Red }
    }
    
    if ($choice -ne "Q") {
        Write-Host "`nDruecke eine Taste zum Fortfahren..." -ForegroundColor $secondaryColor
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
} while ($choice -ne "Q")

Stop-Transcript
Write-Host "Programm beendet." -ForegroundColor $primaryColor