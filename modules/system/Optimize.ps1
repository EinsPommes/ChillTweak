# System-Optimierungsfunktionen

# Create system restore point
function New-SystemRestorePoint {
    param(
        [string]$Description = "ChillTweak System Optimization"
    )
    try {
        Write-Host "`n[*] Creating system restore point..." -ForegroundColor $script:primaryColor
        
        # Check if System Restore is enabled
        $restoreEnabled = (Get-ComputerRestorePoint -ErrorAction SilentlyContinue) -ne $null
        
        if (-not $restoreEnabled) {
            # Try to enable System Restore for C: drive
            try {
                vssadmin list shadowstorage | Out-Null
                Write-Host "[*] Checking system restore..." -ForegroundColor $script:secondaryColor
            }
            catch {
                Write-Host "[!] System restore may be disabled" -ForegroundColor Yellow
                Write-Host "[!] Please enable system restore in system properties" -ForegroundColor Yellow
                return $false
            }
        }
        
        # Create restore point using Checkpoint-Computer
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $restoreDescription = "$Description - $timestamp"
        
        try {
            Checkpoint-Computer -Description $restoreDescription -RestorePointType "MODIFY_SETTINGS"
            Write-Host "[+] System restore point created: $restoreDescription" -ForegroundColor Green
            return $true
        }
        catch {
            # Fallback: Try using vssadmin if Checkpoint-Computer fails
            try {
                Write-Host "[*] Trying alternative method..." -ForegroundColor $script:secondaryColor
                $scriptBlock = {
                    $script = New-Object -ComObject Scripting.FileSystemObject
                    $script = $null
                    [System.GC]::Collect()
                }
                Invoke-Command -ScriptBlock $scriptBlock
                
                # Use WMI to create restore point
                $restore = Get-WmiObject -Class "SystemRestore" -Namespace "root\default" -ErrorAction SilentlyContinue
                if ($restore) {
                    $result = $restore.CreateRestorePoint($restoreDescription, 0, 100)
                    if ($result.ReturnValue -eq 0) {
                        Write-Host "[+] System restore point created: $restoreDescription" -ForegroundColor Green
                        return $true
                    }
                    else {
                        Write-Host "[!] Error creating restore point (Code: $($result.ReturnValue))" -ForegroundColor Yellow
                        return $false
                    }
                }
                else {
                    Write-Host "[!] System restore is not available" -ForegroundColor Yellow
                    return $false
                }
            }
            catch {
                Write-Host "[!] Could not create system restore point" -ForegroundColor Yellow
                Write-Host "[!] Reason: $($_.Exception.Message)" -ForegroundColor Yellow
                Write-Host "[!] Optimization will continue anyway..." -ForegroundColor Yellow
                return $false
            }
        }
    }
    catch {
        Write-Host "[!] Error creating restore point" -ForegroundColor Yellow
        Write-Host "[!] Optimization will continue anyway..." -ForegroundColor Yellow
        return $false
    }
}

