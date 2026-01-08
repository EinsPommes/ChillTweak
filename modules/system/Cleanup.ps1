# Cleanup functions
function Clear-SystemFiles {
    try {
        Write-Host "`n[*] Starting system cleanup..." -ForegroundColor $script:primaryColor
        
        # Temporary files
        if ($script:CleanupSettings.TempFiles) {
            Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "[+] Temporary files removed" -ForegroundColor $script:secondaryColor
        }
        
        # Recycle bin
        if ($script:CleanupSettings.RecycleBin) {
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            Write-Host "[+] Recycle bin emptied" -ForegroundColor $script:secondaryColor
        }
        
        # Windows Logs
        if ($script:CleanupSettings.WindowsLogs) {
            wevtutil el | ForEach-Object {
                wevtutil cl "$_" 2>&1 | Out-Null
            }
            Write-Host "[+] Windows logs cleaned" -ForegroundColor $script:secondaryColor
        }
        
        # Windows Update Cache
        $updateCache = "C:\Windows\SoftwareDistribution\Download"
        if (Test-Path $updateCache) {
            Stop-Service -Name wuauserv -Force
            Remove-Item -Path "$updateCache\*" -Recurse -Force -ErrorAction SilentlyContinue
            Start-Service -Name wuauserv
            Write-Host "[+] Windows Update cache cleaned" -ForegroundColor $script:secondaryColor
        }
        
        Write-Host "[+] System cleanup completed" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Error during system cleanup" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Clear-TempFiles {
    Write-Host "[*] Deleting temporary files..." -ForegroundColor $script:primaryColor
    try {
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[+] Temporary files deleted" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Error deleting temporary files: $_" -ForegroundColor Red
    }
}

function Clear-UpdateCache {
    Write-Host "[*] Clearing Windows Update cache..." -ForegroundColor $script:primaryColor
    try {
        Stop-Service -Name wuauserv
        Remove-Item -Path "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Service -Name wuauserv
        Write-Host "[+] Update cache cleared" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Error clearing update cache: $_" -ForegroundColor Red
    }
} 