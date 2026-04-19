# Tattoo AI MVP Spec

Stand: 2026-04-12

## 1. Ziel

Dieses Dokument ersetzt das alte reine Setup-Spec komplett.

Der MVP ist eine iOS-first Tattoo-Generation-App in Flutter mit:

- Firebase Auth
- RevenueCat Paywall
- serverseitiger Bildgenerierung mit Gemini
- Upload von Basisbild und optionalem Referenzbild
- optionalem Text-Prompt
- session-basierter Ergebnisanzeige
- Export / Download des generierten Bildes

Die App wird auf Windows entwickelt, aber spaeter fuer iOS auf einem Mac finalisiert, getestet und released.

## 2. Produktkern des MVP

Der User soll:

1. sich registrieren oder einloggen koennen
2. nur mit aktivem Paid-Zugang generieren koennen
3. ein Pflicht-Basisbild hochladen koennen
4. optional ein Referenz-Tattoo-Bild hochladen koennen
5. optional einen Text-Prompt eingeben koennen
6. eine Tattoo-Generation starten koennen
7. das Ergebnis in derselben Session sehen
8. das Ergebnis nach Photos speichern, teilen oder lokal exportieren koennen

Nicht Teil des MVP:

- permanente Galerie historischer Generierungen
- Community / Feed
- Mehrfach-Styles mit komplexem Preset-System
- Web-Release
- Android-Release
- Admin-Backend ausser Firebase Console

## 3. Harte Produktregeln

### Input-Validierung

Pflichtregel:

`baseImage && (referenceImage || tattooDescription)`

Das bedeutet:

- `baseImage` ist immer Pflicht
- zusaetzlich muss mindestens eines gesetzt sein:
  - `referenceImage`
  - `tattooDescription`

### Paywall-Regel

Ohne aktives RevenueCat-Entitlement darf kein Generate-Call ausgefuehrt werden.

### Session-Regel

Generierte Bilder werden nicht als langfristige User-History im Produkt gefuehrt.
Sie stehen nur in der aktuellen Session zur Verfuegung und koennen vom User exportiert werden.

## 4. Plattformstrategie

### Entwicklungsrealitaet

- Entwicklung primar auf Windows
- Flutter-Code, Firebase-Integration, Auth-Flows, App-Logik und UI koennen auf Windows umgesetzt werden
- iOS Build, Signierung, StoreKit-Test, echte In-App-Purchase-Tests, TestFlight und App Store Release brauchen spaeter zwingend einen Mac

### Konsequenz fuer den MVP

Der MVP wird technisch von Anfang an iOS-kompatibel geplant, aber der finale iOS-Handoff ist ein eigener Release-Schritt.

Der Kollege auf Mac uebernimmt spaeter:

- Xcode-Projekt-Checks
- Signing & Capabilities
- Apple-spezifische Entitlements
- StoreKit / RevenueCat iOS QA
- TestFlight
- App Store Submission

## 5. Auth-Konzept

### MVP-Auth-Methoden

Die App unterstuetzt im MVP:

- Email / Passwort
- Google Login
- Sign in with Apple

### Wichtige iOS-Release-Regel

Da die App auf iOS einen Drittanbieter-Login mit Google anbietet, wird fuer den spaeteren App-Store-Release auch Sign in with Apple eingeplant.
Das ist kein Nice-to-have, sondern Release-relevant.

### Firebase Auth Mapping

Jeder eingeloggte User besitzt eine Firebase UID.
Diese UID ist die zentrale Identitaet fuer:

- Firestore
- Storage-Pfade
- RevenueCat App User ID
- Generation Requests

## 6. Monetarisierung / Paywall

### RevenueCat im MVP

RevenueCat ist die zentrale Billing- und Entitlement-Schicht.

### Zielbild

- User loggt sich ein
- App identifiziert den User in RevenueCat mit Firebase UID
- RevenueCat liefert Customer Info + Entitlement Status
- ohne aktives Entitlement wird die Paywall gezeigt
- mit aktivem Entitlement wird die Create-Ansicht freigeschaltet

### MVP-Entitlement

Ein einziges Entitlement reicht fuer den MVP, z. B.:

- `pro`

### Paywall-Verhalten

- beim ersten Versuch zu generieren: Paywall oeffnen
- nach erfolgreichem Kauf oder Restore: Entitlement neu laden
- nur bei aktivem Entitlement darf die Function den Generate-Job annehmen

### Server-Schutz

