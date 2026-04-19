import 'dart:io';

class AppConfig {
  // TODO: Schritt 1.3 — ersetzen mit echtem Android Key aus RevenueCat Dashboard (goog_xxxxx)
  static const String _androidKey = 'test_DCHzncukfpoRyXODyXoyBXGzUNZ';

  // TODO: Schritt 11.1 (Mac-Handoff) — iOS Key aus RevenueCat Dashboard eintragen
  static const String _iosKey = '';

  static String get revenueCatApiKey =>
      Platform.isAndroid ? _androidKey : _iosKey;

  static const String entitlementId = 'TattooAI Pro';

  // RevenueCat offering/product identifiers
  static const String offeringDefault = 'default';
  static const String productLifetime = 'lifetime';
  static const String productYearly = 'yearly';
  static const String productMonthly = 'monthly';
}
