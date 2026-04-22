import 'package:flutter/material.dart';
import '../features/billing/billing_service.dart';
import '../features/billing/presentation/paywall_screen.dart';
import '../shared/widgets/loading_indicator.dart';

class CreateTattooScreen extends StatelessWidget {
  const CreateTattooScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tattoo AI'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts_outlined),
            tooltip: 'Abonnement verwalten',
            onPressed: () => BillingService.instance.presentCustomerCenter(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: BillingService.instance,
        builder: (context, _) {
          final billing = BillingService.instance;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!billing.isPro) _ProBanner(billing: billing),
                if (!billing.isPro) const SizedBox(height: 16),
                const Text(
                  'Create your perfect tattoo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Base Image (Required)',
                  child: _buildPlaceholderBox('Tap to upload Base Image'),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Reference Tattoo (Optional)',
                  child: _buildPlaceholderBox('Tap to upload Reference Image'),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Tattoo Description (Optional)',
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Describe your dream tattoo...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: billing.isLoading
                      ? null
                      : () => _onGenerateTapped(context, billing),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: billing.isLoading
                      ? const LoadingIndicator(size: 20)
                      : const Text(
                          'Generate Tattoo',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onGenerateTapped(
      BuildContext context, BillingService billing) async {
    if (!billing.isPro) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );
      return;
    }
    // TODO Phase 6: actual generation logic
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generation starts here (Phase 6)')),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildPlaceholderBox(String text) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ─── Pro Banner ───────────────────────────────────────────────────────────────

class _ProBanner extends StatelessWidget {
  const _ProBanner({required this.billing});
  final BillingService billing;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.lock_outline, size: 20),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'TattooAI Pro freischalten, um Tattoos zu generieren',
                style: TextStyle(fontSize: 13),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PaywallScreen()),
            ),
              child: const Text('Upgrade'),
            ),
          ],
        ),
      ),
    );
  }
}
