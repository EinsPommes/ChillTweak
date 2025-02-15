# chillTweak - Ein modularer Windows Tweaker
# Autor: [Jannik/Mika]
# Version: 1.0

# Self-elevate to admin if not already running as admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "& '" + $MyInvocation.MyCommand.Path + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Exit
}

# Überprüfe ob das Skript direkt ausgeführt wird oder heruntergeladen wurde
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

# Am Anfang der Datei nach den Farbdefinitionen
$script:CurrentLanguage = 'de'  # Standardsprache
$script:CustomSoftware = @()    # Leeres Array für benutzerdefinierte Software
$script:LastBackupPath = ""     # Letzter Backup-Pfad

# Sprachdateien
$script:Strings = @{
    'de' = @{
        'WelcomeMessage' = "Willkommen bei chillTweak!"
        'SelectOption' = "Wähle eine Option"
        'Success' = "Erfolgreich"
        'Error' = "Fehler"
        # ... weitere Übersetzungen ...
    }
    'en' = @{
        'WelcomeMessage' = "Welcome to chillTweak!"
        'SelectOption' = "Select an option"
        'Success' = "Success"
        'Error' = "Error"
        # ... weitere Übersetzungen ...
    }
}

# Sprachauswahl-Funktion
function Set-Language {
    Write-Host "`nSprache / Language:" -ForegroundColor $primaryColor
    Write-Host "[1]" -ForegroundColor $primaryColor -NoNewline
    Write-Host " Deutsch" -ForegroundColor $secondaryColor
    Write-Host "[2]" -ForegroundColor $primaryColor -NoNewline
    Write-Host " English" -ForegroundColor $secondaryColor
    
    $choice = Read-Host "`nWähle eine Option / Select an option"
    
    switch ($choice) {
        "1" { $script:CurrentLanguage = 'de' }
        "2" { $script:CurrentLanguage = 'en' }
        default { $script:CurrentLanguage = 'de' }
    }
}

# Funktion zum Abrufen von Strings
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
    Write-Host " System aufräumen" -ForegroundColor $secondaryColor
    Write-Host "[5]" -ForegroundColor $primaryColor -NoNewline
    Write-Host " Backup erstellen" -ForegroundColor $secondaryColor
    Write-Host "[6]" -ForegroundColor $primaryColor -NoNewline
    Write-Host " Hilfe anzeigen" -ForegroundColor $secondaryColor
    Write-Host "[7]" -ForegroundColor $primaryColor -NoNewline
    Write-Host " Sprache ändern" -ForegroundColor $secondaryColor
    Write-Host "[Q]" -ForegroundColor $primaryColor -NoNewline
    Write-Host " Beenden" -ForegroundColor $secondaryColor
}

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

# Neue Funktion für Fortschrittsbalken
function Show-Progress {
    param (
        [string]$Activity,
        [int]$PercentComplete,
        [string]$Status = "In Bearbeitung..."
    )
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
}

