# Sicherheitsfunktionen
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
        
        $choice = Read-Host "`nWaehle eine Option"
        
        try {
            switch ($choice) {
                "1" { 
                    Write-Host "[*] Suche nach Updates..." -ForegroundColor $primaryColor
                    $updates = Get-WindowsUpdate
                    if ($updates) {
                        Write-Host "[✓] $($updates.Count) Updates gefunden" -ForegroundColor $secondaryColor
                    }
                    else {
                        Write-Host "[✓] System ist aktuell" -ForegroundColor $secondaryColor
                    }
                }
                "2" {
                    Write-Host "[*] Installiere Updates..." -ForegroundColor $primaryColor
                    Install-WindowsUpdate -AcceptAll -AutoReboot
                }
                "3" {
                    Write-Host "[*] Update-Verlauf:" -ForegroundColor $primaryColor
                    Get-WindowsUpdateLog
                }
                "4" {
                    Write-Host "[*] Updates werden pausiert..." -ForegroundColor $primaryColor
                    Set-Service -Name wuauserv -StartupType Disabled
                    Stop-Service -Name wuauserv -Force
                    Write-Host "[✓] Updates pausiert" -ForegroundColor $secondaryColor
                }
                default { Write-Host "`n[!] Ungueltige Eingabe" -ForegroundColor Red }
            }
        }
        catch {
            Write-Host "[!] Fehler bei der Update-Operation: $_" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "[!] Fehler beim Windows Update: $_" -ForegroundColor Red
    }
}

function Test-ScriptSignature {
    param (
        [string]$ScriptPath
    )
    try {
        $signature = Get-AuthenticodeSignature -FilePath $ScriptPath
        if ($signature.Status -ne 'Valid') {
            Write-Host "[!] WARNUNG: Skript-Signatur ist nicht gueltig!" -ForegroundColor Red
            $confirm = Read-Host "Moechten Sie trotzdem fortfahren? (J/N)"
            if ($confirm -ne 'J') {
                Exit
            }
        }
    }
    catch {
        Write-Host "[!] Fehler bei der Signaturpruefung: $_" -ForegroundColor Red
    }
} 