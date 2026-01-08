# Backup functions
function Backup-System {
    param(
        [string]$BackupPath = $script:BackupSettings.DefaultPath
    )
    
    try {
        Write-Host "`n[*] Creating system backup..." -ForegroundColor $script:primaryColor
        
        # Create backup directory
        if (-not (Test-Path $BackupPath)) {
            New-Item -Path $BackupPath -ItemType Directory -Force | Out-Null
            Write-Host "[+] Backup directory created: $BackupPath" -ForegroundColor $script:secondaryColor
        }
        
        # Timestamp for backup name
        $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
        $backupFile = Join-Path $BackupPath "ChillTweak_Backup_$timestamp.zip"
        
        # Backup important system folders and files
        $sourcePaths = @(
            "$env:USERPROFILE\Documents",
            "$env:USERPROFILE\Desktop",
            "$env:USERPROFILE\Pictures",
            "$env:APPDATA\Microsoft\Windows\Start Menu\Programs",
            "$env:LOCALAPPDATA\Microsoft\Windows\WinX"
        )
        
        # Create backup
        Compress-Archive -Path $sourcePaths -DestinationPath $backupFile -Force
        
        # Encrypt backup if enabled
        if ($script:BackupSettings.Encryption) {
            try {
                Protect-BackupData -BackupPath $BackupPath
                Write-Host "[+] Backup encrypted" -ForegroundColor $script:secondaryColor
            }
            catch {
                Write-Host "[!] Error during backup encryption" -ForegroundColor Yellow
                Write-Host $_.Exception.Message -ForegroundColor Yellow
            }
        }
        
        # Clean old backups
        Clean-OldBackups -BackupPath $BackupPath
        
        $script:LastBackupPath = $backupFile
        Write-Host "[+] System backup created: $backupFile" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Error during system backup" -ForegroundColor Red
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
                Write-Host "[+] Old backup removed: $($backup.Name)" -ForegroundColor $script:secondaryColor
            }
        }
    }
    catch {
        Write-Host "[!] Error cleaning old backups" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Export-SystemSettings {
    try {
        Write-Host "`n[*] Exporting system settings..." -ForegroundColor $script:primaryColor
        
        # Export registry settings
        $regBackupPath = Join-Path $script:BackupSettings.DefaultPath "registry_backup.reg"
        reg export "HKCU\Software\Microsoft\Windows\CurrentVersion" $regBackupPath /y | Out-Null
        
        # Export Windows settings
        $winSettingsPath = Join-Path $script:BackupSettings.DefaultPath "windows_settings.txt"
        Get-ComputerInfo | Out-File $winSettingsPath
        
        Write-Host "[+] System settings exported" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Error exporting system settings" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}