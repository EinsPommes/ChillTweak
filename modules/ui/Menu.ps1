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
        Write-Host "[!] Fehler beim Laden der Systeminformationen" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Show-Menu {
    Clear-Host
    Write-Host "`n=== $($script:Translations[$script:CurrentLanguage]['Menu_Title']) ===" -ForegroundColor $script:primaryColor
    Write-Host "1. $($script:Translations[$script:CurrentLanguage]['Menu_Privacy'])" -ForegroundColor $script:secondaryColor
    Write-Host "2. $($script:Translations[$script:CurrentLanguage]['Menu_Performance'])" -ForegroundColor $script:secondaryColor
    Write-Host "3. $($script:Translations[$script:CurrentLanguage]['Menu_Software'])" -ForegroundColor $script:secondaryColor
    Write-Host "4. $($script:Translations[$script:CurrentLanguage]['Menu_Cleanup'])" -ForegroundColor $script:secondaryColor
    Write-Host "5. $($script:Translations[$script:CurrentLanguage]['Menu_Backup'])" -ForegroundColor $script:secondaryColor
    Write-Host "6. $($script:Translations[$script:CurrentLanguage]['Menu_Services'])" -ForegroundColor $script:secondaryColor
    Write-Host "7. $($script:Translations[$script:CurrentLanguage]['Menu_Help'])" -ForegroundColor $script:secondaryColor
    Write-Host "8. $($script:Translations[$script:CurrentLanguage]['Menu_Language'])" -ForegroundColor $script:secondaryColor
    Write-Host "9. $($script:Translations[$script:CurrentLanguage]['Menu_Updates'])" -ForegroundColor $script:secondaryColor
    Write-Host "Q. $($script:Translations[$script:CurrentLanguage]['Menu_Exit'])" -ForegroundColor $script:secondaryColor
}

function Show-Progress {
    param (
        [string]$Activity,
        [int]$PercentComplete,
        [string]$Status = "In Bearbeitung..."
    )
    try {
        Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
    }
    catch {
        Write-Host "[!] Fehler beim Anzeigen des Fortschritts" -ForegroundColor Red
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
        Write-Host "[!] Fehler beim Anzeigen der Hilfe" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
} 