# Tattoo AI App – Setup & Start Phase Spec

## Zweck dieses Dokuments
Dieses Dokument beschreibt **nur die Aufsetzungs- und Startphase** des Projekts.  
Es ist dafür gedacht, in Antigravity bzw. im Coding-Setup als Grundlage zu dienen, damit das Projekt lokal sauber gestartet, ausgeführt und für die weitere Entwicklung vorbereitet werden kann.

Dieses Dokument behandelt **noch nicht** die vollständige Architektur-Fortsetzung, keine finale Feature-Implementierung und keine tiefe Backend-Integration.  
Fokus ist nur:

- Repository lokal verfügbar machen
- Flutter-Projekt lauffähig machen
- Android-Emulator starten
- MVP-Grundlage bootstrappen
- erste lauffähige App sehen
- saubere Basis für spätere Prompts schaffen

---

# 1. Projektkontext

## Projektname
Tattoo AI App

## MVP-Idee
Der User soll:

1. ein **Basisbild** hochladen können
2. zusätzlich **ein Referenz-Tattoo-Bild** und/oder **eine Textbeschreibung** angeben können
3. dann eine Tattoo-Generierung starten können

Im MVP gibt es **kein Login**.

---

# 2. Ziel der Aufsetzungsphase

Am Ende dieser Phase soll Folgendes funktionieren:

- Repository ist lokal geklont
- Flutter ist im Terminal verfügbar
- Android-Tooling funktioniert
- Emulator oder physisches Android-Gerät ist startklar
- Projekt startet mit `flutter run`
- App läuft erfolgreich
- Basisstruktur für MVP ist vorbereitet
- Es gibt eine erste einfache Start-App mit sauberer Grundlage

---

# 3. Voraussetzungen

## Benötigte Software
Folgende Tools müssen installiert oder verfügbar sein:

- Git
- Flutter SDK
- Android Studio
- Android SDK
- Android Emulator
- optional: VS Code / Antigravity als Editor
- optional: Chrome für Flutter Web Tests

## Prüfen, ob Flutter verfügbar ist
Im Terminal:

```bash
flutter --version
```

Wenn Flutter korrekt installiert ist, sollte eine Versionsausgabe erscheinen.

Danach:

```bash
flutter doctor
```

Ziel:
- keine kritischen Errors
- Android toolchain sollte ok sein
- Android Studio sollte erkannt werden
- mindestens ein Device/Emulator sollte später nutzbar sein

---

# 4. Repository klonen

## Ziel
Das bestehende Repository lokal auf den Rechner holen.

## Schritte
Im gewünschten Projektordner Terminal öffnen und ausführen:

```bash
git clone <REPO-URL>
```

Dann:

```bash
cd <REPO-NAME>
```

Wenn das Repository bereits besteht und nur verbunden werden muss, zuerst prüfen:

```bash
git remote -v
```

Wenn noch kein Remote gesetzt ist:

```bash
git remote add origin <REPO-URL>
```

---

# 5. Flutter-Projektstatus prüfen

Nach dem Klonen prüfen, ob bereits ein Flutter-Projekt vorliegt.

## Erwartete Flutter-Struktur
Im Root sollten typischerweise diese Dateien/Ordner existieren:

- `pubspec.yaml`
- `lib/`
- `android/`
- `ios/` (optional, wenn Plattform aktiv)
- `test/`

## Falls es schon ein Flutter-Projekt ist
Dann ausführen:

```bash
flutter pub get
```

## Falls es noch **kein** Flutter-Projekt ist
Dann im gewünschten Ordner ein neues Flutter-Projekt anlegen:

```bash
flutter create .
```

Wichtig:  
Nur dann `flutter create .` verwenden, wenn im aktuellen Repository wirklich noch **keine** Flutter-Struktur existiert.

Danach erneut:

```bash
flutter pub get
```

---

# 6. Android-Setup prüfen

## Emulator über Android Studio vorbereiten
Android Studio öffnen und:

1. **More Actions** oder **Device Manager** öffnen
2. ein Android Virtual Device erstellen
3. ein Standardgerät wählen, z. B. Pixel
4. ein aktuelles Android-Systemimage herunterladen
5. Emulator speichern
6. Emulator starten

## Prüfen, ob Gerät erkannt wird
Im Terminal:

```bash
flutter devices
```

Es sollte mindestens ein Device auftauchen, z. B. Emulator.

Optional auch:

```bash
adb devices
```

---

# 7. Projekt erstmal lauffähig machen

## Dependencies laden
Im Projektordner:

```bash
flutter pub get
```

## App starten
Mit laufendem Emulator:

```bash
flutter run
```

Wenn mehrere Devices existieren:

```bash
flutter run -d <deviceId>
```

Ziel:
- App kompiliert erfolgreich
- Standard- oder vorhandene Startseite öffnet sich
- Hot reload funktioniert

---

# 8. Was in der Startphase **noch nicht** gemacht wird

Diese Punkte sollen in der Setup-Phase bewusst **nicht** umgesetzt werden:

