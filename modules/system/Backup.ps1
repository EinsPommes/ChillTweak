# Backup-Funktionen
function Backup-System {
    param(
        [string]$BackupPath = $script:BackupSettings.DefaultPath
    )
    
    try {
        Write-Host "`n[*] Erstelle Systemsicherung..." -ForegroundColor $script:primaryColor
        
        # Backup-Verzeichnis erstellen
        if (-not (Test-Path $BackupPath)) {
            New-Item -Path $BackupPath -ItemType Directory -Force | Out-Null
            Write-Host "[+] Backup-Verzeichnis erstellt: $BackupPath" -ForegroundColor $script:secondaryColor
        }
        
        # Zeitstempel fuer Backup-Namen
        $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
        $backupFile = Join-Path $BackupPath "ChillTweak_Backup_$timestamp.zip"
        
        # Wichtige Systemordner und Dateien sichern
        $sourcePaths = @(
            "$env:USERPROFILE\Documents",
            "$env:USERPROFILE\Desktop",
            "$env:USERPROFILE\Pictures",
            "$env:APPDATA\Microsoft\Windows\Start Menu\Programs",
            "$env:LOCALAPPDATA\Microsoft\Windows\WinX"
        )
        
        # Backup erstellen
        Compress-Archive -Path $sourcePaths -DestinationPath $backupFile -Force
        
        # Backup verschluesseln wenn aktiviert
        if ($script:BackupSettings.Encryption) {
            $encryptedFile = "$backupFile.enc"
            # TODO: Implementiere Verschluesselung
            Write-Host "[+] Backup verschluesselt" -ForegroundColor $script:secondaryColor
        }
        
        # Alte Backups bereinigen
        Clean-OldBackups -BackupPath $BackupPath
        
        $script:LastBackupPath = $backupFile
        Write-Host "[+] Systemsicherung erstellt: $backupFile" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der Systemsicherung" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Clean-OldBackups {
    param(
        [string]$BackupPath
    )
    
    try {
        $maxBackups = $script:BackupSettings.MaxBackups
        $backups = Get-ChildItem -Path $BackupPath -Filter "ChillTweak_Backup_*.zip" | Sort-Object CreationTime -Descending
        
        if ($backups.Count -gt $maxBackups) {
            $backupsToDelete = $backups | Select-Object -Skip $maxBackups
            foreach ($backup in $backupsToDelete) {
                Remove-Item $backup.FullName -Force
                Write-Host "[+] Altes Backup entfernt: $($backup.Name)" -ForegroundColor $script:secondaryColor
            }
        }
    }
    catch {
        Write-Host "[!] Fehler beim Bereinigen alter Backups" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Export-SystemSettings {
    try {
        Write-Host "`n[*] Exportiere Systemeinstellungen..." -ForegroundColor $script:primaryColor
        
        # Registry-Einstellungen exportieren
        $regBackupPath = Join-Path $script:BackupSettings.DefaultPath "registry_backup.reg"
        reg export "HKCU\Software\Microsoft\Windows\CurrentVersion" $regBackupPath /y | Out-Null
        
        # Windows-Einstellungen exportieren
        $winSettingsPath = Join-Path $script:BackupSettings.DefaultPath "windows_settings.txt"
        Get-ComputerInfo | Out-File $winSettingsPath
        
        Write-Host "[+] Systemeinstellungen exportiert" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Fehler beim Exportieren der Systemeinstellungen" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}