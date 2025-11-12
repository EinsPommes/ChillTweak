# UI-Funktionen
function Show-Banner {
    Clear-Host
    $version = "2.0"
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
    Show-Banner
    Write-Host "`n=== chillTweak Hauptmenü ===" -ForegroundColor $script:primaryColor
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor $script:primaryColor
    Write-Host "║  Optimierungen                                            ║" -ForegroundColor $script:primaryColor
    Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor $script:primaryColor
    Write-Host "[1]  Privatsphaere & Telemetrie" -ForegroundColor $script:secondaryColor
    Write-Host "[2]  Performance-Optimierung" -ForegroundColor $script:secondaryColor
    Write-Host "[3]  Registry Tweaks (Explorer, Taskbar, etc.)" -ForegroundColor $script:secondaryColor
    Write-Host "[4]  Netzwerk-Optimierung" -ForegroundColor $script:secondaryColor
    Write-Host "[5]  Disk-Optimierung (SSD/HDD)" -ForegroundColor $script:secondaryColor
    Write-Host "[6]  Windows-Dienste optimieren" -ForegroundColor $script:secondaryColor
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor $script:primaryColor
    Write-Host "║  Konfigurations-Profile                                   ║" -ForegroundColor $script:primaryColor
    Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor $script:primaryColor
    Write-Host "[7]  Profile (Gaming, Privacy, Performance, etc.)" -ForegroundColor $script:secondaryColor
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor $script:primaryColor
    Write-Host "║  System-Verwaltung                                        ║" -ForegroundColor $script:primaryColor
    Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor $script:primaryColor
    Write-Host "[8]  Software-Installation" -ForegroundColor $script:secondaryColor
    Write-Host "[9]  System-Reinigung" -ForegroundColor $script:secondaryColor
    Write-Host "[10] Backup & Wiederherstellung" -ForegroundColor $script:secondaryColor
    Write-Host "[11] Windows Updates" -ForegroundColor $script:secondaryColor
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor $script:primaryColor
    Write-Host "║  Informationen & Einstellungen                            ║" -ForegroundColor $script:primaryColor
    Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor $script:primaryColor
    Write-Host "[12] System-Dashboard anzeigen" -ForegroundColor $script:secondaryColor
    Write-Host "[13] Logs anzeigen" -ForegroundColor $script:secondaryColor
    Write-Host "[14] Hilfe & Informationen" -ForegroundColor $script:secondaryColor
    Write-Host "[15] Sprache ändern" -ForegroundColor $script:secondaryColor
    Write-Host ""
    Write-Host "[Q]  Beenden" -ForegroundColor $script:secondaryColor
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