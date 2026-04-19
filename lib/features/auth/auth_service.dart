// Phase 3 – Auth Service wird hier implementiert.
//
// Verantwortung:
// - Email / Passwort Login + Registrierung
// - Google Login
// - Apple Login (Phase 11 – Mac-Handoff)
// - Firebase UID liefern
// - BillingService.instance.login(uid) nach erfolgreichem Login aufrufen
// - BillingService.instance.logout() beim Logout aufrufen

import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  // Wird in Phase 3.1 und 3.2 implementiert
}
