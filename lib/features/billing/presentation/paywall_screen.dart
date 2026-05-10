import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../billing_service.dart';
import '../../../core/config/app_config.dart';

// ─── Colors ──────────────────────────────────────────────────────────────────

const Color _bgDark = Color(0xFF0D0D0D);
const Color _bgCard = Color(0xFF1A1A1A);
const Color _accentRed = Color(0xFFE84A5E);
const Color _accentCoral = Color(0xFFFF6B6B);
const Color _textPrimary = Color(0xFFF5F0EB);
const Color _textSecondary = Color(0xFFA09890);
const Color _textMuted = Color(0xFF6B6360);
const Color _dividerColor = Color(0xFF2A2520);

// ─── Screen ───────────────────────────────────────────────────────────────────

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  Offerings? _offerings;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final o = await Purchases.getOfferings();
      if (mounted) setState(() => _offerings = o);
    } catch (_) {}
  }

  Package? get _weeklyPackage {
    final current = _offerings?.current;
    if (current == null) return null;
    try {
      return current.availablePackages
          .firstWhere((p) => p.identifier == AppConfig.productWeekly);
    } catch (_) {
      return null;
    }
  }

  String get _price =>
      _weeklyPackage?.storeProduct.priceString ?? 'CHF 5.00';

  Future<void> _subscribe() async {
    final pkg = _weeklyPackage;
    if (pkg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produkte werden noch geladen…')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final ok = await BillingService.instance.purchasePackage(pkg);
      if (ok && mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isLoading = true);
    try {
      final ok = await BillingService.instance.restorePurchases();
      if (mounted && ok) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _topBar(),
              const SizedBox(height: 24),
              const Text(
                '003 — UNLOCK',
                style: TextStyle(
                  color: _accentCoral,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              _headline(),
              const SizedBox(height: 28),
              const _FeatureRow(
                icon: '6',
                title: '6 Credits per week',
                subtitle: 'ONE GENERATION = ONE CREDIT',
              ),
              const SizedBox(height: 16),
              const _FeatureRow(
                icon: 'HD',
                title: 'HD export, no watermark',
                subtitle: 'PRINT-READY 4096PX',
              ),
              const SizedBox(height: 16),
              const _FeatureRow(
                icon: '⚡',
                title: 'Priority queue',
                subtitle: '3× FASTER · FLAGSHIP MODEL',
              ),
              const SizedBox(height: 16),
              const _FeatureRow(icon: '×', title: 'Cancel anytime'),
              const SizedBox(height: 32),
              _priceCard(),
              const SizedBox(height: 28),
              _ctaButton(),
              const SizedBox(height: 16),
              _footer(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(false),
          icon: const Icon(Icons.close, color: _textSecondary, size: 22),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        TextButton(
          onPressed: _isLoading ? null : _restore,
          child: const Text(
            'RESTORE',
            style: TextStyle(
                color: _textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 1),
          ),
        ),
      ],
    );
  }

  Widget _headline() {
    return RichText(
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
              height: 1.15,
            ),
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
    );
  }

  Widget _priceCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _dividerColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Weekly',
                style: TextStyle(
                    color: _textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 2),
              Text(
                '6 CREDITS INCLUDED',
                style: TextStyle(
                    color: _accentCoral,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _price,
                style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              const Text(
                '/ WEEK',
                style: TextStyle(
                    color: _textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ctaButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _isLoading ? null : _subscribe,
        style: FilledButton.styleFrom(
          backgroundColor: _accentRed,
          disabledBackgroundColor: _accentRed.withValues(alpha: 0.6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : const Text(
                'Subscribe Weekly',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
      ),
    );
  }

  Widget _footer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {},
          child: const Text('TERMS',
              style: TextStyle(
                  color: _textMuted, fontSize: 11, letterSpacing: 1)),
        ),
        const SizedBox(width: 16),
        TextButton(
          onPressed: () {},
          child: const Text('PRIVACY',
              style: TextStyle(
                  color: _textMuted, fontSize: 11, letterSpacing: 1)),
        ),
      ],
    );
  }
}

// ─── Feature Row ─────────────────────────────────────────────────────────────

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.title, this.subtitle});
  final String icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: _bgCard, borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: Text(icon,
              style: const TextStyle(
                  color: _accentCoral,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(
                    color: _textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1),
              ),
          ],
        ),
      ],
    );
  }
}
