# ChillTweak Installer
$ErrorActionPreference = 'Stop'

function Install-ChillTweak {
    try {
        Write-Host "[*] Starting ChillTweak installation..." -ForegroundColor Cyan
        
        # Create target directory
        $installDir = "$env:USERPROFILE\ChillTweak"
        if (-not (Test-Path $installDir)) {
            New-Item -Path $installDir -ItemType Directory -Force | Out-Null
            Write-Host "[+] Installation directory created: $installDir" -ForegroundColor Green
        }
        
        # Download main script
        $mainScriptUrl = "https://raw.githubusercontent.com/einspommes/chillTweak/main/chillTweak.ps1"
        $mainScriptPath = Join-Path $installDir "chillTweak.ps1"
        
        Write-Host "[*] Downloading ChillTweak..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $mainScriptUrl -OutFile $mainScriptPath -UseBasicParsing
        Write-Host "[+] ChillTweak successfully downloaded" -ForegroundColor Green
        
        # Create desktop shortcut
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $shortcutPath = Join-Path $desktopPath "ChillTweak.lnk"
        
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = "powershell.exe"
        $shortcut.Arguments = "-NoExit -ExecutionPolicy Bypass -File `"$mainScriptPath`""
        $shortcut.WorkingDirectory = $installDir
        $shortcut.Description = "ChillTweak Windows Optimizer"
        $shortcut.WindowStyle = 1  # Normal window
        $shortcut.Save()
        
        Write-Host "[+] Desktop shortcut created" -ForegroundColor Green
        
        # Create launch script
        $launchScript = @"
# ChillTweak Starter
Write-Host "Starting ChillTweak..." -ForegroundColor Cyan
Set-Location "$installDir"

try {
    # Check administrator rights
    `$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not `$isAdmin) {
        Write-Host "[!] ChillTweak requires administrator rights!" -ForegroundColor Red
        Write-Host "Please start ChillTweak as Administrator." -ForegroundColor Yellow
        Read-Host "Press ENTER to exit"
        return
    }

    # Run ChillTweak
    & "$mainScriptPath"
}
catch {
    Write-Host "[!] Error running ChillTweak:" -ForegroundColor Red
    Write-Host `$_.Exception.Message -ForegroundColor Red
    Read-Host "Press ENTER to exit"
}
"@
        $launchPath = Join-Path $installDir "start.ps1"
        $launchScript | Out-File -FilePath $launchPath -Encoding UTF8
        
        Write-Host "`n[+] Installation completed!" -ForegroundColor Green
        Write-Host "ChillTweak has been installed to: $installDir" -ForegroundColor Cyan
        Write-Host "You can start ChillTweak by:" -ForegroundColor Cyan
        Write-Host "1. Double-click the desktop shortcut" -ForegroundColor Cyan
        Write-Host "2. Run: $launchPath" -ForegroundColor Cyan
        Write-Host "`nNote: Always start ChillTweak as Administrator!" -ForegroundColor Yellow
    }
    catch {
        Write-Host "[!] Installation error:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Read-Host "Press ENTER to exit"
        return
    }
}

# Check administrator rights
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[!] This script requires administrator rights!" -ForegroundColor Red
    Write-Host "Please start PowerShell as Administrator and try again." -ForegroundColor Yellow
    Read-Host "Press ENTER to exit"
    return
}

# Start installation
Install-ChillTweak
Read-Host "Press ENTER to exit"
