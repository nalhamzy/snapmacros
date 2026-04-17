import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/services/iap_product_ids.dart';
import '../core/services/iap_service.dart';
import '../core/utils/responsive.dart';
import '../providers/iap_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/section_card.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});
  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  String _selected = IapProductIds.proYearly;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    if (profile.isPro) {
      return _Already(onBack: _back);
    }
    final iap = ref.read(iapServiceProvider);

    return SafeArea(
      child: ResponsiveContentBox(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: context.s(18), vertical: 8),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _back, icon: const Icon(Icons.close_rounded)),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    await iap.restorePurchases();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Restore requested')),
                    );
                  },
                  child: const Text('Restore'),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientGold,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.workspace_premium_rounded,
                      color: Colors.black, size: 40),
                ),
                const SizedBox(height: 12),
                Text('SnapMacros Pro',
                    style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 4),
                Text('Unlimited AI · No ads · Adaptive macros',
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            const SizedBox(height: 18),
            const _Compare(),
            const SizedBox(height: 14),
            for (final id in [
              IapProductIds.proYearly,
              IapProductIds.proMonthly,
              IapProductIds.proWeekly,
              IapProductIds.lifetime,
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _Tile(
                  product: iap.product(id)!,
                  selected: _selected == id,
                  highlight: id == IapProductIds.proYearly,
                  sub: _sub(id),
                  onTap: () => setState(() => _selected = id),
                ),
              ),
            GradientButton(
              label: _busy ? 'Processing…' : 'Continue',
              icon: Icons.rocket_launch_rounded,
              loading: _busy,
              onPressed: _busy ? null : _buy,
            ),
            const SizedBox(height: 10),
            Text(
              'Transparent pricing · cancel anytime in App Store / Play Store · no hidden fees.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }

  String _sub(String id) => switch (id) {
        IapProductIds.proYearly => 'Best value · saves 67% vs weekly',
        IapProductIds.proMonthly => '7-day free trial',
        IapProductIds.proWeekly => '3-day free trial',
        IapProductIds.lifetime => 'One-time · never expires',
        _ => '',
      };

  Future<void> _buy() async {
    setState(() => _busy = true);
    final ok = await ref.read(iapServiceProvider).purchase(_selected);
    if (!mounted) return;
    if (!ok) {
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Purchase unavailable. Set up IAP products in App Store Connect / Play Console.'),
        ),
      );
      return;
    }
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _busy = false);
    });
  }

  void _back() => ref.read(screenProvider.notifier).go(AppScreen.home);
}

class _Compare extends StatelessWidget {
  const _Compare();
  static const _rows = [
    ['Unlimited AI photo scans', '3 / day free'],
    ['Adaptive macro targets', 'Static targets'],
    ['Weekly insights & trends', 'Last 7 days'],
    ['No ads', 'Banner + interstitial'],
    ['Priority AI analysis', 'Standard queue'],
  ];
  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          for (final r in _rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Text(r[0],
                        style: Theme.of(context).textTheme.bodyLarge),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(r[1],
                        textAlign: TextAlign.right,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textMuted)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IapProduct product;
  final bool selected;
  final bool highlight;
  final String sub;
  final VoidCallback onTap;
  const _Tile({
    required this.product,
    required this.selected,
    required this.highlight,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.gold : AppColors.border;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.gold : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.gold : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.black)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(product.title,
                          style: Theme.of(context).textTheme.titleLarge),
                      if (highlight) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('BEST VALUE',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6)),
                        ),
                      ],
                    ],
                  ),
                  if (sub.isNotEmpty)
                    Text(sub,
                        style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Text(product.price,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: selected ? AppColors.gold : AppColors.textPrimary,
                    )),
          ],
        ),
      ),
    );
  }
}

class _Already extends StatelessWidget {
  final VoidCallback onBack;
  const _Already({required this.onBack});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium_rounded,
                color: AppColors.gold, size: 64),
            const SizedBox(height: 12),
            Text("You're Pro! 🎉",
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text(
                'Enjoy unlimited AI scans, adaptive macros and an ad-free experience.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: onBack, child: const Text('Back')),
          ],
        ),
      ),
    );
  }
}
