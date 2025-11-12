# System Information Module for ChillTweak

function Show-SystemDashboard {
    try {
        Clear-Host
        Write-Host "`n╔══════════════════════════════════════════════════════════════╗" -ForegroundColor $script:primaryColor
        Write-Host "║           ChillTweak System Information Dashboard          ║" -ForegroundColor $script:primaryColor
        Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor $script:primaryColor
        
        # System Information
        Write-Host "`n=== Systeminformationen ===" -ForegroundColor $script:primaryColor
        $os = Get-CimInstance Win32_OperatingSystem
        $cs = Get-CimInstance Win32_ComputerSystem
        $bios = Get-CimInstance Win32_BIOS
        
        Write-Host "Computer Name: $($cs.Name)" -ForegroundColor $script:secondaryColor
        Write-Host "Betriebssystem: $($os.Caption)" -ForegroundColor $script:secondaryColor
        Write-Host "Version: $($os.Version)" -ForegroundColor $script:secondaryColor
        Write-Host "Build: $($os.BuildNumber)" -ForegroundColor $script:secondaryColor
        Write-Host "Architektur: $($os.OSArchitecture)" -ForegroundColor $script:secondaryColor
        Write-Host "BIOS Version: $($bios.SMBIOSBIOSVersion)" -ForegroundColor $script:secondaryColor
        Write-Host "Installationsdatum: $($os.InstallDate)" -ForegroundColor $script:secondaryColor
        Write-Host "Letzter Neustart: $($os.LastBootUpTime)" -ForegroundColor $script:secondaryColor
        
        # CPU Information
        Write-Host "`n=== Prozessor ===" -ForegroundColor $script:primaryColor
        $cpu = Get-CimInstance Win32_Processor
        Write-Host "Name: $($cpu.Name)" -ForegroundColor $script:secondaryColor
        Write-Host "Kerne: $($cpu.NumberOfCores)" -ForegroundColor $script:secondaryColor
        Write-Host "Logische Prozessoren: $($cpu.NumberOfLogicalProcessors)" -ForegroundColor $script:secondaryColor
        Write-Host "Taktfrequenz: $($cpu.MaxClockSpeed) MHz" -ForegroundColor $script:secondaryColor
        Write-Host "Auslastung: $($cpu.LoadPercentage)%" -ForegroundColor $(if ($cpu.LoadPercentage -gt 80) { 'Red' } elseif ($cpu.LoadPercentage -gt 50) { 'Yellow' } else { 'Green' })
        
        # RAM Information
        Write-Host "`n=== Arbeitsspeicher ===" -ForegroundColor $script:primaryColor
        $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
        $freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
        $usedRAM = $totalRAM - $freeRAM
        $ramUsagePercent = [math]::Round(($usedRAM / $totalRAM) * 100, 2)
        
        Write-Host "Gesamt: $totalRAM GB" -ForegroundColor $script:secondaryColor
        Write-Host "Verwendet: $usedRAM GB" -ForegroundColor $script:secondaryColor
        Write-Host "Frei: $freeRAM GB" -ForegroundColor $script:secondaryColor
        Write-Host "Auslastung: $ramUsagePercent%" -ForegroundColor $(if ($ramUsagePercent -gt 80) { 'Red' } elseif ($ramUsagePercent -gt 60) { 'Yellow' } else { 'Green' })
        
        # Disk Information
        Write-Host "`n=== Festplatten ===" -ForegroundColor $script:primaryColor
        $disks = Get-PhysicalDisk
        foreach ($disk in $disks) {
            Write-Host "`n$($disk.FriendlyName):" -ForegroundColor $script:secondaryColor
            Write-Host "  Typ: $($disk.MediaType)" -ForegroundColor $script:secondaryColor
            Write-Host "  Größe: $([math]::Round($disk.Size/1GB, 2)) GB" -ForegroundColor $script:secondaryColor
            Write-Host "  Bus-Typ: $($disk.BusType)" -ForegroundColor $script:secondaryColor
            Write-Host "  Gesundheit: $($disk.HealthStatus)" -ForegroundColor $(if ($disk.HealthStatus -eq 'Healthy') { 'Green' } else { 'Red' })
        }
        
        # Volume Information
        Write-Host "`n=== Laufwerke ===" -ForegroundColor $script:primaryColor
        $volumes = Get-Volume | Where-Object {$_.DriveType -eq 'Fixed' -and $_.DriveLetter}
        foreach ($vol in $volumes) {
            $freePercent = [math]::Round(($vol.SizeRemaining / $vol.Size) * 100, 2)
            Write-Host "`nLaufwerk $($vol.DriveLetter):" -ForegroundColor $script:secondaryColor
            Write-Host "  Dateisystem: $($vol.FileSystemType)" -ForegroundColor $script:secondaryColor
            Write-Host "  Größe: $([math]::Round($vol.Size/1GB, 2)) GB" -ForegroundColor $script:secondaryColor
            Write-Host "  Frei: $([math]::Round($vol.SizeRemaining/1GB, 2)) GB ($freePercent%)" -ForegroundColor $(if ($freePercent -lt 10) { 'Red' } elseif ($freePercent -lt 20) { 'Yellow' } else { 'Green' })
        }
        
        # Network Adapters
        Write-Host "`n=== Netzwerkadapter ===" -ForegroundColor $script:primaryColor
        $adapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
        foreach ($adapter in $adapters) {
            Write-Host "`n$($adapter.Name):" -ForegroundColor $script:secondaryColor
            Write-Host "  Status: $($adapter.Status)" -ForegroundColor Green
            Write-Host "  Geschwindigkeit: $([math]::Round($adapter.LinkSpeed / 1000000, 0)) Mbps" -ForegroundColor $script:secondaryColor
            Write-Host "  MAC: $($adapter.MacAddress)" -ForegroundColor $script:secondaryColor
            
            # IP-Adresse
            $ipConfig = Get-NetIPAddress -InterfaceIndex $adapter.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue
            if ($ipConfig) {
                Write-Host "  IPv4: $($ipConfig.IPAddress)" -ForegroundColor $script:secondaryColor
            }
        }
        
        # Graphics Card
        Write-Host "`n=== Grafikkarte ===" -ForegroundColor $script:primaryColor
        $gpu = Get-CimInstance Win32_VideoController
        foreach ($card in $gpu) {
            Write-Host "Name: $($card.Name)" -ForegroundColor $script:secondaryColor
            Write-Host "Treiber: $($card.DriverVersion)" -ForegroundColor $script:secondaryColor
            Write-Host "RAM: $([math]::Round($card.AdapterRAM/1GB, 2)) GB" -ForegroundColor $script:secondaryColor
        }
        
        # Windows Updates
        Write-Host "`n=== Windows Update Status ===" -ForegroundColor $script:primaryColor
        try {
            $updateSession = New-Object -ComObject Microsoft.Update.Session
            $updateSearcher = $updateSession.CreateUpdateSearcher()
            $searchResult = $updateSearcher.Search("IsInstalled=0")
            $updateCount = $searchResult.Updates.Count
            
            if ($updateCount -eq 0) {
                Write-Host "System ist auf dem neuesten Stand" -ForegroundColor Green
            } else {
                Write-Host "$updateCount ausstehende Update(s)" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "Update-Status konnte nicht abgerufen werden" -ForegroundColor Yellow
        }
        
        # Windows Defender Status
        Write-Host "`n=== Windows Defender Status ===" -ForegroundColor $script:primaryColor
        try {
            $defenderStatus = Get-MpComputerStatus -ErrorAction Stop
            Write-Host "Echtzeitschutz: $(if ($defenderStatus.RealTimeProtectionEnabled) { 'Aktiviert' } else { 'Deaktiviert' })" -ForegroundColor $(if ($defenderStatus.RealTimeProtectionEnabled) { 'Green' } else { 'Red' })
            Write-Host "Signaturversion: $($defenderStatus.AntivirusSignatureVersion)" -ForegroundColor $script:secondaryColor
            Write-Host "Letzter Scan: $($defenderStatus.AntivirusSignatureLastUpdated)" -ForegroundColor $script:secondaryColor
        }
        catch {
            Write-Host "Defender-Status konnte nicht abgerufen werden" -ForegroundColor Yellow
        }
        
        # Performance Metrics
        Write-Host "`n=== Performance Metriken ===" -ForegroundColor $script:primaryColor
        $uptime = (Get-Date) - $os.LastBootUpTime
        Write-Host "Uptime: $($uptime.Days) Tage, $($uptime.Hours) Stunden, $($uptime.Minutes) Minuten" -ForegroundColor $script:secondaryColor
        
        $processes = Get-Process
        Write-Host "Laufende Prozesse: $($processes.Count)" -ForegroundColor $script:secondaryColor
        
        # Top 5 Prozesse nach CPU
        Write-Host "`nTop 5 Prozesse (CPU):" -ForegroundColor $script:secondaryColor
        Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | ForEach-Object {
            Write-Host "  $($_.ProcessName): $([math]::Round($_.CPU, 2))s" -ForegroundColor $script:secondaryColor
        }
        
        # Top 5 Prozesse nach RAM
        Write-Host "`nTop 5 Prozesse (RAM):" -ForegroundColor $script:secondaryColor
        Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 | ForEach-Object {
            Write-Host "  $($_.ProcessName): $([math]::Round($_.WorkingSet/1MB, 2)) MB" -ForegroundColor $script:secondaryColor
        }
        
        Write-Host "`n" -ForegroundColor $script:primaryColor
        Write-Host "Drücke eine beliebige Taste um fortzufahren..." -ForegroundColor $script:secondaryColor
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    catch {
        Write-Host "[!] Fehler beim Anzeigen des System-Dashboards: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Export-SystemReport {
    try {
        Write-Host "`n[*] Erstelle System-Report..." -ForegroundColor $script:primaryColor
        
        $reportPath = "$env:USERPROFILE\Documents\ChillTweak_SystemReport_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt"
        
        $report = @"
╔══════════════════════════════════════════════════════════════╗
║           ChillTweak System Information Report             ║
║                   $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')                    ║
╚══════════════════════════════════════════════════════════════╝

=== System Information ===
"@
        
        $os = Get-CimInstance Win32_OperatingSystem
        $cs = Get-CimInstance Win32_ComputerSystem
        $bios = Get-CimInstance Win32_BIOS
        
        $report += @"

Computer Name: $($cs.Name)
Operating System: $($os.Caption)
Version: $($os.Version)
Build: $($os.BuildNumber)
Architecture: $($os.OSArchitecture)
BIOS Version: $($bios.SMBIOSBIOSVersion)
Install Date: $($os.InstallDate)
Last Boot: $($os.LastBootUpTime)

=== Processor ===
"@
        
        $cpu = Get-CimInstance Win32_Processor
        $report += @"

Name: $($cpu.Name)
Cores: $($cpu.NumberOfCores)
Logical Processors: $($cpu.NumberOfLogicalProcessors)
Clock Speed: $($cpu.MaxClockSpeed) MHz
Current Load: $($cpu.LoadPercentage)%

=== Memory ===
"@
        
        $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
        $freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
        $usedRAM = $totalRAM - $freeRAM
        
        $report += @"

Total: $totalRAM GB
Used: $usedRAM GB
Free: $freeRAM GB

=== Physical Disks ===
"@
        
        $disks = Get-PhysicalDisk
        foreach ($disk in $disks) {
            $report += @"

$($disk.FriendlyName)
  Type: $($disk.MediaType)
  Size: $([math]::Round($disk.Size/1GB, 2)) GB
  Bus Type: $($disk.BusType)
  Health: $($disk.HealthStatus)
"@
        }
        
        $report += "`n`n=== Volumes ===`n"
        $volumes = Get-Volume | Where-Object {$_.DriveType -eq 'Fixed' -and $_.DriveLetter}
        foreach ($vol in $volumes) {
            $report += @"

Drive $($vol.DriveLetter):
  File System: $($vol.FileSystemType)
  Size: $([math]::Round($vol.Size/1GB, 2)) GB
  Free: $([math]::Round($vol.SizeRemaining/1GB, 2)) GB
"@
        }
        
        $report += "`n`n=== Network Adapters ===`n"
        $adapters = Get-NetAdapter
        foreach ($adapter in $adapters) {
            $report += @"

$($adapter.Name)
  Status: $($adapter.Status)
  Speed: $($adapter.LinkSpeed)
  MAC: $($adapter.MacAddress)
"@
        }
        
        $report += "`n`n=== Graphics Card ===`n"
        $gpu = Get-CimInstance Win32_VideoController
        foreach ($card in $gpu) {
            $report += @"

Name: $($card.Name)
Driver: $($card.DriverVersion)
RAM: $([math]::Round($card.AdapterRAM/1GB, 2)) GB
"@
        }
        
        $report | Out-File -FilePath $reportPath -Encoding UTF8
        
        Write-Host "[+] System-Report erstellt: $reportPath" -ForegroundColor Green
        Write-Host "[*] Öffne Report? (J/N)" -ForegroundColor Yellow
        $open = Read-Host
        if ($open -eq "J") {
            Start-Process notepad.exe -ArgumentList $reportPath
        }
    }
    catch {
        Write-Host "[!] Fehler beim Erstellen des System-Reports: $($_.Exception.Message)" -ForegroundColor Red
    }
}
