# Configuration Profiles Module for ChillTweak

function Show-ProfilesMenu {
    try {
        Write-Host "`n=== Konfigurations-Profile ===" -ForegroundColor $script:primaryColor
        Write-Host "Profile wenden vordefinierte Einstellungen auf dein System an." -ForegroundColor $script:secondaryColor
        Write-Host ""
        Write-Host "[1] Gaming-Profil (Maximale Performance)" -ForegroundColor $script:secondaryColor
        Write-Host "[2] Privacy-Profil (Maximaler Datenschutz)" -ForegroundColor $script:secondaryColor
        Write-Host "[3] Performance-Profil (Ausgewogene Performance)" -ForegroundColor $script:secondaryColor
        Write-Host "[4] Balanced-Profil (Standard-Empfehlungen)" -ForegroundColor $script:secondaryColor
        Write-Host "[5] SSD-Optimierungs-Profil" -ForegroundColor $script:secondaryColor
        Write-Host "[6] Aktuelles Profil anzeigen" -ForegroundColor $script:secondaryColor
        Write-Host "[Q] Zurück" -ForegroundColor $script:secondaryColor
        
        $choice = Read-Host "`nWähle ein Profil"
        
        switch ($choice) {
            "1" { Apply-GamingProfile }
            "2" { Apply-PrivacyProfile }
            "3" { Apply-PerformanceProfile }
            "4" { Apply-BalancedProfile }
            "5" { Apply-SSDProfile }
            "6" { Show-CurrentProfile }
            "Q" { return }
            default { Write-Host "[!] Ungültige Eingabe" -ForegroundColor Red }
        }
        
        if ($choice -ne "Q" -and $choice -ne "6") {
            Write-Host "`n[!] WICHTIG: Bitte starte deinen Computer neu, damit alle Änderungen wirksam werden." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "[!] Fehler im Profil-Menü: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Apply-GamingProfile {
    try {
        Write-Host "`n[*] Wende Gaming-Profil an..." -ForegroundColor $script:primaryColor
        Write-LogEntry "Starte Anwendung des Gaming-Profils" -Level "INFO" -Category "Profiles"
        
        # Erstelle Wiederherstellungspunkt
        Write-Host "[*] Erstelle Wiederherstellungspunkt..." -ForegroundColor $script:secondaryColor
        if (Get-Command New-RestorePoint -ErrorAction SilentlyContinue) {
            New-RestorePoint -Description "ChillTweak Gaming-Profil"
        }
        
        # 1. Energieplan auf Höchstleistung
        Write-Host "[*] Setze Energieplan auf Höchstleistung..." -ForegroundColor $script:secondaryColor
        powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        powercfg /change standby-timeout-ac 0
        powercfg /change monitor-timeout-ac 0
        Write-Host "[+] Energieplan optimiert" -ForegroundColor Green
        
        # 2. Game Mode aktivieren
        Write-Host "[*] Aktiviere Game Mode..." -ForegroundColor $script:secondaryColor
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1 -Force
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 1 -Force
        Write-Host "[+] Game Mode aktiviert" -ForegroundColor Green
        
        # 3. Deaktiviere Game DVR
        Write-Host "[*] Deaktiviere Game DVR..." -ForegroundColor $script:secondaryColor
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Force
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Force
        Write-Host "[+] Game DVR deaktiviert" -ForegroundColor Green
        
        # 4. Optimiere CPU-Priorität für Spiele
        Write-Host "[*] Optimiere CPU-Priorität..." -ForegroundColor $script:secondaryColor
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Force
        Write-Host "[+] CPU-Priorität optimiert" -ForegroundColor Green
        
        # 5. Netzwerk-Optimierungen für Gaming
        Write-Host "[*] Optimiere Netzwerk für Gaming..." -ForegroundColor $script:secondaryColor
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 4294967295 -Force
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Force
        
        # Nagle Algorithm deaktivieren
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
        Get-ChildItem $regPath | ForEach-Object {
            Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        }
        Write-Host "[+] Netzwerk optimiert" -ForegroundColor Green
        
        # 6. Deaktiviere unnötige Dienste
        Write-Host "[*] Deaktiviere unnötige Dienste..." -ForegroundColor $script:secondaryColor
        $servicesToDisable = @("SysMain", "WSearch", "DiagTrack")
        foreach ($service in $servicesToDisable) {
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
        }
        Write-Host "[+] Dienste deaktiviert" -ForegroundColor Green
        
        # 7. Visuelle Effekte minimieren
        Write-Host "[*] Minimiere visuelle Effekte..." -ForegroundColor $script:secondaryColor
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force
        Write-Host "[+] Visuelle Effekte minimiert" -ForegroundColor Green
        
        # 8. GPU Scheduling aktivieren (Windows 10 2004+)
        Write-Host "[*] Aktiviere Hardware-beschleunigte GPU-Planung..." -ForegroundColor $script:secondaryColor
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Force
        Write-Host "[+] GPU-Planung aktiviert" -ForegroundColor Green
        
        Write-Host "`n[+] Gaming-Profil erfolgreich angewendet!" -ForegroundColor Green
        Write-LogEntry "Gaming-Profil erfolgreich angewendet" -Level "SUCCESS" -Category "Profiles"
        
        # Speichere Profil-Info
        if (-not (Test-Path "HKCU:\Software\ChillTweak")) {
            New-Item -Path "HKCU:\Software\ChillTweak" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\Software\ChillTweak" -Name "ActiveProfile" -Value "Gaming" -Force
    }
    catch {
        Write-Host "[!] Fehler beim Anwenden des Gaming-Profils: $($_.Exception.Message)" -ForegroundColor Red
        Write-LogEntry "Fehler beim Anwenden des Gaming-Profils: $($_.Exception.Message)" -Level "ERROR" -Category "Profiles"
    }
}

function Apply-PrivacyProfile {
    try {
        Write-Host "`n[*] Wende Privacy-Profil an..." -ForegroundColor $script:primaryColor
        Write-LogEntry "Starte Anwendung des Privacy-Profils" -Level "INFO" -Category "Profiles"
        
        # Erstelle Wiederherstellungspunkt
        if (Get-Command New-RestorePoint -ErrorAction SilentlyContinue) {
            New-RestorePoint -Description "ChillTweak Privacy-Profil"
        }
        
        # 1. Telemetrie komplett deaktivieren
        Write-Host "[*] Deaktiviere Telemetrie..." -ForegroundColor $script:secondaryColor
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Force
        Write-Host "[+] Telemetrie deaktiviert" -ForegroundColor Green
        
        # 2. Cortana deaktivieren
        Write-Host "[*] Deaktiviere Cortana..." -ForegroundColor $script:secondaryColor
        if (-not (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search")) {
            New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0 -Force
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Force
        Write-Host "[+] Cortana deaktiviert" -ForegroundColor Green
        
        # 3. Web-Suche im Startmenü deaktivieren
        Write-Host "[*] Deaktiviere Web-Suche..." -ForegroundColor $script:secondaryColor
        if (-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1 -Force
        Write-Host "[+] Web-Suche deaktiviert" -ForegroundColor Green
        
        # 4. Deaktiviere Werbung und Tracking
        Write-Host "[*] Deaktiviere Werbung..." -ForegroundColor $script:secondaryColor
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Value 0 -Force
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Value 0 -Force
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0 -Force
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Value 0 -Force
        Write-Host "[+] Werbung deaktiviert" -ForegroundColor Green
        
        # 5. Deaktiviere Aktivitätsverlauf
        Write-Host "[*] Deaktiviere Aktivitätsverlauf..." -ForegroundColor $script:secondaryColor
        if (-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -Force
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -Force
        Write-Host "[+] Aktivitätsverlauf deaktiviert" -ForegroundColor Green
        
        # 6. Standortverfolgung deaktivieren
        Write-Host "[*] Deaktiviere Standortverfolgung..." -ForegroundColor $script:secondaryColor
        if (-not (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location")) {
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny" -Force
        Write-Host "[+] Standortverfolgung deaktiviert" -ForegroundColor Green
        
        # 7. Deaktiviere Telemetrie-Dienste
        Write-Host "[*] Deaktiviere Telemetrie-Dienste..." -ForegroundColor $script:secondaryColor
        $services = @("DiagTrack", "dmwappushservice", "RemoteRegistry")
        foreach ($service in $services) {
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
        }
        Write-Host "[+] Telemetrie-Dienste deaktiviert" -ForegroundColor Green
        
        # 8. Windows Defender Privacy Settings
        Write-Host "[*] Optimiere Windows Defender Datenschutz..." -ForegroundColor $script:secondaryColor
        Set-MpPreference -MAPSReporting Disabled -ErrorAction SilentlyContinue
        Set-MpPreference -SubmitSamplesConsent NeverSend -ErrorAction SilentlyContinue
        Write-Host "[+] Windows Defender Datenschutz optimiert" -ForegroundColor Green
        
        Write-Host "`n[+] Privacy-Profil erfolgreich angewendet!" -ForegroundColor Green
        Write-LogEntry "Privacy-Profil erfolgreich angewendet" -Level "SUCCESS" -Category "Profiles"
        
        if (-not (Test-Path "HKCU:\Software\ChillTweak")) {
            New-Item -Path "HKCU:\Software\ChillTweak" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\Software\ChillTweak" -Name "ActiveProfile" -Value "Privacy" -Force
    }
    catch {
        Write-Host "[!] Fehler beim Anwenden des Privacy-Profils: $($_.Exception.Message)" -ForegroundColor Red
        Write-LogEntry "Fehler beim Anwenden des Privacy-Profils: $($_.Exception.Message)" -Level "ERROR" -Category "Profiles"
    }
}

function Apply-PerformanceProfile {
    try {
        Write-Host "`n[*] Wende Performance-Profil an..." -ForegroundColor $script:primaryColor
        Write-LogEntry "Starte Anwendung des Performance-Profils" -Level "INFO" -Category "Profiles"
        
        if (Get-Command New-RestorePoint -ErrorAction SilentlyContinue) {
            New-RestorePoint -Description "ChillTweak Performance-Profil"
        }
        
        # 1. Energieplan optimieren
        Write-Host "[*] Optimiere Energieplan..." -ForegroundColor $script:secondaryColor
        powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        Write-Host "[+] Energieplan optimiert" -ForegroundColor Green
        
        # 2. Visuelle Effekte für beste Performance
        Write-Host "[*] Optimiere visuelle Effekte..." -ForegroundColor $script:secondaryColor
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force
        Write-Host "[+] Visuelle Effekte optimiert" -ForegroundColor Green
        
        # 3. Deaktiviere unnötige Dienste
        Write-Host "[*] Optimiere Dienste..." -ForegroundColor $script:secondaryColor
        $services = @("SysMain", "WSearch")
        foreach ($service in $services) {
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
        }
        Write-Host "[+] Dienste optimiert" -ForegroundColor Green
        
        # 4. Netzwerk optimieren
        Write-Host "[*] Optimiere Netzwerk..." -ForegroundColor $script:secondaryColor
        netsh interface tcp set global autotuninglevel=normal
        netsh interface tcp set global chimney=enabled
        Write-Host "[+] Netzwerk optimiert" -ForegroundColor Green
        
        Write-Host "`n[+] Performance-Profil erfolgreich angewendet!" -ForegroundColor Green
        Write-LogEntry "Performance-Profil erfolgreich angewendet" -Level "SUCCESS" -Category "Profiles"
        
        if (-not (Test-Path "HKCU:\Software\ChillTweak")) {
            New-Item -Path "HKCU:\Software\ChillTweak" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\Software\ChillTweak" -Name "ActiveProfile" -Value "Performance" -Force
    }
    catch {
        Write-Host "[!] Fehler beim Anwenden des Performance-Profils: $($_.Exception.Message)" -ForegroundColor Red
        Write-LogEntry "Fehler: $($_.Exception.Message)" -Level "ERROR" -Category "Profiles"
    }
}

function Apply-BalancedProfile {
    try {
        Write-Host "`n[*] Wende Balanced-Profil an..." -ForegroundColor $script:primaryColor
        Write-LogEntry "Starte Anwendung des Balanced-Profils" -Level "INFO" -Category "Profiles"
        
        if (Get-Command New-RestorePoint -ErrorAction SilentlyContinue) {
            New-RestorePoint -Description "ChillTweak Balanced-Profil"
        }
        
        # Balanced = Standard Windows-Empfehlungen mit minimalen Optimierungen
        Write-Host "[*] Setze Standard-Energieplan..." -ForegroundColor $script:secondaryColor
        powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e
        Write-Host "[+] Energieplan gesetzt" -ForegroundColor Green
        
        Write-Host "[*] Aktiviere empfohlene Dienste..." -ForegroundColor $script:secondaryColor
        Set-Service -Name "SysMain" -StartupType Automatic -ErrorAction SilentlyContinue
        Start-Service -Name "SysMain" -ErrorAction SilentlyContinue
        Write-Host "[+] Dienste aktiviert" -ForegroundColor Green
        
        Write-Host "`n[+] Balanced-Profil erfolgreich angewendet!" -ForegroundColor Green
        Write-LogEntry "Balanced-Profil erfolgreich angewendet" -Level "SUCCESS" -Category "Profiles"
        
        if (-not (Test-Path "HKCU:\Software\ChillTweak")) {
            New-Item -Path "HKCU:\Software\ChillTweak" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\Software\ChillTweak" -Name "ActiveProfile" -Value "Balanced" -Force
    }
    catch {
        Write-Host "[!] Fehler beim Anwenden des Balanced-Profils: $($_.Exception.Message)" -ForegroundColor Red
        Write-LogEntry "Fehler: $($_.Exception.Message)" -Level "ERROR" -Category "Profiles"
    }
}

function Apply-SSDProfile {
    try {
        Write-Host "`n[*] Wende SSD-Optimierungs-Profil an..." -ForegroundColor $script:primaryColor
        Write-LogEntry "Starte Anwendung des SSD-Profils" -Level "INFO" -Category "Profiles"
        
        # Prüfe ob SSDs vorhanden sind
        $ssds = Get-PhysicalDisk | Where-Object {$_.MediaType -eq 'SSD'}
        if ($ssds.Count -eq 0) {
            Write-Host "[!] Keine SSDs gefunden!" -ForegroundColor Red
            return
        }
        
        if (Get-Command New-RestorePoint -ErrorAction SilentlyContinue) {
            New-RestorePoint -Description "ChillTweak SSD-Profil"
        }
        
        Write-Host "[*] TRIM aktivieren..." -ForegroundColor $script:secondaryColor
        fsutil behavior set DisableDeleteNotify 0
        Write-Host "[+] TRIM aktiviert" -ForegroundColor Green
        
        Write-Host "[*] Deaktiviere Superfetch für SSD..." -ForegroundColor $script:secondaryColor
        Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "[+] Superfetch deaktiviert" -ForegroundColor Green
        
        Write-Host "[*] Deaktiviere Prefetch für SSD..." -ForegroundColor $script:secondaryColor
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnablePrefetcher" -Value 0 -Force
        Write-Host "[+] Prefetch deaktiviert" -ForegroundColor Green
        
        Write-Host "`n[+] SSD-Profil erfolgreich angewendet!" -ForegroundColor Green
        Write-LogEntry "SSD-Profil erfolgreich angewendet" -Level "SUCCESS" -Category "Profiles"
        
        if (-not (Test-Path "HKCU:\Software\ChillTweak")) {
            New-Item -Path "HKCU:\Software\ChillTweak" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\Software\ChillTweak" -Name "ActiveProfile" -Value "SSD" -Force
    }
    catch {
        Write-Host "[!] Fehler beim Anwenden des SSD-Profils: $($_.Exception.Message)" -ForegroundColor Red
        Write-LogEntry "Fehler: $($_.Exception.Message)" -Level "ERROR" -Category "Profiles"
    }
}

function Show-CurrentProfile {
    try {
        Write-Host "`n=== Aktuelles Profil ===" -ForegroundColor $script:primaryColor
        
        if (-not (Test-Path "HKCU:\Software\ChillTweak")) {
            New-Item -Path "HKCU:\Software\ChillTweak" -Force | Out-Null
        }
        
        $currentProfile = Get-ItemProperty -Path "HKCU:\Software\ChillTweak" -Name "ActiveProfile" -ErrorAction SilentlyContinue
        
        if ($currentProfile) {
            Write-Host "Aktives Profil: $($currentProfile.ActiveProfile)" -ForegroundColor Green
        }
        else {
            Write-Host "Kein Profil aktiv (Standard-Konfiguration)" -ForegroundColor Yellow
        }
        
        Write-Host "`nDrücke eine beliebige Taste um fortzufahren..." -ForegroundColor $script:secondaryColor
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    catch {
        Write-Host "[!] Fehler beim Anzeigen des aktuellen Profils: $($_.Exception.Message)" -ForegroundColor Red
    }
}