function Optimize-System {
    Write-Host "`n[*] Performance-Optimierung wird gestartet..." -ForegroundColor $primaryColor
    
    try {
        $totalSteps = 5
        $currentStep = 0

        # Fortschritt anzeigen
        Show-Progress -Activity "System-Optimierung" -PercentComplete (($currentStep++ / $totalSteps) * 100)
        
        # Untermenü für Performance-Optimierungen
        Write-Host "`nWähle eine Performance-Option:" -ForegroundColor $secondaryColor
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
        Write-Host " Zurück zum Hauptmenü" -ForegroundColor $secondaryColor

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

function Optimize-PowerPlan {
    Write-Host "`n[*] Optimiere Energieeinstellungen..." -ForegroundColor $primaryColor
    try {
        # Höchstleistung aktivieren
        powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        
        # Bildschirm-Timeout anpassen
        powercfg /change monitor-timeout-ac 15
        powercfg /change monitor-timeout-dc 5
        
        # Festplatte nie ausschalten
        powercfg /change disk-timeout-ac 0
        powercfg /change disk-timeout-dc 0
        
        # Ruhezustand deaktivieren
        powercfg /hibernate off
        
        Write-Host "[✓] Energieplan optimiert" -ForegroundColor $secondaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der Energieplan-Optimierung: $_" -ForegroundColor Red
    }
}

function Set-Autostart {
    Write-Host "`n[*] Verwalte Autostart-Programme..." -ForegroundColor $primaryColor
    try {
        # Autostart-Einträge auflisten
        $autostart = Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location
        
        Write-Host "`nAktuell aktivierte Autostart-Programme:" -ForegroundColor $secondaryColor
        $autostart | Format-Table -AutoSize
        
        # Optionale Deaktivierung von Autostart-Programmen
        Write-Host "`nMöchtest du bestimmte Programme deaktivieren? (J/N)" -ForegroundColor $primaryColor
        $answer = Read-Host
        
        if ($answer -eq "J") {
            Write-Host "Gib den Namen des Programms ein:" -ForegroundColor $secondaryColor
            $programName = Read-Host
            
            # Registry-Pfade für Autostart
            $regPaths = @(
                "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
                "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
            )
            
            foreach ($path in $regPaths) {
                Remove-ItemProperty -Path $path -Name $programName -ErrorAction SilentlyContinue
            }
            
            Write-Host "[✓] Autostart-Eintrag entfernt" -ForegroundColor $secondaryColor
        }
    }
    catch {
        Write-Host "[!] Fehler bei der Autostart-Verwaltung: $_" -ForegroundColor Red
    }
}

function Optimize-Services {
    Write-Host "`n[*] Optimiere Windows-Dienste..." -ForegroundColor $primaryColor
    try {
        # Liste von Diensten, die deaktiviert werden können
        $servicesToDisable = @(
            "SysMain",           # Superfetch
            "WSearch",           # Windows Search
            "DiagTrack",         # Connected User Experiences and Telemetry
            "WMPNetworkSvc",     # Windows Media Player Network Sharing
            "TabletInputService" # Touch Keyboard and Handwriting Panel Service
        )
        
        foreach ($service in $servicesToDisable) {
            $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
            if ($svc) {
                Stop-Service -Name $service -Force
                Set-Service -Name $service -StartupType Disabled
                Write-Host "[✓] Dienst $service deaktiviert" -ForegroundColor $secondaryColor
            }
        }
    }
    catch {
        Write-Host "[!] Fehler bei der Dienste-Optimierung: $_" -ForegroundColor Red
    }
}

function Optimize-Gaming {
    Write-Host "`n[*] Optimiere System für Gaming..." -ForegroundColor $primaryColor
    try {
        # Game Mode aktivieren
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1
        
        # Visual Effects für Performance optimieren
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
        
        # HPET (High Precision Event Timer) deaktivieren
        bcdedit /deletevalue useplatformclock
        
        # Speicheroptimierung für Gaming
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "LargeSystemCache" -Value 0
        
        # Netzwerk-Optimierung
        Set-NetTCPSetting -SettingName InternetCustom -AutoTuningLevelLocal Normal
        
        Write-Host "[✓] Gaming-Optimierungen abgeschlossen" -ForegroundColor $secondaryColor
        Write-Host "[!] Bitte System neu starten für volle Wirkung" -ForegroundColor $primaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der Gaming-Optimierung: $_" -ForegroundColor Red
    }
}

function Optimize-RAM {
    Write-Host "`n[*] Optimiere RAM-Nutzung..." -ForegroundColor $primaryColor
    try {
        # Pagefile optimieren
        $computersys = Get-WmiObject Win32_ComputerSystem
        $memory = [math]::Round($computersys.TotalPhysicalMemory / 1GB)
        $pageFileSize = $memory * 1.5
        
        $pagefile = Get-WmiObject Win32_PageFileSetting
        $pagefile.InitialSize = $pageFileSize
        $pagefile.MaximumSize = $pageFileSize * 2
        $pagefile.Put()
        
        # Speicherbereinigung
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        
        # RAM-Komprimierung optimieren
        Enable-MMAgent -mc
        
        Write-Host "[✓] RAM-Optimierung abgeschlossen" -ForegroundColor $secondaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der RAM-Optimierung: $_" -ForegroundColor Red
    }
}

function Install-CommonSoftware {
    Write-Host "`n[*] Installiere Software..." -ForegroundColor $primaryColor
    try {
        # Prüfe ob winget verfügbar ist
        if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
            Write-Host "[!] Winget nicht gefunden. Bitte installiere es zuerst." -ForegroundColor Red
            return
        }

        $software = @(
            "7zip.7zip",
            "Notepad++.Notepad++",
            "VideoLAN.VLC"
        )

        $totalApps = $software.Count
        $currentApp = 0
        
        foreach ($app in $software) {
            Show-Progress -Activity "Software-Installation" -PercentComplete (($currentApp++ / $totalApps) * 100)
            Write-Host "Installing $app..." -ForegroundColor $secondaryColor
            winget install -e --id $app --accept-source-agreements --accept-package-agreements
        }
        
        Write-Host "[✓] Software-Installation abgeschlossen" -ForegroundColor $secondaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der Software-Installation: $_" -ForegroundColor Red
    }
}

function Clear-SystemFiles {
    Write-Host "`n[*] Räume System auf..." -ForegroundColor $primaryColor
    try {
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Host "[✓] System erfolgreich aufgeräumt" -ForegroundColor $secondaryColor
    }
    catch {
        Write-Host "[!] Fehler beim Aufräumen: $_" -ForegroundColor Red
    }
}

function Backup-System {
    Write-Host "`n[*] Backup-Assistent wird gestartet..." -ForegroundColor $primaryColor
    
    # Backup-Ziel festlegen
    $defaultPath = "$env:USERPROFILE\Documents\chillTweak_Backups"
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
    $backupPath = "$defaultPath\Backup_$timestamp"
    
    try {
        # Erstelle Backup-Verzeichnis falls nicht vorhanden
        if (-not (Test-Path $defaultPath)) {
            New-Item -ItemType Directory -Path $defaultPath | Out-Null
        }
        
        # Backup-Menü anzeigen
        Write-Host "`nWähle die Backup-Option:" -ForegroundColor $secondaryColor
        Write-Host "[1]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Wichtige Benutzerordner (Dokumente, Bilder, Desktop)" -ForegroundColor $secondaryColor
        Write-Host "[2]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Systemeinstellungen (Registry-Exports)" -ForegroundColor $secondaryColor
        Write-Host "[3]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Vollständiges Backup (Benutzerordner + Einstellungen)" -ForegroundColor $secondaryColor
        Write-Host "[4]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Zurück zum Hauptmenü" -ForegroundColor $secondaryColor
        
        $choice = Read-Host "`nWähle eine Option"
        
        switch ($choice) {
            "1" {
                # Backup wichtiger Benutzerordner
                $folders = @(
                    "$env:USERPROFILE\Documents",
                    "$env:USERPROFILE\Pictures",
                    "$env:USERPROFILE\Desktop"
                )
                
                New-Item -ItemType Directory -Path "$backupPath\UserFolders" | Out-Null
                
                foreach ($folder in $folders) {
                    $folderName = Split-Path $folder -Leaf
                    Write-Host "[*] Sichere $folderName..." -ForegroundColor $secondaryColor
                    Copy-Item -Path $folder -Destination "$backupPath\UserFolders\$folderName" -Recurse -Force
                }
            }
            "2" {
                # Backup von Systemeinstellungen
                New-Item -ItemType Directory -Path "$backupPath\Registry" | Out-Null
                
                Write-Host "[*] Exportiere Registry-Einstellungen..." -ForegroundColor $secondaryColor
                
                # Export wichtiger Registry-Zweige
                $registryPaths = @(
                    "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer",
                    "HKCU\Software\Microsoft\Windows\CurrentVersion\Run",
                    "HKLM\SYSTEM\CurrentControlSet\Services"
                )
                
                foreach ($path in $registryPaths) {
                    $name = ($path -split '\\')[-1]
                    REG EXPORT $path "$backupPath\Registry\$name.reg" /y
                }
            }
            "3" {
                # Vollständiges Backup
                Backup-System # Rekursiver Aufruf für Option 1
                $choice = "1"
                Backup-System # Rekursiver Aufruf für Option 2
                $choice = "2"
            }
            "4" {
                return
            }
            default {
                Write-Host "[!] Ungültige Eingabe" -ForegroundColor Red
                return
            }
        }
        
        # Backup-Info in JSON-Datei speichern
        $backupInfo = @{
            TimeStamp = $timestamp
            Type = switch ($choice) {
                "1" { "UserFolders" }
                "2" { "SystemSettings" }
                "3" { "Complete" }
            }
            Path = $backupPath
        } | ConvertTo-Json
        
        $backupInfo | Out-File "$backupPath\backup_info.json"
        
        # Erstelle Backup-Log
        Write-Host "`n[✓] Backup erfolgreich erstellt unter: $backupPath" -ForegroundColor $secondaryColor
        Write-Host "[*] Größe:" -ForegroundColor $primaryColor -NoNewline
        $size = (Get-ChildItem $backupPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
        Write-Host " $([math]::Round($size, 2)) MB" -ForegroundColor $secondaryColor
        
    }
    catch {
        Write-Host "[!] Fehler beim Backup: $_" -ForegroundColor Red
    }
}

function Show-Help {
    Write-Host @"
`n[HILFE] chillTweak Funktionen:

1. Windows Telemetrie deaktivieren
   - Stoppt und deaktiviert Telemetrie-Dienste
   
2. System optimieren
   - Aktiviert Höchstleistungs-Energieplan
   - Optimiert visuelle Effekte
   
3. Software installieren
   - Installiert gängige Programme (7-Zip, Notepad++, VLC)
   
4. System aufräumen
   - Löscht temporäre Dateien
   - Leert Papierkorb

5. Backup erstellen
   - Sichert wichtige Benutzerordner
   - Exportiert Systemeinstellungen
   - Erstellt vollständige Backups
"@ -ForegroundColor $secondaryColor
}

# Konfigurationsdatei
$script:ConfigPath = "$env:USERPROFILE\Documents\chillTweak_config.json"

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

function Load-Config {
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
            # Standardwerte setzen
            $script:CurrentLanguage = 'de'
            Save-Config
        }
    }
    catch {
        Write-Host "[!] Fehler beim Laden der Konfiguration: $_" -ForegroundColor Red
        # Standardwerte setzen
        $script:CurrentLanguage = 'de'
    }
}

# Hauptprogramm
# Konfiguration laden
Load-Config

# Wenn keine Sprache gesetzt ist, Sprachauswahl anzeigen
if (-not $script:CurrentLanguage) {
    Set-Language
    Save-Config
}

# Logging initialisieren
$logPath = "$env:USERPROFILE\Documents\chillTweak_log.txt"
Start-Transcript -Path $logPath -Append

do {
    Show-Banner
    Show-Menu
    $choice = Read-Host "`nWähle eine Option"
    
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
        "Q" { break }
        default { Write-Host "`n[!] Ungültige Eingabe" -ForegroundColor Red }
    }
    
    if ($choice -ne "Q") {
        Write-Host "`nDrücke eine Taste zum Fortfahren..." -ForegroundColor $secondaryColor
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
} while ($choice -ne "Q")

Stop-Transcript

Write-Host "`n[*] Programm wird beendet. Logs wurden gespeichert in: $logPath" -ForegroundColor $primaryColor 