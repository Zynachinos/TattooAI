# Tattoo AI MVP Step-by-Step

Stand: 2026-04-19
Bezug: `tattoo_ai_mvp_spec.md`

---

## Arbeitsregeln (für die KI – immer lesen)

1. **Status darf die KI NIE selbst ändern.** Nur der User ändert `Locked → Active` oder `Active → Done`.
2. **Die KI führt nur Schritte aus, die explizit auf `Active` stehen.**
3. **Bei `Locked`-Schritten: nur lesen, nicht ausführen, nicht vorbereiten.**
4. Wenn ein Schritt `Active` wird und die KI etwas braucht (Keys, IDs, Pfade), fragt sie gezielt.
5. Kein paralleles Aktivieren mehrerer Phasen-Blöcke.

### Statuslegende

```
Status: Locked   → darf noch nicht angefasst werden
Status: Active   → wird gerade bearbeitet
Status: Done     → abgeschlossen und verifiziert
```

### Zuständigkeiten

- **Du machst** = Accounts, Konsolen, Klickpfade, Secrets, externe Dashboards
- **KI macht** = Code, lokale Dateien, technische Anleitungen im Repo

---

## Plattformstrategie (Entscheidung 2026-04-19)

**Entwicklung auf Windows, Android zuerst, iOS später auf Mac.**

- Flutter-Code, Firebase, RevenueCat, Auth, Paywall, Generate Flow → alles auf Windows umsetzbar
- Android Build und Test → auf Windows möglich (Android Studio / Emulator)
- iOS Build, Signing, StoreKit, TestFlight, App Store → braucht Mac, kommt später
- Das Design wird mit Claude Design erstellt und danach in Flutter implementiert
- iOS kann nachträglich mit identischem Flutter-Code und angepassten nativen Configs released werden — bei gutem Flutter-UI sieht das nativ aus

---

## Phase 0 – Arbeitsmodus

### 0.1 Dieses Dokument als einziges Execution-Board verwenden

Status: Done

Du machst:
- Dieses File bei jedem neuen Arbeitsschritt zuerst öffnen
- Vor einem neuen Schritt den gewünschten Punkt manuell auf `Active` setzen
- Nach erfolgreicher Prüfung den Punkt auf `Done` setzen

KI macht:
- Führt nur Schritte aus, die auf `Active` stehen
- Wartet bei `Locked`-Schritten, fragt nicht vor
- Orientiert sich immer an diesem File und am MVP-Spec

Done wenn: User und KI dieses File als verbindliche Steuerung benutzen

---

### 0.2 Alte Schritte nie parallel aktivieren

Status: Done

Du machst:
- Immer nur einen zusammenhängenden Block gleichzeitig auf `Active` setzen

KI macht:
- Arbeitet keine späteren `Locked`-Schritte vor
- Mischt keine fremden Phasen in den aktiven Block

Done wenn: immer klar ist, was gerade bearbeitet wird

---

### 0.3 Flutter Projekt initialisiert

Status: Done

Ergebnis im Repo:
- `lib/main.dart` und `lib/app.dart` existieren
- `lib/screens/create_tattoo_screen.dart` als Platzhalter vorhanden
- Android- und iOS-Ordnerstruktur angelegt
- Noch kein Firebase, kein RevenueCat, keine Feature-Struktur

---

## Phase 1 – Produkt- und Account-Grundlage

### 1.1 Firebase-Projekt anlegen

Status: Done

Du machst:
- In Firebase Console ein neues Projekt für Tattoo AI anlegen
- Blaze Plan aktivieren (wegen Functions, Storage, Bildgenerierung)
- Projekt-ID notieren
- Region für Functions festlegen

KI macht (sobald Active):
- Sagen, welche Projektdaten für die Code-Integration gebraucht werden:
  - `projectId`
  - `appId` (Android)
  - `apiKey`
  - `storageBucket`
  - `messagingSenderId`
  - `measurementId` (optional)

Done wenn:
- Firebase-Projekt existiert
- Blaze aktiv
- Projekt-ID dokumentiert

