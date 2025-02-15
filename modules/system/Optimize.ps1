# System-Optimierungsfunktionen
function Optimize-System {
    try {
        Write-Host "`n[*] Starte Systemoptimierung..." -ForegroundColor $script:primaryColor
        
        # PowerPlan optimieren
        Write-Host "[*] Optimiere Energieeinstellungen..." -ForegroundColor $script:secondaryColor
        powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        powercfg /change standby-timeout-ac 0
        powercfg /change standby-timeout-dc 0
        powercfg /change monitor-timeout-ac 0
        powercfg /change monitor-timeout-dc 0
        powercfg /change hibernate-timeout-ac 0
        powercfg /change hibernate-timeout-dc 0
        Write-Host "[+] Energieeinstellungen optimiert" -ForegroundColor Green
        
        # GameMode und Game DVR
        Write-Host "[*] Optimiere Gaming-Einstellungen..." -ForegroundColor $script:secondaryColor
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0
        Write-Host "[+] Gaming-Einstellungen optimiert" -ForegroundColor Green
        
        # Visuelle Effekte optimieren
        Write-Host "[*] Optimiere visuelle Effekte..." -ForegroundColor $script:secondaryColor
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
        Write-Host "[+] Visuelle Effekte optimiert" -ForegroundColor Green
        
        # Windows-Dienste optimieren
        Write-Host "[*] Optimiere Windows-Dienste..." -ForegroundColor $script:secondaryColor
        $services = @(
            "SysMain", # Superfetch
            "DiagTrack", # Connected User Experiences and Telemetry
            "WSearch" # Windows Search
        )
        
        foreach ($service in $services) {
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "[+] Dienst '$service' optimiert" -ForegroundColor Green
        }
        
        # Windows-Defender für Gaming optimieren
        Write-Host "[*] Optimiere Windows Defender..." -ForegroundColor $script:secondaryColor
        Set-MpPreference -DisableRealtimeMonitoring $false
        Set-MpPreference -ScanScheduleDay 1
        Set-MpPreference -ScanScheduleTime 12:00
        Add-MpPreference -ExclusionPath "C:\Program Files (x86)\Steam"
        Add-MpPreference -ExclusionPath "C:\Program Files\Steam"
        Write-Host "[+] Windows Defender optimiert" -ForegroundColor Green
        
        # Netzwerk optimieren
        Write-Host "[*] Optimiere Netzwerkeinstellungen..." -ForegroundColor $script:secondaryColor
        # Aktiviere großes MTU
        netsh interface ipv4 set subinterface "Ethernet" mtu=1500 store=persistent
        # Aktiviere QoS
        Set-NetQosPolicy -Name "Gaming Traffic" -IPProtocol Both -NetworkProfile All -ThrottleRateActionBitsPerSecond 100mb
        Write-Host "[+] Netzwerkeinstellungen optimiert" -ForegroundColor Green
        
        # Registry-Optimierungen
        Write-Host "[*] Optimiere Registry-Einstellungen..." -ForegroundColor $script:secondaryColor
        # HKLM Optimierungen
        $regOptimizations = @{
            "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" = @{
                "LargeSystemCache" = 0
                "IoPageLockLimit" = 983040
            }
            "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" = @{
                "Win32PrioritySeparation" = 38
            }
            "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" = @{
                "SystemResponsiveness" = 0
                "NetworkThrottlingIndex" = 4294967295
            }
        }
        
        foreach ($path in $regOptimizations.Keys) {
            if (!(Test-Path $path)) {
                New-Item -Path $path -Force | Out-Null
            }
            foreach ($name in $regOptimizations[$path].Keys) {
                Set-ItemProperty -Path $path -Name $name -Value $regOptimizations[$path][$name]
            }
        }
        Write-Host "[+] Registry-Einstellungen optimiert" -ForegroundColor Green
        
        # Temporäre Dateien bereinigen
        Write-Host "[*] Bereinige temporäre Dateien..." -ForegroundColor $script:secondaryColor
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[+] Temporäre Dateien bereinigt" -ForegroundColor Green
        
        Write-Host "`n[+] Systemoptimierung abgeschlossen!" -ForegroundColor Green
        Write-Host "[!] Bitte starte deinen Computer neu, damit alle Änderungen wirksam werden." -ForegroundColor Yellow
    }
    catch {
        Write-Host "[!] Fehler bei der Systemoptimierung" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

# Gaming-Optimierungen
function Optimize-Gaming {
    Write-Host "`n[*] Optimiere System für Gaming..." -ForegroundColor $script:primaryColor
    try {
        # NVIDIA-Einstellungen (falls vorhanden)
        $nvidiaSMI = "C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe"
        if (Test-Path $nvidiaSMI) {
            Write-Host "[*] Optimiere NVIDIA-Einstellungen..." -ForegroundColor $script:secondaryColor
            # Setze maximale Performance
            & $nvidiaSMI --gpu-max-power-limit 100
            & $nvidiaSMI --auto-boost-default=ENABLED
            Write-Host "[+] NVIDIA-Einstellungen optimiert" -ForegroundColor Green
        }
        
        # Steam-Spiele optimieren (falls installiert)
        $steamPath = "C:\Program Files (x86)\Steam"
        if (Test-Path $steamPath) {
            Write-Host "[*] Optimiere Steam-Einstellungen..." -ForegroundColor $script:secondaryColor
            # Füge Steam-Verzeichnis zu Windows Defender Ausnahmen hinzu
            Add-MpPreference -ExclusionPath $steamPath
            Write-Host "[+] Steam-Einstellungen optimiert" -ForegroundColor Green
        }
        
        # DirectX-Shader-Cache leeren
        Write-Host "[*] Optimiere DirectX-Cache..." -ForegroundColor $script:secondaryColor
        $shadercache = "$env:LOCALAPPDATA\D3DSCache"
        if (Test-Path $shadercache) {
            Remove-Item -Path "$shadercache\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
        Write-Host "[+] DirectX-Cache optimiert" -ForegroundColor Green
        
        Write-Host "`n[+] Gaming-Optimierung abgeschlossen!" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler bei der Gaming-Optimierung" -ForegroundColor Red
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

function Optimize-WindowsServices {
    Write-Host "`n=== Windows-Dienste Optimierung ===" -ForegroundColor $script:primaryColor
    
    # Liste der Windows-Dienste mit Beschreibungen
    $services = @{
        "DiagTrack" = "Connected User Experiences and Telemetry"
        "dmwappushservice" = "Device Management Wireless Application Protocol"
        "SysMain" = "Superfetch"
        "WSearch" = "Windows Search"
        "WMPNetworkSvc" = "Windows Media Player Network Sharing"
        "RemoteRegistry" = "Remote Registry"
        "TapiSrv" = "Telephony"
        "PhoneSvc" = "Phone Service"
        "lfsvc" = "Geolocation Service"
        "MapsBroker" = "Downloaded Maps Manager"
    }
    
    Write-Host "`nVerfügbare Dienste:" -ForegroundColor $script:secondaryColor
    $i = 1
    $serviceList = @()
    foreach ($service in $services.GetEnumerator()) {
        Write-Host "[$i] $($service.Key) - $($service.Value)" -ForegroundColor $script:secondaryColor
        $serviceList += $service.Key
        $i++
    }
    
    Write-Host "`n[A] Alle Dienste deaktivieren" -ForegroundColor $script:secondaryColor
    Write-Host "[E] Empfohlene Dienste deaktivieren" -ForegroundColor $script:secondaryColor
    Write-Host "[Q] Zurück zum Hauptmenü" -ForegroundColor $script:secondaryColor
    
    $choice = Read-Host "`nWähle eine Option"
    
    switch ($choice) {
        "A" {
            foreach ($serviceName in $serviceList) {
                Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
                Set-Service -Name $serviceName -StartupType Disabled -ErrorAction SilentlyContinue
                Write-Host "[+] Dienst deaktiviert: $serviceName" -ForegroundColor Green
            }
        }
        "E" {
            $recommended = @("DiagTrack", "dmwappushservice", "SysMain", "WMPNetworkSvc", "RemoteRegistry")
            foreach ($serviceName in $recommended) {
                Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
                Set-Service -Name $serviceName -StartupType Disabled -ErrorAction SilentlyContinue
                Write-Host "[+] Dienst deaktiviert: $serviceName" -ForegroundColor Green
            }
        }
        "Q" { return }
        default {
            if ([int]::TryParse($choice, [ref]$null)) {
                $index = [int]$choice - 1
                if ($index -ge 0 -and $index -lt $serviceList.Count) {
                    $serviceName = $serviceList[$index]
                    Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
                    Set-Service -Name $serviceName -StartupType Disabled -ErrorAction SilentlyContinue
                    Write-Host "[+] Dienst deaktiviert: $serviceName" -ForegroundColor Green
                }
                else {
                    Write-Host "[!] Ungültige Eingabe" -ForegroundColor Red
                }
            }
            else {
                Write-Host "[!] Ungültige Eingabe" -ForegroundColor Red
            }
        }
    }
    
    Write-Host "`n[+] Windows-Dienste-Optimierung abgeschlossen!" -ForegroundColor Green
    Write-Host "[!] Bitte starte deinen Computer neu, damit alle Änderungen wirksam werden." -ForegroundColor Yellow
}