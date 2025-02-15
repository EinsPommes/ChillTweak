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
        $shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$mainScriptPath`""
        $shortcut.WorkingDirectory = $installDir
        $shortcut.Save()
        
        Write-Host "[+] Desktop-Verknüpfung erstellt" -ForegroundColor Green
        
        # Erstelle Ausführungsskript
        $launchScript = @"
Set-Location "$installDir"
& "$mainScriptPath"
"@
        $launchPath = Join-Path $installDir "start.ps1"
        $launchScript | Out-File -FilePath $launchPath -Encoding UTF8
        
        Write-Host "`n[+] Installation abgeschlossen!" -ForegroundColor Green
        Write-Host "ChillTweak wurde installiert in: $installDir" -ForegroundColor Cyan
        Write-Host "Du kannst ChillTweak starten durch:" -ForegroundColor Cyan
        Write-Host "1. Doppelklick auf die Desktop-Verknüpfung" -ForegroundColor Cyan
        Write-Host "2. Ausführen von: $launchPath" -ForegroundColor Cyan
    }
    catch {
        Write-Host "[!] Fehler bei der Installation:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        return
    }
}

# Prüfe Administratorrechte
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[!] Dieses Skript benötigt Administratorrechte!" -ForegroundColor Red
    Write-Host "Bitte starte PowerShell als Administrator und versuche es erneut." -ForegroundColor Yellow
    return
}

# Starte Installation
Install-ChillTweak
