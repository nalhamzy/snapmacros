import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../core/models/meal.dart';
import '../core/utils/responsive.dart';
import '../providers/meals_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/macro_ring.dart';
import '../widgets/section_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    ref.watch(mealsProvider); // rebuild on meal change
    final today = ref.read(mealsProvider.notifier).mealsOn(DateTime.now());
    final totals = ref.read(mealsProvider.notifier).totalOn(DateTime.now());

    return SafeArea(
      child: ResponsiveContentBox(
        child: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: context.s(16), vertical: context.s(10)),
          children: [
            _TopBar(
              streak: profile.streakDays,
              isPro: profile.isPro,
              onSettings: () =>
                  ref.read(screenProvider.notifier).go(AppScreen.settings),
              onHistory: () =>
                  ref.read(screenProvider.notifier).go(AppScreen.history),
            ),
            const SizedBox(height: 18),
            _SummaryCard(
              consumed: totals,
              targets: profile,
            ),
            const SizedBox(height: 14),
            _LogButton(
              onTap: () =>
                  ref.read(screenProvider.notifier).go(AppScreen.log),
              scanTokens: profile.isPro ? -1 : profile.scanTokens,
              hasAi: ref.read(mealsProvider.notifier).hasRealAi,
            ),
            const SizedBox(height: 18),
            if (today.isEmpty) _EmptyToday()
            else ...[
              Text("Today's Meals",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              for (final m in today) _MealTile(meal: m),
            ],
            const SizedBox(height: 12),
            if (!profile.isPro) _ProPromo(ref: ref),
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int streak;
  final bool isPro;
  final VoidCallback onSettings;
  final VoidCallback onHistory;
  const _TopBar({
    required this.streak,
    required this.isPro,
    required this.onSettings,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('SnapMacros',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(width: 8),
        if (isPro)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              gradient: AppColors.gradientGold,
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'PRO',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: 0.8,
              ),
            ),
          ),
        const Spacer(),
        if (streak > 0) ...[
          const Icon(Icons.local_fire_department_rounded,
              color: AppColors.warn),
          Text('$streak',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.warn,
                  )),
          const SizedBox(width: 8),
        ],
        IconButton(
          onPressed: onHistory,
          icon: const Icon(Icons.bar_chart_rounded),
        ),
        IconButton(
          onPressed: onSettings,
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final Macros consumed;
  final targets;
  const _SummaryCard({required this.consumed, required this.targets});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      child: Column(
        children: [
          Text(DateFormat('EEEE, MMM d').format(DateTime.now()),
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          MacroRing(
            consumed: consumed.calories,
            target: targets.calorieTarget,
            size: 200,
            unit: 'kcal',
            label: 'CALORIES',
          ),
          const SizedBox(height: 18),
          MacroBar(
            label: 'Protein',
            consumed: consumed.protein,
            target: targets.proteinTarget,
            color: AppColors.accentProtein,
          ),
          const SizedBox(height: 12),
          MacroBar(
            label: 'Carbs',
            consumed: consumed.carbs,
            target: targets.carbsTarget,
            color: AppColors.accentCarbs,
          ),
          const SizedBox(height: 12),
          MacroBar(
            label: 'Fat',
            consumed: consumed.fat,
            target: targets.fatTarget,
            color: AppColors.accentFat,
          ),
        ],
      ),
    );
  }
}

class _LogButton extends StatelessWidget {
  final VoidCallback onTap;
  final int scanTokens;   // -1 if pro
  final bool hasAi;
  const _LogButton({
    required this.onTap,
    required this.scanTokens,
    required this.hasAi,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.gradientMain,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.add_a_photo_rounded,
                color: Colors.white, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Log a Meal',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(
                    scanTokens < 0
                        ? (hasAi
                            ? 'Pro · unlimited AI scans'
                            : 'Pro · unlimited · AI offline')
                        : '$scanTokens AI scan${scanTokens == 1 ? "" : "s"} left today · or tap to search',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _MealTile extends ConsumerWidget {
  final Meal meal;
  const _MealTile({required this.meal});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = meal.total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SectionCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (meal.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(meal.imagePath!),
                  width: 56, height: 56, fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.restaurant_menu_rounded,
                    color: AppColors.textMuted),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.items.isEmpty
                        ? 'Empty meal'
                        : meal.items.map((i) => i.name).join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '${meal.type.name[0].toUpperCase()}${meal.type.name.substring(1)} · '
                    '${DateFormat('h:mm a').format(meal.timestamp)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${t.calories.round()}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.accent,
                        )),
                Text('kcal',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  color: AppColors.textMuted),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
              onSelected: (v) {
                if (v == 'delete') {
                  ref.read(mealsProvider.notifier).deleteMeal(meal.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyToday extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          const Icon(Icons.ramen_dining_rounded,
              size: 40, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text("No meals logged today",
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Snap a photo, search, or add manually to get started.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ProPromo extends StatelessWidget {
  final WidgetRef ref;
  const _ProPromo({required this.ref});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => ref.read(screenProvider.notifier).go(AppScreen.paywall),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.gradientGold,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_rounded,
                color: Colors.black, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Go Pro — Unlimited AI Scans',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black)),
                  Text('No ads · Adaptive macros · Weekly insights',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
