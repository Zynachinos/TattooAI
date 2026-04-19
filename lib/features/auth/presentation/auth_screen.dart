import 'package:flutter/material.dart';
import '../auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool get _isLogin => _tabs.index == 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              children: [
                // Logo / Title
                Icon(Icons.auto_fix_high, size: 56, color: cs.primary),
                const SizedBox(height: 12),
                Text(
                  'Tattoo AI',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                // Tab bar
                Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabs,
                    indicator: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: cs.onPrimary,
                    unselectedLabelColor: cs.onSurface,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Login'),
                      Tab(text: 'Registrieren'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Form
                ListenableBuilder(
                  listenable: AuthService.instance,
                  builder: (context, _) {
                    final auth = AuthService.instance;
                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'E-Mail',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Bitte E-Mail eingeben';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(auth),
                            decoration: InputDecoration(
                              labelText: 'Passwort',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(_obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Bitte Passwort eingeben';
                              }
                              if (!_isLogin && v.length < 6) {
                                return 'Mindestens 6 Zeichen';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),

                          // Forgot password
                          if (_isLogin)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    _showForgotPassword(context),
                                child:
                                    const Text('Passwort vergessen?'),
                              ),
                            ),

                          // Error
                          if (auth.error != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: cs.errorContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      size: 18,
                                      color: cs.onErrorContainer),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      auth.error!,
                                      style: TextStyle(
                                          color: cs.onErrorContainer,
                                          fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          // Submit
                          FilledButton(
                            onPressed:
                                auth.isLoading ? null : () => _submit(auth),
                            style: FilledButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: auth.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white),
                                  )
                                : Text(
                                    _isLogin ? 'Einloggen' : 'Account erstellen',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                          ),
                          const SizedBox(height: 16),

                          // Divider
                          Row(children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('oder',
                                  style: TextStyle(
                                      color: cs.onSurface.withValues(
                                          alpha: 0.5),
                                      fontSize: 13)),
                            ),
                            const Expanded(child: Divider()),
                          ]),
                          const SizedBox(height: 16),

                          // Google Sign-In
                          OutlinedButton.icon(
                            onPressed: auth.isLoading
                                ? null
                                : () => auth.signInWithGoogle(),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: Image.asset(
                              'assets/google_logo.png',
                              height: 18,
                              errorBuilder: (context, e, s) => const Icon(
                                  Icons.login,
                                  size: 18),
                            ),
                            label: const Text('Mit Google fortfahren'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(AuthService auth) async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailCtrl.text;
    final password = _passwordCtrl.text;

    if (_isLogin) {
      await auth.signInWithEmailPassword(email, password);
    } else {
      await auth.registerWithEmailPassword(email, password);
    }
  }

  Future<void> _showForgotPassword(BuildContext context) async {
    final ctrl = TextEditingController(text: _emailCtrl.text);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Passwort zurücksetzen'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'E-Mail',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Senden'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final sent =
          await AuthService.instance.sendPasswordResetEmail(ctrl.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(sent
              ? 'Reset-E-Mail gesendet.'
              : 'E-Mail konnte nicht gesendet werden.'),
        ));
      }
    }
  }
}
