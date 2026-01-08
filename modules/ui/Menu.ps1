# UI-Funktionen
function Show-Banner {
    Clear-Host
    $version = "1.0"
    Write-Host @"

    ╔═══════════════════════════════════════╗
    ║           c h i l l T w e a k          ║
    ║              v$version                ║
    ╚═══════════════════════════════════════╝

"@ -ForegroundColor $script:primaryColor

    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $cpu = Get-CimInstance Win32_Processor
        $ram = [math]::Round(($os.TotalVisibleMemorySize / 1MB), 2)
        
        Write-Host "`n$(Get-Translation 'Banner_SystemInfo'):" -ForegroundColor $script:secondaryColor
        Write-Host "$(Get-Translation 'Banner_OS'): $($os.Caption)" -ForegroundColor $script:primaryColor
        Write-Host "$(Get-Translation 'Banner_CPU'): $($cpu.Name)" -ForegroundColor $script:primaryColor
        Write-Host "$(Get-Translation 'Banner_RAM'): $ram GB" -ForegroundColor $script:primaryColor
    }
    catch {
        Write-Host "[!] Error loading system information" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Show-Menu {
    Show-Banner
    Write-Host "`n=== ChillTweak Menu ===" -ForegroundColor $script:primaryColor
    Write-Host "[1] Privacy" -ForegroundColor $script:secondaryColor
    Write-Host "[2] Performance" -ForegroundColor $script:secondaryColor
    Write-Host "[3] Software" -ForegroundColor $script:secondaryColor
    Write-Host "[4] Cleanup" -ForegroundColor $script:secondaryColor
    Write-Host "[5] Backup" -ForegroundColor $script:secondaryColor
    Write-Host "[6] Windows Services" -ForegroundColor $script:secondaryColor
    Write-Host "[7] Help" -ForegroundColor $script:secondaryColor
    Write-Host "[8] Language" -ForegroundColor $script:secondaryColor
    Write-Host "[9] Updates" -ForegroundColor $script:secondaryColor
    Write-Host "[Q] Exit" -ForegroundColor $script:secondaryColor
}

function Show-Progress {
    param (
        [string]$Activity,
        [int]$PercentComplete,
        [string]$Status = "Processing..."
    )
    try {
        Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
    }
    catch {
        Write-Host "[!] Error displaying progress" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Show-Help {
    try {
        Write-Host "`n=== $(Get-Translation 'Menu_Help') ===" -ForegroundColor $script:primaryColor
        Write-Host "1. $(Get-Translation 'Menu_Privacy') - $(Get-Translation 'Help_Privacy')"
        Write-Host "2. $(Get-Translation 'Menu_Performance') - $(Get-Translation 'Help_Performance')"
        Write-Host "3. $(Get-Translation 'Menu_Software') - $(Get-Translation 'Help_Software')"
        Write-Host "4. $(Get-Translation 'Menu_Cleanup') - $(Get-Translation 'Help_Cleanup')"
        Write-Host "5. $(Get-Translation 'Menu_Backup') - $(Get-Translation 'Help_Backup')"
        Write-Host "6. $(Get-Translation 'Menu_Help') - $(Get-Translation 'Help_Help')"
        Write-Host "7. $(Get-Translation 'Menu_Language') - $(Get-Translation 'Help_Language')"
        Write-Host "8. $(Get-Translation 'Menu_Updates') - $(Get-Translation 'Help_Updates')"
    }
    catch {
        Write-Host "[!] Error displaying help" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
} 