- kein Login
- keine Datenbank
- keine Cloud-Storage-Logik
- keine echte AI-API-Integration
- keine finale Projektarchitektur
- keine komplexe Navigation
- keine Persistenz über Sessions
- keine Samsung-spezifischen SDKs
- keine Produktionsoptimierung

Ziel ist zuerst nur eine **saubere lokale Entwicklungsbasis**.

---

# 9. Start-MVP technisch minimal aufsetzen

Nach erfolgreichem Start der App soll die App auf ein minimales MVP-Scaffold reduziert werden.

## Ziel dieser Mini-Version
Es soll zuerst nur eine einfache App-Struktur geben mit:

- AppBar / Titel
- Hinweistext
- Platzhalter für Basisbild
- Platzhalter für Referenzbild
- Platzhalter für Textbeschreibung
- Generate-Button (noch ohne echte Funktion)

Noch keine echte Business-Logik.  
Nur sichtbare Grundstruktur.

---

# 10. Empfohlene erste Dateistruktur

Für die Aufsetzungsphase reicht zunächst diese minimale Struktur:

```text
lib/
  main.dart
```

Optional direkt etwas sauberer:

```text
lib/
  main.dart
  app.dart
  screens/
    create_tattoo_screen.dart
```

Noch keine zu tiefe Struktur erzwingen.  
Erstmal nur so viel, dass der Einstieg sauber bleibt.

---

# 11. Empfohlene erste UI für den Start

Die erste MVP-Startansicht soll nur zeigen, dass die App läuft und inhaltlich korrekt ausgerichtet ist.

## Inhalt der ersten Screen-Version
- Titel: `Tattoo AI`
- kurzer Untertitel
- Bereich „Base Image“
- Bereich „Reference Tattoo (optional)“
- Bereich „Tattoo Description (optional)“
- Button „Generate Tattoo“

Diese Elemente dürfen anfangs nur statisch sein.

---

# 12. Validierungslogik als fachliche Notiz

Diese Regel ist für spätere Schritte wichtig und soll bereits jetzt dokumentiert sein:

## MVP-Regel
- `baseImage` ist Pflicht
- zusätzlich muss **mindestens eines** vorhanden sein:
  - `referenceImage`
  - `tattooDescription`

Logik:

```text
baseImage && (referenceImage || tattooDescription)
```

Diese Regel in der Setup-Phase nur dokumentieren, noch nicht vollständig umsetzen, wenn der Fokus nur auf Aufsetzung liegt.

---

# 13. Erste Testziele

Nach der Aufsetzungsphase soll geprüft werden:

## Technische Tests
- Projekt startet ohne Fehler
- Emulator wird erkannt
- `flutter run` funktioniert
- Hot reload funktioniert
- Codeänderung wird sichtbar

## Inhaltliche Tests
- Startscreen zeigt Tattoo-AI-Grundlayout
- Projekt lässt sich im Team reproduzierbar starten
- Repo ist sauber verbunden

---

# 14. Git-Workflow für den Start

## Empfohlen
Nach erfolgreicher Aufsetzung direkt ersten sauberen Commit machen.

```bash
git status
git add .
git commit -m "Initial Flutter setup and MVP start scaffold"
git push
```

Wenn auf Branches gearbeitet wird:

```bash
git checkout -b setup/flutter-initial
```

Dann committen und pushen.

---

# 15. Definition of Done für die Setup-Phase

Die Setup-Phase ist abgeschlossen, wenn:

- das Repo lokal geklont wurde
- Flutter im Projekt funktioniert
- alle Abhängigkeiten geladen wurden
- ein Emulator oder Android-Gerät verbunden ist
- die App erfolgreich startet
- ein erster einfacher Tattoo-AI-Startscreen sichtbar ist
- das Ganze im Repo committed ist

---

# 16. Hinweise für spätere Folgeprompts

Nach Abschluss dieser Phase können Folgeprompts auf diesen Punkten aufbauen:

- Projektstruktur erweitern
- Screens sauber aufteilen
- Image Picker integrieren
- State Management wählen
- Input-Validierung umsetzen
- echte Generate-Flow-Logik bauen
- AI-Backend-Schnittstelle vorbereiten

Wichtig:  
Spätere Prompts sollen **nicht** wieder bei null anfangen, sondern auf dieser Setup-Basis weiterarbeiten.

---

# 17. Nächster sinnvoller Prompt nach dieser Phase

Beispiel für den nächsten Prompt:

> Erstelle mir die nächste Projektphase für die Tattoo AI App in Flutter.  
> Das Setup steht bereits.  
> Baue jetzt eine saubere minimale Projektstruktur mit `main.dart`, `app.dart` und einem `create_tattoo_screen.dart`.  
> Gib mir die Dateien vollständig und nenne immer den genauen Dateipfad.

---

# 18. Kurzfassung für das Team

## Was jetzt gemacht wird
- Repo klonen
- Flutter prüfen
- Emulator starten
- App lauffähig machen
- einfachen Startscreen bauen
- initial committen

## Was jetzt noch nicht gemacht wird
- keine AI
- kein Login
- kein Backend
- keine Persistenz
- keine komplexen Features

Damit ist die Basis sauber vorbereitet.
