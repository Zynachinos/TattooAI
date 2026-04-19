import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_service.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/billing/billing_service.dart';
import 'screens/create_tattoo_screen.dart';

class TattooAiApp extends StatelessWidget {
  const TattooAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tattoo AI',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: ListenableBuilder(
        listenable: Listenable.merge(
            [AuthService.instance, BillingService.instance]),
        builder: (context, _) {
          if (!AuthService.instance.isLoggedIn) {
            return const AuthScreen();
          }
          return const CreateTattooScreen();
        },
      ),
    );
  }
}