---

### 1.2 Firebase Auth Provider vorbereiten

Status: Done

Du machst:
- Email/Password in Firebase Auth aktivieren
- Google Sign-In in Firebase Auth aktivieren
- Apple Provider noch nicht aktivieren (kommt beim iOS-Handoff)

KI macht:
- Flutter-Integration für Email/Password und Google vorbereiten
- Apple Login nur anlegen, wenn ein späterer Schritt es aktiviert

Done wenn:
- Email/Password aktiv
- Google Provider aktiv

---

### 1.3 RevenueCat Account und Projekt anlegen

Status: Locked

Du machst:
- RevenueCat Account / Projekt anlegen (app.revenuecat.com)
- Android App anlegen → Package: `com.app.TattooAI`
- Entitlement anlegen → ID exakt: `TattooAI Pro`
- Offering anlegen → 3 Packages: `lifetime`, `yearly`, `monthly`
- Android API Key (sieht aus wie `goog_xxxxx`) notieren
- Key in `lib/core/config/app_config.dart` bei `_androidKey` eintragen

KI macht:
- Nichts mehr — Code ist bereits fertig (siehe 4.1–4.3)

Code-Status (bereits umgesetzt, wartet nur auf echten API Key):
- `lib/core/config/app_config.dart` → Platzhalter `_androidKey` vorhanden
- `lib/features/billing/billing_service.dart` → `BillingService` vollständig implementiert
- `pubspec.yaml` → `purchases_flutter` + `purchases_ui_flutter` bereits drin

Done wenn:
- RevenueCat Projekt existiert
- Entitlement `TattooAI Pro` existiert
- Offering mit `lifetime` / `yearly` / `monthly` angelegt
- Echter Android API Key in `app_config.dart` eingetragen

---

### 1.4 Mac-Handoff für iOS planen

Status: Locked

Du machst:
- Klären, wer später Apple Developer, App Store Connect, Bundle ID, IAP-Produkte und TestFlight übernimmt
- Verantwortlichkeiten kurz notieren

KI macht:
- Knappe Handoff-Checkliste aus dem Spec formulieren

Done wenn:
- klar ist, wer den iOS-Release-Teil übernimmt

---

## Phase 2 – Flutter- und Firebase-Basis im Repo

### 2.1 Flutter Firebase Core Setup anlegen

Status: Done

Code-Status:
- `pubspec.yaml` → `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` eingetragen
- `lib/firebase_options.dart` → Android-Config mit Projekt `tattooai-3ca74`
- `lib/main.dart` → `Firebase.initializeApp()` vor `runApp()`
- `android/app/google-services.json` → vorhanden (in `.gitignore`)
- `android/settings.gradle.kts` + `android/app/build.gradle.kts` → google-services Plugin eingebunden
- `applicationId` auf `com.app.TattooAI` gefixt (matcht Firebase-Registrierung)

Done wenn:
- Firebase im Flutter-Projekt initialisiert wird
- App mit Firebase-Setup startet

---

### 2.2 Grundstruktur nach Feature-Bereichen anlegen

Status: Done

Du machst:
- Nichts außer Aktivierung

KI macht:
- Projektstruktur gemäß MVP-Spec anlegen:
  ```
  lib/
    app.dart
    main.dart
    core/config/ routing/ theme/ utils/
    features/
      auth/data/ domain/ presentation/
      billing/data/ domain/ presentation/
      tattoo_generation/data/ domain/ presentation/
      export/presentation/
    shared/widgets/ services/
  ```

Done wenn:
- Zielstruktur im Repo sichtbar

---

### 2.3 Environments und Secrets-Schnittstellen vorbereiten

Status: Locked

Du machst:
- Noch keine echten Secrets in den Chat

KI macht:
- Sichere Config-Schnittstellen anlegen
- Keine Server-Secrets im Client
- Platzhalter / Dokumentation für nötige lokale Werte

Done wenn:
- klar ist, welche Werte lokal, serverseitig und in RevenueCat/Firebase gepflegt werden

