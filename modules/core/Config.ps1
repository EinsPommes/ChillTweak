# Konfigurationsfunktionen
function Save-Config {
    param()
    try {
        # Konfiguration erstellen
        $config = @{
            Language = $script:CurrentLanguage
            Theme = @{
                Primary = $script:primaryColor
                Secondary = $script:secondaryColor
            }
            Backup = @{
                DefaultPath = "%USERPROFILE%\Documents\chillTweak_Backups"
                Encryption = $true
                MaxBackups = 5
            }
            Updates = @{
                AutoCheck = $true
                Channel = "stable"
            }
            Performance = @{
                PowerPlan = "High"
                VisualEffects = "Custom"
                GameMode = $true
            }
            Privacy = @{
                DisableTelemetry = $true
                DisableTracking = $true
                BlockAds = $false
            }
            Cleanup = @{
                TempFiles = $true
                RecycleBin = $false
                WindowsLogs = $true
            }
            CustomSoftware = $script:CustomSoftware
            LastBackupPath = $script:LastBackupPath
            LogRotation = @{
                MaxSize = "5MB"
                BackupCount = 5
            }
        }

        # Save configuration
        $config | ConvertTo-Json -Depth 4 | Set-Content $script:ConfigPath -Force -Encoding UTF8
        Write-Host "[+] Configuration saved" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Error saving configuration" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Import-Config {
    param()
    try {
        if (Test-Path $script:ConfigPath) {
            $config = Get-Content $script:ConfigPath -Raw | ConvertFrom-Json
            
            # Basic settings
            $script:CurrentLanguage = $config.Language
            $script:primaryColor = $config.Theme.Primary
            $script:secondaryColor = $config.Theme.Secondary
            
            # Backup settings
            $script:BackupSettings = @{
                DefaultPath = $ExecutionContext.InvokeCommand.ExpandString($config.Backup.DefaultPath)
                Encryption = $config.Backup.Encryption
                MaxBackups = $config.Backup.MaxBackups
            }
            
            # Performance settings
            $script:PerformanceSettings = $config.Performance
            
            # Privacy settings
            $script:PrivacySettings = $config.Privacy
            
            # Cleanup settings
            $script:CleanupSettings = $config.Cleanup
            
            # Update settings
            $script:UpdateSettings = $config.Updates
            
            # Additional settings
            $script:CustomSoftware = $config.CustomSoftware
            $script:LastBackupPath = $config.LastBackupPath
            $script:LogRotation = $config.LogRotation
        }
        else {
            # Create default configuration
            Save-Config
        }
    }
    catch {
        Write-Host "[!] Error loading configuration" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Set-Language {
    Write-Host "`nChoose language:" -ForegroundColor $script:primaryColor
    Write-Host "[1] English" -ForegroundColor $script:secondaryColor
    Write-Host "[2] Deutsch" -ForegroundColor $script:secondaryColor
    
    $choice = Read-Host "`nChoose an option"
    switch ($choice) {
        "1" { $script:CurrentLanguage = "en" }
        "2" { $script:CurrentLanguage = "de" }
        default { Write-Host "[!] Invalid input" -ForegroundColor Red }
    }
}

# Sprachdateien
$script:Translations = @{
    'de' = @{
        'Menu_Title' = 'ChillTweak Menue'
        'Menu_Privacy' = 'Privatsphaere'
        'Menu_Performance' = 'Performance'
        'Menu_Software' = 'Software'
        'Menu_Cleanup' = 'Reinigung'
        'Menu_Backup' = 'Backup'
        'Menu_Services' = 'Windows-Dienste'
        'Menu_Help' = 'Hilfe'
        'Menu_Language' = 'Sprache'
        'Menu_Updates' = 'Updates'
        'Menu_Exit' = 'Beenden'
        'Error_Admin' = 'Dieses Skript benötigt Administratorrechte!'
        'Error_Invalid' = 'Ungültige Eingabe'
        'Status_Loading' = 'Lade...'
        'Status_Done' = 'Fertig'
        'Status_Error' = 'Fehler'
        'Prompt_Continue' = 'Weiter mit beliebiger Taste...'
        'Prompt_Choice' = 'Wähle eine Option'
        'Help_Privacy' = 'Deaktiviert Telemetrie und Tracking'
        'Help_Performance' = 'Optimiert Windows für bessere Leistung'
        'Help_Software' = 'Installiert häufig benötigte Programme'
        'Help_Cleanup' = 'Entfernt temporäre und unnötige Dateien'
        'Help_Backup' = 'Erstellt verschlüsselte Systemsicherungen'
        'Help_Help' = 'Zeigt diese Hilfe an'
        'Help_Language' = 'Ändert die Programmsprache'
        'Help_Updates' = 'Verwaltet Windows Updates'
        'Help_Services' = 'Verwaltet Windows-Dienste'
        'Banner_SystemInfo' = 'System Info'
        'Banner_OS' = 'Betriebssystem'
        'Banner_CPU' = 'Prozessor'
        'Banner_RAM' = 'Arbeitsspeicher'
    }
    'en' = @{
        'Menu_Title' = 'ChillTweak Menu'
        'Menu_Privacy' = 'Privacy'
        'Menu_Performance' = 'Performance'
        'Menu_Software' = 'Software'
        'Menu_Cleanup' = 'Cleanup'
        'Menu_Backup' = 'Backup'
        'Menu_Services' = 'Windows Services'
        'Menu_Help' = 'Help'
        'Menu_Language' = 'Language'
        'Menu_Updates' = 'Updates'
        'Menu_Exit' = 'Exit'
        'Error_Admin' = 'This script requires administrator rights!'
        'Error_Invalid' = 'Invalid input'
        'Status_Loading' = 'Loading...'
        'Status_Done' = 'Done'
        'Status_Error' = 'Error'
        'Prompt_Continue' = 'Press any key to continue...'
        'Prompt_Choice' = 'Choose an option'
        'Help_Privacy' = 'Disables telemetry and tracking'
        'Help_Performance' = 'Optimizes Windows for better performance'
        'Help_Software' = 'Installs commonly needed programs'
        'Help_Cleanup' = 'Removes temporary and unnecessary files'
        'Help_Backup' = 'Creates encrypted system backups'
        'Help_Help' = 'Shows this help'
        'Help_Language' = 'Changes the program language'
        'Help_Updates' = 'Manages Windows Updates'
        'Help_Services' = 'Manages Windows Services'
        'Banner_SystemInfo' = 'System Info'
        'Banner_OS' = 'Operating System'
        'Banner_CPU' = 'Processor'
        'Banner_RAM' = 'Memory'
    }
}

# Hilfsfunktion für Übersetzungen
function Get-Translation {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Key
    )
    try {
        if (-not $script:Translations.ContainsKey($script:CurrentLanguage)) {
            Write-Host "[!] Language '$script:CurrentLanguage' not found, using 'en'" -ForegroundColor Yellow
            $script:CurrentLanguage = "en"
        }
        
        if (-not $script:Translations[$script:CurrentLanguage].ContainsKey($Key)) {
            Write-Host "[!] Translation for '$Key' not found" -ForegroundColor Yellow
            return $Key
        }
        
        return $script:Translations[$script:CurrentLanguage][$Key]
    }
    catch {
        Write-Host "[!] Error loading translation" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        return $Key
    }
}