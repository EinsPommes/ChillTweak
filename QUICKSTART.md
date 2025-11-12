# ChillTweak v2.0 - Quick Start Guide

## 🚀 Quick Installation

### Method 1: One-Line Install (Recommended)
1. Open PowerShell as Administrator
2. Run this command:
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/einspommes/chillTweak/main/install.ps1" -UseBasicParsing | Invoke-Expression
```

### Method 2: Manual Install
1. Download the repository
2. Extract to a folder
3. Right-click `chillTweak.ps1` → Run with PowerShell (as Administrator)

---

## 🎯 First Time Setup

After installation, you'll find:
- **Desktop Shortcut**: `ChillTweak.lnk` (Right-click → Run as Administrator)
- **Installation Folder**: `%USERPROFILE%\ChillTweak`
- **Logs**: `%USERPROFILE%\Documents\ChillTweak_Logs`

---

## 💡 Recommended First Steps

### For Gamers
1. Start ChillTweak as Administrator
2. Select **[7] Profile** → **[1] Gaming Profile**
3. Wait for completion
4. Restart your computer
5. Enjoy better gaming performance!

### For Privacy-Conscious Users
1. Start ChillTweak as Administrator
2. Select **[7] Profile** → **[2] Privacy Profile**
3. Wait for completion
4. Restart your computer
5. Your privacy is now enhanced!

### For General Performance
1. Start ChillTweak as Administrator
2. Select **[7] Profile** → **[3] Performance Profile**
3. Wait for completion
4. Restart your computer
5. Experience faster Windows!

### For SSD Users
1. Start ChillTweak as Administrator
2. Select **[7] Profile** → **[5] SSD Profile**
3. Wait for completion
4. Your SSD is now optimized!

---

## 🔧 Common Use Cases

### "I want the best gaming performance"
```
[7] Profile → [1] Gaming Profile
Then:
[2] Performance Optimization (optional, for extra tweaks)
[5] Disk Optimization → [2] SSD TRIM (if you have an SSD)
```

### "I want maximum privacy"
```
[7] Profile → [2] Privacy Profile
Then:
[1] Privacy & Telemetry (for additional privacy tweaks)
[3] Registry Tweaks → [5] Advanced Privacy Tweaks
```

### "My computer is slow"
```
[2] Performance Optimization
[5] Disk Optimization
[9] System Cleanup
[6] Windows Services → [E] Disable Recommended
```

### "I want to customize Windows appearance"
```
[3] Registry Tweaks → [1] Windows Explorer
[3] Registry Tweaks → [2] Taskbar
[3] Registry Tweaks → [3] Start Menu
[3] Registry Tweaks → [4] Context Menu
```

### "My internet is slow"
```
[4] Network Optimization
Select options 1-5 based on your needs
```

### "I need to free up disk space"
```
[9] System Cleanup
[5] Disk Optimization → [4] Disk Cleanup
```

---

## 📊 Understanding the Menu

### Main Categories

**Optimizations** (Options 1-6)
- Individual optimization modules
- Fine-grained control
- For advanced users

**Configuration Profiles** (Option 7)
- One-click optimizations
- Pre-configured settings
- For quick setup

**System Management** (Options 8-11)
- Software installation
- Cleanup and maintenance
- Backup and updates

**Information & Settings** (Options 12-15)
- System information
- Logs and diagnostics
- Configuration

---

## ⚠️ Important Safety Tips

### Before Making Changes
1. ✅ **Create a backup** of important files
2. ✅ **Create a restore point** (ChillTweak does this automatically)
3. ✅ **Note your current settings**
4. ✅ **Close all important applications**

### After Making Changes
1. ✅ **Restart your computer** for changes to take effect
2. ✅ **Check the logs** if something doesn't work (`[13] Logs`)
3. ✅ **Review system dashboard** for system status (`[12] Dashboard`)

### If Something Goes Wrong
1. Use **System Restore** to revert changes
2. Check **ChillTweak logs** for error details
3. Apply the **[7] Balanced Profile** to reset to defaults
4. Manually re-enable any services you need

---

## 🎮 Gaming Optimization Checklist

Use this checklist for the best gaming experience:

- [ ] Apply Gaming Profile (`[7] → [1]`)
- [ ] Check SSD optimization (`[5] → [2]` if applicable)
- [ ] Disable unnecessary services (`[6] → [E]`)
- [ ] Optimize network settings (`[4] → [5] All optimizations`)
- [ ] Clean system files (`[9]`)
- [ ] Check system dashboard for hardware status (`[12]`)
- [ ] Restart computer
- [ ] Test your favorite game!

---

## 🔒 Privacy Enhancement Checklist

For maximum privacy:

- [ ] Apply Privacy Profile (`[7] → [2]`)
- [ ] Disable telemetry (`[1]`)
- [ ] Apply advanced privacy tweaks (`[3] → [5]`)
- [ ] Disable location tracking (included in Privacy Profile)
- [ ] Review Windows Update settings (`[11]`)
- [ ] Check system dashboard (`[12]`)
- [ ] Restart computer

---

## 🏎️ Performance Boost Checklist

For overall system performance:

- [ ] Apply Performance Profile (`[7] → [3]`)
- [ ] Optimize disk (`[5]`)
- [ ] Clean system (`[9]`)
- [ ] Optimize services (`[6] → [E]`)
- [ ] Configure visual effects (`[2]`)
- [ ] Review startup programs (in Performance Optimization)
- [ ] Restart computer

---

## 📈 Monitoring Your System

### Use the System Dashboard
Press `[12]` to view:
- CPU and RAM usage
- Disk health
- Network status
- Windows Defender status
- Top resource-consuming processes

### Check the Logs
Press `[13]` to:
- View what changes were made
- Check for errors
- Export log summaries
- Diagnose issues

### Create System Reports
In System Dashboard, export a report to:
- Document your system configuration
- Share with support
- Compare before/after changes

---

## 🔄 Reverting Changes

### Method 1: System Restore
1. Open System Restore (`systempropertiesprotection`)
2. Select a restore point created by ChillTweak
3. Follow the wizard
4. Restart

### Method 2: Balanced Profile
1. Open ChillTweak
2. Select `[7] Profile`
3. Select `[4] Balanced Profile`
4. Restart

### Method 3: Manual Revert
1. Check the logs to see what was changed
2. Manually reverse the changes
3. Re-enable services if needed
4. Reset registry values

---

## ❓ FAQ

### Q: Do I need to run ChillTweak regularly?
**A:** No, most optimizations are permanent. Run it when:
- You want to change settings
- After a major Windows update
- When experiencing performance issues

### Q: Will this break my Windows?
**A:** No, ChillTweak:
- Creates restore points automatically
- Only modifies non-critical settings
- Can be reverted with System Restore
- Logs all changes

### Q: Can I use this on multiple computers?
**A:** Yes! ChillTweak is portable and can be:
- Installed on multiple systems
- Run from a USB drive
- Used in enterprise environments

### Q: Which profile should I use?
**A:** It depends on your needs:
- **Gaming**: For gamers seeking maximum FPS
- **Privacy**: For privacy-focused users
- **Performance**: For general performance boost
- **Balanced**: For default Windows behavior
- **SSD**: For SSD-specific optimizations

### Q: How do I know if optimizations worked?
**A:** Check:
- System Dashboard for performance metrics
- Logs for successful operations
- In-game FPS (for Gaming Profile)
- Task Manager for resource usage
- Internet speed tests (for Network optimizations)

### Q: Can I combine profiles?
**A:** Profiles overwrite each other, but you can:
1. Apply a profile
2. Use individual optimization options to fine-tune
3. Changes are cumulative

### Q: Is this safe for my computer?
**A:** Yes, ChillTweak:
- Uses standard Windows APIs
- Doesn't install drivers
- Doesn't modify critical system files
- Creates restore points
- Is open source (you can review the code)

---

## 📞 Getting Help

### Resources
- 📖 **FEATURES.md**: Detailed feature documentation
- 📋 **README.md**: General information
- 📝 **Logs**: Check `%USERPROFILE%\Documents\ChillTweak_Logs\`
- 🐛 **GitHub Issues**: Report bugs or request features

### Common Issues

**Issue: "Script cannot be loaded"**
- Solution: Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

**Issue: "Access Denied"**
- Solution: Run PowerShell as Administrator

**Issue: "Module not found"**
- Solution: Modules will download automatically on first run

**Issue: "Changes not taking effect"**
- Solution: Restart your computer

---

## 🎯 Pro Tips

1. **Start with Profiles**: Use profiles first, then fine-tune with individual options
2. **Check Logs Regularly**: Review logs to understand what was changed
3. **Use System Dashboard**: Monitor your system health regularly
4. **Backup Settings**: Export system reports before major changes
5. **Test Changes**: Apply changes one at a time if unsure
6. **Read Documentation**: Check FEATURES.md for detailed information
7. **Keep Updated**: Check for ChillTweak updates regularly

---

## 🌟 Best Practices

### For Gamers
- Apply Gaming Profile
- Close background apps while gaming
- Monitor temperatures
- Keep drivers updated
- Disable Windows Update during gaming sessions

### For Privacy
- Apply Privacy Profile
- Review Windows Privacy settings manually
- Use a VPN for additional privacy
- Regularly check for telemetry re-enabling after updates
- Consider using alternative DNS servers

### For Performance
- Apply Performance Profile
- Keep only essential software installed
- Regularly clean temporary files
- Monitor disk space
- Defragment HDDs regularly (not SSDs!)

### For SSD Users
- Apply SSD Profile
- Never defragment SSDs
- Keep 20% free space
- Enable TRIM
- Update SSD firmware

---

## 🚀 Next Steps

After getting started:

1. **Explore Individual Options**: Try specific optimizations
2. **Monitor Performance**: Use System Dashboard regularly
3. **Review Logs**: Understand what ChillTweak is doing
4. **Fine-tune Settings**: Adjust based on your needs
5. **Share Feedback**: Help improve ChillTweak

---

Enjoy your optimized Windows experience! 🎉

Made with ❤️ by EinsPommes
