# System-Optimierungsfunktionen
function Optimize-System {
    Write-Host "`n[*] Performance-Optimierung wird gestartet..." -ForegroundColor $primaryColor
    try {
        $totalSteps = 5
        $currentStep = 0
        Show-Progress -Activity "System-Optimierung" -PercentComplete (($currentStep++ / $totalSteps) * 100)
        
        Write-Host "`nWaehle eine Performance-Option:" -ForegroundColor $secondaryColor
        Write-Host "[1]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Energieplan optimieren" -ForegroundColor $secondaryColor
        Write-Host "[2]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Autostart-Programme verwalten" -ForegroundColor $secondaryColor
        Write-Host "[3]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Windows-Dienste optimieren" -ForegroundColor $secondaryColor
        Write-Host "[4]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Gaming-Optimierung" -ForegroundColor $secondaryColor
        Write-Host "[5]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " RAM-Optimierung" -ForegroundColor $secondaryColor
        Write-Host "[6]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Alle Optimierungen ausfuehren" -ForegroundColor $secondaryColor
        Write-Host "[7]" -ForegroundColor $primaryColor -NoNewline
        Write-Host " Zurueck zum Hauptmenue" -ForegroundColor $secondaryColor

        $choice = Read-Host "`nWaehle eine Option"

        if (-not (Test-UserInput -Input $choice -ValidOptions @('1','2','3','4','5','6','7'))) {
            Write-Host "[!] Ungueltige Eingabe" -ForegroundColor Red
            return
        }

        try {
            switch ($choice) {
                "1" { Optimize-PowerPlan }
                "2" { Set-Autostart }
                "3" { Optimize-Services }
                "4" { Optimize-Gaming }
                "5" { Optimize-RAM }
                "6" { 
                    Optimize-PowerPlan
                    Set-Autostart
                    Optimize-Services
                    Optimize-Gaming
                    Optimize-RAM
                }
                "7" { return }
            }
        }
        catch {
            Write-Host "[!] Fehler bei der Optimierungs-Operation: $_" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "[!] Fehler bei der Performance-Optimierung: $_" -ForegroundColor Red
    }
}

function Optimize-PowerPlan {
    Write-Host "`n[*] Optimiere Energieplan..." -ForegroundColor $primaryColor
    try {
        # Hoechstleistung aktivieren
        powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        
        # Energiesparplan anpassen
        powercfg /change monitor-timeout-ac 15
        powercfg /change disk-timeout-ac 0
        powercfg /change standby-timeout-ac 0
        powercfg /change hibernate-timeout-ac 0
        
        Write-Host "[✓] Energieplan optimiert" -ForegroundColor $secondaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der Energieplan-Optimierung: $_" -ForegroundColor Red
    }
}

function Set-Autostart {
    Write-Host "`n[*] Verwalte Autostart-Programme..." -ForegroundColor $primaryColor
    try {
        # Autostart-Einträge auflisten
        $autostart = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        
        Write-Host "`nAktuelle Autostart-Programme:" -ForegroundColor $secondaryColor
        $i = 1
        $programs = @()
        $autostart.PSObject.Properties | Where-Object { $_.Name -notlike "PS*" } | ForEach-Object {
            Write-Host "[$i] $($_.Name)" -ForegroundColor $secondaryColor
            $programs += $_.Name
            $i++
        }
        
        Write-Host "`n[D] Programm deaktivieren" -ForegroundColor $secondaryColor
        Write-Host "[Z] Zurueck" -ForegroundColor $secondaryColor
        
        $choice = Read-Host "`nWaehle eine Option"
        
        if ($choice -eq "Z") { return }
        if ($choice -eq "D") {
            $programIndex = [int](Read-Host "Nummer des zu deaktivierenden Programms") - 1
            if ($programIndex -ge 0 -and $programIndex -lt $programs.Count) {
                $programName = $programs[$programIndex]
                Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $programName
                Write-Host "[✓] Programm '$programName' aus Autostart entfernt" -ForegroundColor $secondaryColor
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
    Write-Host "`n[*] Optimiere Windows-Dienste..." -ForegroundColor $primaryColor
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
            Write-Host "[✓] Dienst '$service' deaktiviert" -ForegroundColor $secondaryColor
        }
    }
    catch {
        Write-Host "[!] Fehler bei der Dienste-Optimierung: $_" -ForegroundColor Red
    }
}

function Optimize-Gaming {
    Write-Host "`n[*] Optimiere System fuer Gaming..." -ForegroundColor $primaryColor
    try {
        # Game Mode aktivieren
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 1
        
        # Visuelle Effekte optimieren
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
        
        Write-Host "[✓] Gaming-Optimierungen abgeschlossen" -ForegroundColor $secondaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der Gaming-Optimierung: $_" -ForegroundColor Red
    }
}

function Optimize-RAM {
    Write-Host "`n[*] Optimiere RAM-Nutzung..." -ForegroundColor $primaryColor
    try {
        # Pagefile optimieren
        $computersys = Get-WmiObject Win32_ComputerSystem
        $computersys.AutomaticManagedPagefile = $False
        $computersys.Put()
        
        $pagefile = Get-WmiObject Win32_PageFileSetting
        $pagefile.InitialSize = 8192  # 8 GB
        $pagefile.MaximumSize = 16384 # 16 GB
        $pagefile.Put()
        
        Write-Host "[✓] RAM-Optimierung abgeschlossen" -ForegroundColor $secondaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der RAM-Optimierung: $_" -ForegroundColor Red
    }
} 