Die Paywall darf nicht nur clientseitig sein.
Die serverseitige Generierungs-Function prueft vor jeder Generation ebenfalls den Entitlement-Status.

## 7. AI-Modellentscheidung fuer den MVP

### Standardmodell

Fuer den MVP wird standardmaessig verwendet:

- `gemini-2.5-flash-image`

### Warum dieses Modell

Begruendung fuer diese Wahl:

- stabiler Modellname statt Preview
- klar fuer schnelle native Bildgenerierung geeignet
- deutlich guenstiger als die neueren Preview-Modelle
- geringeres Produkt- und Betriebsrisiko fuer einen bezahlten MVP

### Nicht als Default im MVP

Diese Modelle werden vorerst nicht Default:

- `gemini-3.1-flash-image-preview` ("Nano Banana 2")
- `gemini-3-pro-image-preview`

Grund:

- beide sind Preview
- hoeheres Release-Risiko
- hoeherer Preis

### Spaetere Erweiterung

Das Modell muss serverseitig konfigurierbar sein, damit spaeter ohne App-Release gewechselt werden kann.

Empfohlen:

- Function Config / Environment Variable `IMAGE_MODEL`

Default im MVP:

- `gemini-2.5-flash-image`

## 8. Architekturentscheidung

### Grundsatz

Die bezahlte Bildgenerierung wird nicht direkt vom Client zum Modell geschickt.

### Warum

Auch wenn Firebase AI Logic Client-SDKs fuer Flutter existieren, ist fuer einen Paid-Flow die sicherere MVP-Architektur:

- Flutter App sammelt Input
- Firebase prueft User + Entitlement
- Cloud Function orchestriert den Generate-Job serverseitig
- Modellzugriff und Kostenkontrolle bleiben ausserhalb des Clients

### Ergebnis

Die App nutzt Firebase als Produkt- und Infrastruktur-Basis.
Die eigentliche Generate-Orchestrierung liegt in Cloud Functions.

## 9. Firebase-Services im MVP

Verwendete Services:

- Firebase Authentication
- Cloud Firestore
- Cloud Storage
- Cloud Functions
- Firebase App Check

Optional spaeter, aber nicht MVP-blocking:

- Remote Config
- Crashlytics
- Analytics

## 10. Datenmodell

### Firestore Collections

#### `users/{uid}`

Zweck:

- User-Profil
- Login-Metadaten
- Billing-Referenzen

Felder:

- `email`
- `displayName`
- `photoUrl`
- `providers[]`
- `revenueCatAppUserId`
- `createdAt`
- `updatedAt`

#### `entitlements/{uid}`

Zweck:

- serverlesbarer Cache des Billing-Status

Felder:

- `isPro`
- `source`
- `productId`
- `expiresAt`
- `updatedAt`

Wichtig:

- Client darf dieses Dokument nicht direkt schreiben
- Update kommt nur ueber RevenueCat-Webhooks oder gesicherte Serverlogik

#### `generation_requests/{requestId}`

Zweck:

- aktueller Generation-Job
- Status fuer UI

Felder:

- `uid`
- `status` (`draft`, `uploading`, `queued`, `generating`, `completed`, `failed`, `expired`)
- `baseImagePath`
- `referenceImagePath`
- `prompt`
- `model`
- `resultImagePath`
- `errorCode`
- `errorMessage`
- `createdAt`
- `updatedAt`
- `expiresAt`

Nur die letzten Session-Daten sind relevant; keine Produkt-Historie in der UI.

## 11. Storage-Struktur

### Ziel

Cloud Storage wird genutzt fuer:

- hochgeladene Basisbilder
- hochgeladene Referenzbilder
- generierte Ergebnisbilder

### Pfadkonvention

```text
users/{uid}/generation_requests/{requestId}/base.jpg
users/{uid}/generation_requests/{requestId}/reference.jpg
users/{uid}/generation_requests/{requestId}/result.png
```

### Aufbewahrung

Da der MVP session-basiert ist, werden diese Dateien nur temporaer gehalten.

Empfehlung:

- `expiresAt` pro Request setzen
- geplante Cleanup-Function loescht abgelaufene Firestore-Dokumente und Storage-Dateien
- Ziel-TTL im MVP: 24 Stunden

24 Stunden sind lang genug fuer Retry, Download und Support-Faelle, aber kurz genug, um keine echte Galerie aufzubauen.

## 12. Cloud Functions

### `createGeneration`

Typ:

- callable HTTPS Function oder HTTP Function mit Firebase Auth Token

Aufgaben:

