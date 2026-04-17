import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/app_colors.dart';
import '../core/models/meal.dart';
import '../core/services/nutrition_db.dart';
import '../core/utils/responsive.dart';
import '../providers/ad_provider.dart';
import '../providers/meals_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/section_card.dart';

class LogScreen extends ConsumerStatefulWidget {
  const LogScreen({super.key});
  @override
  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen> {
  final _picker = ImagePicker();
  final _search = TextEditingController();
  List<NutritionEntry> _results = NutritionDb.entries.take(12).toList();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _pickAndAnalyze(ImageSource source) async {
    final profile = ref.read(profileProvider);
    if (!profile.isPro && profile.scanTokens <= 0) {
      await _noTokensSheet();
      return;
    }

    final x = await _picker.pickImage(
      source: source,
      imageQuality: 92,
      maxWidth: 1800, maxHeight: 1800,
    );
    if (x == null) return;

    await ref.read(mealsProvider.notifier).analyzePhoto(File(x.path));
    final s = ref.read(mealsProvider);
    if (s.error != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.error!), backgroundColor: AppColors.danger),
      );
      ref.read(mealsProvider.notifier).clearError();
      return;
    }

    if (!profile.isPro) {
      await ref.read(adServiceProvider).maybeShowInterstitial();
    }
    if (!mounted) return;
    ref.read(screenProvider.notifier).go(AppScreen.confirmMeal);
  }

  Future<void> _noTokensSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_outlined,
                  color: AppColors.warn, size: 40),
              const SizedBox(height: 12),
              Text("Out of free AI scans today",
                  style: Theme.of(ctx).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Unlimited scans with Pro, or watch a short ad for +1 scan.',
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: 'Watch Ad for +1 Scan',
                icon: Icons.play_circle_fill_rounded,
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final ok =
                      await ref.read(adServiceProvider).showRewarded();
                  if (ok) {
                    await ref.read(profileProvider.notifier).grantBonusScan();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('+1 scan unlocked!')),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ref.read(screenProvider.notifier).go(AppScreen.paywall);
                },
                icon: const Icon(Icons.workspace_premium_rounded),
                label: const Text('Go Pro — Unlimited'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _searchChanged(String v) {
    setState(() {
      _results = NutritionDb.search(v).take(40).toList();
    });
  }

  Future<void> _addFromDb(NutritionEntry entry) async {
    final grams = await _gramsDialog(entry);
    if (grams == null) return;
    final now = DateTime.now();
    final meal = Meal(
      id: now.millisecondsSinceEpoch.toString(),
      type: mealTypeFromHour(now.hour),
      timestamp: now,
      items: [
        MealItem(
          name: entry.name,
          grams: grams,
          macros: entry.macrosFor(grams),
        )
      ],
      source: 'search',
      confidence: 1.0,
    );
    await ref.read(mealsProvider.notifier).addManual(meal);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${entry.name}')),
    );
  }

  Future<double?> _gramsDialog(NutritionEntry entry) async {
    double g = entry.defaultServingG;
    return showDialog<double>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          final macros = entry.macrosFor(g);
          return AlertDialog(
            backgroundColor: AppColors.card,
            title: Text(entry.name),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${g.round()} g',
                    style: Theme.of(ctx).textTheme.headlineMedium),
                Slider(
                  min: 10, max: 500,
                  value: g.clamp(10, 500),
                  onChanged: (v) => setD(() => g = v),
                ),
                Text('${macros.calories.round()} kcal · '
                    'P ${macros.protein.toStringAsFixed(0)} g · '
                    'C ${macros.carbs.toStringAsFixed(0)} g · '
                    'F ${macros.fat.toStringAsFixed(0)} g'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(g),
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analyzing = ref.watch(mealsProvider).analyzing;
    final profile = ref.watch(profileProvider);

    return SafeArea(
      child: ResponsiveContentBox(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: context.s(16), vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => ref
                        .read(screenProvider.notifier)
                        .go(AppScreen.home),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Text('Log a Meal',
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      color: AppColors.accent,
                      icon: Icons.camera_alt_rounded,
                      label: 'Snap',
                      subtitle: 'AI photo scan',
                      onTap: analyzing
                          ? null
                          : () => _pickAndAnalyze(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionTile(
                      color: AppColors.accent2,
                      icon: Icons.photo_library_rounded,
                      label: 'Library',
                      subtitle: 'Pick photo',
                      onTap: analyzing
                          ? null
                          : () => _pickAndAnalyze(ImageSource.gallery),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionTile(
                      color: AppColors.accentFat,
                      icon: Icons.edit_rounded,
                      label: 'Manual',
                      subtitle: 'Build meal',
                      onTap: analyzing
                          ? null
                          : () {
                              ref
                                  .read(mealsProvider.notifier)
                                  .startManualMeal();
                              ref
                                  .read(screenProvider.notifier)
                                  .go(AppScreen.confirmMeal);
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (analyzing) ...[
                const LinearProgressIndicator(
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(AppColors.accent)),
                const SizedBox(height: 12),
                Text('Analyzing food…',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
              const SizedBox(height: 4),
              TextField(
                controller: _search,
                onChanged: _searchChanged,
                decoration: InputDecoration(
                  hintText: 'Search foods (chicken, rice, avocado...)',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (ctx, i) {
                    final e = _results[i];
                    return InkWell(
                      onTap: () => _addFromDb(e),
                      borderRadius: BorderRadius.circular(14),
                      child: SectionCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.restaurant_rounded,
                                  color: AppColors.accent),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.name,
                                      style: Theme.of(ctx)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600)),
                                  Text(
                                    '${e.caloriesPer100g.round()} kcal · '
                                    'P ${e.proteinPer100g.toStringAsFixed(0)} / '
                                    'C ${e.carbsPer100g.toStringAsFixed(0)} / '
                                    'F ${e.fatPer100g.toStringAsFixed(0)} per 100g',
                                    style: Theme.of(ctx).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.add_rounded,
                                color: AppColors.accent),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Text(
                profile.isPro
                    ? 'Pro · unlimited AI scans'
                    : '${profile.scanTokens} AI scan${profile.scanTokens == 1 ? "" : "s"} left today',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 14, fontWeight: FontWeight.w700)),
            Text(subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                    )),
          ],
        ),
      ),
    );
  }
}
