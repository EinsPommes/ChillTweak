# ChillTweak

Ein modularer Windows-Optimierer, der dir hilft, dein System zu optimieren und anzupassen.

## 🚀 Features

- 🔒 **Privatsphäre**: Deaktiviere Windows-Telemetrie und Tracking
- ⚡ **Performance**: Optimiere Windows für bessere Leistung
- 📦 **Software**: Installiere häufig benötigte Programme automatisch
- 🧹 **Reinigung**: Entferne temporäre Dateien und Windows-Update-Cache
- 💾 **Backup**: Erstelle Systemsicherungen (coming soon)
- 🌍 **Mehrsprachig**: Unterstützt Deutsch und Englisch
- 🛡️ **Sicherheit**: Verbessere die Windows-Sicherheitseinstellungen

## 📥 Installation

### Einfache Installation (Empfohlen)

1. Öffne PowerShell als Administrator
2. Führe folgenden Befehl aus:
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/einspommes/chillTweak/main/install.ps1" -UseBasicParsing | Invoke-Expression
```
3. Folge den Anweisungen auf dem Bildschirm

Das Installationsprogramm wird:
- ChillTweak in dein Benutzerverzeichnis installieren
- Eine Desktop-Verknüpfung erstellen
- Ein Start-Skript erstellen

### Manuelle Installation

1. Lade das Repository herunter
2. Entpacke es in einen Ordner deiner Wahl
3. Führe `chillTweak.ps1` als Administrator aus

## 🎮 Verwendung

1. Starte ChillTweak über die Desktop-Verknüpfung (Rechtsklick → Als Administrator ausführen)
2. Wähle im Hauptmenü die gewünschte Option:
   - 1️⃣ Privatsphäre
   - 2️⃣ Performance
   - 3️⃣ Software
   - 4️⃣ Reinigung
   - 5️⃣ Backup
   - 6️⃣ Hilfe
   - 7️⃣ Sprache
   - 8️⃣ Updates
   - Q️⃣ Beenden

## ⚠️ Wichtige Hinweise

- ChillTweak benötigt **Administratorrechte**
- Erstelle einen **Backup** vor größeren Änderungen
- Einige Funktionen erfordern einen **Neustart**
- Das Tool ist in **aktiver Entwicklung**

## 🛠️ Technische Details

- Geschrieben in PowerShell
- Modularer Aufbau für einfache Erweiterbarkeit
- Automatische Winget-Installation bei Bedarf
- JSON-basierte Konfiguration
- Ausführliche Fehlerbehandlung und Logging

## 🤝 Mitwirken

Beiträge sind willkommen! Du kannst:
- Fehler melden
- Neue Features vorschlagen
- Pull Requests einreichen

## 📜 Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert.

## 🙏 Danksagung

- Dank an alle Mitwirkenden
- Inspiriert von verschiedenen Windows-Optimierungstools
- Dank an die PowerShell-Community

---

Made with ❤️ by EinsPommes