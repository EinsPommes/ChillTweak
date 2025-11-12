# ChillTweak v2.0 - Comprehensive Feature Documentation

## 📋 Overview

ChillTweak v2.0 is a powerful, professional-grade Windows optimization tool designed to enhance your Windows experience through comprehensive system tweaks, privacy improvements, and performance optimizations.

---

## 🚀 Main Features

### 1. Privacy & Telemetry (Option 1)
Protect your privacy by disabling Windows telemetry and tracking features.

**Features:**
- Disable Windows telemetry services (DiagTrack, dmwappushservice)
- Disable data collection at registry level
- Block telemetry connections
- Disable remote registry access
- Disable Windows Media Player network sharing

**Affected Services:**
- Connected User Experiences and Telemetry (DiagTrack)
- WAP Push Message Routing Service (dmwappushservice)
- Program Compatibility Assistant
- Remote Registry
- Windows Media Player Network Sharing

---

### 2. Performance Optimization (Option 2)
Optimize Windows for maximum performance.

**Features:**
- Set power plan to High Performance
- Optimize energy settings (disable sleep, hibernate)
- Enable Game Mode
- Disable Game DVR
- Optimize visual effects for performance
- Disable unnecessary services (Superfetch, Windows Search)
- Configure Windows Defender for gaming
- Optimize network settings
- Registry optimizations for better responsiveness
- Clean temporary files

**Registry Tweaks:**
- LargeSystemCache: Optimized for applications
- IoPageLockLimit: Increased for better I/O
- Win32PrioritySeparation: Optimized for foreground apps
- SystemResponsiveness: Set to 0 for maximum performance
- NetworkThrottlingIndex: Disabled

---

### 3. Registry Tweaks (Option 3)
Customize Windows interface and behavior through registry modifications.

#### Windows Explorer Optimizations
- Show hidden files and folders
- Show file extensions
- Show full path in title bar
- Start with "This PC" instead of Quick Access
- Disable Quick Access history
- Enable checkboxes for file selection
- Show protected system files

#### Taskbar Optimizations
- Hide Task View button
- Hide People button
- Hide Cortana button
- Never combine taskbar buttons
- Enable small taskbar icons

#### Start Menu Optimizations
- Disable app suggestions
- Disable tracking of frequently used apps
- Optimize start menu layout

#### Context Menu Customization
- Add "Copy to" and "Move to" options
- Add "Command Prompt here"
- Add "PowerShell here"
- Custom entries support

#### Advanced Privacy Tweaks
- Disable Cortana completely
- Disable web search in Start Menu
- Disable advertising and auto app installation
- Disable activity history
- Disable location tracking
- Disable app diagnostics

**Safety:** All registry tweaks create a system restore point before making changes!

---

### 4. Network Optimization (Option 4)
Optimize network settings for better speed and lower latency.

#### TCP/IP Stack Optimization
- Increase TCP Window Size to 65535
- Enable TCP 1323 Timestamps
- Set DefaultTTL to 64
- Optimize KeepAlive Time
- Enable SYN Attack Protection
- Increase MaxUserPort to 65534
- Reduce TcpTimedWaitDelay to 30

#### DNS Cache Optimization
- Increase DNS cache size
- Extend DNS cache TTL
- Configure fast DNS servers:
  - Cloudflare (1.1.1.1, 1.0.0.1)
  - Google (8.8.8.8, 8.8.4.4)
  - Quad9 (9.9.9.9, 149.112.112.112)

#### Windows Auto-Tuning
- Set Auto-Tuning Level
- Enable Chimney Offload
- Enable Direct Cache Access
- Enable NetDMA
- Enable RSS (Receive Side Scaling)
- Set Congestion Provider to CTCP
- Enable ECN Capability

#### QoS Optimization
- Remove QoS bandwidth reservation (100% available)
- Disable Nagle Algorithm for lower latency
- Increase IRPStackSize for better network performance

#### Network Adapter Optimization
- Enable Large Send Offload
- Enable Receive Side Scaling
- Enable Jumbo Frames (for local networks)
- Enable Checksum Offload

#### Windows Firewall
- Configure firewall profiles
- Block incoming connections by default
- Enable logging

---

### 5. Disk Optimization (Option 5)
Optimize disk performance for both SSDs and HDDs.

