# ChillTweak

Ein modularer Windows-Optimierer, der dir hilft, dein System zu optimieren und anzupassen.

## 🚀 Features

### 🔒 Privatsphäre & Sicherheit
- Deaktiviere Windows-Telemetrie und Tracking
- Deaktiviere Cortana und Web-Suche
- Blockiere Werbung und App-Vorschläge
- Deaktiviere Aktivitätsverlauf und Standortverfolgung
- Windows Defender Optimierung

### ⚡ Performance-Optimierung
- Energieplan-Optimierung (Höchstleistung)
- Gaming-Optimierungen (Game Mode, GPU-Tweaks)
- RAM und Auslagerungsdatei-Optimierung
- Visuelle Effekte anpassen
- Windows-Dienste optimieren
- Autostart-Programme verwalten

### 🎨 Registry Tweaks
- **Windows Explorer**: Versteckte Dateien, Dateiendungen, Pfadanzeige
- **Taskleiste**: Buttons, Symbolgröße, Cortana-Deaktivierung
- **Startmenü**: App-Vorschläge deaktivieren, Layout optimieren
- **Kontextmenü**: Eigene Einträge hinzufügen (CMD, PowerShell, etc.)
- Wiederherstellungspunkte vor jeder Änderung

### 🌐 Netzwerk-Optimierung
- TCP/IP Stack Optimierung
- DNS Cache Optimierung
- Schnelle DNS-Server (Cloudflare, Google, Quad9)
- Windows Auto-Tuning
- QoS Packet Scheduler
- Netzwerkadapter-Optimierungen
- Firewall-Einstellungen

### 💿 Disk-Optimierung
- SSD TRIM Optimierung
- HDD Defragmentierung
- Auslagerungsdatei-Verwaltung
- Prefetch/Superfetch für SSD/HDD
- Erweiterte Disk-Bereinigung
- SMART-Status anzeigen

### 📦 Software-Management
- Automatische Winget-Installation
- Häufig benötigte Programme installieren
- Paketmanager-Integration

### 🧹 System-Reinigung
- Temporäre Dateien
- Windows Update Cache
- Prefetch-Dateien
- Thumbnail-Cache
- DNS Cache
- Papierkorb

### 💾 Backup & Wiederherstellung
- Systemsicherungen erstellen
- Verschlüsselte Backups
- Backup-Rotation
- Wiederherstellungspunkte

### 🌍 Weitere Features
- Mehrsprachig (Deutsch und Englisch)
- Modularer Aufbau
- Ausführliche Fehlerbehandlung
- Automatische Updates

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
   - **[1]** Privatsphäre & Telemetrie
   - **[2]** Performance-Optimierung
   - **[3]** Registry Tweaks (Explorer, Taskbar, etc.)
   - **[4]** Netzwerk-Optimierung
   - **[5]** Disk-Optimierung (SSD/HDD)
   - **[6]** Software-Installation
   - **[7]** System-Reinigung
   - **[8]** Windows-Dienste
   - **[9]** Backup & Wiederherstellung
   - **[10]** Windows Updates
   - **[11]** Hilfe & Informationen
   - **[12]** Sprache ändern
   - **[Q]** Beenden

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