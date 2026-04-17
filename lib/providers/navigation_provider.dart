import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppScreen {
  onboarding,
  home,
  log,
  confirmMeal,
  history,
  paywall,
  settings,
}

class _NavNotifier extends Notifier<AppScreen> {
  @override
  AppScreen build() => AppScreen.onboarding;
  void go(AppScreen s) => state = s;
}

final screenProvider =
    NotifierProvider<_NavNotifier, AppScreen>(_NavNotifier.new);