#### Disk Fragmentation Check
- Analyze fragmentation levels
- Automatic SSD/HDD detection
- Run TRIM on SSDs
- Defragment HDDs when needed

#### SSD Optimization
- Enable TRIM
- Disable Superfetch
- Disable Prefetch
- Disable automatic defragmentation
- Optimize write caching

#### Pagefile Optimization
- Automatic management
- Fixed size (1.5x RAM)
- Move to fastest disk
- Disable option (for systems with lots of RAM)

#### Disk Cleanup
- Delete temporary files
- Clear Windows Update cache
- Clear Prefetch files
- Clear Thumbnail cache
- Delete Windows Error Reports
- Empty Recycle Bin
- Clear DNS cache

#### SMART Status
- Display disk health status
- Show disk type (SSD/HDD)
- Show disk size and status

---

### 6. Windows Services Optimization (Option 6)
Manage and optimize Windows services.

**Services that can be optimized:**
- DiagTrack (Telemetry)
- dmwappushservice (WAP Push)
- SysMain (Superfetch)
- WSearch (Windows Search)
- WMPNetworkSvc (Media Player)
- RemoteRegistry
- TapiSrv (Telephony)
- PhoneSvc (Phone Service)
- lfsvc (Geolocation)
- MapsBroker (Maps Manager)

**Options:**
- Disable all services
- Disable recommended services only
- Disable individual services

---

### 7. Configuration Profiles (Option 7)
Apply pre-configured optimization profiles with one click.

#### Gaming Profile
- Maximum performance power plan
- Enable Game Mode
- Disable Game DVR
- Optimize CPU priority for games
- Network optimizations (disable Nagle, reduce latency)
- Disable unnecessary services
- Minimize visual effects
- Enable Hardware-accelerated GPU scheduling

#### Privacy Profile
- Disable all telemetry
- Disable Cortana
- Disable web search
- Disable advertising
- Disable activity history
- Disable location tracking
- Configure Windows Defender for privacy

#### Performance Profile
- High Performance power plan
- Optimize visual effects
- Disable unnecessary services
- Network optimizations

#### Balanced Profile
- Standard Windows recommendations
- Minimal optimizations
- Balanced power plan

#### SSD Profile
- Enable TRIM
- Disable Superfetch
- Disable Prefetch
- Disable automatic defragmentation
- Optimize write caching

---

### 8. Software Installation (Option 8)
Install commonly used software automatically.

**Features:**
- Automatic Winget installation if missing
- Silent installation of software packages
- Pre-configured software list:
  - Mozilla Firefox
  - VLC Media Player
  - 7-Zip
  - Notepad++
  - Visual Studio Code
  - Google Chrome
  - Adobe Acrobat Reader
  - TeamViewer

---

### 9. System Cleanup (Option 9)
Clean temporary files and free up disk space.

**Cleanup targets:**
- Temporary files (%TEMP% and C:\Windows\Temp)
- Windows Update cache
- Prefetch files
- Thumbnail cache
- Windows Error Reports
- Recycle Bin
- DNS cache
- Windows Logs (optional)

---

### 10. Backup & Restore (Option 10)
Create system backups for safety.

**Features:**
- Backup important user folders
- Encrypted backups (optional)
- Automatic backup rotation (max 5 backups)
- Export system settings
- Registry backup

**Backed up folders:**
- Documents
- Desktop
- Pictures
- Start Menu Programs
- Windows shortcuts

---

### 11. Windows Updates (Option 11)
Manage Windows Updates.

**Features:**
- Check for available updates
- Install updates with user confirmation
- Automatic update management

---

### 12. System Dashboard (Option 12)
View comprehensive system information in real-time.

**Information displayed:**
- System Information (OS, Version, Build, Architecture)
- BIOS Information
- CPU Information (Name, Cores, Speed, Usage)
- RAM Information (Total, Used, Free, Usage %)
- Physical Disks (Type, Size, Health Status)
- Volumes (Drive letters, File system, Free space)
- Network Adapters (Status, Speed, MAC, IP)
- Graphics Card (Name, Driver, RAM)
- Windows Update Status
- Windows Defender Status
- Performance Metrics (Uptime, Processes)
- Top 5 Processes by CPU
- Top 5 Processes by RAM

**Export Options:**
- Export system report to text file
- Open report in Notepad

---

### 13. Logs (Option 13)
View and manage ChillTweak logs.

