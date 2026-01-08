param([switch]$TestMode)

# chillTweak - A modular Windows Tweaker
# Version: 1.0

# Base URL for modules
$baseUrl = "https://raw.githubusercontent.com/einspommes/chillTweak/main"

# Function to download modules
function Initialize-Modules {
    # Create module directories
    $moduleDirs = @(
        "modules/core",
        "modules/ui",
        "modules/system",
        "modules/security"
    )

    foreach ($dir in $moduleDirs) {
        if (-not (Test-Path $dir)) {
            New-Item -Path $dir -ItemType Directory -Force | Out-Null
        }
    }

    # Download modules
    $moduleFiles = @(
        "modules/core/Config.ps1",
        "modules/ui/Menu.ps1",
        "modules/system/Optimize.ps1",
        "modules/system/Backup.ps1",
        "modules/system/Cleanup.ps1",
        "modules/system/Software.ps1",
        "modules/security/Security.ps1"
    )

    foreach ($module in $moduleFiles) {
        $moduleUrl = "$baseUrl/$module"
        $localPath = $module

        try {
            Invoke-WebRequest -Uri $moduleUrl -OutFile $localPath -UseBasicParsing
            Write-Host "[+] Module downloaded: $module" -ForegroundColor Green
        }
        catch {
            Write-Host "[!] Error downloading $module" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
            return $false
        }
    }

    return $true
}

# Check if modules exist locally, if not, download them
$modulesExist = $true
$moduleFiles = @(
    "modules/core/Config.ps1",
    "modules/ui/Menu.ps1",
    "modules/system/Optimize.ps1",
    "modules/system/Backup.ps1",
    "modules/system/Cleanup.ps1",
    "modules/system/Software.ps1",
    "modules/security/Security.ps1"
)

foreach ($module in $moduleFiles) {
    if (-not (Test-Path $module)) {
        $modulesExist = $false
        break
    }
}

if (-not $modulesExist) {
    Write-Host "[*] Downloading modules..." -ForegroundColor Cyan
    if (-not (Initialize-Modules)) {
        Write-Host "[!] Error initializing modules" -ForegroundColor Red
        Exit
    }
}

# Global variables
$script:primaryColor = "Magenta"
$script:secondaryColor = "White"
$script:CurrentLanguage = "en"
$script:ConfigPath = "$env:USERPROFILE\Documents\chillTweak_config.json"

# Load modules
foreach ($module in $moduleFiles) {
    if (-not (Test-Path $module)) {
        Write-Host "[!] Module not found: $module" -ForegroundColor Red
        Exit
    }
    try {
        . $module
        Write-Host "[+] Module loaded: $module" -ForegroundColor Green
    }
    catch {
        Write-Host "[!] Error loading $module" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Exit
    }
}

# Main program
try {
    Test-AdminRights
    Import-Config
    
    do {
        Show-Menu
        $choice = Read-Host "`nChoose an option"
        
        switch ($choice) {
            "1" { Disable-Telemetry }
            "2" { Optimize-System }
            "3" { Install-CommonSoftware }
            "4" { Clear-SystemFiles }
            "5" { Backup-System }
            "6" { Optimize-WindowsServices }
            "7" { Show-Help }
            "8" { Set-Language; Save-Config }
            "9" { Update-Windows }
            "Q" { break }
            default { Write-Host "[!] Invalid input" -ForegroundColor Red }
        }
        
        if ($choice -ne "Q") {
            Write-Host "`nPress any key to continue..." -ForegroundColor $script:secondaryColor
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    } while ($choice -ne "Q")
    
    Write-Host "Program terminated." -ForegroundColor $script:primaryColor
}
catch {
    Write-Host "[!] An error occurred" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Exit
}