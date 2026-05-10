import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_service.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/billing/billing_service.dart';
import 'features/billing/presentation/paywall_gate_screen.dart';
import 'screens/create_tattoo_screen.dart';
import 'shared/widgets/loading_indicator.dart';

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
          final auth = AuthService.instance;

          final billing = BillingService.instance;

          if (!auth.isInitialized || billing.isLoading) {
            return const _SplashScreen();
          }
          if (!auth.isLoggedIn) {
            return const AuthScreen();
          }
          // Admin users bypass the paywall gate (for testing)
          if (!billing.isPro && !auth.isAdmin) {
            return const PaywallGateScreen();
          }
          return const CreateTattooScreen();
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_fix_high, size: 56, color: cs.primary),
            const SizedBox(height: 24),
            const LoadingIndicator(size: 28),
          ],
        ),
      ),
    );
  }
}
