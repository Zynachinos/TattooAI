import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'features/auth/auth_service.dart';
import 'features/billing/billing_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  // RevenueCat – UID wird über AuthService.init() nach Login gesetzt
  await BillingService.instance.configure();

  // Auth-State Listener starten (verbindet Firebase UID mit RevenueCat)
  AuthService.instance.init();

  runApp(const TattooAiApp());
}
