import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/responsive.dart';
import '../providers/iap_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/section_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return SafeArea(
      child: ResponsiveContentBox(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: context.s(18), vertical: 8),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () =>
                      ref.read(screenProvider.notifier).go(AppScreen.home),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: 6),
                Text('Settings',
                    style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                children: [
                  _Row(
                    icon: Icons.workspace_premium_rounded,
                    label: 'Subscription',
                    value: profile.isPro
                        ? 'Pro · ${profile.proTier.name}'
                        : 'Free',
                    onTap: profile.isPro
                        ? null
                        : () => ref
                            .read(screenProvider.notifier)
                            .go(AppScreen.paywall),
                  ),
                  const Divider(),
                  _Row(
                    icon: Icons.restore_rounded,
                    label: 'Restore Purchases',
                    value: '',
                    onTap: () async {
                      await ref.read(iapServiceProvider).restorePurchases();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Restore requested')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                children: [
                  _Row(
                    icon: Icons.flag_outlined,
                    label: 'Goal',
                    value: profile.goal.name,
                    onTap: null,
                  ),
                  const Divider(),
                  _Row(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Calorie target',
                    value: '${profile.calorieTarget.round()} kcal',
                    onTap: null,
                  ),
                  const Divider(),
                  _Row(
                    icon: Icons.fitness_center_rounded,
                    label: 'Protein target',
                    value: '${profile.proteinTarget.round()} g',
                    onTap: null,
                  ),
                  const Divider(),
                  _Row(
                    icon: Icons.tune_rounded,
                    label: 'Recompute from profile',
                    value: '',
                    onTap: () async {
                      await ref
                          .read(profileProvider.notifier)
                          .recomputeTargets();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Macro targets recomputed')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                children: [
                  _Row(
                    icon: Icons.person_outline,
                    label: 'Sex',
                    value: profile.sex.name,
                    onTap: null,
                  ),
                  const Divider(),
                  _Row(
                    icon: Icons.cake_outlined,
                    label: 'Age',
                    value: '${profile.age}',
                    onTap: null,
                  ),
                  const Divider(),
                  _Row(
                    icon: Icons.height_rounded,
                    label: 'Height',
                    value: '${profile.heightCm.round()} cm',
                    onTap: null,
                  ),
                  const Divider(),
                  _Row(
                    icon: Icons.monitor_weight_outlined,
                    label: 'Weight',
                    value: '${profile.weightKg.toStringAsFixed(1)} kg',
                    onTap: null,
                  ),
                  const Divider(),
                  _Row(
                    icon: Icons.directions_run_rounded,
                    label: 'Activity',
                    value: profile.activity.name,
                    onTap: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SectionCard(
              child: Column(
                children: [
                  _Row(
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    value: '',
                    onTap: () {},
                  ),
                  const Divider(),
                  _Row(
                    icon: Icons.description_outlined,
                    label: 'Terms of Service',
                    value: '',
                    onTap: () {},
                  ),
                  const Divider(),
                  _Row(
                    icon: Icons.mail_outline_rounded,
                    label: 'Support',
                    value: 'nalhamzy@gmail.com',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text('SnapMacros v1.0.0',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
            Text(value, style: Theme.of(context).textTheme.bodyMedium),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted),
            ],
          ],
        ),
      ),
    );
  }
}