**Features:**
- View current session log
- List all log files
- Open log files in Notepad
- Open log directory in Explorer
- Clean up old logs
- Automatic log rotation (max 50 files, 30 days)

**Log Categories:**
- INFO: General information
- SUCCESS: Successful operations
- WARNING: Warnings
- ERROR: Errors
- DEBUG: Debug information

**Log Contexts:**
- General
- Registry
- Services
- Optimization
- Network
- Disk
- Backup
- Software
- Maintenance
- Profiles
- Error

**Log Summary:**
- Export log summary with statistics
- Error count and recent errors
- Success operation count

---

### 14. Help & Information (Option 14)
Get help and information about ChillTweak features.

**Information provided:**
- Feature descriptions
- Usage instructions
- Safety recommendations

---

### 15. Language Settings (Option 15)
Change the interface language.

**Supported Languages:**
- Deutsch (German)
- English

---

## 🛡️ Safety Features

### Automatic Restore Points
ChillTweak automatically creates Windows System Restore Points before making significant changes, especially:
- Registry modifications
- Service changes
- System optimizations

### Logging System
All changes are logged with:
- Timestamp
- Severity level
- Category
- Detailed description

### Error Handling
Comprehensive error handling ensures:
- Graceful failure recovery
- Detailed error messages
- No system damage on errors

### Validation
- Administrator rights verification
- System compatibility checks
- Automatic module loading

---

## 📊 Technical Details

### Architecture
- **Modular Design**: Each feature is in its own module
- **PowerShell Based**: Native Windows scripting
- **Registry Safe**: Creates restore points before changes
- **Service Safe**: Only modifies non-critical services

### Modules
- `modules/core/Config.ps1` - Configuration management
- `modules/core/Logging.ps1` - Logging system
- `modules/core/Security.ps1` - Security functions
- `modules/ui/Menu.ps1` - User interface
- `modules/system/Optimize.ps1` - Performance optimizations
- `modules/system/Registry.ps1` - Registry tweaks
- `modules/system/Network.ps1` - Network optimizations
- `modules/system/Disk.ps1` - Disk optimizations
- `modules/system/SystemInfo.ps1` - System information
- `modules/system/Profiles.ps1` - Configuration profiles
- `modules/system/Backup.ps1` - Backup functions
- `modules/system/Cleanup.ps1` - Cleanup functions
- `modules/system/Software.ps1` - Software installation
- `modules/security/Security.ps1` - Security features

### Configuration Files
- `config/settings.json` - Global settings
- `%USERPROFILE%\Documents\chillTweak_config.json` - User settings
- `%USERPROFILE%\Documents\ChillTweak_Logs\` - Log files

### Registry Locations
- `HKCU:\Software\ChillTweak` - ChillTweak settings
- Various Windows registry locations (documented in code)

---

## ⚠️ Important Notes

### Administrator Rights Required
ChillTweak requires administrator privileges to:
- Modify system settings
- Change registry values
- Manage Windows services
- Create restore points

### Restart Required
Some optimizations require a system restart to take effect:
- Registry changes
- Service modifications
- Power plan changes
- Network settings

### Backup Recommendations
Before using ChillTweak:
1. Create a full system backup
2. Create a system restore point
3. Note current settings

### Compatibility
- Windows 10 (1809 or later)
- Windows 11
- PowerShell 5.1 or later

### Known Limitations
- Some features require Windows Pro or Enterprise
- Network optimizations may need adjustment for specific hardware
- Game Mode features require Windows 10 1803+
- Hardware-accelerated GPU scheduling requires Windows 10 2004+

---

## 🔄 Reversibility

Most changes can be reversed:
1. Use System Restore to revert to a restore point
2. Manually re-enable services
3. Reset registry values to defaults
4. Use the Balanced Profile to restore defaults

---

## 📞 Support

For issues or questions:
- Check the logs in `%USERPROFILE%\Documents\ChillTweak_Logs\`
- Review the system dashboard for system status
- Create a system report for troubleshooting
- Check GitHub issues

---

## 📝 Version History

### Version 2.0 (Current)
- Complete rewrite with modular architecture
- Added 10+ new modules
- Added configuration profiles
- Added system dashboard
- Added comprehensive logging
- Added restore point creation
- Enhanced all optimization features
- Improved user interface

### Version 1.0
- Initial release
- Basic optimization features
- Simple menu system

---

Made with ❤️ by EinsPommes