1. Authentifizierung pruefen
2. Entitlement pruefen
3. Input-Regeln pruefen
4. Request-Dokument anlegen / aktualisieren
5. Bilder aus Storage lesen
6. Prompt fuer das Bildmodell zusammensetzen
7. Modell callen
8. Ergebnisbild in Storage speichern
9. Firestore-Status auf `completed` setzen
10. Fehler sauber als `failed` schreiben

### `syncRevenueCatEntitlement`

Typ:

- webhook endpoint

Aufgaben:

1. RevenueCat Event empfangen
2. betroffene Firebase UID aufloesen
3. `entitlements/{uid}` aktualisieren
4. optional `users/{uid}` Billing-Metadaten mitschreiben

### `cleanupExpiredGenerations`

Typ:

- scheduled Function

Aufgaben:

1. abgelaufene `generation_requests` finden
2. zugehoerige Storage-Dateien loeschen
3. Firestore-Dokument als `expired` markieren oder entfernen

## 13. Generate Flow

### Happy Path

1. User startet App
2. Firebase wird initialisiert
3. Auth-Status wird geladen
4. Falls ausgeloggt: Auth-Screen
5. Nach Login: RevenueCat initialisieren und mit Firebase UID verknuepfen
6. Entitlement laden
7. Falls kein `pro`: Paywall zeigen
8. Falls `pro`: Create-Screen freischalten
9. User waehlt `baseImage`
10. User waehlt optional `referenceImage`
11. User schreibt optional `tattooDescription`
12. App validiert `baseImage && (referenceImage || tattooDescription)`
13. App legt einen `generation_request` an
14. App laedt Bilder nach Storage hoch
15. App ruft `createGeneration`
16. Function generiert das Bild
17. App hoert auf Statusaenderungen in Firestore
18. Bei `completed` wird das Ergebnis angezeigt
19. User kann speichern, teilen oder erneut generieren

### Error States

- nicht eingeloggt
- kein aktives Entitlement
- Pflichtbild fehlt
- zweiter Input fehlt
- Upload fehlgeschlagen
- Function fehlgeschlagen
- Modellfehler / Timeout
- Export fehlgeschlagen

## 14. Prompt-Logik

### Inputs

Der Modell-Input kombiniert:

- Basisbild
- optionales Referenzbild
- optionalen Text-Prompt

### Prompt-Ziel

Das generierte Bild soll eine Tattoo-Idee liefern, die stilistisch zur Referenz und inhaltlich zum Prompt passt, aber sichtbar auf dem Basisbild-Kontext aufsetzt.

### Prompting-Regel fuer MVP

Das System-Prompting soll knapp und reproduzierbar bleiben.
Keine ueberkomplexen Chain-of-Thought-Konstrukte im MVP.

Empfohlen:

- klarer Stilauftrag
- Fokus auf tattoo-ready visual concept
- Hinweis auf placement / composition
- Hinweis auf clean linework / shading je nach Referenz und Prompt

## 15. Flutter App-Struktur fuer den MVP

Empfohlene Zielstruktur:

```text
lib/
  app.dart
  main.dart
  core/
    config/
    routing/
    theme/
    utils/
  features/
    auth/
      data/
      domain/
      presentation/
    billing/
      data/
      domain/
      presentation/
    tattoo_generation/
      data/
      domain/
      presentation/
    export/
      presentation/
  shared/
    widgets/
    services/
```

Fokus:

- keine uebertriebene Enterprise-Tiefe
- aber klar getrennt nach Auth, Billing und Generation

## 16. Client-seitige Services

### Auth Service

Verantwortung:

- Email / Passwort
- Google Login
- Apple Login
- aktuelle Firebase UID

### Billing Service

Verantwortung:

- RevenueCat SDK Setup
- Login / Logout mit Firebase UID synchronisieren
- Entitlements abrufen
- Paywall triggern
- Restore Purchases

### Generation Service

Verantwortung:

- lokale Validierung
- Bildauswahl
- Upload
- Generation Request starten
- Firestore-Status beobachten

### Export Service

Verantwortung:

- Ergebnisbild lokal cachen
- Share Sheet
- Save to Photos
- Download / Export

## 17. UI-Flows

### Auth Flow

- Welcome / Einstieg
- Login
- Registrierung
- Passwort vergessen
- Google Login
- Apple Login

### Paywall Flow

- kurzer Value Pitch
- Abo / Kaufoption
- Restore Purchases
- Close nur falls App danach noch begrenzt nutzbar ist

### Create Flow

