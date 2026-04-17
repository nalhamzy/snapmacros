import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../core/models/meal.dart';
import '../core/utils/responsive.dart';
import '../providers/meals_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/section_card.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final notifier = ref.read(mealsProvider.notifier);
    final today = DateTime.now();
    final days = List.generate(
        7, (i) => DateTime(today.year, today.month, today.day - (6 - i)));
    final spots = <FlSpot>[];
    for (int i = 0; i < days.length; i++) {
      final kcal = notifier.totalOn(days[i]).calories;
      spots.add(FlSpot(i.toDouble(), kcal));
    }
    final avg7 = spots.isEmpty
        ? 0.0
        : spots.map((s) => s.y).reduce((a, b) => a + b) / spots.length;

    return SafeArea(
      child: ResponsiveContentBox(
        child: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: context.s(16), vertical: 10),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () =>
                      ref.read(screenProvider.notifier).go(AppScreen.home),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Text('Progress',
                    style: Theme.of(context).textTheme.headlineMedium),
              ],
            ),
            SectionCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('7-day calories',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(
                        'Avg ${avg7.round()} · Target ${profile.calorieTarget.round()}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 20,
                              getTitlesWidget: (v, meta) {
                                final i = v.toInt();
                                if (i < 0 || i >= days.length) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  DateFormat('E').format(days[i]),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontSize: 10),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minY: 0,
                        extraLinesData: ExtraLinesData(horizontalLines: [
                          HorizontalLine(
                            y: profile.calorieTarget,
                            color: AppColors.accent2.withValues(alpha: 0.6),
                            strokeWidth: 1,
                            dashArray: [5, 4],
                          ),
                        ]),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            curveSmoothness: 0.28,
                            barWidth: 3,
                            color: AppColors.accent,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.accent.withValues(alpha: 0.35),
                                  AppColors.accent.withValues(alpha: 0.02),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('Recent meals',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            for (final m in ref.watch(mealsProvider).meals.take(30))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MealRow(meal: m),
              ),
          ],
        ),
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  final Meal meal;
  const _MealRow({required this.meal});
  @override
  Widget build(BuildContext context) {
    final t = meal.total;
    return SectionCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
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
                Text(
                  meal.items.isEmpty
                      ? 'Empty'
                      : meal.items.map((i) => i.name).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  DateFormat('MMM d, yyyy · h:mm a').format(meal.timestamp),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text('${t.calories.round()} kcal',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 14, color: AppColors.accent)),
        ],
      ),
    );
  }
}
