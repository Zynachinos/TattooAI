import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'features/billing/billing_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // RevenueCat – no user ID yet; synced with Firebase UID after login (Phase 3)
  await BillingService.instance.configure();

  runApp(const TattooAiApp());
}
