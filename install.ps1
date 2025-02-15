# ChillTweak Installer
$ErrorActionPreference = 'Stop'

function Install-ChillTweak {
    try {
        Write-Host "[*] Starte ChillTweak Installation..." -ForegroundColor Cyan
        
        # Erstelle Zielverzeichnis
        $installDir = "$env:USERPROFILE\ChillTweak"
        if (-not (Test-Path $installDir)) {
            New-Item -Path $installDir -ItemType Directory -Force | Out-Null
            Write-Host "[+] Installationsverzeichnis erstellt: $installDir" -ForegroundColor Green
        }
        
        # Lade Hauptskript herunter
        $mainScriptUrl = "https://raw.githubusercontent.com/einspommes/chillTweak/main/chillTweak.ps1"
        $mainScriptPath = Join-Path $installDir "chillTweak.ps1"
        
        Write-Host "[*] Lade ChillTweak herunter..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $mainScriptUrl -OutFile $mainScriptPath -UseBasicParsing
        Write-Host "[+] ChillTweak erfolgreich heruntergeladen" -ForegroundColor Green
        
        # Erstelle Desktop-Verknüpfung
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $shortcutPath = Join-Path $desktopPath "ChillTweak.lnk"
        
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = "powershell.exe"
        $shortcut.Arguments = "-NoExit -ExecutionPolicy Bypass -File `"$mainScriptPath`""
        $shortcut.WorkingDirectory = $installDir
        $shortcut.Description = "ChillTweak Windows Optimierer"
        $shortcut.WindowStyle = 1  # Normal window
        $shortcut.Save()
        
        Write-Host "[+] Desktop-Verknüpfung erstellt" -ForegroundColor Green
        
        # Erstelle Ausführungsskript
        $launchScript = @"
# ChillTweak Starter
Write-Host "Starte ChillTweak..." -ForegroundColor Cyan
Set-Location "$installDir"

try {
    # Prüfe Administratorrechte
    `$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not `$isAdmin) {
        Write-Host "[!] ChillTweak benötigt Administratorrechte!" -ForegroundColor Red
        Write-Host "Bitte starte ChillTweak als Administrator." -ForegroundColor Yellow
        Read-Host "Drücke ENTER zum Beenden"
        return
    }

    # Führe ChillTweak aus
    & "$mainScriptPath"
}
catch {
    Write-Host "[!] Fehler beim Ausführen von ChillTweak:" -ForegroundColor Red
    Write-Host `$_.Exception.Message -ForegroundColor Red
    Read-Host "Drücke ENTER zum Beenden"
}
"@
        $launchPath = Join-Path $installDir "start.ps1"
        $launchScript | Out-File -FilePath $launchPath -Encoding UTF8
        
        Write-Host "`n[+] Installation abgeschlossen!" -ForegroundColor Green
        Write-Host "ChillTweak wurde installiert in: $installDir" -ForegroundColor Cyan
        Write-Host "Du kannst ChillTweak starten durch:" -ForegroundColor Cyan
        Write-Host "1. Doppelklick auf die Desktop-Verknüpfung" -ForegroundColor Cyan
        Write-Host "2. Ausführen von: $launchPath" -ForegroundColor Cyan
        Write-Host "`nHinweis: Starte ChillTweak immer als Administrator!" -ForegroundColor Yellow
    }
    catch {
        Write-Host "[!] Fehler bei der Installation:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Read-Host "Drücke ENTER zum Beenden"
        return
    }
}

# Prüfe Administratorrechte
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[!] Dieses Skript benötigt Administratorrechte!" -ForegroundColor Red
    Write-Host "Bitte starte PowerShell als Administrator und versuche es erneut." -ForegroundColor Yellow
    Read-Host "Drücke ENTER zum Beenden"
    return
}

# Starte Installation
Install-ChillTweak
Read-Host "Drücke ENTER zum Beenden"
