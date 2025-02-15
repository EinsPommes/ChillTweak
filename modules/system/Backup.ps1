# Backup-Funktionen
function Backup-System {
    Write-Host "`n[*] Backup-Assistent wird gestartet..." -ForegroundColor $primaryColor
    try {
        # Backup-Ziel festlegen
        $defaultPath = "$env:USERPROFILE\Documents\chillTweak_Backups"
        $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
        $backupPath = "$defaultPath\Backup_$timestamp"
        
        # Backup-Verzeichnis erstellen
        if (-not (Test-Path $defaultPath)) {
            New-Item -ItemType Directory -Path $defaultPath | Out-Null
        }
        
        # Backup-Menü
        Write-Host "`nWaehle eine Backup-Option:" -ForegroundColor $secondaryColor
        Write-Host "[1] Wichtige Benutzerordner sichern" -ForegroundColor $secondaryColor
        Write-Host "[2] Systemeinstellungen exportieren" -ForegroundColor $secondaryColor
        Write-Host "[3] Vollstaendiges Backup" -ForegroundColor $secondaryColor
        Write-Host "[4]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Zurueck" -ForegroundColor $secondaryColor
        
        $choice = Read-Host "`nWaehle eine Option"
        
        try {
            switch ($choice) {
                "1" { Backup-UserFolders -BackupPath $backupPath }
                "2" { Export-SystemSettings -BackupPath $backupPath }
                "3" { 
                    Backup-UserFolders -BackupPath $backupPath
                    Export-SystemSettings -BackupPath $backupPath
                }
                "4" { return }
                default { Write-Host "`n[!] Ungueltige Eingabe" -ForegroundColor Red }
            }
        }
        catch {
            Write-Host "[!] Fehler bei der Backup-Operation: $_" -ForegroundColor Red
        }
        
        # Backup-Pfad speichern
        $script:LastBackupPath = $backupPath
        Save-Config
        
        # Nach erfolgreichem Backup
        if ($script:LastBackupPath) {
            Protect-BackupData -BackupPath $script:LastBackupPath
        }
    }
    catch {
        Write-Host "[!] Fehler beim Backup: $_" -ForegroundColor Red
    }
}

function Backup-UserFolders {
    param (
        [string]$BackupPath
    )
    Write-Host "[*] Sichere Benutzerordner..." -ForegroundColor $primaryColor
    $folders = @(
        "$env:USERPROFILE\Documents",
        "$env:USERPROFILE\Desktop",
        "$env:USERPROFILE\Pictures",
        "$env:USERPROFILE\Downloads"
    )
    
    foreach ($folder in $folders) {
        $folderName = Split-Path $folder -Leaf
        $destination = "$BackupPath\UserFolders\$folderName"
        Copy-Item -Path $folder -Destination $destination -Recurse -Force
    }
    Write-Host "[✓] Benutzerordner gesichert" -ForegroundColor $secondaryColor
}

function Export-SystemSettings {
    param (
        [string]$BackupPath
    )
    Write-Host "[*] Exportiere Systemeinstellungen..." -ForegroundColor $primaryColor
    # Registry-Exports
    reg export "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" "$BackupPath\Settings\Explorer.reg" /y
    reg export "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" "$BackupPath\Settings\Autostart.reg" /y
    Write-Host "[✓] Systemeinstellungen exportiert" -ForegroundColor $secondaryColor
} 