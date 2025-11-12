# Network Optimization Module for ChillTweak

function Optimize-NetworkAdvanced {
    try {
        Write-Host "`n[*] Erweiterte Netzwerk-Optimierung..." -ForegroundColor $script:primaryColor
        
        # Erstelle Wiederherstellungspunkt
        if (Get-Command New-RestorePoint -ErrorAction SilentlyContinue) {
            New-RestorePoint -Description "ChillTweak Netzwerk-Optimierung"
        }
        
        Write-Host "`nNetzwerk-Optimierungen:" -ForegroundColor $script:secondaryColor
        Write-Host "[1] TCP/IP Stack optimieren" -ForegroundColor $script:secondaryColor
        Write-Host "[2] DNS Cache optimieren" -ForegroundColor $script:secondaryColor
        Write-Host "[3] Windows Auto-Tuning Level anpassen" -ForegroundColor $script:secondaryColor
        Write-Host "[4] QoS Packet Scheduler optimieren" -ForegroundColor $script:secondaryColor
        Write-Host "[5] Alle Netzwerk-Optimierungen anwenden" -ForegroundColor $script:secondaryColor
        Write-Host "[Q] Zurück" -ForegroundColor $script:secondaryColor
        
        $choice = Read-Host "`nWähle eine Option"
        
        switch ($choice) {
            "1" { Optimize-TCPIPStack }
            "2" { Optimize-DNSCache }
            "3" { Optimize-WindowsAutoTuning }
            "4" { Optimize-QoS }
            "5" {
                Optimize-TCPIPStack
                Optimize-DNSCache
                Optimize-WindowsAutoTuning
                Optimize-QoS
                Write-Host "`n[+] Alle Netzwerk-Optimierungen angewendet!" -ForegroundColor Green
            }
            "Q" { return }
            default { Write-Host "[!] Ungültige Eingabe" -ForegroundColor Red }
        }
        
        Write-Host "`n[+] Netzwerk-Optimierung abgeschlossen!" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler bei der Netzwerk-Optimierung: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Optimize-TCPIPStack {
    try {
        Write-Host "`n[*] Optimiere TCP/IP Stack..." -ForegroundColor $script:secondaryColor
        
        # TCP Parameter optimieren
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
        
        # TCP Window Size erhöhen
        Set-ItemProperty -Path $regPath -Name "TcpWindowSize" -Value 65535 -Type DWord -Force
        Write-Host "[+] TCP Window Size auf 65535 gesetzt" -ForegroundColor Green
        
        # TCP 1323 Timestamps aktivieren
        Set-ItemProperty -Path $regPath -Name "Tcp1323Opts" -Value 1 -Type DWord -Force
        Write-Host "[+] TCP 1323 Timestamps aktiviert" -ForegroundColor Green
        
        # DefaultTTL erhöhen
        Set-ItemProperty -Path $regPath -Name "DefaultTTL" -Value 64 -Type DWord -Force
        Write-Host "[+] DefaultTTL auf 64 gesetzt" -ForegroundColor Green
        
        # TCP KeepAlive Time reduzieren
        Set-ItemProperty -Path $regPath -Name "KeepAliveTime" -Value 300000 -Type DWord -Force
        Write-Host "[+] KeepAlive Time optimiert" -ForegroundColor Green
        
        # SynAttackProtect aktivieren
        Set-ItemProperty -Path $regPath -Name "SynAttackProtect" -Value 1 -Type DWord -Force
        Write-Host "[+] SYN Attack Protection aktiviert" -ForegroundColor Green
        
        # MaxUserPort erhöhen
        Set-ItemProperty -Path $regPath -Name "MaxUserPort" -Value 65534 -Type DWord -Force
        Write-Host "[+] MaxUserPort erhöht" -ForegroundColor Green
        
        # TcpTimedWaitDelay reduzieren
        Set-ItemProperty -Path $regPath -Name "TcpTimedWaitDelay" -Value 30 -Type DWord -Force
        Write-Host "[+] TcpTimedWaitDelay reduziert" -ForegroundColor Green
        
        Write-Host "[+] TCP/IP Stack optimiert" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler beim Optimieren des TCP/IP Stacks: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Optimize-DNSCache {
    try {
        Write-Host "`n[*] Optimiere DNS Cache..." -ForegroundColor $script:secondaryColor
        
        # DNS Cache Parameter
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
        
        # Erhöhe DNS Cache Größe
        Set-ItemProperty -Path $regPath -Name "CacheHashTableBucketSize" -Value 1 -Type DWord -Force
        Set-ItemProperty -Path $regPath -Name "CacheHashTableSize" -Value 384 -Type DWord -Force
        Set-ItemProperty -Path $regPath -Name "MaxCacheEntryTtlLimit" -Value 86400 -Type DWord -Force
        Set-ItemProperty -Path $regPath -Name "MaxSOACacheEntryTtlLimit" -Value 301 -Type DWord -Force
        Write-Host "[+] DNS Cache Größe erhöht" -ForegroundColor Green
        
        # DNS Cache leeren und neu starten
        Clear-DnsClientCache
        Restart-Service -Name "Dnscache" -Force
        Write-Host "[+] DNS Cache geleert und Dienst neu gestartet" -ForegroundColor Green
        
        # Setze bevorzugte DNS Server (Cloudflare & Google)
        Write-Host "`nSetze schnelle DNS Server:" -ForegroundColor $script:secondaryColor
        Write-Host "[1] Cloudflare (1.1.1.1)" -ForegroundColor $script:secondaryColor
        Write-Host "[2] Google (8.8.8.8)" -ForegroundColor $script:secondaryColor
        Write-Host "[3] Quad9 (9.9.9.9)" -ForegroundColor $script:secondaryColor
        Write-Host "[S] Überspringen" -ForegroundColor $script:secondaryColor
        
        $dnsChoice = Read-Host "`nWähle DNS Provider"
        
        $adapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
        
        switch ($dnsChoice) {
            "1" {
                foreach ($adapter in $adapters) {
                    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses ("1.1.1.1","1.0.0.1")
                }
                Write-Host "[+] Cloudflare DNS gesetzt" -ForegroundColor Green
            }
            "2" {
                foreach ($adapter in $adapters) {
                    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses ("8.8.8.8","8.8.4.4")
                }
                Write-Host "[+] Google DNS gesetzt" -ForegroundColor Green
            }
            "3" {
                foreach ($adapter in $adapters) {
                    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses ("9.9.9.9","149.112.112.112")
                }
                Write-Host "[+] Quad9 DNS gesetzt" -ForegroundColor Green
            }
            "S" { Write-Host "[*] DNS-Einstellung übersprungen" -ForegroundColor Yellow }
            default { Write-Host "[!] Ungültige Eingabe" -ForegroundColor Red }
        }
        
        Write-Host "[+] DNS Cache optimiert" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler beim Optimieren des DNS Cache: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Optimize-WindowsAutoTuning {
    try {
        Write-Host "`n[*] Optimiere Windows Auto-Tuning..." -ForegroundColor $script:secondaryColor
        
        # Auto-Tuning Level setzen
        netsh interface tcp set global autotuninglevel=normal
        Write-Host "[+] Auto-Tuning Level auf 'normal' gesetzt" -ForegroundColor Green
        
        # Chimney Offload aktivieren
        netsh interface tcp set global chimney=enabled
        Write-Host "[+] Chimney Offload aktiviert" -ForegroundColor Green
        
        # Direct Cache Access aktivieren
        netsh interface tcp set global dca=enabled
        Write-Host "[+] Direct Cache Access aktiviert" -ForegroundColor Green
        
        # NetDMA aktivieren
        netsh interface tcp set global netdma=enabled
        Write-Host "[+] NetDMA aktiviert" -ForegroundColor Green
        
        # RSS (Receive Side Scaling) aktivieren
        netsh interface tcp set global rss=enabled
        Write-Host "[+] RSS aktiviert" -ForegroundColor Green
        
        # Congestion Provider auf CTCP setzen
        netsh interface tcp set global congestionprovider=ctcp
        Write-Host "[+] Congestion Provider auf CTCP gesetzt" -ForegroundColor Green
        
        # ECN Capability aktivieren
        netsh interface tcp set global ecncapability=enabled
        Write-Host "[+] ECN Capability aktiviert" -ForegroundColor Green
        
        Write-Host "[+] Windows Auto-Tuning optimiert" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler beim Optimieren von Auto-Tuning: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Optimize-QoS {
    try {
        Write-Host "`n[*] Optimiere QoS Packet Scheduler..." -ForegroundColor $script:secondaryColor
        
        # QoS Registry Settings
        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Psched"
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
        # Entferne reservierte Bandbreite für QoS
        Set-ItemProperty -Path $regPath -Name "NonBestEffortLimit" -Value 0 -Type DWord -Force
        Write-Host "[+] QoS Bandbreitenbeschränkung entfernt (100% verfügbar)" -ForegroundColor Green
        
        # Deaktiviere Nagle Algorithm für geringere Latenz
        $regPath2 = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
        Get-ChildItem $regPath2 | ForEach-Object {
            Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
            Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
        }
        Write-Host "[+] Nagle Algorithm optimiert für geringere Latenz" -ForegroundColor Green
        
        # IRPStackSize erhöhen für Netzwerk-Performance
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "IRPStackSize" -Value 32 -Type DWord -Force
        Write-Host "[+] IRPStackSize für bessere Netzwerk-Performance erhöht" -ForegroundColor Green
        
        Write-Host "[+] QoS Packet Scheduler optimiert" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler beim Optimieren von QoS: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Netzwerkadapter-spezifische Optimierungen
function Optimize-NetworkAdapters {
    try {
        Write-Host "`n[*] Optimiere Netzwerkadapter..." -ForegroundColor $script:primaryColor
        
        # Hole alle aktiven Netzwerkadapter
        $adapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}
        
        Write-Host "`nAktive Netzwerkadapter:" -ForegroundColor $script:secondaryColor
        $i = 1
        foreach ($adapter in $adapters) {
            Write-Host "[$i] $($adapter.Name) - $($adapter.InterfaceDescription)" -ForegroundColor $script:secondaryColor
            $i++
        }
        
        Write-Host "`nOptimierungen:" -ForegroundColor $script:secondaryColor
        Write-Host "[1] Large Send Offload aktivieren" -ForegroundColor $script:secondaryColor
        Write-Host "[2] Receive Side Scaling aktivieren" -ForegroundColor $script:secondaryColor
        Write-Host "[3] Jumbo Frames aktivieren (für lokales Netzwerk)" -ForegroundColor $script:secondaryColor
        Write-Host "[4] Alle Adapter-Optimierungen anwenden" -ForegroundColor $script:secondaryColor
        Write-Host "[Q] Zurück" -ForegroundColor $script:secondaryColor
        
        $choice = Read-Host "`nWähle eine Option"
        
        switch ($choice) {
            "1" {
                foreach ($adapter in $adapters) {
                    Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "*Large Send Offload*" -DisplayValue "Enabled" -ErrorAction SilentlyContinue
                }
                Write-Host "[+] Large Send Offload aktiviert" -ForegroundColor Green
            }
            "2" {
                foreach ($adapter in $adapters) {
                    Enable-NetAdapterRss -Name $adapter.Name -ErrorAction SilentlyContinue
                }
                Write-Host "[+] Receive Side Scaling aktiviert" -ForegroundColor Green
            }
            "3" {
                foreach ($adapter in $adapters) {
                    Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "*Jumbo*" -DisplayValue "9014" -ErrorAction SilentlyContinue
                }
                Write-Host "[+] Jumbo Frames aktiviert" -ForegroundColor Green
                Write-Host "[!] Hinweis: Jumbo Frames sollten nur in lokalen Netzwerken verwendet werden" -ForegroundColor Yellow
            }
            "4" {
                foreach ($adapter in $adapters) {
                    Set-NetAdapterAdvancedProperty -Name $adapter.Name -DisplayName "*Large Send Offload*" -DisplayValue "Enabled" -ErrorAction SilentlyContinue
                    Enable-NetAdapterRss -Name $adapter.Name -ErrorAction SilentlyContinue
                    Enable-NetAdapterChecksumOffload -Name $adapter.Name -ErrorAction SilentlyContinue
                }
                Write-Host "[+] Alle Adapter-Optimierungen angewendet" -ForegroundColor Green
            }
            "Q" { return }
            default { Write-Host "[!] Ungültige Eingabe" -ForegroundColor Red }
        }
        
        Write-Host "`n[+] Netzwerkadapter-Optimierung abgeschlossen!" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler bei der Netzwerkadapter-Optimierung: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Windows Firewall optimieren
function Optimize-WindowsFirewall {
    try {
        Write-Host "`n[*] Optimiere Windows Firewall..." -ForegroundColor $script:primaryColor
        
        Write-Host "`nFirewall-Optionen:" -ForegroundColor $script:secondaryColor
        Write-Host "[1] Firewall-Status anzeigen" -ForegroundColor $script:secondaryColor
        Write-Host "[2] Firewall für private Netzwerke optimieren" -ForegroundColor $script:secondaryColor
        Write-Host "[3] Blockiere eingehende Verbindungen standardmäßig" -ForegroundColor $script:secondaryColor
        Write-Host "[4] Alle Firewall-Optimierungen anwenden" -ForegroundColor $script:secondaryColor
        Write-Host "[Q] Zurück" -ForegroundColor $script:secondaryColor
        
        $choice = Read-Host "`nWähle eine Option"
        
        switch ($choice) {
            "1" {
                Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction | Format-Table -AutoSize
            }
            "2" {
                Set-NetFirewallProfile -Profile Private -Enabled True
                Write-Host "[+] Firewall für private Netzwerke aktiviert" -ForegroundColor Green
            }
            "3" {
                Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultInboundAction Block -DefaultOutboundAction Allow
                Write-Host "[+] Eingehende Verbindungen werden standardmäßig blockiert" -ForegroundColor Green
            }
            "4" {
                Set-NetFirewallProfile -Profile Private -Enabled True
                Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultInboundAction Block -DefaultOutboundAction Allow
                Set-NetFirewallProfile -Profile Domain,Public,Private -LogAllowed True -LogBlocked True
                Write-Host "[+] Alle Firewall-Optimierungen angewendet" -ForegroundColor Green
            }
            "Q" { return }
            default { Write-Host "[!] Ungültige Eingabe" -ForegroundColor Red }
        }
        
        Write-Host "`n[+] Windows Firewall Optimierung abgeschlossen!" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Fehler bei der Firewall-Optimierung: $($_.Exception.Message)" -ForegroundColor Red
    }
}
