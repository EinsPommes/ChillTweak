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
        Invoke-WebRequest -Uri $scriptUrl -OutFile $tempFile
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

function Show-Banner {
    Clear-Host
    Write-Host @"
    ╔═══════════════════════════════════════╗
    ║           c h i l l T w e a k          ║
    ╚═══════════════════════════════════════╝
"@ -ForegroundColor $primaryColor
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
    Write-Host " Hilfe anzeigen" -ForegroundColor $secondaryColor
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

function Optimize-System {
    Write-Host "`n[*] Optimiere System..." -ForegroundColor $primaryColor
    try {
        # Energieplan auf Höchstleistung setzen
        powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        
        # Visual Effects optimieren
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name VisualFXSetting -Value 2
        
        Write-Host "[✓] System erfolgreich optimiert" -ForegroundColor $secondaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der System-Optimierung: $_" -ForegroundColor Red
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

        foreach ($app in $software) {
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
"@ -ForegroundColor $secondaryColor
}

# Hauptprogramm
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
        "5" { Show-Help }
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