- Base Image Upload
- Reference Image Upload
- Prompt Input
- Validation State
- Generate CTA
- Loading State
- Result Screen Inline oder als eigener View

### Result Actions

- Save to Photos
- Share
- Generate Again
- Start New

## 18. Security

### Firestore Rules

- User darf nur eigene `users/{uid}` lesen
- User darf nur eigene `generation_requests` lesen
- Client darf keine Entitlements schreiben
- sensible Statusfelder werden nur serverseitig gesetzt

### Storage Rules

- Upload und Read nur innerhalb des eigenen `uid`-Pfads
- keine offenen Buckets

### App Check

App Check wird eingeplant, um Backend-Missbrauch zu reduzieren.
Auf iOS spaeter mit Apple-geeigneter Attestation-Konfiguration finalisieren.

### Secrets

- keine Modell- oder Server-Secrets im Flutter-Client
- Modellzugriff nur serverseitig
- RevenueCat Public SDK Key darf in die App
- RevenueCat Secret / Webhook-Handling nur serverseitig

## 19. iOS-spezifische Release-Anforderungen

Vor dem iOS-Ship auf Mac muessen mindestens diese Punkte abgeschlossen sein:

- Sign in with Apple final implementiert
- Google Sign-In iOS sauber konfiguriert
- RevenueCat iOS Products in App Store Connect angelegt
- StoreKit / Sandbox Kauf getestet
- In-App Purchase Metadaten gepflegt
- Privacy Manifest / Datenschutztexte geprueft
- Photo Library Permission Strings gesetzt
- Camera / Photos Permission Strings gesetzt, falls benoetigt
- App Icons, Launch Assets, Bundle ID, Signing final

## 20. Was auf Windows machbar ist

Machbar auf Windows:

- Flutter App-Architektur
- Firebase-Projektaufbau
- Firestore / Storage / Functions Code
- RevenueCat Integration im Flutter-Code
- Auth-Flows
- Paywall-State-Handling
- Generate Flow
- Emulator-/Device-nahe App-Logik auf nicht-iOS Targets

Nicht final verifizierbar auf Windows:

- Xcode Build
- iOS Signierung
- StoreKit Kaufablauf
- Sign in with Apple nativer End-to-End-Test
- TestFlight / App Store Upload

## 21. MVP Definition of Done

Der MVP ist fertig, wenn:

- Firebase Projekt produktiv verbunden ist
- Email / Passwort Login funktioniert
- Google Login funktioniert
- Sign in with Apple fuer iOS-Release eingeplant und spezifiziert ist
- RevenueCat Entitlement den Zugriff korrekt sperrt / freischaltet
- Base Image Upload funktioniert
- optionales Reference Image funktioniert
- optionaler Prompt funktioniert
- Generate nur bei gueltigem Input startet
- serverseitige Function ein Bild erzeugt
- Ergebnis in derselben Session angezeigt wird
- User das Bild speichern oder teilen kann
- temporaere Assets automatisch bereinigt werden

## 22. Umsetzungsreihenfolge

### Phase 1

- Firebase Projekt anlegen
- Flutter Firebase Setup
- Auth-Grundlage

### Phase 2

- RevenueCat Setup
- Paywall
- Entitlement-Gating

### Phase 3

- Image Picker
- Form-Validierung
- Storage Upload

### Phase 4

- Cloud Function fuer Generate
- Firestore Status-Flow
- Ergebnisanzeige

### Phase 5

- Export / Share
- Cleanup Job
- QA

### Phase 6

- Mac-Handoff
- iOS native Finalisierung
- StoreKit / TestFlight / Release

## 23. Offene, aber bewusst verschobene Themen

Nicht MVP-blockend, aber spaeter sinnvoll:

- Verlauf / History
- Favoriten
- Presets fuer Tattoo-Stile
- Usage-Limits pro Tarif
- Watermark fuer Free Tier
- Push Notifications bei laengeren Jobs
- Moderation / Image Safety Layer
- Analytics / Funnel Tracking

## 24. Kurzentscheidung

Dies ist das verbindliche MVP-Zielbild:

- Flutter App
- iOS-first
- Entwicklung auf Windows, Release-Handoff spaeter auf Mac
- Firebase Auth + Firestore + Storage + Functions + App Check
- RevenueCat Paywall mit serverseitigem Entitlement-Check
- session-basierte Tattoo-Bildgenerierung
- Standardmodell: `gemini-2.5-flash-image`
- spaetere Modellumschaltung ohne App-Release moeglich
