# Security functions for chillTweak

# Admin rights check
function Test-AdminRights {
    try {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        
        if (-not $isAdmin) {
            Write-Host "[!] This script requires administrator rights!" -ForegroundColor Red
            Exit
        }
    }
    catch {
        Write-Host "[!] Error checking administrator rights" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Exit
    }
}

# Input validation
function Test-UserInput {
    param (
        [string]$UserInput,
        [string[]]$ValidOptions
    )
    return $ValidOptions -contains $UserInput
}

# Log rotation
function Start-LogRotation {
    param()
    try {
        $logPath = "$env:USERPROFILE\Documents\chillTweak_log.txt"
        if (Test-Path $logPath) {
            $maxSize = 5MB
            $fileInfo = Get-Item $logPath
            if ($fileInfo.Length -gt $maxSize) {
                $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
                Move-Item $logPath "$logPath.$timestamp.bak" -Force
            }
        }
    }
    catch {
        Write-Host "[!] Error during log rotation: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Backup encryption functions
function Protect-BackupData {
    param (
        [string]$BackupPath
    )
    try {
        $key = New-Object Byte[] 32
        [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($key)
        $keyFile = "$BackupPath\backup.key"
        $key | Set-Content $keyFile -Encoding Byte
        
        Get-ChildItem $BackupPath -Recurse -File | Where-Object { $_.Name -ne "backup.key" } | ForEach-Object {
            $encrypted = "$($_.FullName).enc"
            Protect-File -SourceFile $_.FullName -DestinationFile $encrypted -KeyFile $keyFile
            Remove-Item $_.FullName -Force
        }
    }
    catch {
        Write-Host "[!] Error during backup encryption: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Protect-File {
    param (
        [string]$SourceFile,
        [string]$DestinationFile,
        [string]$KeyFile
    )
    try {
        $key = Get-Content $KeyFile -Encoding Byte
        $fileContent = Get-Content $SourceFile -Encoding Byte
        $encryptor = [System.Security.Cryptography.Aes]::Create()
        $encryptor.Key = $key
        $encryptor.GenerateIV()
        
        $encryptedData = @()
        $encryptedData += $encryptor.IV
        
        $memoryStream = New-Object System.IO.MemoryStream
        $cryptoStream = New-Object System.Security.Cryptography.CryptoStream(
            $memoryStream, 
            $encryptor.CreateEncryptor(),
            [System.Security.Cryptography.CryptoStreamMode]::Write
        )
        
        $cryptoStream.Write($fileContent, 0, $fileContent.Length)
        $cryptoStream.FlushFinalBlock()
        $encryptedData += $memoryStream.ToArray()
        
        $encryptedData | Set-Content $DestinationFile -Encoding Byte
        
        $cryptoStream.Close()
        $memoryStream.Close()
        $encryptor.Dispose()
    }
    catch {
        Write-Host "[!] Error during file encryption: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

function Unprotect-File {
    param (
        [string]$SourceFile,
        [string]$DestinationFile,
        [string]$KeyFile
    )
    try {
        $key = Get-Content $KeyFile -Encoding Byte
        $encryptedData = Get-Content $SourceFile -Encoding Byte
        
        $decryptor = [System.Security.Cryptography.Aes]::Create()
        $decryptor.Key = $key
        $decryptor.IV = $encryptedData[0..15]
        
        $memoryStream = New-Object System.IO.MemoryStream($encryptedData[16..($encryptedData.Length-1)])
        $cryptoStream = New-Object System.Security.Cryptography.CryptoStream(
            $memoryStream, 
            $decryptor.CreateDecryptor(),
            [System.Security.Cryptography.CryptoStreamMode]::Read
        )
        
        $decryptedData = New-Object byte[] $memoryStream.Length
        $cryptoStream.Read($decryptedData, 0, $decryptedData.Length)
        
        $decryptedData | Set-Content $DestinationFile -Encoding Byte
        
        $cryptoStream.Close()
        $memoryStream.Close()
        $decryptor.Dispose()
    }
    catch {
        Write-Host "[!] Error during file decryption: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

function Enable-WindowsDefender {
    try {
        Write-Host "`n[*] Enabling Windows Defender..." -ForegroundColor $script:primaryColor
        
        # Enable real-time protection
        Set-MpPreference -DisableRealtimeMonitoring $false
        Write-Host "[+] Real-time protection enabled" -ForegroundColor $script:secondaryColor
        
        # Enable cloud protection
        Set-MpPreference -MAPSReporting Advanced
        Set-MpPreference -SubmitSamplesConsent 1
        Write-Host "[+] Cloud protection enabled" -ForegroundColor $script:secondaryColor
        
        # Enable network protection
        Set-MpPreference -EnableNetworkProtection Enabled
        Write-Host "[+] Network protection enabled" -ForegroundColor $script:secondaryColor
        
        # Check signature version
        $defenderStatus = Get-MpComputerStatus
        switch ($defenderStatus.AMSignatureVersion) {
            $null {
                Write-Host "[!] No signatures found" -ForegroundColor Red
                Update-MpSignature
            }
            'NotSigned' {
                Write-Host "[!] Signatures not signed" -ForegroundColor Red
                Update-MpSignature
            }
            default {
                Write-Host "[+] Signature version: $($defenderStatus.AMSignatureVersion)" -ForegroundColor $script:secondaryColor
            }
        }
        
        Write-Host "[+] Windows Defender successfully configured" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Error configuring Windows Defender" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Disable-Telemetry {
    try {
        Write-Host "`n[*] Disabling telemetry..." -ForegroundColor $script:primaryColor
        
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
            Write-Host "[+] Service '$service' disabled" -ForegroundColor $script:secondaryColor
        }
        
        # Disable telemetry in registry
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
        
        Write-Host "[+] Telemetry successfully disabled" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Error disabling telemetry" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Update-Windows {
    try {
        Write-Host "`n[*] Checking for Windows Updates..." -ForegroundColor $script:primaryColor
        
        # Install PSWindowsUpdate module if not available
        if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
            Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
            Import-Module PSWindowsUpdate
        }
        
        # Get available updates
        $updates = Get-WindowsUpdate
        
        if ($updates.Count -eq 0) {
            Write-Host "[+] System is up to date" -ForegroundColor $script:secondaryColor
            return
        }
        
        Write-Host "`nAvailable updates:" -ForegroundColor $script:secondaryColor
        $updates | ForEach-Object {
            Write-Host "- $($_.Title)" -ForegroundColor $script:secondaryColor
        }
        
        $choice = Read-Host "`nInstall updates? (Y/N)"
        if ($choice -eq "Y" -or $choice -eq "y") {
            Install-WindowsUpdate -AcceptAll -AutoReboot:$false
            Write-Host "[+] Windows Updates successfully installed" -ForegroundColor $script:secondaryColor
        }
    }
    catch {
        Write-Host "[!] Error installing Windows Updates" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}