# Disk Optimization Module for ChillTweak

function Optimize-DiskPerformance {
    try {
        Write-Host "`n[*] Disk-Performance Optimierung..." -ForegroundColor $script:primaryColor
        
        Write-Host "`nDisk-Optimierungen:" -ForegroundColor $script:secondaryColor
        Write-Host "[1] Disk-Fragmentierung prüfen" -ForegroundColor $script:secondaryColor
        Write-Host "[2] SSD TRIM optimieren" -ForegroundColor $script:secondaryColor
        Write-Host "[3] Auslagerungsdatei optimieren" -ForegroundColor $script:secondaryColor
        Write-Host "[4] Disk Cleanup ausführen" -ForegroundColor $script:secondaryColor
        Write-Host "[5] Prefetch und Superfetch optimieren" -ForegroundColor $script:secondaryColor
        Write-Host "[6] Alle Disk-Optimierungen anwenden" -ForegroundColor $script:secondaryColor
        Write-Host "[Q] Zurück" -ForegroundColor $script:secondaryColor
        
        $choice = Read-Host "`nWähle eine Option"
        
        switch ($choice) {
            "1" { Check-DiskFragmentation }
            "2" { Optimize-SSD }
            "3" { Optimize-PageFile }
            "4" { Start-DiskCleanup }
            "5" { Optimize-PrefetchSuperfetch }
            "6" {
                Check-DiskFragmentation
                Optimize-SSD
                Optimize-PageFile
                Optimize-PrefetchSuperfetch
                Write-Host "`n[+] Alle Disk-Optimierungen angewendet!" -ForegroundColor Green
            }
            "Q" { return }
            default { Write-Host "[!] Ungültige Eingabe" -ForegroundColor Red }
        }
        
        Write-Host "`n[+] Disk-Optimierung abgeschlossen!" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler bei der Disk-Optimierung: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Check-DiskFragmentation {
    try {
        Write-Host "`n[*] Prüfe Disk-Fragmentierung..." -ForegroundColor $script:secondaryColor
        
        # Hole alle Laufwerke
        $drives = Get-Volume | Where-Object {$_.DriveType -eq 'Fixed' -and $_.DriveLetter}
        
        foreach ($drive in $drives) {
            Write-Host "`nLaufwerk $($drive.DriveLetter):" -ForegroundColor $script:secondaryColor
            
            # Prüfe ob SSD oder HDD
            $disk = Get-PhysicalDisk | Where-Object {$_.DeviceID -eq (Get-Partition -DriveLetter $drive.DriveLetter).DiskNumber}
            
            if ($disk.MediaType -eq 'SSD') {
                Write-Host "  Typ: SSD (keine Defragmentierung erforderlich)" -ForegroundColor Green
                Write-Host "  TRIM-Status wird geprüft..." -ForegroundColor $script:secondaryColor
                Optimize-Volume -DriveLetter $drive.DriveLetter -ReTrim -ErrorAction SilentlyContinue
                Write-Host "  [+] TRIM ausgeführt" -ForegroundColor Green
            }
            else {
                Write-Host "  Typ: HDD" -ForegroundColor Yellow
                Write-Host "  Analysiere Fragmentierung..." -ForegroundColor $script:secondaryColor
                
                # Defrag Analyse
                $analysis = Optimize-Volume -DriveLetter $drive.DriveLetter -Analyze -Verbose 4>&1
                Write-Host "  Analyse abgeschlossen" -ForegroundColor Green
                
                $defrag = Read-Host "  Defragmentierung starten? (J/N)"
                if ($defrag -eq "J") {
                    Write-Host "  [*] Starte Defragmentierung... (Dies kann einige Zeit dauern)" -ForegroundColor Yellow
                    Optimize-Volume -DriveLetter $drive.DriveLetter -Defrag -Verbose
                    Write-Host "  [+] Defragmentierung abgeschlossen" -ForegroundColor Green
                }
            }
        }
        
        Write-Host "`n[+] Disk-Fragmentierungsprüfung abgeschlossen" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler bei der Fragmentierungsprüfung: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Optimize-SSD {
    try {
        Write-Host "`n[*] Optimiere SSD-Einstellungen..." -ForegroundColor $script:secondaryColor
        
        # Prüfe ob SSDs vorhanden sind
        $ssds = Get-PhysicalDisk | Where-Object {$_.MediaType -eq 'SSD'}
        
        if ($ssds.Count -eq 0) {
            Write-Host "[!] Keine SSDs gefunden" -ForegroundColor Yellow
            return
        }
        
        Write-Host "Gefundene SSDs:" -ForegroundColor $script:secondaryColor
        $ssds | ForEach-Object {
            Write-Host "  - $($_.FriendlyName) ($([math]::Round($_.Size/1GB, 2)) GB)" -ForegroundColor $script:secondaryColor
        }
        
        # TRIM aktivieren
        Write-Host "`n[*] Aktiviere TRIM..." -ForegroundColor $script:secondaryColor
        fsutil behavior set DisableDeleteNotify 0
        Write-Host "[+] TRIM aktiviert" -ForegroundColor Green
        
        # Führe TRIM auf allen SSD-Volumes aus
        $drives = Get-Volume | Where-Object {$_.DriveType -eq 'Fixed' -and $_.DriveLetter}
        foreach ($drive in $drives) {
            $disk = Get-PhysicalDisk | Where-Object {$_.DeviceID -eq (Get-Partition -DriveLetter $drive.DriveLetter).DiskNumber}
            if ($disk.MediaType -eq 'SSD') {
                Write-Host "[*] TRIM auf Laufwerk $($drive.DriveLetter):..." -ForegroundColor $script:secondaryColor
                Optimize-Volume -DriveLetter $drive.DriveLetter -ReTrim -ErrorAction SilentlyContinue
                Write-Host "[+] TRIM auf $($drive.DriveLetter): abgeschlossen" -ForegroundColor Green
            }
        }
        
        # Deaktiviere Superfetch für SSDs
        Write-Host "[*] Optimiere Superfetch für SSDs..." -ForegroundColor $script:secondaryColor
        Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "[+] Superfetch für SSDs deaktiviert" -ForegroundColor Green
        
        # Optimiere Prefetch für SSDs
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnablePrefetcher" -Value 0 -Force
        Write-Host "[+] Prefetch für SSDs deaktiviert" -ForegroundColor Green
        
        # Deaktiviere automatische Defragmentierung für SSDs
        Write-Host "[*] Deaktiviere automatische Defragmentierung für SSDs..." -ForegroundColor $script:secondaryColor
        Get-ScheduledTask -TaskName "*defrag*" | Disable-ScheduledTask -ErrorAction SilentlyContinue
        Write-Host "[+] Automatische Defragmentierung deaktiviert" -ForegroundColor Green
        
        # Optimiere Write Caching
        Write-Host "[*] Optimiere Write Caching..." -ForegroundColor $script:secondaryColor
        foreach ($ssd in $ssds) {
            $diskNumber = $ssd.DeviceID
            # Write Cache aktivieren (falls noch nicht)
            Set-PhysicalDisk -UniqueId $ssd.UniqueId -Usage AutoSelect -ErrorAction SilentlyContinue
        }
        Write-Host "[+] Write Caching optimiert" -ForegroundColor Green
        
        Write-Host "`n[+] SSD-Optimierung abgeschlossen!" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler bei der SSD-Optimierung: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Optimize-PageFile {
    try {
        Write-Host "`n[*] Optimiere Auslagerungsdatei..." -ForegroundColor $script:secondaryColor
        
        # Hole Systeminformationen
        $computerSystem = Get-CimInstance Win32_ComputerSystem
        $totalRAM = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
        
        Write-Host "Installierter RAM: $totalRAM GB" -ForegroundColor $script:secondaryColor
        
        Write-Host "`nOptionen:" -ForegroundColor $script:secondaryColor
        Write-Host "[1] Automatisch verwalten lassen (empfohlen)" -ForegroundColor $script:secondaryColor
        Write-Host "[2] Feste Größe setzen (1.5x RAM)" -ForegroundColor $script:secondaryColor
        Write-Host "[3] Auslagerungsdatei deaktivieren (nur bei viel RAM empfohlen)" -ForegroundColor $script:secondaryColor
        Write-Host "[4] Auslagerungsdatei auf schnellste Disk verschieben" -ForegroundColor $script:secondaryColor
        Write-Host "[Q] Zurück" -ForegroundColor $script:secondaryColor
        
        $choice = Read-Host "`nWähle eine Option"
        
        switch ($choice) {
            "1" {
                # Automatische Verwaltung aktivieren
                $computerSystem.AutomaticManagedPagefile = $true
                $computerSystem.Put()
                Write-Host "[+] Automatische Auslagerungsdatei-Verwaltung aktiviert" -ForegroundColor Green
            }
            "2" {
                # Feste Größe setzen
                $pageFileSize = [math]::Round($totalRAM * 1.5 * 1024) # in MB
                
                $computerSystem.AutomaticManagedPagefile = $false
                $computerSystem.Put()
                
                $pageFile = Get-CimInstance -ClassName Win32_PageFileSetting
                if ($pageFile) {
                    $pageFile | Remove-CimInstance
                }
                
                $newPageFile = New-CimInstance -ClassName Win32_PageFileSetting -Property @{
                    Name = "C:\pagefile.sys"
                    InitialSize = $pageFileSize
                    MaximumSize = $pageFileSize
                }
                
                Write-Host "[+] Auslagerungsdatei auf feste Größe gesetzt: $([math]::Round($pageFileSize/1024, 2)) GB" -ForegroundColor Green
            }
            "3" {
                Write-Host "[!] WARNUNG: Deaktivierung der Auslagerungsdatei kann zu Systeminstabilität führen!" -ForegroundColor Red
                $confirm = Read-Host "Wirklich deaktivieren? (J/N)"
                
                if ($confirm -eq "J") {
                    $computerSystem.AutomaticManagedPagefile = $false
                    $computerSystem.Put()
                    
                    Get-CimInstance -ClassName Win32_PageFileSetting | Remove-CimInstance
                    Write-Host "[+] Auslagerungsdatei deaktiviert" -ForegroundColor Green
                    Write-Host "[!] Neustart erforderlich" -ForegroundColor Yellow
                }
            }
            "4" {
                # Finde schnellste Disk
                Write-Host "[*] Suche schnellste Disk..." -ForegroundColor $script:secondaryColor
                
                $ssds = Get-PhysicalDisk | Where-Object {$_.MediaType -eq 'SSD'}
                if ($ssds.Count -gt 0) {
                    # Wähle erste SSD
                    $targetDisk = $ssds[0]
                    $partition = Get-Partition -DiskNumber $targetDisk.DeviceID | Where-Object {$_.DriveLetter} | Select-Object -First 1
                    
                    if ($partition) {
                        $targetDrive = $partition.DriveLetter
                        $pageFileSize = [math]::Round($totalRAM * 1.5 * 1024)
                        
                        $computerSystem.AutomaticManagedPagefile = $false
                        $computerSystem.Put()
                        
                        Get-CimInstance -ClassName Win32_PageFileSetting | Remove-CimInstance
                        
                        $newPageFile = New-CimInstance -ClassName Win32_PageFileSetting -Property @{
                            Name = "${targetDrive}:\pagefile.sys"
                            InitialSize = $pageFileSize
                            MaximumSize = $pageFileSize
                        }
                        
                        Write-Host "[+] Auslagerungsdatei auf SSD (${targetDrive}:) verschoben" -ForegroundColor Green
                        Write-Host "[!] Neustart erforderlich" -ForegroundColor Yellow
                    }
                }
                else {
                    Write-Host "[!] Keine SSD gefunden" -ForegroundColor Yellow
                }
            }
            "Q" { return }
            default { Write-Host "[!] Ungültige Eingabe" -ForegroundColor Red }
        }
        
        Write-Host "`n[+] Auslagerungsdatei-Optimierung abgeschlossen!" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler bei der Auslagerungsdatei-Optimierung: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Start-DiskCleanup {
    try {
        Write-Host "`n[*] Starte erweiterte Disk-Bereinigung..." -ForegroundColor $script:secondaryColor
        
        # Temporäre Dateien
        Write-Host "[*] Lösche temporäre Dateien..." -ForegroundColor $script:secondaryColor
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[+] Temporäre Dateien gelöscht" -ForegroundColor Green
        
        # Windows Update Cache
        Write-Host "[*] Lösche Windows Update Cache..." -ForegroundColor $script:secondaryColor
        Stop-Service -Name wuauserv -Force
        Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Service -Name wuauserv
        Write-Host "[+] Windows Update Cache gelöscht" -ForegroundColor Green
        
        # Prefetch
        Write-Host "[*] Lösche Prefetch-Dateien..." -ForegroundColor $script:secondaryColor
        Remove-Item -Path "C:\Windows\Prefetch\*" -Force -ErrorAction SilentlyContinue
        Write-Host "[+] Prefetch-Dateien gelöscht" -ForegroundColor Green
        
        # Thumbnail Cache
        Write-Host "[*] Lösche Thumbnail-Cache..." -ForegroundColor $script:secondaryColor
        Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -ErrorAction SilentlyContinue
        Write-Host "[+] Thumbnail-Cache gelöscht" -ForegroundColor Green
        
        # Windows Error Reporting
        Write-Host "[*] Lösche Windows Error Reports..." -ForegroundColor $script:secondaryColor
        Remove-Item -Path "C:\ProgramData\Microsoft\Windows\WER\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[+] Windows Error Reports gelöscht" -ForegroundColor Green
        
        # Papierkorb leeren
        Write-Host "[*] Leere Papierkorb..." -ForegroundColor $script:secondaryColor
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Host "[+] Papierkorb geleert" -ForegroundColor Green
        
        # DNS Cache leeren
        Write-Host "[*] Leere DNS Cache..." -ForegroundColor $script:secondaryColor
        Clear-DnsClientCache
        Write-Host "[+] DNS Cache geleert" -ForegroundColor Green
        
        # Berechne freigegebenen Speicherplatz
        Write-Host "`n[+] Disk-Bereinigung abgeschlossen!" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler bei der Disk-Bereinigung: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Optimize-PrefetchSuperfetch {
    try {
        Write-Host "`n[*] Optimiere Prefetch und Superfetch..." -ForegroundColor $script:secondaryColor
        
        # Prüfe ob System SSDs hat
        $hasSSD = (Get-PhysicalDisk | Where-Object {$_.MediaType -eq 'SSD'}).Count -gt 0
        
        if ($hasSSD) {
            Write-Host "SSD erkannt - Deaktiviere Superfetch und Prefetch für bessere Performance" -ForegroundColor Yellow
            
            # Deaktiviere Superfetch
            Stop-Service -Name "SysMain" -Force -ErrorAction SilentlyContinue
            Set-Service -Name "SysMain" -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "[+] Superfetch deaktiviert" -ForegroundColor Green
            
            # Deaktiviere Prefetch
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnablePrefetcher" -Value 0 -Force
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnableSuperfetch" -Value 0 -Force
            Write-Host "[+] Prefetch deaktiviert" -ForegroundColor Green
        }
        else {
            Write-Host "HDD erkannt - Aktiviere Superfetch und Prefetch für bessere Performance" -ForegroundColor Yellow
            
            # Aktiviere Superfetch
            Set-Service -Name "SysMain" -StartupType Automatic -ErrorAction SilentlyContinue
            Start-Service -Name "SysMain" -ErrorAction SilentlyContinue
            Write-Host "[+] Superfetch aktiviert" -ForegroundColor Green
            
            # Aktiviere Prefetch
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnablePrefetcher" -Value 3 -Force
            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnableSuperfetch" -Value 3 -Force
            Write-Host "[+] Prefetch aktiviert" -ForegroundColor Green
        }
        
        Write-Host "`n[+] Prefetch/Superfetch-Optimierung abgeschlossen!" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler bei der Prefetch/Superfetch-Optimierung: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# SMART Status anzeigen
function Show-SMARTStatus {
    try {
        Write-Host "`n[*] SMART-Status der Festplatten..." -ForegroundColor $script:primaryColor
        
        $disks = Get-PhysicalDisk
        
        foreach ($disk in $disks) {
            Write-Host "`n$($disk.FriendlyName)" -ForegroundColor $script:secondaryColor
            Write-Host "  Typ: $($disk.MediaType)" -ForegroundColor $script:secondaryColor
            Write-Host "  Größe: $([math]::Round($disk.Size/1GB, 2)) GB" -ForegroundColor $script:secondaryColor
            Write-Host "  Gesundheitsstatus: $($disk.HealthStatus)" -ForegroundColor $(if ($disk.HealthStatus -eq 'Healthy') { 'Green' } else { 'Red' })
            Write-Host "  Betriebsstatus: $($disk.OperationalStatus)" -ForegroundColor $script:secondaryColor
        }
        
        Write-Host "`n[+] SMART-Status-Prüfung abgeschlossen" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler bei der SMART-Status-Prüfung: $($_.Exception.Message)" -ForegroundColor Red
    }
}
