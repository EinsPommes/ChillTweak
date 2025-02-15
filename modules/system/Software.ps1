# Software-Installationsfunktionen
function Install-CommonSoftware {
    Write-Host "`n[*] Software-Installation wird gestartet..." -ForegroundColor $primaryColor
    try {
        # Winget prüfen/installieren
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            Write-Host "[*] Winget wird installiert..." -ForegroundColor $secondaryColor
            Install-Winget
        }

        # Software-Liste anzeigen
        Write-Host "`nVerfuegbare Software:" -ForegroundColor $secondaryColor
        Write-Host "[1] 7-Zip" -ForegroundColor $secondaryColor
        Write-Host "[2] Notepad++" -ForegroundColor $secondaryColor
        Write-Host "[3] VLC Media Player" -ForegroundColor $secondaryColor
        Write-Host "[4] Alle installieren" -ForegroundColor $secondaryColor
        Write-Host "[5] Zurueck" -ForegroundColor $secondaryColor

        $choice = Read-Host "`nWaehle eine Option"

        try {
            switch ($choice) {
                "1" { Install-Package -Name "7zip.7zip" }
                "2" { Install-Package -Name "Notepad++.Notepad++" }
                "3" { Install-Package -Name "VideoLAN.VLC" }
                "4" { 
                    Install-Package -Name "7zip.7zip"
                    Install-Package -Name "Notepad++.Notepad++"
                    Install-Package -Name "VideoLAN.VLC"
                }
                "5" { return }
                default { Write-Host "`n[!] Ungueltige Eingabe" -ForegroundColor Red }
            }
        }
        catch {
            Write-Host "[!] Fehler bei der Installation: $_" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "[!] Fehler bei der Software-Installation: $_" -ForegroundColor Red
    }
}

function Install-Package {
    param (
        [string]$Name
    )
    Write-Host "[*] Installiere $Name..." -ForegroundColor $primaryColor
    try {
        winget install $Name --accept-source-agreements --accept-package-agreements
        Write-Host "[✓] $Name erfolgreich installiert" -ForegroundColor $secondaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der Installation von $Name : $_" -ForegroundColor Red
    }
}

function Install-Winget {
    try {
        # Download und Installation von winget
        $url = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $output = "$env:TEMP\winget.msixbundle"
        Invoke-WebRequest -Uri $url -OutFile $output
        Add-AppxPackage -Path $output
        Remove-Item $output -Force
        Write-Host "[✓] Winget erfolgreich installiert" -ForegroundColor $secondaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der Winget-Installation: $_" -ForegroundColor Red
        Exit
    }
} 