function Test-UserInput {
    param (
        [string]$UserInput,
        [string[]]$ValidOptions
    )
    return $ValidOptions -contains $UserInput
}

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
        Write-Host "[!] Fehler bei der Log-Rotation: $($_.Exception.Message)" -ForegroundColor Red
    }
}

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
        Write-Host "[!] Fehler bei der Backup-Verschlüsselung: $($_.Exception.Message)" -ForegroundColor Red
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
        Write-Host "[!] Fehler bei der Dateiverschlüsselung: $($_.Exception.Message)" -ForegroundColor Red
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
        Write-Host "[!] Fehler bei der Dateientschlüsselung: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

function Test-AdminRights {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "[!] Dieses Skript benötigt Administratorrechte!" -ForegroundColor Red
        Exit
    }
} 