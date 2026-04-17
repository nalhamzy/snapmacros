import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_colors.dart';
import '../core/models/meal.dart';
import '../core/services/nutrition_db.dart';
import '../core/utils/responsive.dart';
import '../providers/meals_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/section_card.dart';

class ConfirmMealScreen extends ConsumerWidget {
  const ConfirmMealScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(mealsProvider);
    final draft = s.draft;
    if (draft == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No meal in progress.'),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () =>
                  ref.read(screenProvider.notifier).go(AppScreen.home),
              child: const Text('Back'),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: ResponsiveContentBox(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.bg,
              leading: IconButton(
                onPressed: () {
                  ref.read(mealsProvider.notifier).clearDraft();
                  ref.read(screenProvider.notifier).go(AppScreen.home);
                },
                icon: const Icon(Icons.close_rounded),
              ),
              title: Text(draft.source == 'gemini'
                  ? 'Confirm AI Scan'
                  : draft.source == 'heuristic'
                      ? 'Review Estimate'
                      : 'Build Meal'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: context.s(16), vertical: 6),
                child: Column(
                  children: [
                    if (draft.imagePath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: Image.file(File(draft.imagePath!),
                              fit: BoxFit.cover),
                        ),
                      ),
                    if (s.note != null) ...[
                      const SizedBox(height: 10),
                      SectionCard(
                        background: AppColors.warn.withValues(alpha: 0.1),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: AppColors.warn, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(s.note!,
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    _TotalsBar(total: draft.total, confidence: draft.confidence),
                    const SizedBox(height: 14),
                    _MealTypePicker(
                      type: draft.type,
                      onChanged: (t) => ref
                          .read(mealsProvider.notifier)
                          .updateDraft((d) => d.copyWith(type: t)),
                    ),
                    const SizedBox(height: 14),
                    Text('Items',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    for (int i = 0; i < draft.items.length; i++)
                      _ItemEditor(
                        item: draft.items[i],
                        index: i,
                        onChanged: (newItem) {
                          final list = [...draft.items];
                          list[i] = newItem;
                          ref
                              .read(mealsProvider.notifier)
                              .updateDraft((d) => d.copyWith(items: list));
                        },
                        onDelete: () {
                          final list = [...draft.items]..removeAt(i);
                          ref
                              .read(mealsProvider.notifier)
                              .updateDraft((d) => d.copyWith(items: list));
                        },
                      ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => _pickFromDb(context, ref, draft),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add item from library'),
                    ),
                    const SizedBox(height: 18),
                    GradientButton(
                      label: 'Save to Today',
                      icon: Icons.save_rounded,
                      onPressed: draft.items.isEmpty ? null : () async {
                        await ref.read(mealsProvider.notifier).saveDraft();
                        if (!context.mounted) return;
                        ref
                            .read(screenProvider.notifier)
                            .go(AppScreen.home);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromDb(
      BuildContext context, WidgetRef ref, Meal draft) async {
    final entry = await showModalBottomSheet<NutritionEntry>(
      context: context,
      backgroundColor: AppColors.bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _FoodPickerSheet(),
    );
    if (entry == null) return;
    final item = MealItem(
      name: entry.name,
      grams: entry.defaultServingG,
      macros: entry.macrosFor(entry.defaultServingG),
    );
    ref.read(mealsProvider.notifier).updateDraft(
          (d) => d.copyWith(items: [...d.items, item]),
        );
  }
}

class _TotalsBar extends StatelessWidget {
  final Macros total;
  final double confidence;
  const _TotalsBar({required this.total, required this.confidence});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _col('Calories', '${total.calories.round()}',
                  AppColors.accent, 'kcal'),
              _col('Protein', '${total.protein.round()}',
                  AppColors.accentProtein, 'g'),
              _col('Carbs', '${total.carbs.round()}',
                  AppColors.accentCarbs, 'g'),
              _col('Fat', '${total.fat.round()}',
                  AppColors.accentFat, 'g'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.verified_outlined,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('Confidence: ${(confidence * 100).round()}%',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _col(String label, String value, Color color, String unit) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color)),
        Text('$label · $unit',
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _ItemEditor extends StatelessWidget {
  final MealItem item;
  final int index;
  final ValueChanged<MealItem> onChanged;
  final VoidCallback onDelete;
  const _ItemEditor({
    required this.item,
    required this.index,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SectionCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item.name,
                    onChanged: (v) => onChanged(item.copyWith(name: v)),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.textMuted),
                ),
              ],
            ),
            Row(
              children: [
                Text('Serving: ${item.grams.round()} g',
                    style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                Text(
                  '${item.macros.calories.round()} kcal · '
                  'P ${item.macros.protein.toStringAsFixed(0)} / '
                  'C ${item.macros.carbs.toStringAsFixed(0)} / '
                  'F ${item.macros.fat.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            Slider(
              min: 10, max: 800,
              value: item.grams.clamp(10, 800),
              onChanged: (v) {
                // Rescale macros proportionally.
                if (item.grams == 0) {
                  onChanged(item.copyWith(grams: v));
                  return;
                }
                final factor = v / item.grams;
                onChanged(item.copyWith(
                  grams: v,
                  macros: item.macros.scale(factor),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MealTypePicker extends StatelessWidget {
  final MealType type;
  final ValueChanged<MealType> onChanged;
  const _MealTypePicker({required this.type, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: MealType.values.map((t) {
        final selected = type == t;
        return ChoiceChip(
          label: Text(t.name[0].toUpperCase() + t.name.substring(1)),
          selected: selected,
          onSelected: (_) => onChanged(t),
          selectedColor: AppColors.accent.withValues(alpha: 0.25),
          labelStyle: TextStyle(
            color: selected ? AppColors.accent : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: AppColors.card,
          side: BorderSide(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        );
      }).toList(),
    );
  }
}

class _FoodPickerSheet extends StatefulWidget {
  const _FoodPickerSheet();
  @override
  State<_FoodPickerSheet> createState() => _FoodPickerSheetState();
}

class _FoodPickerSheetState extends State<_FoodPickerSheet> {
  final _ctrl = TextEditingController();
  List<NutritionEntry> _results = NutritionDb.entries;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 14,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          TextField(
            controller: _ctrl,
            autofocus: true,
            onChanged: (v) =>
                setState(() => _results = NutritionDb.search(v).take(50).toList()),
            decoration: InputDecoration(
              hintText: 'Search foods…',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.55),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (ctx, i) {
                final e = _results[i];
                return ListTile(
                  onTap: () => Navigator.of(ctx).pop(e),
                  tileColor: AppColors.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(e.name),
                  subtitle: Text('${e.caloriesPer100g.round()} kcal / 100 g'),
                  trailing: const Icon(Icons.add_rounded),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
