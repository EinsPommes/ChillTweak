# Sicherheitsfunktionen für chillTweak
function Test-AdminRights {
    try {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        
        if (-not $isAdmin) {
            Write-Host "[!] Dieses Skript benoetigt Administratorrechte!" -ForegroundColor Red
            Exit
        }
    }
    catch {
        Write-Host "[!] Fehler bei der Ueberpruefung der Administratorrechte" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Exit
    }
}

function Enable-WindowsDefender {
    try {
        Write-Host "`n[*] Aktiviere Windows Defender..." -ForegroundColor $script:primaryColor
        
        # Aktiviere Echtzeitschutz
        Set-MpPreference -DisableRealtimeMonitoring $false
        Write-Host "[+] Echtzeitschutz aktiviert" -ForegroundColor $script:secondaryColor
        
        # Aktiviere Cloud-Schutz
        Set-MpPreference -MAPSReporting Advanced
        Set-MpPreference -SubmitSamplesConsent 1
        Write-Host "[+] Cloud-Schutz aktiviert" -ForegroundColor $script:secondaryColor
        
        # Aktiviere Netzwerkschutz
        Set-MpPreference -EnableNetworkProtection Enabled
        Write-Host "[+] Netzwerkschutz aktiviert" -ForegroundColor $script:secondaryColor
        
        # Pruefe Signaturversion
        $defenderStatus = Get-MpComputerStatus
        switch ($defenderStatus.AMSignatureVersion) {
            $null {
                Write-Host "[!] Keine Signaturen gefunden" -ForegroundColor Red
                Update-MpSignature
            }
            'NotSigned' {
                Write-Host "[!] Signaturen nicht signiert" -ForegroundColor Red
                Update-MpSignature
            }
            default {
                Write-Host "[+] Signaturversion: $($defenderStatus.AMSignatureVersion)" -ForegroundColor $script:secondaryColor
            }
        }
        
        Write-Host "[+] Windows Defender erfolgreich konfiguriert" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der Windows Defender Konfiguration" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Disable-Telemetry {
    try {
        Write-Host "`n[*] Deaktiviere Telemetrie..." -ForegroundColor $script:primaryColor
        
        # Telemetrie-Dienste deaktivieren
        $services = @(
            "DiagTrack",                     # Connected User Experiences and Telemetry
            "dmwappushservice",              # WAP Push Message Routing Service
            "PcaSvc",                        # Program Compatibility Assistant Service
            "RemoteRegistry",                # Remote Registry
            "WMPNetworkSvc"                  # Windows Media Player Network Sharing Service
        )
        
        foreach ($service in $services) {
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "[+] Dienst '$service' deaktiviert" -ForegroundColor $script:secondaryColor
        }
        
        # Telemetrie in Registry deaktivieren
        $regKeys = @{
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" = @{
                "AllowTelemetry" = 0
            }
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" = @{
                "AllowTelemetry" = 0
            }
            "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection" = @{
                "AllowTelemetry" = 0
            }
        }
        
        foreach ($key in $regKeys.Keys) {
            if (-not (Test-Path $key)) {
                New-Item -Path $key -Force | Out-Null
            }
            
            foreach ($value in $regKeys[$key].Keys) {
                Set-ItemProperty -Path $key -Name $value -Value $regKeys[$key][$value]
            }
        }
        
        Write-Host "[+] Telemetrie erfolgreich deaktiviert" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Fehler bei der Deaktivierung der Telemetrie" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Update-Windows {
    try {
        Write-Host "`n[*] Pruefe auf Windows Updates..." -ForegroundColor $script:primaryColor
        
        # Installiere PSWindowsUpdate Modul wenn nicht vorhanden
        if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
            Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
            Import-Module PSWindowsUpdate
        }
        
        # Hole verfuegbare Updates
        $updates = Get-WindowsUpdate
        
        if ($updates.Count -eq 0) {
            Write-Host "[+] System ist auf dem neuesten Stand" -ForegroundColor $script:secondaryColor
            return
        }
        
        Write-Host "`nVerfuegbare Updates:" -ForegroundColor $script:secondaryColor
        $updates | ForEach-Object {
            Write-Host "- $($_.Title)" -ForegroundColor $script:secondaryColor
        }
        
        $choice = Read-Host "`nUpdates installieren? (J/N)"
        if ($choice -eq "J") {
            Install-WindowsUpdate -AcceptAll -AutoReboot:$false
            Write-Host "[+] Windows Updates erfolgreich installiert" -ForegroundColor $script:secondaryColor
        }
    }
    catch {
        Write-Host "[!] Fehler bei der Windows Update Installation" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}