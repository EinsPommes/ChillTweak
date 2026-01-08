# Software installation functions
function Install-CommonSoftware {
    try {
        Write-Host "`n[*] Installing commonly needed software..." -ForegroundColor $script:primaryColor
        
        # Check if Winget is installed
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            Install-Winget
        }
        
        # List of programs to install
        $software = @(
            "Mozilla.Firefox",
            "VideoLAN.VLC",
            "7zip.7zip",
            "Notepad++.Notepad++",
            "Microsoft.VisualStudioCode",
            "Google.Chrome",
            "Adobe.Acrobat.Reader.64-bit",
            "TeamViewer.TeamViewer"
        )
        
        foreach ($app in $software) {
            try {
                Write-Host "[*] Installing $app..." -ForegroundColor $script:secondaryColor
                winget install --id $app --accept-source-agreements --accept-package-agreements --silent
                Write-Host "[+] $app successfully installed" -ForegroundColor $script:secondaryColor
            }
            catch {
                Write-Host "[!] Error installing $app" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
                continue
            }
        }
        
        Write-Host "[+] Software installation completed" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Error during software installation" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

function Install-Winget {
    try {
        Write-Host "[*] Installing Winget..." -ForegroundColor $script:primaryColor
        
        # Download Winget
        $wingetUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $wingetPath = "$env:TEMP\winget.msixbundle"
        
        Invoke-WebRequest -Uri $wingetUrl -OutFile $wingetPath
        
        # Install Winget
        Add-AppxPackage -Path $wingetPath
        
        # Cleanup
        Remove-Item $wingetPath -Force
        
        Write-Host "[+] Winget successfully installed" -ForegroundColor $script:secondaryColor
    }
    catch {
        Write-Host "[!] Error installing Winget" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}