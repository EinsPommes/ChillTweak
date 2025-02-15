# Cleanup-Funktionen
function Clear-SystemFiles {
    try {
        Write-Host "`n[*] Starte Systemreinigung..." -ForegroundColor $script:primaryColor
        
        # Temporaere Dateien
        if ($script:CleanupSettings.TempFiles) {
            Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "[+] Temporaere Dateien entfernt" -ForegroundColor $script:secondaryColor
        }
        
        # Papierkorb
        if ($script:CleanupSettings.RecycleBin) {
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            Write-Host "[+] Papierkorb geleert" -ForegroundColor $script:secondaryColor
        }
        
        # Windows Logs
        if ($script:CleanupSettings.WindowsLogs) {
            wevtutil el | ForEach-Object {
                wevtutil cl "$_" 2>&1 | Out-Null
            }
            Write-Host "[+] Windows Logs bereinigt" -ForegroundColor $script:secondaryColor
        }
        
        # Windows Update Cache
        $updateCache = "C:\Windows\SoftwareDistribution\Download"
        if (Test-Path $updateCache) {
            Stop-Service -Name wuauserv -Force
            Remove-Item -Path "$updateCache\*" -Recurse -Force -ErrorAction SilentlyContinue
            Start-Service -Name wuauserv
            Write-Host "[+] Windows Update Cache bereinigt" -ForegroundColor $script:secondaryColor
        }
        
        Write-Host "[+] Systemreinigung abgeschlossen" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der Systemreinigung" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
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