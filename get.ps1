# ChillTweak One-Line Installer
# Usage: irm https://raw.githubusercontent.com/einspommes/chillTweak/main/get.ps1 | iex

$ErrorActionPreference = 'Stop'

Write-Host @"

╔═══════════════════════════════════════╗
║           c h i l l T w e a k          ║
║         One-Line Installer             ║
╚═══════════════════════════════════════╝

"@ -ForegroundColor Magenta

# Check for administrator rights
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[!] Administrator rights required!" -ForegroundColor Red
    Write-Host "[*] Restarting PowerShell as Administrator..." -ForegroundColor Yellow
    
    # Relaunch as administrator
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Wait
    exit
}

try {
    Write-Host "[*] Starting ChillTweak installation..." -ForegroundColor Cyan
    
    # Create installation directory
    $installDir = "$env:USERPROFILE\ChillTweak"
    if (-not (Test-Path $installDir)) {
        New-Item -Path $installDir -ItemType Directory -Force | Out-Null
        Write-Host "[+] Installation directory created: $installDir" -ForegroundColor Green
    }
    
    # Base URL for repository
    $baseUrl = "https://raw.githubusercontent.com/einspommes/chillTweak/main"
    
    # Download main script
    Write-Host "[*] Downloading ChillTweak..." -ForegroundColor Cyan
    $mainScriptUrl = "$baseUrl/chillTweak.ps1"
    $mainScriptPath = Join-Path $installDir "chillTweak.ps1"
    
    try {
        Invoke-WebRequest -Uri $mainScriptUrl -OutFile $mainScriptPath -UseBasicParsing
        Write-Host "[+] ChillTweak successfully downloaded" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Error downloading ChillTweak" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        throw
    }
    
    # Download config file if it doesn't exist
    $configDir = Join-Path $installDir "config"
    if (-not (Test-Path $configDir)) {
        New-Item -Path $configDir -ItemType Directory -Force | Out-Null
    }
    
    $configUrl = "$baseUrl/config/settings.json"
    $configPath = Join-Path $configDir "settings.json"
    
    if (-not (Test-Path $configPath)) {
        try {
            Invoke-WebRequest -Uri $configUrl -OutFile $configPath -UseBasicParsing
            Write-Host "[+] Configuration file downloaded" -ForegroundColor Green
        }
        catch {
            Write-Host "[!] Warning: Could not download configuration file" -ForegroundColor Yellow
        }
    }
    
    # Create desktop shortcut
    Write-Host "[*] Creating desktop shortcut..." -ForegroundColor Cyan
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopPath "ChillTweak.lnk"
    
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "powershell.exe"
    $shortcut.Arguments = "-NoExit -ExecutionPolicy Bypass -File `"$mainScriptPath`""
    $shortcut.WorkingDirectory = $installDir
    $shortcut.Description = "ChillTweak Windows Optimizer"
    $shortcut.IconLocation = "powershell.exe,0"
    $shortcut.WindowStyle = 1  # Normal window
    $shortcut.Save()
    
    Write-Host "[+] Desktop shortcut created" -ForegroundColor Green
    
    # Create start script
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
    Write-Host "`nChillTweak has been installed to: $installDir" -ForegroundColor Cyan
    Write-Host "`nYou can start ChillTweak by:" -ForegroundColor Cyan
    Write-Host "1. Double-click the desktop shortcut (Right-click → Run as Administrator)" -ForegroundColor White
    Write-Host "2. Run: $launchPath" -ForegroundColor White
    Write-Host "3. Direct start: powershell -ExecutionPolicy Bypass -File `"$mainScriptPath`"" -ForegroundColor White
    
    Write-Host "`n[!] IMPORTANT: Always start ChillTweak as Administrator!" -ForegroundColor Yellow
    
    # Ask if user wants to start ChillTweak now
    Write-Host "`nDo you want to start ChillTweak now? (Y/N)" -ForegroundColor Cyan
    $startNow = Read-Host
    
    if ($startNow -eq "Y" -or $startNow -eq "y") {
        Write-Host "`n[*] Starting ChillTweak..." -ForegroundColor Cyan
        Set-Location $installDir
        & $mainScriptPath
    }
    else {
        Write-Host "`nChillTweak can be started anytime via the desktop shortcut." -ForegroundColor Green
    }
}
catch {
    Write-Host "`n[!] Installation error:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nPlease try again or report the error." -ForegroundColor Yellow
    Read-Host "`nPress ENTER to exit"
    exit 1
}

