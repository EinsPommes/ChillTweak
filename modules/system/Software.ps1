# Software-Installationsfunktionen
function Install-CommonSoftware {
    try {
        Write-Host "`n[*] Installiere haeufig benoetigte Software..." -ForegroundColor $script:primaryColor
        
        # Pruefen ob Winget installiert ist
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            Install-Winget
        }
        
        # Liste der zu installierenden Programme
        $software = @(
            "Mozilla.Firefox",
            "VideoLAN.VLC",
            "7zip.7zip",
            "Notepad++.Notepad++",
            "Microsoft.VisualStudioCode",
            "Google.Chrome",
            "Adobe.Acrobat.Reader.64-bit",
            "TeamViewer.TeamViewer"
        )
        
        foreach ($app in $software) {
            try {
                Write-Host "[*] Installiere $app..." -ForegroundColor $script:secondaryColor
                winget install --id $app --accept-source-agreements --accept-package-agreements --silent
                Write-Host "[+] $app erfolgreich installiert" -ForegroundColor $script:secondaryColor
            }
            catch {
                Write-Host "[!] Fehler bei der Installation von $app" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
                continue
            }
        }
        
        Write-Host "[+] Software-Installation abgeschlossen" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der Software-Installation" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Install-Winget {
    try {
        Write-Host "[*] Installiere Winget..." -ForegroundColor $script:primaryColor
        
        # Download Winget
        $wingetUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $wingetPath = "$env:TEMP\winget.msixbundle"
        
        Invoke-WebRequest -Uri $wingetUrl -OutFile $wingetPath
        
        # Installiere Winget
        Add-AppxPackage -Path $wingetPath
        
        # Cleanup
        Remove-Item $wingetPath -Force
        
        Write-Host "[+] Winget erfolgreich installiert" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der Winget-Installation" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}