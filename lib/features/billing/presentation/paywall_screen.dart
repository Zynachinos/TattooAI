import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../billing_service.dart';
import '../../../core/config/app_config.dart';

// ─── Colors ──────────────────────────────────────────────────────────────────

const Color _bgDark = Color(0xFF0D0D0D);
const Color _bgCard = Color(0xFF1A1A1A);
const Color _bgCardSelected = Color(0xFF2A1215);
const Color _accentRed = Color(0xFFE84A5E);
const Color _accentCoral = Color(0xFFFF6B6B);
const Color _textPrimary = Color(0xFFF5F0EB);
const Color _textSecondary = Color(0xFFA09890);
const Color _textMuted = Color(0xFF6B6360);
const Color _badgeBg = Color(0xFFE8384A);
const Color _dividerColor = Color(0xFF2A2520);

// ─── Plan Types ───────────────────────────────────────────────────────────────

enum _Plan { monthly, yearly, lifetime }

// ─── Screen ───────────────────────────────────────────────────────────────────

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  _Plan _selected = _Plan.yearly;
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

  Package? _pkg(_Plan plan) {
    final current = _offerings?.current;
    if (current == null) return null;
    final id = switch (plan) {
      _Plan.monthly => AppConfig.productMonthly,
      _Plan.yearly => AppConfig.productYearly,
      _Plan.lifetime => AppConfig.productLifetime,
    };
    try {
      return current.availablePackages.firstWhere((p) => p.identifier == id);
    } catch (_) {
      return null;
    }
  }

  String _price(_Plan plan) {
    final p = _pkg(plan)?.storeProduct.priceString;
    if (p != null) return p;
    return switch (plan) {
      _Plan.monthly => '\$6.99',
      _Plan.yearly => '\$39.99',
      _Plan.lifetime => '\$89.99',
    };
  }

  Future<void> _subscribe() async {
    final pkg = _pkg(_selected);
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
              const _FeatureRow(icon: '∞', title: 'Unlimited generations', subtitle: 'NO DAILY CAPS'),
              const SizedBox(height: 16),
              const _FeatureRow(icon: 'HD', title: 'HD export, no watermark', subtitle: 'PRINT-READY 4096PX'),
              const SizedBox(height: 16),
              const _FeatureRow(icon: '⚡', title: 'Priority queue', subtitle: '3× FASTER · FLAGSHIP MODEL'),
              const SizedBox(height: 16),
              const _FeatureRow(icon: '×', title: 'Cancel anytime'),
              const SizedBox(height: 28),
              _PlanCard(
                title: 'Monthly',
                subtitle: '/ MONTH',
                price: _price(_Plan.monthly),
                isSelected: _selected == _Plan.monthly,
                onTap: () => setState(() => _selected = _Plan.monthly),
              ),
              const SizedBox(height: 18),
              _PlanCard(
                title: 'Yearly',
                subtitle: '/ YEAR · 3-DAY TRIAL',
                price: _price(_Plan.yearly),
                badge: 'SAVE 72%',
                originalPrice: '\$143.88',
                isSelected: _selected == _Plan.yearly,
                onTap: () => setState(() => _selected = _Plan.yearly),
              ),
              const SizedBox(height: 18),
              _PlanCard(
                title: 'Lifetime',
                subtitle: 'ONE-TIME',
                price: _price(_Plan.lifetime),
                isSelected: _selected == _Plan.lifetime,
                onTap: () => setState(() => _selected = _Plan.lifetime),
              ),
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
            style: TextStyle(color: _textMuted, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1),
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
            style: TextStyle(color: _textPrimary, fontSize: 36, fontWeight: FontWeight.bold, height: 1.15),
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
            style: TextStyle(color: _textPrimary, fontSize: 36, fontWeight: FontWeight.bold, height: 1.15),
          ),
        ],
      ),
    );
  }

  Widget _ctaButton() {
    final label = switch (_selected) {
      _Plan.yearly => 'Start 3-day free trial',
      _Plan.monthly => 'Subscribe Monthly',
      _Plan.lifetime => 'Buy Lifetime Access',
    };
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _isLoading ? null : _subscribe,
        style: FilledButton.styleFrom(
          backgroundColor: _accentRed,
          disabledBackgroundColor: _accentRed.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }

  Widget _footer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {},
          child: const Text('TERMS', style: TextStyle(color: _textMuted, fontSize: 11, letterSpacing: 1)),
        ),
        const SizedBox(width: 16),
        TextButton(
          onPressed: () {},
          child: const Text('PRIVACY', style: TextStyle(color: _textMuted, fontSize: 11, letterSpacing: 1)),
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
          decoration: BoxDecoration(color: _bgCard, borderRadius: BorderRadius.circular(8)),
          alignment: Alignment.center,
          child: Text(icon, style: const TextStyle(color: _accentCoral, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(color: _textMuted, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 1),
              ),
          ],
        ),
      ],
    );
  }
}

// ─── Plan Card ────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.isSelected,
    required this.onTap,
    this.badge,
    this.originalPrice,
  });

  final String title;
  final String subtitle;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;
  final String? originalPrice;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? _bgCardSelected : _bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? _accentRed : _dividerColor,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                _radio(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(subtitle,
                          style: const TextStyle(
                              color: _textMuted, fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (originalPrice != null)
                      Text(
                        originalPrice!,
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: _textMuted,
                        ),
                      ),
                    Text(price,
                        style: const TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            top: -11,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: _badgeBg, borderRadius: BorderRadius.circular(4)),
              child: Text(
                badge!,
                style: const TextStyle(
                    color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _radio() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: isSelected ? _accentRed : _textMuted, width: 2),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: _accentRed),
              ),
            )
          : null,
    );
  }
}
