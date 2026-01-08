# ChillTweak

A modular Windows optimizer that helps you optimize and customize your system.

## 🚀 Features

- 🔒 **Privacy**: Disable Windows telemetry and tracking
- ⚡ **Performance**: Optimize Windows for better performance
- 📦 **Software**: Automatically install commonly needed programs
- 🧹 **Cleanup**: Remove temporary files and Windows Update cache
- 💾 **Backup**: Create system backups with encryption
- 🌍 **Multilingual**: Supports English and German
- 🛡️ **Security**: Improve Windows security settings

## 📥 Installation

### ⚡ One-Click Installation (Recommended)

Open PowerShell as Administrator and run this command:

```powershell
irm https://raw.githubusercontent.com/einspommes/chillTweak/main/get.ps1 | iex
```

That's it! ChillTweak will automatically:
- ✅ Download and install
- ✅ Create desktop shortcut
- ✅ Create start script
- ✅ Optionally start directly

### Alternative Installation

1. Open PowerShell as Administrator
2. Run the following command:
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/einspommes/chillTweak/main/install.ps1" -UseBasicParsing | Invoke-Expression
```

### Manual Installation

1. Download the repository
2. Extract it to a folder of your choice
3. Run `chillTweak.ps1` as Administrator

## 🎮 Usage

1. Start ChillTweak via the desktop shortcut (Right-click → Run as Administrator)
2. Choose the desired option from the main menu:
   - 1️⃣ Privacy
   - 2️⃣ Performance
   - 3️⃣ Software
   - 4️⃣ Cleanup
   - 5️⃣ Backup
   - 6️⃣ Windows Services
   - 7️⃣ Help
   - 8️⃣ Language
   - 9️⃣ Updates
   - Q️⃣ Exit

## ⚠️ Important Notes

- ChillTweak requires **Administrator rights**
- Create a **backup** before making major changes
- Some functions require a **restart**
- The tool is in **active development**

## 🛠️ Technical Details

- Written in PowerShell
- Modular structure for easy extensibility
- Automatic Winget installation when needed
- JSON-based configuration
- Comprehensive error handling and logging

## 🤝 Contributing

Contributions are welcome! You can:
- Report bugs
- Suggest new features
- Submit pull requests

## 📜 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Thanks to all contributors
- Inspired by various Windows optimization tools
- Thanks to the PowerShell community

---

Made with ❤️ by EinsPommes