---

## Phase 3 – Auth

### 3.1 Email/Password Auth Flow bauen

Status: Locked

Du machst:
- Firebase Auth Provider muss aktiv sein (1.2)

KI macht:
- Login, Registrierung und Logout im Flutter-Code bauen
- Auth-State Handling anbinden
- einfache Fehlerfälle sichtbar machen

Done wenn:
- Registrierung und Login mit Email/Password funktionieren

---

### 3.2 Google Login Flow bauen

Status: Locked

Du machst:
- Firebase Google Provider muss aktiv sein
- OAuth-Konfiguration in Firebase/Google Cloud abschließen

KI macht:
- Google Login im Flutter-Code integrieren
- User auf Firebase UID mappen
- Fehlerfälle sauber behandeln

Done wenn:
- Google Login funktioniert

---

### 3.3 Sign in with Apple als iOS-Handoff dokumentieren

Status: Locked

Du machst:
- Erst aktivieren, wenn Mac-Handoff vorbereitet wird

KI macht:
- iOS-Release-Anforderungen ins technische Handoff übertragen
- Flutter-seitige Vorstruktur anlegen, falls gewünscht

Done wenn:
- Apple Login für die spätere Mac-Phase dokumentiert

---

## Phase 4 – RevenueCat und Paywall

### 4.1 RevenueCat Flutter SDK integrieren

Status: Locked

Du machst:
- Echten Android API Key aus RevenueCat Dashboard in `lib/core/config/app_config.dart` → `_androidKey` eintragen
- Voraussetzung: 1.3 muss Done sein

KI macht:
- Nichts mehr — Code ist fertig

Code-Status (bereits vollständig implementiert):
- `lib/features/billing/billing_service.dart` → `BillingService` (Singleton, ChangeNotifier)
  - `configure({String? firebaseUid})` → RevenueCat init, wird in `main.dart` aufgerufen
  - `login(uid)` / `logout()` → sync mit Firebase UID (wird von AuthService in Phase 3 aufgerufen)
  - `refreshCustomerInfo()` → Customer Info neu laden
  - `restorePurchases()` → Käufe wiederherstellen
  - `isPro` getter → prüft Entitlement `TattooAI Pro`
  - `presentPaywall()` → Paywall immer zeigen
  - `presentPaywallIfNeeded()` → Paywall nur wenn kein Pro
  - `presentCustomerCenter()` → Abo verwalten / Support
- `lib/main.dart` → `BillingService.instance.configure()` nach Firebase init
- `lib/app.dart` → `ListenableBuilder` auf `BillingService.instance`

Offener Punkt nach 1.3:
- `_androidKey` in `app_config.dart` auf echten `goog_xxxxx` Key setzen

Done wenn:
- Echter API Key eingetragen
- App initialisiert RevenueCat ohne Fehler

---

### 4.2 Entitlement State im Client abbilden

Status: Locked

Du machst:
- Nichts außer Aktivierung (Code ist fertig)

KI macht:
- Nichts mehr

Code-Status (bereits vollständig implementiert):
- `BillingService.isPro` → prüft `entitlements.active['TattooAI Pro']`
- `_handleCustomerInfoUpdate()` → aktualisiert State bei jedem SDK-Event
- `lib/screens/create_tattoo_screen.dart` → `_ProBanner` wenn kein Pro, `ListenableBuilder` reagiert live
- Generate-Button ist hinter Paywall-Gate (`_onGenerateTapped`)

Done wenn:
- Echter API Key in `app_config.dart` (aus 4.1)
- Entitlement `TattooAI Pro` im RevenueCat Dashboard existiert
- App erkennt Pro-Status korrekt

---

### 4.3 Paywall UI und Kauf-Flow anbinden

Status: Locked

Du machst:
- Offering mit Packages (`lifetime`, `yearly`, `monthly`) im RevenueCat Dashboard anlegen
- Paywall im Dashboard designen (RevenueCat Paywall Builder)

KI macht:
- Nichts mehr — Code ist fertig

