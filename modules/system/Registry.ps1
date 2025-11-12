# Registry Tweaks Module for ChillTweak

# Erstelle Systemwiederherstellungspunkt vor Änderungen
function New-RestorePoint {
    param(
        [string]$Description = "ChillTweak Änderungen"
    )
    try {
        Write-Host "[*] Erstelle Systemwiederherstellungspunkt..." -ForegroundColor $script:secondaryColor
        
        # Aktiviere Systemwiederherstellung falls deaktiviert
        Enable-ComputerRestore -Drive "C:\"
        
        # Erstelle Wiederherstellungspunkt
        Checkpoint-Computer -Description $Description -RestorePointType "MODIFY_SETTINGS"
        Write-Host "[+] Wiederherstellungspunkt erstellt: $Description" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler beim Erstellen des Wiederherstellungspunkts: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Windows Explorer Optimierungen
function Optimize-WindowsExplorer {
    try {
        Write-Host "`n[*] Optimiere Windows Explorer..." -ForegroundColor $script:primaryColor
        
        # Erstelle Wiederherstellungspunkt
        New-RestorePoint -Description "ChillTweak Explorer Optimierung"
        
        # Zeige versteckte Dateien und Ordner
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1
        Write-Host "[+] Versteckte Dateien werden angezeigt" -ForegroundColor Green
        
        # Zeige Dateiendungen
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
        Write-Host "[+] Dateiendungen werden angezeigt" -ForegroundColor Green
        
        # Zeige vollständigen Pfad in Titelleiste
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Name "FullPath" -Value 1 -Force
        Write-Host "[+] Vollständiger Pfad in Titelleiste aktiviert" -ForegroundColor Green
        
        # Öffne Explorer mit "Dieser PC" statt Quick Access
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1
        Write-Host "[+] Explorer startet mit 'Dieser PC'" -ForegroundColor Green
        
        # Deaktiviere zuletzt verwendete Dateien im Quick Access
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Value 0
        Write-Host "[+] Quick Access Historie deaktiviert" -ForegroundColor Green
        
        # Aktiviere Checkboxen für Dateiauswahl
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AutoCheckSelect" -Value 1
        Write-Host "[+] Checkboxen für Dateiauswahl aktiviert" -ForegroundColor Green
        
        # Zeige geschützte Systemdateien
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSuperHidden" -Value 1
        Write-Host "[+] Geschützte Systemdateien werden angezeigt" -ForegroundColor Green
        
        # Explorer neu starten
        Stop-Process -Name "explorer" -Force
        Write-Host "[+] Windows Explorer wurde neu gestartet" -ForegroundColor Green
        
        Write-Host "`n[+] Windows Explorer Optimierung abgeschlossen!" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler bei der Explorer-Optimierung: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Taskleiste optimieren
function Optimize-Taskbar {
    try {
        Write-Host "`n[*] Optimiere Taskleiste..." -ForegroundColor $script:primaryColor
        
        # Erstelle Wiederherstellungspunkt
        New-RestorePoint -Description "ChillTweak Taskleisten-Optimierung"
        
        # Deaktiviere Task-Ansicht Button
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0
        Write-Host "[+] Task-Ansicht Button ausgeblendet" -ForegroundColor Green
        
        # Deaktiviere Personen Button
        if (-not (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
            New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name "PeopleBand" -Value 0
        Write-Host "[+] Personen Button ausgeblendet" -ForegroundColor Green
        
        # Deaktiviere Cortana Button
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCortanaButton" -Value 0 -ErrorAction SilentlyContinue
        Write-Host "[+] Cortana Button ausgeblendet" -ForegroundColor Green
        
        # Nie Taskleisten-Buttons kombinieren
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarGlomLevel" -Value 2
        Write-Host "[+] Taskleisten-Buttons werden nicht kombiniert" -ForegroundColor Green
        
        # Kleine Taskleisten-Symbole
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSmallIcons" -Value 1
        Write-Host "[+] Kleine Taskleisten-Symbole aktiviert" -ForegroundColor Green
        
        # Explorer neu starten
        Stop-Process -Name "explorer" -Force
        Write-Host "[+] Taskleiste wurde aktualisiert" -ForegroundColor Green
        
        Write-Host "`n[+] Taskleisten-Optimierung abgeschlossen!" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler bei der Taskleisten-Optimierung: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Startmenü optimieren
function Optimize-StartMenu {
    try {
        Write-Host "`n[*] Optimiere Startmenü..." -ForegroundColor $script:primaryColor
        
        # Erstelle Wiederherstellungspunkt
        New-RestorePoint -Description "ChillTweak Startmenü-Optimierung"
        
        # Deaktiviere App-Vorschläge
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Value 0
        Write-Host "[+] App-Vorschläge deaktiviert" -ForegroundColor Green
        
        # Deaktiviere häufig verwendete Apps
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Value 0
        Write-Host "[+] Tracking häufig verwendeter Apps deaktiviert" -ForegroundColor Green
        
        # Zeige mehr Kacheln
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_Layout" -Value 1 -ErrorAction SilentlyContinue
        Write-Host "[+] Startmenü Layout optimiert" -ForegroundColor Green
        
        # Explorer neu starten
        Stop-Process -Name "explorer" -Force
        Write-Host "[+] Startmenü wurde aktualisiert" -ForegroundColor Green
        
        Write-Host "`n[+] Startmenü-Optimierung abgeschlossen!" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler bei der Startmenü-Optimierung: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Kontextmenü optimieren
function Optimize-ContextMenu {
    try {
        Write-Host "`n[*] Optimiere Kontextmenü..." -ForegroundColor $script:primaryColor
        
        # Erstelle Wiederherstellungspunkt
        New-RestorePoint -Description "ChillTweak Kontextmenü-Optimierung"
        
        Write-Host "`nKontextmenü-Optionen:" -ForegroundColor $script:secondaryColor
        Write-Host "[1] 'Kopieren nach' und 'Verschieben nach' hinzufügen" -ForegroundColor $script:secondaryColor
        Write-Host "[2] 'Eingabeaufforderung hier öffnen' hinzufügen" -ForegroundColor $script:secondaryColor
        Write-Host "[3] 'PowerShell hier öffnen' hinzufügen" -ForegroundColor $script:secondaryColor
        Write-Host "[4] 'In neuem Fenster öffnen' entfernen" -ForegroundColor $script:secondaryColor
        Write-Host "[5] Alle Optimierungen anwenden" -ForegroundColor $script:secondaryColor
        Write-Host "[Q] Zurück" -ForegroundColor $script:secondaryColor
        
        $choice = Read-Host "`nWähle eine Option"
        
        switch ($choice) {
            "1" {
                # Füge 'Kopieren nach' und 'Verschieben nach' hinzu
                New-Item -Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\Copy To" -Force | Out-Null
                Set-ItemProperty -Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\Copy To" -Name "(default)" -Value "{C2FBB630-2971-11D1-A18C-00C04FD75D13}"
                
                New-Item -Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\Move To" -Force | Out-Null
                Set-ItemProperty -Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\Move To" -Name "(default)" -Value "{C2FBB631-2971-11D1-A18C-00C04FD75D13}"
                
                Write-Host "[+] 'Kopieren nach' und 'Verschieben nach' hinzugefügt" -ForegroundColor Green
            }
            "2" {
                # Füge 'Eingabeaufforderung hier öffnen' hinzu
                New-Item -Path "HKCR:\Directory\shell\cmd2" -Force | Out-Null
                Set-ItemProperty -Path "HKCR:\Directory\shell\cmd2" -Name "(default)" -Value "Eingabeaufforderung hier öffnen"
                Set-ItemProperty -Path "HKCR:\Directory\shell\cmd2" -Name "Icon" -Value "cmd.exe"
                
                New-Item -Path "HKCR:\Directory\shell\cmd2\command" -Force | Out-Null
                Set-ItemProperty -Path "HKCR:\Directory\shell\cmd2\command" -Name "(default)" -Value 'cmd.exe /s /k pushd "%V"'
                
                Write-Host "[+] 'Eingabeaufforderung hier öffnen' hinzugefügt" -ForegroundColor Green
            }
            "3" {
                # Füge 'PowerShell hier öffnen' hinzu
                New-Item -Path "HKCR:\Directory\shell\powershell2" -Force | Out-Null
                Set-ItemProperty -Path "HKCR:\Directory\shell\powershell2" -Name "(default)" -Value "PowerShell hier öffnen"
                Set-ItemProperty -Path "HKCR:\Directory\shell\powershell2" -Name "Icon" -Value "powershell.exe"
                
                New-Item -Path "HKCR:\Directory\shell\powershell2\command" -Force | Out-Null
                Set-ItemProperty -Path "HKCR:\Directory\shell\powershell2\command" -Name "(default)" -Value 'powershell.exe -NoExit -Command Set-Location -LiteralPath "%V"'
                
                Write-Host "[+] 'PowerShell hier öffnen' hinzugefügt" -ForegroundColor Green
            }
            "5" {
                # Alle Optimierungen
                # Kopieren nach / Verschieben nach
                New-Item -Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\Copy To" -Force | Out-Null
                Set-ItemProperty -Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\Copy To" -Name "(default)" -Value "{C2FBB630-2971-11D1-A18C-00C04FD75D13}"
                New-Item -Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\Move To" -Force | Out-Null
                Set-ItemProperty -Path "HKCR:\AllFilesystemObjects\shellex\ContextMenuHandlers\Move To" -Name "(default)" -Value "{C2FBB631-2971-11D1-A18C-00C04FD75D13}"
                
                # Eingabeaufforderung
                New-Item -Path "HKCR:\Directory\shell\cmd2" -Force | Out-Null
                Set-ItemProperty -Path "HKCR:\Directory\shell\cmd2" -Name "(default)" -Value "Eingabeaufforderung hier öffnen"
                Set-ItemProperty -Path "HKCR:\Directory\shell\cmd2" -Name "Icon" -Value "cmd.exe"
                New-Item -Path "HKCR:\Directory\shell\cmd2\command" -Force | Out-Null
                Set-ItemProperty -Path "HKCR:\Directory\shell\cmd2\command" -Name "(default)" -Value 'cmd.exe /s /k pushd "%V"'
                
                # PowerShell
                New-Item -Path "HKCR:\Directory\shell\powershell2" -Force | Out-Null
                Set-ItemProperty -Path "HKCR:\Directory\shell\powershell2" -Name "(default)" -Value "PowerShell hier öffnen"
                Set-ItemProperty -Path "HKCR:\Directory\shell\powershell2" -Name "Icon" -Value "powershell.exe"
                New-Item -Path "HKCR:\Directory\shell\powershell2\command" -Force | Out-Null
                Set-ItemProperty -Path "HKCR:\Directory\shell\powershell2\command" -Name "(default)" -Value 'powershell.exe -NoExit -Command Set-Location -LiteralPath "%V"'
                
                Write-Host "[+] Alle Kontextmenü-Optimierungen angewendet" -ForegroundColor Green
            }
            "Q" { return }
            default { Write-Host "[!] Ungültige Eingabe" -ForegroundColor Red }
        }
        
        Write-Host "`n[+] Kontextmenü-Optimierung abgeschlossen!" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler bei der Kontextmenü-Optimierung: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Privacy-Tweaks erweitern
function Optimize-PrivacyAdvanced {
    try {
        Write-Host "`n[*] Erweiterte Datenschutz-Optimierung..." -ForegroundColor $script:primaryColor
        
        # Erstelle Wiederherstellungspunkt
        New-RestorePoint -Description "ChillTweak Datenschutz-Optimierung"
        
        # Deaktiviere Cortana
        if (-not (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search")) {
            New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
        Write-Host "[+] Cortana deaktiviert" -ForegroundColor Green
        
        # Deaktiviere Web-Suche in Startmenü
        if (-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
        }
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1
        Write-Host "[+] Web-Suche im Startmenü deaktiviert" -ForegroundColor Green
        
        # Deaktiviere Werbung und Tracking
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0
        Write-Host "[+] Werbung und automatische App-Installation deaktiviert" -ForegroundColor Green
        
        # Deaktiviere Aktivitätsverlauf
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -Force
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -Force
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Value 0 -Force
        Write-Host "[+] Aktivitätsverlauf deaktiviert" -ForegroundColor Green
        
        # Deaktiviere Standortverfolgung
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny" -Force
        Write-Host "[+] Standortverfolgung deaktiviert" -ForegroundColor Green
        
        # Deaktiviere App-Diagnose
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0
        Write-Host "[+] App-Diagnose und personalisierte Erfahrungen deaktiviert" -ForegroundColor Green
        
        Write-Host "`n[+] Erweiterte Datenschutz-Optimierung abgeschlossen!" -ForegroundColor Green
        Write-Host "[!] Bitte starte deinen Computer neu, damit alle Änderungen wirksam werden." -ForegroundColor Yellow
    }
    catch {
        Write-Host "[!] Fehler bei der Datenschutz-Optimierung: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Registry Tweaks Hauptmenü
function Show-RegistryTweaksMenu {
    do {
        Write-Host "`n=== Registry Tweaks ===" -ForegroundColor $script:primaryColor
        Write-Host "[1] Windows Explorer optimieren" -ForegroundColor $script:secondaryColor
        Write-Host "[2] Taskleiste optimieren" -ForegroundColor $script:secondaryColor
        Write-Host "[3] Startmenü optimieren" -ForegroundColor $script:secondaryColor
        Write-Host "[4] Kontextmenü anpassen" -ForegroundColor $script:secondaryColor
        Write-Host "[5] Erweiterte Datenschutz-Tweaks" -ForegroundColor $script:secondaryColor
        Write-Host "[6] Alle Optimierungen anwenden" -ForegroundColor $script:secondaryColor
        Write-Host "[Q] Zurück" -ForegroundColor $script:secondaryColor
        
        $choice = Read-Host "`nWähle eine Option"
        
        switch ($choice) {
            "1" { Optimize-WindowsExplorer }
            "2" { Optimize-Taskbar }
            "3" { Optimize-StartMenu }
            "4" { Optimize-ContextMenu }
            "5" { Optimize-PrivacyAdvanced }
            "6" {
                Optimize-WindowsExplorer
                Optimize-Taskbar
                Optimize-StartMenu
                Optimize-PrivacyAdvanced
                Write-Host "`n[+] Alle Registry-Optimierungen angewendet!" -ForegroundColor Green
            }
            "Q" { return }
            default { Write-Host "[!] Ungültige Eingabe" -ForegroundColor Red }
        }
        
        if ($choice -ne "Q") {
            Write-Host "`nWeiter mit beliebiger Taste..." -ForegroundColor $script:secondaryColor
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    } while ($choice -ne "Q")
}