function Optimize-System {
    try {
        Write-Host "`n[*] Starting system optimization..." -ForegroundColor $script:primaryColor
        
        # Create system restore point before making changes
        $restorePointCreated = New-SystemRestorePoint -Description "ChillTweak System Optimization"
        
        if (-not $restorePointCreated) {
            $continue = Read-Host "`nDo you want to continue without a restore point? (Y/N)"
            if ($continue -ne "Y" -and $continue -ne "y") {
                Write-Host "[*] Optimization cancelled" -ForegroundColor Yellow
                return
            }
        }
        
        # Optimize PowerPlan
        Write-Host "[*] Optimizing power settings..." -ForegroundColor $script:secondaryColor
        powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        powercfg /change standby-timeout-ac 0
        powercfg /change standby-timeout-dc 0
        powercfg /change monitor-timeout-ac 0
        powercfg /change monitor-timeout-dc 0
        powercfg /change hibernate-timeout-ac 0
        powercfg /change hibernate-timeout-dc 0
        Write-Host "[+] Power settings optimized" -ForegroundColor Green
        
        # GameMode and Game DVR
        Write-Host "[*] Optimizing gaming settings..." -ForegroundColor $script:secondaryColor
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1
        Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0
        Write-Host "[+] Gaming settings optimized" -ForegroundColor Green
        
        # Optimize visual effects
        Write-Host "[*] Optimizing visual effects..." -ForegroundColor $script:secondaryColor
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2
        Write-Host "[+] Visual effects optimized" -ForegroundColor Green
        
        # Optimize Windows services
        Write-Host "[*] Optimizing Windows services..." -ForegroundColor $script:secondaryColor
        $services = @(
            "SysMain", # Superfetch
            "DiagTrack", # Connected User Experiences and Telemetry
            "WSearch" # Windows Search
        )
        
        foreach ($service in $services) {
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "[+] Service '$service' optimized" -ForegroundColor Green
        }
        
        # Optimize Windows Defender for gaming
        Write-Host "[*] Optimizing Windows Defender..." -ForegroundColor $script:secondaryColor
        Set-MpPreference -DisableRealtimeMonitoring $false
        Set-MpPreference -ScanScheduleDay 1
        Set-MpPreference -ScanScheduleTime 12:00
        Add-MpPreference -ExclusionPath "C:\Program Files (x86)\Steam"
        Add-MpPreference -ExclusionPath "C:\Program Files\Steam"
        Write-Host "[+] Windows Defender optimized" -ForegroundColor Green
        
        # Optimize network
        Write-Host "[*] Optimizing network settings..." -ForegroundColor $script:secondaryColor
        # Enable large MTU
        try {
            netsh interface ipv4 set subinterface "Ethernet" mtu=1500 store=persistent 2>&1 | Out-Null
        }
        catch {
            # Ignore if interface doesn't exist
        }
        # Enable QoS (if available)
        try {
            Set-NetQosPolicy -Name "Gaming Traffic" -IPProtocol Both -NetworkProfile All -ThrottleRateActionBitsPerSecond 100mb -ErrorAction SilentlyContinue
        }
        catch {
            # QoS might not be available on all systems
        }
        Write-Host "[+] Network settings optimized" -ForegroundColor Green
        
        # Registry optimizations
        Write-Host "[*] Optimizing registry settings..." -ForegroundColor $script:secondaryColor
        # HKLM optimizations
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
        Write-Host "[+] Registry settings optimized" -ForegroundColor Green
        
        # Clean temporary files
        Write-Host "[*] Cleaning temporary files..." -ForegroundColor $script:secondaryColor
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[+] Temporary files cleaned" -ForegroundColor Green
        
        Write-Host "`n[+] System optimization completed!" -ForegroundColor Green
        Write-Host "[!] Please restart your computer for all changes to take effect." -ForegroundColor Yellow
    }
    catch {
        Write-Host "[!] Error during system optimization" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

# Gaming optimizations
function Optimize-Gaming {
    Write-Host "`n[*] Optimizing system for gaming..." -ForegroundColor $script:primaryColor
    try {
        # NVIDIA settings (if available)
        $nvidiaSMI = "C:\Program Files\NVIDIA Corporation\NVSMI\nvidia-smi.exe"
        if (Test-Path $nvidiaSMI) {
            Write-Host "[*] Optimizing NVIDIA settings..." -ForegroundColor $script:secondaryColor
            # Set maximum performance
            & $nvidiaSMI --gpu-max-power-limit 100
            & $nvidiaSMI --auto-boost-default=ENABLED
            Write-Host "[+] NVIDIA settings optimized" -ForegroundColor Green
        }
        
        # Optimize Steam games (if installed)
        $steamPath = "C:\Program Files (x86)\Steam"
        if (Test-Path $steamPath) {
            Write-Host "[*] Optimizing Steam settings..." -ForegroundColor $script:secondaryColor
            # Add Steam directory to Windows Defender exclusions
            Add-MpPreference -ExclusionPath $steamPath
            Write-Host "[+] Steam settings optimized" -ForegroundColor Green
        }
        
        # Clear DirectX shader cache
        Write-Host "[*] Optimizing DirectX cache..." -ForegroundColor $script:secondaryColor
        $shadercache = "$env:LOCALAPPDATA\D3DSCache"
        if (Test-Path $shadercache) {
            Remove-Item -Path "$shadercache\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
        Write-Host "[+] DirectX cache optimized" -ForegroundColor Green
        
        Write-Host "`n[+] Gaming optimization completed!" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Error during gaming optimization" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Optimize-PowerPlan {
    Write-Host "`n[*] Optimizing power plan..." -ForegroundColor $script:primaryColor
    try {
        # Activate high performance
        powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
        
        # Adjust power saving plan
        powercfg /change monitor-timeout-ac 15
        powercfg /change disk-timeout-ac 0
        powercfg /change standby-timeout-ac 0
        powercfg /change hibernate-timeout-ac 0
        
        Write-Host "[+] Power plan optimized" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Error optimizing power plan: $_" -ForegroundColor Red
    }
}

function Set-Autostart {
    Write-Host "`n[*] Managing autostart programs..." -ForegroundColor $script:primaryColor
    try {
        # List autostart entries
        $autostart = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        
        Write-Host "`nCurrent autostart programs:" -ForegroundColor $script:secondaryColor
        $i = 1
        $programs = @()
        $autostart.PSObject.Properties | Where-Object { $_.Name -notlike "PS*" } | ForEach-Object {
            Write-Host "[$i] $($_.Name)" -ForegroundColor $script:secondaryColor
            $programs += $_.Name
            $i++
        }
        
        Write-Host "`n[D] Disable program" -ForegroundColor $script:secondaryColor
        Write-Host "[B] Back" -ForegroundColor $script:secondaryColor
        
        $choice = Read-Host "`nChoose an option"
        
        if ($choice -eq "B") { return }
        if ($choice -eq "D") {
            $programIndex = [int](Read-Host "Number of program to disable") - 1
            if ($programIndex -ge 0 -and $programIndex -lt $programs.Count) {
                $programName = $programs[$programIndex]
                Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $programName
                Write-Host "[+] Program '$programName' removed from autostart" -ForegroundColor $script:secondaryColor
            }
            else {
                Write-Host "[!] Invalid program number" -ForegroundColor Red
            }
        }
    }
    catch {
        Write-Host "[!] Error managing autostart: $_" -ForegroundColor Red
    }
}

function Optimize-RAM {
    Write-Host "`n[*] Optimizing RAM usage..." -ForegroundColor $script:primaryColor
    try {
        # Optimize pagefile
        $computersys = Get-WmiObject Win32_ComputerSystem
        $computersys.AutomaticManagedPagefile = $False
        $computersys.Put()
        
        $pagefile = Get-WmiObject Win32_PageFileSetting
        $pagefile.InitialSize = 8192  # 8 GB
        $pagefile.MaximumSize = 16384 # 16 GB
        $pagefile.Put()
        
        Write-Host "[+] RAM optimization completed" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Error optimizing RAM: $_" -ForegroundColor Red
    }
}

function Optimize-WindowsServices {
    try {
        Write-Host "`n=== Windows Services Optimization ===" -ForegroundColor $script:primaryColor
        
        # Create system restore point before disabling services
        $restorePointCreated = New-SystemRestorePoint -Description "ChillTweak Windows Services Optimization"
        
        if (-not $restorePointCreated) {
            $continue = Read-Host "`nDo you want to continue without a restore point? (Y/N)"
            if ($continue -ne "Y" -and $continue -ne "y") {
                Write-Host "[*] Optimization cancelled" -ForegroundColor Yellow
                return
            }
        }
        
        # List of Windows services with descriptions
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
        
        Write-Host "`nAvailable services:" -ForegroundColor $script:secondaryColor
        $i = 1
        $serviceList = @()
        foreach ($service in $services.GetEnumerator()) {
            Write-Host "[$i] $($service.Key) - $($service.Value)" -ForegroundColor $script:secondaryColor
            $serviceList += $service.Key
            $i++
        }
        
        Write-Host "`n[A] Disable all services" -ForegroundColor $script:secondaryColor
        Write-Host "[E] Disable recommended services" -ForegroundColor $script:secondaryColor
        Write-Host "[Q] Back to main menu" -ForegroundColor $script:secondaryColor
        
        $choice = Read-Host "`nChoose an option"
        
        switch ($choice) {
            "A" {
                foreach ($serviceName in $serviceList) {
                    Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
                    Set-Service -Name $serviceName -StartupType Disabled -ErrorAction SilentlyContinue
                    Write-Host "[+] Service disabled: $serviceName" -ForegroundColor Green
                }
            }
            "E" {
                $recommended = @("DiagTrack", "dmwappushservice", "SysMain", "WMPNetworkSvc", "RemoteRegistry")
                foreach ($serviceName in $recommended) {
                    Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
                    Set-Service -Name $serviceName -StartupType Disabled -ErrorAction SilentlyContinue
                    Write-Host "[+] Service disabled: $serviceName" -ForegroundColor Green
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
                        Write-Host "[+] Service disabled: $serviceName" -ForegroundColor Green
                    }
                    else {
                        Write-Host "[!] Invalid input" -ForegroundColor Red
                    }
                }
                else {
                    Write-Host "[!] Invalid input" -ForegroundColor Red
                }
            }
        }
        
        Write-Host "`n[+] Windows Services optimization completed!" -ForegroundColor Green
        Write-Host "[!] Please restart your computer for all changes to take effect." -ForegroundColor Yellow
    }
    catch {
        Write-Host "[!] Error during Windows Services optimization" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}