Code-Status (bereits vollständig implementiert):
- `BillingService.presentPaywall()` → zeigt native RevenueCat Paywall (kein eigener Screen nötig)
- `BillingService.presentPaywallIfNeeded()` → zeigt nur wenn kein Pro
- `BillingService.presentCustomerCenter()` → Abo verwalten, lädt CustomerInfo nach Restore
- `BillingService.restorePurchases()` → Käufe wiederherstellen
- Paywall-Gate im Generate-Button in `create_tattoo_screen.dart`
- `_ProBanner` mit Upgrade-Button in der UI

Done wenn:
- Offerings im RevenueCat Dashboard angelegt
- Paywall aus App öffnet sich korrekt
- Kauf und Restore funktionieren (Sandbox-Test auf Android)

---

## Phase 5 – Firestore, Storage, Functions Grundlage

### 5.1 Firestore Collections und Datenmodell im Code verankern

Status: Locked

Du machst:
- Nichts außer Aktivierung

KI macht:
- Datenmodelle für `users`, `entitlements`, `generation_requests`
- App-seitige Mapping-Modelle
- Firestore-Zugriff strukturiert vorbereiten

Done wenn:
- Collections im Code konsistent modelliert

---

### 5.2 Storage-Pfade und Upload-Konzept umsetzen

Status: Locked

Du machst:
- Nichts außer Aktivierung

KI macht:
- Upload-Pfade gemäß Spec: `users/{uid}/generation_requests/{requestId}/base.jpg` etc.
- Base Image und Reference Image Upload
- Fehler- und Ladezustände

Done wenn:
- Bilder können in die vorgesehenen Pfade hochgeladen werden

---

### 5.3 Firebase Functions Projektstruktur vorbereiten

Status: Locked

Du machst:
- Firebase CLI Login und lokales Functions-Setup anstößen, falls nötig

KI macht:
- Functions-Struktur anlegen
- Platz für `createGeneration`, `syncRevenueCatEntitlement`, `cleanupExpiredGenerations`

Done wenn:
- Functions-Ordner und Basisstruktur stehen

---

## Phase 6 – Tattoo Create Flow

### 6.1 Create Screen auf echten Input umbauen

Status: Locked

Du machst:
- Nichts außer Aktivierung

KI macht:
- Echten Form-State bauen
- Base Image Pflichtfeld anbinden
- Reference Image optional anbinden
- Prompt-Feld anbinden

Done wenn:
- Create Screen hat alle Inputs als echte Interaktion

---

### 6.2 Validierungslogik umsetzen

Status: Locked

Du machst:
- Nichts außer Aktivierung

KI macht:
- `baseImage && (referenceImage || tattooDescription)` clientseitig umsetzen
- Generate CTA nur bei gültigem Input aktivieren

Done wenn:
- ungültige Kombinationen können nicht abgesendet werden

---

### 6.3 Generation Request im Client anlegen

Status: Locked

Du machst:
- Nichts außer Aktivierung

KI macht:
- `generation_request` Lebenszyklus im Client modellieren
- Request anlegen, Upload triggern, Status beobachten

Done wenn:
- Client kann einen vollständigen Request anlegen und verfolgen

---

## Phase 7 – Serverseitige Generierung

### 7.1 `createGeneration` Function bauen

Status: Locked

Du machst:
- Nötige Projekt- und Billing-Voraussetzungen in Firebase bereitstellen

KI macht:
- Function implementieren: Auth prüfen → Entitlement prüfen → Input validieren → Storage lesen → Ergebnis speichern

Done wenn:
- Function verarbeitet einen echten Generation-Request

---

### 7.2 Gemini Modell serverseitig anbinden

Status: Locked

Du machst:
- Firebase / Google Billing aktiv halten

KI macht:
- Standardmodell `gemini-2.5-flash-image` anbinden
- Modellname über `IMAGE_MODEL` env var konfigurierbar halten
- Fehler- und Timeout-Behandlung

