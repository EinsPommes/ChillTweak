# 🌸 chillTweak

Ein moderner Windows Tweaker mit pink-weißem Design für schnelle und einfache Systemoptimierung.

## 🚀 Schnellstart

1. PowerShell als Administrator öffnen
2. Diesen Befehl kopieren und einfügen:
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/einspommes/chillTweak/main/chillTweak.ps1" -UseBasicParsing | Invoke-Expression

3. Skript ausführen:

## ✨ Features

### 🛡️ Privatsphäre
- Windows Telemetrie deaktivieren
- Tracking-Dienste stoppen
- Datenschutz verbessern

### ⚡ Performance
- Höchstleistungs-Energieplan aktivieren
- Visuelle Effekte optimieren
- Systemleistung verbessern

### 📦 Software
Automatische Installation von:
- 7-Zip
- Notepad++
- VLC Media Player

### 🧹 Reinigung
- Temporäre Dateien löschen
- Papierkorb leeren
- Speicherplatz optimieren

### 💾 Backup
- Benutzerordner sichern (Dokumente, Bilder, Desktop)
- Registry-Einstellungen exportieren
- Vollständige System-Backups erstellen
- AES-256 Verschlüsselung der Backups
- Sicherer Schlüssel-Export

## 📋 Voraussetzungen

- Windows 10 oder 11
- PowerShell 5.1+
- Administratorrechte
- Internetverbindung

## 📁 Projektstruktur

```
ChillTweak/
├── chillTweak.ps1          # Hauptskript
├── README.md               # Dokumentation
├── modules/
│   ├── core/
│   │   ├── Config.ps1      # Konfigurationsfunktionen
│   │   └── Security.ps1    # Sicherheitsfunktionen
│   ├── system/
│   │   ├── Backup.ps1      # Backup-Funktionen
│   │   ├── Cleanup.ps1     # Aufräumfunktionen
│   │   ├── Optimize.ps1    # Optimierungsfunktionen
│   │   └── Software.ps1    # Software-Installation
│   └── ui/
│       └── Menu.ps1        # Menü und UI-Funktionen
└── config/
    └── settings.json       # Standardeinstellungen
```

## 💡 Verwendung

1. **Start:**
   - PowerShell als Administrator öffnen
   - Schnellstart-Befehl eingeben

2. **Navigation:**
   - Optionen mit Zahlen [1-6] auswählen
   - [Q] zum Beenden
   - Beliebige Taste zum Fortfahren

3. **Backup-Speicherort:**
   - `%USERPROFILE%\Documents\chillTweak_Backups`

4. **Logs:**
   - `%USERPROFILE%\Documents\chillTweak_log.txt`

## ⚠️ Wichtige Hinweise

- Vor Verwendung System-Backup erstellen
- Nur als Administrator ausführen
- Nach manchen Änderungen Neustart erforderlich
- Bei Problemen Logs prüfen

## 🛠️ Entwicklung

### Mitarbeit
1. Repository forken
2. Feature-Branch erstellen
3. Änderungen committen
4. Pull Request öffnen

### Kontakt
- GitHub Issues für Bugs
- Pull Requests für Features

### Logging
- Einfache Fehlerprotokollierung
- Klare Fehlermeldungen
- Benutzerfreundliche Statusmeldungen

### Sicherheit
- Verschlüsselte Backups mit AES-256
- Sichere Zufallszahlengenerierung für Schlüssel
- Automatische Schlüsselverwaltung

## 📄 Lizenz

MIT-Lizenz - Siehe [LICENSE](LICENSE)

## 👥 Team

- Entwickler: Jannik
- Design: Jannik

---

Made with 💖 in Germany
