import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/models/user_profile.dart';
import '../core/services/iap_product_ids.dart';
import '../core/services/tdee_calculator.dart';
import 'ad_provider.dart';
import 'storage_provider.dart';

class ProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    final storage = ref.read(storageServiceProvider);
    final p = storage.loadProfile();
    Future.microtask(() {
      ref.read(adServiceProvider).setAdsRemoved(p.isPro);
    });
    return _withDailyReset(p);
  }

  UserProfile _withDailyReset(UserProfile p) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (p.scanTokenDate != today) {
      return p.copyWith(
        scanTokens: 3,
        scanTokenDate: today,
      );
    }
    return p;
  }

  void _persist() =>
      ref.read(storageServiceProvider).saveProfile(state);

  Future<void> completeOnboarding({
    required Sex sex,
    required int age,
    required double heightCm,
    required double weightKg,
    required Activity activity,
    required Goal goal,
  }) async {
    final base = state.copyWith(
      sex: sex,
      age: age,
      heightCm: heightCm,
      weightKg: weightKg,
      activity: activity,
      goal: goal,
    );
    final t = TdeeCalculator.compute(base);
    state = base.copyWith(
      onboarded: true,
      calorieTarget: t.calories,
      proteinTarget: t.protein,
      carbsTarget: t.carbs,
      fatTarget: t.fat,
    );
    _persist();
  }

  Future<void> recomputeTargets() async {
    final t = TdeeCalculator.compute(state);
    state = state.copyWith(
      calorieTarget: t.calories,
      proteinTarget: t.protein,
      carbsTarget: t.carbs,
      fatTarget: t.fat,
    );
    _persist();
  }

  Future<void> updateWeight(double kg) async {
    state = state.copyWith(weightKg: kg);
    await recomputeTargets();
  }

  Future<void> activatePro(String productId) async {
    final tier = switch (productId) {
      IapProductIds.proWeekly => ProTier.weekly,
      IapProductIds.proMonthly => ProTier.monthly,
      IapProductIds.proYearly => ProTier.yearly,
      _ => ProTier.monthly,
    };
    state = state.copyWith(proTier: tier);
    ref.read(adServiceProvider).setAdsRemoved(true);
    _persist();
  }

  Future<void> activateLifetime() async {
    state = state.copyWith(proTier: ProTier.lifetime);
    ref.read(adServiceProvider).setAdsRemoved(true);
    _persist();
  }

  Future<void> consumeScanToken() async {
    if (state.isPro) return;
    if (state.scanTokens <= 0) return;
    state = state.copyWith(scanTokens: state.scanTokens - 1);
    _persist();
  }

  Future<void> grantBonusScan() async {
    state = state.copyWith(scanTokens: state.scanTokens + 1);
    _persist();
  }

  Future<void> recordLogForStreak() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (state.lastLogDate == today) return;
    final yesterday = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(const Duration(days: 1)));
    final newStreak =
        state.lastLogDate == yesterday ? state.streakDays + 1 : 1;
    state = state.copyWith(lastLogDate: today, streakDays: newStreak);
    _persist();
  }
}

final profileProvider =
    NotifierProvider<ProfileNotifier, UserProfile>(ProfileNotifier.new);
