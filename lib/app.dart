import 'package:flutter/material.dart';
import 'features/billing/billing_service.dart';
import 'screens/create_tattoo_screen.dart';

class TattooAiApp extends StatelessWidget {
  const TattooAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tattoo AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: ListenableBuilder(
        listenable: BillingService.instance,
        builder: (context, _) => const CreateTattooScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
