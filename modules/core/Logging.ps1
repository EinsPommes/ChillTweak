# Logging Module for ChillTweak

# Globale Log-Variablen
$script:LogPath = "$env:USERPROFILE\Documents\ChillTweak_Logs"
$script:CurrentLogFile = ""
$script:LoggingEnabled = $true

function Initialize-Logging {
    try {
        # Erstelle Log-Verzeichnis
        if (-not (Test-Path $script:LogPath)) {
            New-Item -Path $script:LogPath -ItemType Directory -Force | Out-Null
        }
        
        # Erstelle neue Log-Datei für diese Session
        $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
        $script:CurrentLogFile = Join-Path $script:LogPath "ChillTweak_$timestamp.log"
        
        # Log-Header schreiben
        $header = @"
╔══════════════════════════════════════════════════════════════╗
║              ChillTweak Log File                             ║
║              Session: $timestamp                    ║
╚══════════════════════════════════════════════════════════════╝

"@
        $header | Out-File -FilePath $script:CurrentLogFile -Encoding UTF8
        
        Write-LogEntry "ChillTweak gestartet" -Level "INFO"
        Write-LogEntry "Log-Datei: $script:CurrentLogFile" -Level "INFO"
        
        # Log-Rotation durchführen
        Start-LogRotation
    }
    catch {
        Write-Host "[!] Fehler beim Initialisieren des Loggings: $($_.Exception.Message)" -ForegroundColor Red
        $script:LoggingEnabled = $false
    }
}

function Write-LogEntry {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS", "DEBUG")]
        [string]$Level = "INFO",
        
        [Parameter(Mandatory=$false)]
        [string]$Category = "General"
    )
    
    if (-not $script:LoggingEnabled) {
        return
    }
    
    try {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logEntry = "[$timestamp] [$Level] [$Category] $Message"
        
        # Schreibe in Log-Datei
        $logEntry | Out-File -FilePath $script:CurrentLogFile -Append -Encoding UTF8
        
        # Optional: Schreibe auch in Console (nur für wichtige Meldungen)
        if ($Level -eq "ERROR") {
            Write-Host $logEntry -ForegroundColor Red
        }
        elseif ($Level -eq "WARNING") {
            Write-Host $logEntry -ForegroundColor Yellow
        }
    }
    catch {
        # Fehler beim Logging selbst - Ausgabe nur in Console
        Write-Host "[!] Logging-Fehler: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Start-LogRotation {
    try {
        # Lösche Log-Dateien älter als 30 Tage
        $maxAge = (Get-Date).AddDays(-30)
        Get-ChildItem -Path $script:LogPath -Filter "ChillTweak_*.log" | 
            Where-Object { $_.LastWriteTime -lt $maxAge } | 
            Remove-Item -Force
        
        # Begrenze Anzahl der Log-Dateien auf 50
        $logs = Get-ChildItem -Path $script:LogPath -Filter "ChillTweak_*.log" | 
                Sort-Object LastWriteTime -Descending
        
        if ($logs.Count -gt 50) {
            $logs | Select-Object -Skip 50 | Remove-Item -Force
        }
        
        Write-LogEntry "Log-Rotation durchgeführt" -Level "INFO" -Category "Maintenance"
    }
    catch {
        Write-LogEntry "Fehler bei Log-Rotation: $($_.Exception.Message)" -Level "ERROR" -Category "Maintenance"
    }
}

