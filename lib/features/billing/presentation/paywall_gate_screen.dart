import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../billing_service.dart';

// Full-screen paywall gate — shown when user is logged in but has no Pro entitlement.
// No close/back button. Admin users and debug skip-button bypass this screen.

const Color _bgDark = Color(0xFF0D0D0D);
const Color _bgCard = Color(0xFF1A1A1A);
const Color _accentRed = Color(0xFFE84A5E);
const Color _accentCoral = Color(0xFFFF6B6B);
const Color _textPrimary = Color(0xFFF5F0EB);
const Color _textSecondary = Color(0xFFA09890);
const Color _textMuted = Color(0xFF6B6360);

class PaywallGateScreen extends StatefulWidget {
  const PaywallGateScreen({super.key});

  @override
  State<PaywallGateScreen> createState() => _PaywallGateScreenState();
}

class _PaywallGateScreenState extends State<PaywallGateScreen> {
  bool _isLoading = false;

  Future<void> _openPaywall() async {
    setState(() => _isLoading = true);
    try {
      await BillingService.instance.presentPaywall(displayCloseButton: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isLoading = true);
    try {
      await BillingService.instance.restorePurchases();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // blocks back button
      child: Scaffold(
        backgroundColor: _bgDark,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // debug skip button — only visible in debug builds
                if (kDebugMode)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        // temporarily marks isPro via a fake entitlement flag for this session
                        // real purchases still go through RevenueCat
                        await BillingService.instance.debugSkipPaywall();
                      },
                      child: const Text(
                        'DEBUG SKIP',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 11,
                            letterSpacing: 1),
                      ),
                    ),
                  ),

                const Spacer(),

                // branding
                const Text(
                  '003 — UNLOCK',
                  style: TextStyle(
                      color: _accentCoral,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2),
                ),
                const SizedBox(height: 14),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Go Pro.\n',
                        style: TextStyle(
                            color: _textPrimary,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            height: 1.15),
                      ),
                      TextSpan(
                        text: 'Draw ',
                        style: TextStyle(
                            color: _accentCoral,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            height: 1.15),
                      ),
                      TextSpan(
                        text: 'your\nnext piece.',
                        style: TextStyle(
                            color: _textPrimary,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            height: 1.15),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // feature list
                _FeatureRow(icon: '6', text: '6 Credits per week'),
                const SizedBox(height: 14),
                _FeatureRow(icon: 'HD', text: 'HD export, no watermark'),
                const SizedBox(height: 14),
                _FeatureRow(icon: '⚡', text: 'Priority queue · 3× faster'),
                const SizedBox(height: 14),
                _FeatureRow(icon: '×', text: 'Cancel anytime'),

                const SizedBox(height: 40),

                // price hint
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2520)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Weekly',
                              style: TextStyle(
                                  color: _textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          Text('6 CREDITS INCLUDED',
                              style: TextStyle(
                                  color: _accentCoral,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('~CHF 5.00',
                              style: TextStyle(
                                  color: _textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Text('/ WEEK',
                              style: TextStyle(
                                  color: _textMuted,
                                  fontSize: 11,
                                  letterSpacing: 0.5)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // CTA
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _openPaywall,
                    style: FilledButton.styleFrom(
                      backgroundColor: _accentRed,
                      disabledBackgroundColor:
                          _accentRed.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text('Subscribe Weekly',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),

                // restore
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : _restore,
                    child: const Text('Restore Purchase',
                        style:
                            TextStyle(color: _textSecondary, fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});
  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: _bgCard, borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: Text(icon,
              style: const TextStyle(
                  color: _accentCoral,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Text(text,
            style: const TextStyle(color: _textSecondary, fontSize: 14)),
      ],
    );
  }
}
