# Cleanup-Funktionen
function Clear-SystemFiles {
    Write-Host "`n[*] System wird aufgeraeumt..." -ForegroundColor $primaryColor
    try {
        # Menü anzeigen
        Write-Host "`nWaehle eine Option:" -ForegroundColor $secondaryColor
        Write-Host "[1] Temporaere Dateien loeschen" -ForegroundColor $secondaryColor
        Write-Host "[2] Papierkorb leeren" -ForegroundColor $secondaryColor
        Write-Host "[3] Windows Update Cache leeren" -ForegroundColor $secondaryColor
        Write-Host "[4] Alles aufraeumen" -ForegroundColor $secondaryColor
        Write-Host "[5] Zurueck" -ForegroundColor $secondaryColor

        $choice = Read-Host "`nWaehle eine Option"

        try {
            switch ($choice) {
                "1" { Clear-TempFiles }
                "2" { Clear-RecycleBin -Force -ErrorAction SilentlyContinue }
                "3" { Clear-UpdateCache }
                "4" { 
                    Clear-TempFiles
                    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
                    Clear-UpdateCache
                }
                "5" { return }
                default { Write-Host "`n[!] Ungueltige Eingabe" -ForegroundColor Red }
            }
        }
        catch {
            Write-Host "[!] Fehler bei der Aktion: $_" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "[!] Fehler beim Aufraeumen: $_" -ForegroundColor Red
    }
}

function Clear-TempFiles {
    Write-Host "[*] Loesche temporaere Dateien..." -ForegroundColor $primaryColor
    try {
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[✓] Temporaere Dateien geloescht" -ForegroundColor $secondaryColor
    }
    catch {
        Write-Host "[!] Fehler beim Loeschen temporaerer Dateien: $_" -ForegroundColor Red
    }
}

function Clear-UpdateCache {
    Write-Host "[*] Leere Windows Update Cache..." -ForegroundColor $primaryColor
    try {
        Stop-Service -Name wuauserv
        Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Service -Name wuauserv
        Write-Host "[✓] Update Cache geleert" -ForegroundColor $secondaryColor
    }
    catch {
        Write-Host "[!] Fehler beim Leeren des Update Cache: $_" -ForegroundColor Red
    }
} 