function Show-Logs {
    try {
        Write-Host "`n=== ChillTweak Logs ===" -ForegroundColor $script:primaryColor
        Write-Host "[1] Aktuelles Log anzeigen" -ForegroundColor $script:secondaryColor
        Write-Host "[2] Alle Logs auflisten" -ForegroundColor $script:secondaryColor
        Write-Host "[3] Log-Verzeichnis öffnen" -ForegroundColor $script:secondaryColor
        Write-Host "[4] Logs bereinigen" -ForegroundColor $script:secondaryColor
        Write-Host "[Q] Zurück" -ForegroundColor $script:secondaryColor
        
        $choice = Read-Host "`nWähle eine Option"
        
        switch ($choice) {
            "1" {
                if (Test-Path $script:CurrentLogFile) {
                    Get-Content $script:CurrentLogFile | Out-Host
                    Write-Host "`nDrücke eine beliebige Taste um fortzufahren..." -ForegroundColor $script:secondaryColor
                    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                }
                else {
                    Write-Host "[!] Keine aktuelle Log-Datei gefunden" -ForegroundColor Red
                }
            }
            "2" {
                $logs = Get-ChildItem -Path $script:LogPath -Filter "ChillTweak_*.log" | 
                        Sort-Object LastWriteTime -Descending
                
                Write-Host "`nGefundene Log-Dateien:" -ForegroundColor $script:secondaryColor
                $i = 1
                foreach ($log in $logs) {
                    $size = [math]::Round($log.Length / 1KB, 2)
                    Write-Host "[$i] $($log.Name) - $size KB - $($log.LastWriteTime)" -ForegroundColor $script:secondaryColor
                    $i++
                }
                
                Write-Host "`nLog-Nummer zum Öffnen eingeben (oder Enter zum Abbrechen): " -ForegroundColor Yellow -NoNewline
                $logChoice = Read-Host
                
                if ($logChoice -match '^\d+$') {
                    $index = [int]$logChoice - 1
                    if ($index -ge 0 -and $index -lt $logs.Count) {
                        Start-Process notepad.exe -ArgumentList $logs[$index].FullName
                    }
                }
            }
            "3" {
                Start-Process explorer.exe -ArgumentList $script:LogPath
            }
            "4" {
                Write-Host "`n[!] WARNUNG: Dies löscht alle Log-Dateien!" -ForegroundColor Red
                $confirm = Read-Host "Wirklich fortfahren? (J/N)"
                
                if ($confirm -eq "J") {
                    Get-ChildItem -Path $script:LogPath -Filter "ChillTweak_*.log" | 
                        Where-Object { $_.FullName -ne $script:CurrentLogFile } | 
                        Remove-Item -Force
                    
                    Write-Host "[+] Alte Logs wurden gelöscht" -ForegroundColor Green
                }
            }
            "Q" { return }
            default { Write-Host "[!] Ungültige Eingabe" -ForegroundColor Red }
        }
    }
    catch {
        Write-Host "[!] Fehler beim Anzeigen der Logs: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Log-Wrapper-Funktionen für verschiedene Operationen
function Write-RegistryChangeLog {
    param(
        [string]$Path,
        [string]$Name,
        [string]$OldValue,
        [string]$NewValue
    )
    Write-LogEntry "Registry geändert: $Path\$Name von '$OldValue' zu '$NewValue'" -Level "INFO" -Category "Registry"
}

function Write-ServiceChangeLog {
    param(
        [string]$ServiceName,
        [string]$Action,
        [string]$OldState,
        [string]$NewState
    )
    Write-LogEntry "Dienst '$ServiceName' $Action - Status: $OldState -> $NewState" -Level "INFO" -Category "Services"
}

function Write-OptimizationLog {
    param(
        [string]$OptimizationType,
        [string]$Details
    )
    Write-LogEntry "Optimierung: $OptimizationType - $Details" -Level "SUCCESS" -Category "Optimization"
}

function Write-ErrorLog {
    param(
        [string]$Operation,
        [string]$ErrorMessage
    )
    Write-LogEntry "Fehler bei $Operation: $ErrorMessage" -Level "ERROR" -Category "Error"
}

function Write-NetworkChangeLog {
    param(
        [string]$Setting,
        [string]$OldValue,
        [string]$NewValue
    )
    Write-LogEntry "Netzwerk-Einstellung geändert: $Setting von '$OldValue' zu '$NewValue'" -Level "INFO" -Category "Network"
}

function Write-DiskOperationLog {
    param(
        [string]$Operation,
        [string]$Target,
        [string]$Result
    )
    Write-LogEntry "Disk-Operation: $Operation auf $Target - $Result" -Level "INFO" -Category "Disk"
}

function Write-BackupLog {
    param(
        [string]$BackupPath,
        [string]$Status
    )
    Write-LogEntry "Backup erstellt: $BackupPath - Status: $Status" -Level "SUCCESS" -Category "Backup"
}

function Write-SoftwareInstallLog {
    param(
        [string]$SoftwareName,
        [string]$Status
    )
    Write-LogEntry "Software '$SoftwareName' installiert - Status: $Status" -Level "INFO" -Category "Software"
}

# Export Log-Zusammenfassung
function Export-LogSummary {
    try {
        Write-Host "`n[*] Erstelle Log-Zusammenfassung..." -ForegroundColor $script:secondaryColor
        
        $summaryPath = "$env:USERPROFILE\Documents\ChillTweak_LogSummary_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt"
        
        # Analysiere alle Log-Dateien
        $logs = Get-ChildItem -Path $script:LogPath -Filter "ChillTweak_*.log"
        
        $summary = @"
╔══════════════════════════════════════════════════════════════╗
║           ChillTweak Log Summary                             ║
║           Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')                  ║
╚══════════════════════════════════════════════════════════════╝

Total Log Files: $($logs.Count)
Total Log Size: $([math]::Round(($logs | Measure-Object -Property Length -Sum).Sum / 1MB, 2)) MB

=== Log Files ===
"@
        
        foreach ($log in $logs | Sort-Object LastWriteTime -Descending) {
            $summary += "`n$($log.Name) - $($log.LastWriteTime) - $([math]::Round($log.Length / 1KB, 2)) KB"
        }
        
        # Analysiere Fehler
        $summary += "`n`n=== Error Summary ===`n"
        $allErrors = @()
        foreach ($log in $logs) {
            $content = Get-Content $log.FullName
            $errors = $content | Where-Object { $_ -match '\[ERROR\]' }
            $allErrors += $errors
        }
        
        if ($allErrors.Count -gt 0) {
            $summary += "`nTotal Errors: $($allErrors.Count)`n"
            $summary += "`nRecent Errors (Last 10):`n"
            $allErrors | Select-Object -Last 10 | ForEach-Object {
                $summary += "$_`n"
            }
        }
        else {
            $summary += "`nNo errors found.`n"
        }
        
        # Analysiere Erfolgreiche Operationen
        $summary += "`n=== Success Summary ===`n"
        $allSuccess = @()
        foreach ($log in $logs) {
            $content = Get-Content $log.FullName
            $success = $content | Where-Object { $_ -match '\[SUCCESS\]' }
            $allSuccess += $success
        }
        
        $summary += "Total Successful Operations: $($allSuccess.Count)`n"
        
        $summary | Out-File -FilePath $summaryPath -Encoding UTF8
        
        Write-Host "[+] Log-Zusammenfassung erstellt: $summaryPath" -ForegroundColor Green
        Write-Host "[*] Öffne Zusammenfassung? (J/N)" -ForegroundColor Yellow
        $open = Read-Host
        if ($open -eq "J") {
            Start-Process notepad.exe -ArgumentList $summaryPath
        }
    }
    catch {
        Write-Host "[!] Fehler beim Erstellen der Log-Zusammenfassung: $($_.Exception.Message)" -ForegroundColor Red
    }
}
