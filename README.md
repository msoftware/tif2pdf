# tif2pdf

PowerShell-Skript zur automatisierten Konvertierung von TIFF-Dateien in PDF-Dateien mithilfe von [ImageMagick](https://imagemagick.org/).

Das Skript durchsucht ein angegebenes Verzeichnis nach TIFF-Dateien und erstellt für jede gefundene Datei eine separate PDF-Datei. Mehrseitige TIFF-Dateien werden dabei vollständig in eine mehrseitige PDF-Datei umgewandelt.

## Inhaltsverzeichnis

- [Features](#features)
- [Voraussetzungen](#voraussetzungen)
- [Installation](#installation)
- [Verwendung](#verwendung)
- [Parameter](#parameter)
- [Beispiele](#beispiele)
- [Funktionsweise](#funktionsweise)
- [Ausgabe und Protokollierung](#ausgabe-und-protokollierung)
- [Fehlerbehandlung](#fehlerbehandlung)
- [Bekannte Einschränkungen](#bekannte-einschränkungen)
- [Fehlerbehebung](#fehlerbehebung)
- [Lizenz](#lizenz)

## Features

- Automatische Konvertierung aller TIFF-Dateien in einem Verzeichnis.
- Unterstützung für die Dateiendungen `.tif` und `.tiff`.
- Unterstützung mehrseitiger TIFF-Dateien.
- Erstellung einer PDF-Datei pro TIFF-Datei.
- Verlustfreie ZIP-Komprimierung der Bilddaten bei der PDF-Erstellung.
- Optionale Drehung der Bilder um 90°, 180° oder 270° im Uhrzeigersinn.
- Frei konfigurierbares Eingabe- und Ausgabeverzeichnis.
- Automatische Erstellung des Ausgabeverzeichnisses, falls es noch nicht existiert.
- Prüfung, ob ImageMagick installiert und verfügbar ist.
- Prüfung des Konvertierungsergebnisses anhand des Rückgabecodes von ImageMagick.
- Fehlerbehandlung pro Datei, damit die Verarbeitung weiterer Dateien nach einem Fehler fortgesetzt werden kann.
- Zusammenfassung der erfolgreichen und fehlgeschlagenen Konvertierungen.

## Voraussetzungen

### Betriebssystem

- Windows 10 oder Windows 11
- Windows Server mit installierter PowerShell

### PowerShell

Das Skript ist für Windows PowerShell 5.1 und PowerShell 7 ausgelegt.

### ImageMagick

Für die Konvertierung wird ImageMagick benötigt.

Offizielle Website:

https://imagemagick.org/

Download:

https://imagemagick.org/script/download.php

Nach der Installation muss der Befehl `magick` über die Umgebungsvariable `PATH` erreichbar sein.

Die Installation lässt sich in PowerShell überprüfen:

```powershell
magick -version
```

Wird die installierte ImageMagick-Version angezeigt, ist der Befehl grundsätzlich verfügbar.

**Hinweis:** ImageMagick muss die Verarbeitung von PDF-Dateien unterstützen. Abhängig von der Installation können Sicherheitsrichtlinien die PDF-Erstellung verhindern. In diesem Fall müssen die ImageMagick-Konfiguration und die aktivierten Delegates geprüft werden.

## Installation

### 1. Projektverzeichnis erstellen

Beispielsweise:

```powershell
New-Item -ItemType Directory -Path "C:\Projekte\tif2pdf" -Force
```

### 2. Skript speichern

Speichere das PowerShell-Skript unter folgendem Pfad:

```text
C:\Projekte\tif2pdf\tif2pdf.ps1
```

### 3. ImageMagick installieren

Installiere ImageMagick über die offizielle Download-Seite und stelle sicher, dass `magick.exe` über `PATH` erreichbar ist.

Prüfe anschließend:

```powershell
Get-Command magick
```

Die Ausgabe sollte den Pfad zur ausführbaren Datei enthalten.

### 4. Skript ausführen

Wechsle in das Projektverzeichnis:

```powershell
Set-Location "C:\Projekte\tif2pdf"
```

Starte das Skript:

```powershell
.\tif2pdf.ps1
```

Standardmäßig werden die TIFF-Dateien im aktuellen Verzeichnis gesucht. Die erzeugten PDF-Dateien werden im selben Verzeichnis abgelegt.

Falls PowerShell die Skriptausführung aufgrund der Execution Policy verhindert, kann das Skript für den aktuellen Prozess beispielsweise so gestartet werden:

```powershell
powershell.exe -ExecutionPolicy Bypass -File "C:\Projekte\tif2pdf\tif2pdf.ps1"
```

Diese Option umgeht die Execution Policy für diesen Aufruf. Sie sollte nur für vertrauenswürdige Skripte verwendet werden und ersetzt keine Sicherheitsprüfung.

## Verwendung

### Standardaufruf

```powershell
.\tif2pdf.ps1
```

Das Skript verwendet das aktuelle Verzeichnis als Eingabe- und Ausgabeverzeichnis.

Beispiel:

```text
C:\Scans\
├── dokument1.tif
├── dokument2.tiff
└── dokument3.tif
```

Nach der Konvertierung:

```text
C:\Scans\
├── dokument1.tif
├── dokument1.pdf
├── dokument2.tiff
├── dokument2.pdf
├── dokument3.tif
└── dokument3.pdf
```

### Eingabeverzeichnis angeben

```powershell
.\tif2pdf.ps1 -InputDirectory "C:\Scans"
```

Das Skript verarbeitet alle TIFF-Dateien direkt im Verzeichnis `C:\Scans`.

### Eingabe- und Ausgabeverzeichnis angeben

```powershell
.\tif2pdf.ps1 `
    -InputDirectory "C:\Scans" `
    -OutputDirectory "C:\PDF"
```

Die TIFF-Dateien werden aus `C:\Scans` gelesen. Die PDF-Dateien werden in `C:\PDF` gespeichert.

Falls das Ausgabeverzeichnis nicht existiert, wird es automatisch erstellt.

### Bilder drehen

```powershell
.\tif2pdf.ps1 `
    -InputDirectory "C:\Scans" `
    -Rotate 90
```

Alle Seiten der TIFF-Dateien werden vor der PDF-Erstellung um 90° im Uhrzeigersinn gedreht.

### Aufruf über einen absoluten Skriptpfad

```powershell
& "C:\Projekte\tif2pdf\tif2pdf.ps1" `
    -InputDirectory "C:\Scans" `
    -OutputDirectory "C:\PDF"
```

Damit kann das Skript auch aus einem anderen Arbeitsverzeichnis gestartet werden.

## Parameter

Das Skript unterstützt folgende Parameter:

| Parameter | Typ | Standardwert | Beschreibung |
|---|---|---|---|
| `InputDirectory` | `string` | `.` | Verzeichnis, in dem nach TIFF-Dateien gesucht wird. |
| `OutputDirectory` | `string` | `""` | Zielverzeichnis für die erzeugten PDF-Dateien. Bei leerem Wert wird das Eingabeverzeichnis verwendet. |
| `Rotate` | `int` | `0` | Drehung der Bilder im Uhrzeigersinn in Grad. Erlaubt sind `0`, `90`, `180` und `270`. |

### InputDirectory

Legt das Verzeichnis fest, aus dem die TIFF-Dateien gelesen werden.

Beispiel:

```powershell
-InputDirectory "D:\Archiv\Scans"
```

Das Verzeichnis muss existieren. Andernfalls beendet das Skript die Verarbeitung mit einer Fehlermeldung.

### OutputDirectory

Legt fest, wo die PDF-Dateien gespeichert werden.

Beispiel:

```powershell
-OutputDirectory "D:\Archiv\PDF"
```

Existiert das Verzeichnis noch nicht, wird es automatisch erstellt.

Wird kein Ausgabeverzeichnis angegeben, werden die PDF-Dateien im Eingabeverzeichnis gespeichert.

### Rotate

Dreht die Bilder vor der Konvertierung im Uhrzeigersinn.

Beispiel:

```powershell
-Rotate 180
```

Erlaubte Werte:

| Wert | Wirkung |
|---|---|
| `0` | Keine Drehung (Standard). |
| `90` | Drehung um 90° im Uhrzeigersinn. |
| `180` | Drehung um 180°. |
| `270` | Drehung um 270° im Uhrzeigersinn (entspricht 90° gegen den Uhrzeigersinn). |

Andere Werte werden von PowerShell bereits beim Aufruf abgelehnt.

Die Drehung gilt für alle Seiten aller Dateien eines Laufs. Sollen Dateien unterschiedlich gedreht werden, muss das Skript für jede Gruppe separat aufgerufen werden.

## Beispiele

### Beispiel 1: Dokumente im Projektverzeichnis konvertieren

```powershell
Set-Location "C:\Projekte\tif2pdf"
.\tif2pdf.ps1
```

### Beispiel 2: Verzeichnis eines Scanners verarbeiten

```powershell
.\tif2pdf.ps1 `
    -InputDirectory "C:\Scanner\Import" `
    -OutputDirectory "C:\Scanner\PDF"
```

### Beispiel 3: Netzlaufwerk verwenden

```powershell
.\tif2pdf.ps1 `
    -InputDirectory "Z:\Dokumente\TIFF" `
    -OutputDirectory "Z:\Dokumente\PDF"
```

Bei Netzlaufwerken muss das ausführende Benutzerkonto Zugriff auf die Verzeichnisse haben. Bei geplanten Aufgaben sind zugewiesene Laufwerksbuchstaben möglicherweise nicht verfügbar. In diesem Fall sollte ein UNC-Pfad verwendet werden.

Beispiel:

```powershell
.\tif2pdf.ps1 `
    -InputDirectory "\\server\share\TIFF" `
    -OutputDirectory "\\server\share\PDF"
```

### Beispiel 4: Verarbeitung über eine geplante Aufgabe

Für die regelmäßige Verarbeitung kann das Skript über die Windows-Aufgabenplanung gestartet werden.

Programm:

```text
powershell.exe
```

Argumente:

```text
-NoProfile -File "C:\Projekte\tif2pdf\tif2pdf.ps1" -InputDirectory "C:\Scans" -OutputDirectory "C:\PDF"
```

Das Benutzerkonto der Aufgabe benötigt Lesezugriff auf das Eingabeverzeichnis sowie Schreibzugriff auf das Ausgabeverzeichnis.

### Beispiel 5: Quer eingescannte Dokumente aufrichten

```powershell
.\tif2pdf.ps1 `
    -InputDirectory "C:\Scans\Quer" `
    -OutputDirectory "C:\PDF" `
    -Rotate 270
```

Die Seiten werden um 270° im Uhrzeigersinn (also 90° gegen den Uhrzeigersinn) gedreht und anschließend als PDF gespeichert.

## Funktionsweise

### 1. Prüfung von ImageMagick

Das Skript prüft zunächst, ob der Befehl `magick` verfügbar ist.

Ist ImageMagick nicht installiert oder nicht über `PATH` erreichbar, wird eine Fehlermeldung ausgegeben.

### 2. Validierung der Verzeichnisse

Das Eingabeverzeichnis wird auf Existenz geprüft und aufgelöst.

Das Ausgabeverzeichnis wird entweder auf das Eingabeverzeichnis gesetzt oder bei Bedarf angelegt.

### 3. Ermittlung der TIFF-Dateien

Das Skript sucht mit `Get-ChildItem` nach Dateien mit folgenden Erweiterungen:

- `.tif`
- `.tiff`

Die Suche erfolgt ausschließlich im angegebenen Verzeichnis. Unterverzeichnisse werden nicht automatisch durchsucht.

### 4. Erzeugung der PDF-Dateien

Für jede gefundene TIFF-Datei wird der Dateiname ohne Erweiterung übernommen und die Endung `.pdf` ergänzt.

Beispiel:

```text
eingang.tif  -> eingang.pdf
archiv.tiff  -> archiv.pdf
```

Die Konvertierung erfolgt über ImageMagick:

```powershell
magick.exe "eingang.tif" -compress Zip "eingang.pdf"
```

Ist der Parameter `Rotate` gesetzt, wird zusätzlich die Option `-rotate` übergeben:

```powershell
magick.exe "eingang.tif" -rotate 90 -compress Zip "eingang.pdf"
```

ImageMagick verarbeitet dabei grundsätzlich alle Bilder beziehungsweise Frames der TIFF-Datei. Eine mehrseitige TIFF-Datei wird somit als mehrseitige PDF-Datei ausgegeben.

### 5. Prüfung des Ergebnisses

Nach dem Aufruf wird der Rückgabecode von ImageMagick geprüft. Zusätzlich wird kontrolliert, ob die Ausgabedatei existiert.

Bei Erfolg wird die Datei als erfolgreich konvertiert gezählt. Bei einem Fehler wird eine Warnung ausgegeben und die Verarbeitung mit der nächsten TIFF-Datei fortgesetzt.

### 6. Zusammenfassung

Am Ende werden die Anzahl erfolgreicher und fehlgeschlagener Konvertierungen sowie das Ausgabeverzeichnis angezeigt.

## Ausgabe und Protokollierung

Während der Verarbeitung gibt das Skript Statusmeldungen aus.

Beispiel:

```text
Konvertiere: dokument1.tif
Erfolgreich: C:\PDF\dokument1.pdf

Konvertiere: dokument2.tiff
Erfolgreich: C:\PDF\dokument2.pdf

Konvertierung abgeschlossen.
Erfolgreich: 2
Fehler:      0
Ausgabe:     C:\PDF
```

Die Meldungen werden standardmäßig nur in der PowerShell-Konsole ausgegeben. Eine separate Protokolldatei wird nicht automatisch erzeugt.

Für eine einfache Protokollierung kann die Ausgabe beim Aufruf umgeleitet werden:

```powershell
.\tif2pdf.ps1 `
    -InputDirectory "C:\Scans" `
    -OutputDirectory "C:\PDF" *>&1 |
    Out-File "C:\Projekte\tif2pdf\conversion.log" -Append -Encoding utf8
```

Damit werden die PowerShell-Ausgaben einschließlich Warnungen und Fehlern in einer Protokolldatei gesammelt. Für eine robuste Produktionsprotokollierung sollte zusätzlich ein Zeitstempel pro Lauf und pro Datei vorgesehen werden.

## Fehlerbehandlung

Das Skript behandelt Fehler auf mehreren Ebenen.

| Fehler | Verhalten |
|---|---|
| ImageMagick fehlt | Das Skript wird mit einer Fehlermeldung beendet. |
| Eingabeverzeichnis fehlt | Das Skript wird mit einer Fehlermeldung beendet. |
| Keine TIFF-Dateien vorhanden | Eine entsprechende Meldung wird ausgegeben; die Verarbeitung endet regulär. |
| Ausgabeverzeichnis fehlt | Das Verzeichnis wird automatisch erstellt. |
| Einzelne Datei kann nicht konvertiert werden | Eine Warnung wird ausgegeben; weitere Dateien werden verarbeitet. |
| ImageMagick liefert einen Fehlercode | Die betreffende Konvertierung wird als fehlgeschlagen gezählt. |
| PDF-Datei wurde nicht erzeugt | Die Konvertierung wird als fehlgeschlagen gezählt. |

## Bekannte Einschränkungen

### Keine rekursive Suche

Es werden nur TIFF-Dateien direkt im Eingabeverzeichnis verarbeitet.

Dateien in Unterverzeichnissen werden ignoriert.

### Bestehende PDF-Dateien

Das Skript verwendet den ursprünglichen Dateinamen als PDF-Dateinamen. Existiert bereits eine PDF-Datei mit demselben Namen, kann ImageMagick diese überschreiben.

Vor einer Verarbeitung produktiver Dokumentenbestände sollte deshalb geprüft werden, ob vorhandene PDFs erhalten bleiben müssen.

### Dateinamenkollisionen

Dateien wie `dokument.tif` und `dokument.tiff` haben denselben Basisnamen. Beide würden auf `dokument.pdf` abgebildet. Solche Namenskollisionen sollten vor der Verarbeitung ausgeschlossen oder durch eine zusätzliche Kollisionsprüfung behandelt werden.

### Bildqualität und Dateigröße

Die Option `-compress Zip` verwendet ZIP-Komprimierung für die Bilddaten im PDF. Die Komprimierung ist verlustfrei, sofern das Bild bei der Konvertierung nicht anderweitig verändert wird.

Die resultierende PDF-Datei kann trotzdem größer oder kleiner als die TIFF-Datei ausfallen. Das hängt unter anderem von der ursprünglichen Komprimierung, den Farbräumen und der Anzahl der Seiten ab.

### Metadaten

Die Konvertierung übernimmt nicht zwangsläufig sämtliche TIFF-Metadaten in das PDF. Falls beispielsweise Dokumenteigenschaften, Farbprofile, Auflösung oder spezielle Scaninformationen erhalten bleiben müssen, ist eine gesonderte Prüfung erforderlich.

### ImageMagick-Sicherheitsrichtlinien

Ein Fehler wie `not authorized` beim Schreiben einer PDF-Datei kann durch die Sicherheitskonfiguration von ImageMagick verursacht werden.

In diesem Fall müssen die aktiven Policies und gegebenenfalls die PDF-Delegate-Konfiguration geprüft werden. Sicherheitsrichtlinien sollten nicht pauschal deaktiviert werden.

### PDF-Ausgabe überprüfen

Ein erfolgreicher Rückgabecode und eine vorhandene PDF-Datei garantieren nicht in jedem Fall, dass das PDF inhaltlich korrekt ist. Bei geschäftskritischen Dokumenten empfiehlt sich eine zusätzliche Validierung der erzeugten PDFs.

## Fehlerbehebung

### `magick` wurde nicht gefunden

Prüfe die Installation:

```powershell
Get-Command magick
```

Falls kein Ergebnis zurückgegeben wird, kontrolliere den Installationspfad und die Umgebungsvariable `PATH`. Öffne nach einer Änderung gegebenenfalls eine neue PowerShell-Sitzung.

### PDF-Erstellung wird verweigert

Prüfe die ImageMagick-Konfiguration und die Fehlermeldungen. Eine Ablehnung der PDF-Ausgabe kann durch eine Sicherheitsrichtlinie oder eine fehlende Abhängigkeit verursacht werden.

### TIFF-Datei kann nicht gelesen werden

Teste die Quelldatei direkt:

```powershell
magick identify "C:\Scans\dokument.tif"
```

Bei mehrseitigen TIFF-Dateien kann die Seitenanzahl beispielsweise mit folgendem Befehl ermittelt werden:

```powershell
magick identify "C:\Scans\dokument.tif"
```

ImageMagick gibt für erkannte Bilder beziehungsweise Frames Informationen aus. Vergleiche die Anzahl mit der erwarteten Seitenzahl.

### Ausgabedatei wird nicht erstellt

Prüfe:

- Schreibrechte im Ausgabeverzeichnis.
- Ob die Zieldatei durch einen anderen Prozess gesperrt ist.
- Ob eine ImageMagick-Sicherheitsrichtlinie die PDF-Ausgabe verhindert.
- Ob genügend Speicherplatz verfügbar ist.
- Ob ImageMagick beim Aufruf einen Fehlercode zurückliefert.

## Lizenz

Dieses Projekt stellt ein PowerShell-Skript zur Verwendung mit ImageMagick bereit.

ImageMagick wird separat installiert und unterliegt seinen eigenen Lizenzbedingungen. Informationen dazu finden sich in der offiziellen Dokumentation:

https://imagemagick.org/script/license.php

## Zusammenfassung

`tif2pdf` ermöglicht die einfache Stapelkonvertierung von TIFF-Dateien in PDF-Dateien unter Windows. Durch die Verwendung von ImageMagick werden auch mehrseitige TIFF-Dateien unterstützt. Eingabe- und Ausgabeverzeichnisse können über Parameter festgelegt werden, und Fehler einzelner Dateien verhindern nicht automatisch die Verarbeitung der übrigen Dateien.