Done wenn:
- serverseitig wird erfolgreich ein Bild generiert

---

### 7.3 Firestore Status-Flow komplettieren

Status: Locked

Du machst:
- Nichts außer Aktivierung

KI macht:
- Statuswechsel `queued → generating → completed / failed` sauber schreiben
- Client reagiert auf diese Änderungen

Done wenn:
- End-to-End-Status für den User nachvollziehbar

---

## Phase 8 – RevenueCat Server-Schutz

### 8.1 RevenueCat Webhook anbinden

Status: Locked

Du machst:
- RevenueCat Webhook im Dashboard konfigurieren
- URL und Signaturdaten lokal pflegen

KI macht:
- `syncRevenueCatEntitlement` Function bauen
- Entitlement-Cache in Firestore aktualisieren

Done wenn:
- RevenueCat-Änderungen kommen serverseitig an

---

### 8.2 Serverseitige Entitlement-Prüfung erzwingen

Status: Locked

Du machst:
- Nichts außer Aktivierung

KI macht:
- `createGeneration` hart gegen fehlendes `pro` absichern

Done wenn:
- Paywall ist nicht nur clientseitig

---

## Phase 9 – Ergebnis und Export

### 9.1 Result Screen / Result State bauen

Status: Locked

Du machst:
- Nichts außer Aktivierung

KI macht:
- Ergebnisanzeige auf Basis des fertigen Storage-Resultats
- Loading, Error, Success sauber darstellen

Done wenn:
- User sieht das generierte Bild in derselben Session

---

### 9.2 Export / Share / Save anbinden

Status: Locked

Du machst:
- Für iOS später Photo-Library-Rechte im Mac-Handoff beachten

KI macht:
- Export-Funktionen im Flutter-Code anbinden
- Save / Share / Download je nach Plattform

Done wenn:
- User kann das Ergebnis lokal sichern oder teilen

---

## Phase 10 – Cleanup und Security

### 10.1 Firestore und Storage Rules scharfziehen

Status: Locked

Du machst:
- Rules-Änderungen in Firebase anwenden

KI macht:
- Konkrete Rules für User-Isolation und Server-Schutz formulieren

Done wenn:
- User liest nur eigene Daten
- Entitlements nicht clientseitig schreibbar

---

### 10.2 Cleanup Function für abgelaufene Generations bauen

Status: Locked

Du machst:
- Scheduling in Firebase aktivieren, falls nötig

KI macht:
- TTL-Logik (24h) und Cleanup-Function implementieren

Done wenn:
- Session-Daten verfallen automatisch

---

### 10.3 App Check einplanen oder integrieren

Status: Locked

Du machst:
- Für finale iOS-Attestation den Mac-Block mitdenken

KI macht:
- App Check Integrationspfad vorbereiten oder umsetzen

Done wenn:
- Missbrauchsschutz für den MVP klar abgesichert

---

## Phase 11 – iOS-Handoff (braucht Mac)

### 11.1 Mac-Handoff File erzeugen

Status: Locked

Du machst:
- Erst aktivieren, wenn die Windows/Android-Seite weitgehend steht

KI macht:
- Konkrete Mac-Handoff-Checkliste: Xcode, Signing, RevenueCat, Apple Login, TestFlight

Done wenn:
- Es gibt ein separates iOS-Handoff-Dokument

---

### 11.2 iOS Release-Vorbereitung abschließen

Status: Locked

Du machst:
- App Store Connect, In-App Purchases, TestFlight und Release mit Mac-Kollegen finalisieren

KI macht:
- Begleitet nur dokumentierend und code-seitig

Done wenn:
- App ist technisch releasebereit für iOS

---

## Aktueller Fokus

**Nächster Schritt: 1.1 ist Active.**

Was die KI jetzt von dir braucht, sobald du Firebase angelegt hast:
- `projectId`
- `appId` (Android App in Firebase registriert)
- `apiKey`
- `storageBucket`
- `messagingSenderId`

Dann: `google-services.json` herunterladen und ins Repo geben → 2.1 kann starten.
