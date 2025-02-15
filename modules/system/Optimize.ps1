# System-Optimierungsfunktionen
function Optimize-System {
    try {
        Write-Host "`n[+] Starte Systemoptimierung..." -ForegroundColor $script:primaryColor
        
        # PowerPlan optimieren
        if ($script:PerformanceSettings.PowerPlan -eq "High") {
            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
            Write-Host "[+] Hoechstleistungs-Energieplan aktiviert" -ForegroundColor Green
        }
        
        # GameMode aktivieren
        if ($script:PerformanceSettings.GameMode) {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1
            Write-Host "[+] Windows GameMode aktiviert" -ForegroundColor Green
        }
        
        # Visuelle Effekte anpassen
        if ($script:PerformanceSettings.VisualEffects -eq "Custom") {
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 3
            Write-Host "[+] Visuelle Effekte optimiert" -ForegroundColor Green
        }
        
        Write-Host "[+] Systemoptimierung abgeschlossen" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler bei der Systemoptimierung" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Optimize-PowerPlan {
    Write-Host "`n[*] Optimiere Energieplan..." -ForegroundColor $script:primaryColor
    try {
        # Hoechstleistung aktivieren
        powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        
        # Energiesparplan anpassen
        powercfg /change monitor-timeout-ac 15
        powercfg /change disk-timeout-ac 0
        powercfg /change standby-timeout-ac 0
        powercfg /change hibernate-timeout-ac 0
        
        Write-Host "[+] Energieplan optimiert" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der Energieplan-Optimierung: $_" -ForegroundColor Red
    }
}

function Set-Autostart {
    Write-Host "`n[*] Verwalte Autostart-Programme..." -ForegroundColor $script:primaryColor
    try {
        # Autostart-Eintraege auflisten
        $autostart = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        
        Write-Host "`nAktuelle Autostart-Programme:" -ForegroundColor $script:secondaryColor
        $i = 1
        $programs = @()
        $autostart.PSObject.Properties | Where-Object { $_.Name -notlike "PS*" } | ForEach-Object {
            Write-Host "[$i] $($_.Name)" -ForegroundColor $script:secondaryColor
            $programs += $_.Name
            $i++
        }
        
        Write-Host "`n[D] Programm deaktivieren" -ForegroundColor $script:secondaryColor
        Write-Host "[Z] Zurueck" -ForegroundColor $script:secondaryColor
        
        $choice = Read-Host "`nWaehle eine Option"
        
        if ($choice -eq "Z") { return }
        if ($choice -eq "D") {
            $programIndex = [int](Read-Host "Nummer des zu deaktivierenden Programms") - 1
            if ($programIndex -ge 0 -and $programIndex -lt $programs.Count) {
                $programName = $programs[$programIndex]
                Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $programName
                Write-Host "[+] Programm '$programName' aus Autostart entfernt" -ForegroundColor $script:secondaryColor
            }
            else {
                Write-Host "[!] Ungueltige Programmnummer" -ForegroundColor Red
            }
        }
    }
    catch {
        Write-Host "[!] Fehler bei der Autostart-Verwaltung: $_" -ForegroundColor Red
    }
}

function Optimize-Services {
    Write-Host "`n[*] Optimiere Windows-Dienste..." -ForegroundColor $script:primaryColor
    try {
        # Unerwuenschte Dienste deaktivieren
        $services = @(
            "DiagTrack",          # Connected User Experiences and Telemetry
            "dmwappushservice",   # WAP Push Message Routing Service
            "SysMain",            # Superfetch
            "WSearch"             # Windows Search
        )
        
        foreach ($service in $services) {
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "[+] Dienst '$service' deaktiviert" -ForegroundColor $script:secondaryColor
        }
    }
    catch {
        Write-Host "[!] Fehler bei der Dienste-Optimierung: $_" -ForegroundColor Red
    }
}

function Optimize-Gaming {
    Write-Host "`n[*] Optimiere System fuer Gaming..." -ForegroundColor $script:primaryColor
    try {
        # Game Mode aktivieren
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 1
        
        # Visuelle Effekte optimieren
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
        
        Write-Host "[+] Gaming-Optimierungen abgeschlossen" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der Gaming-Optimierung: $_" -ForegroundColor Red
    }
}

function Optimize-RAM {
    Write-Host "`n[*] Optimiere RAM-Nutzung..." -ForegroundColor $script:primaryColor
    try {
        # Pagefile optimieren
        $computersys = Get-WmiObject Win32_ComputerSystem
        $computersys.AutomaticManagedPagefile = $False
        $computersys.Put()
        
        $pagefile = Get-WmiObject Win32_PageFileSetting
        $pagefile.InitialSize = 8192  # 8 GB
        $pagefile.MaximumSize = 16384 # 16 GB
        $pagefile.Put()
        
        Write-Host "[+] RAM-Optimierung abgeschlossen" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der RAM-Optimierung: $_" -ForegroundColor Red
    }
}