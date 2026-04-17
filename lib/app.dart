import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/theme.dart';
import 'core/services/iap_product_ids.dart';
import 'providers/ad_provider.dart';
import 'providers/iap_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/confirm_meal_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/log_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/ad_banner_widget.dart';

class SnapMacrosApp extends StatelessWidget {
  const SnapMacrosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapMacros',
      debugShowCheckedModeBanner: false,
      theme: buildSnapMacrosTheme(),
      home: const _AppShell(),
    );
  }
}

class _AppShell extends ConsumerStatefulWidget {
  const _AppShell();
  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(adServiceProvider).initialize();
      final iap = ref.read(iapServiceProvider);
      iap.onPurchaseSuccess = (productId) {
        final n = ref.read(profileProvider.notifier);
        if (productId == IapProductIds.lifetime) {
          n.activateLifetime();
        } else {
          n.activatePro(productId);
        }
      };
      await iap.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = ref.watch(screenProvider);
    final profile = ref.watch(profileProvider);

    Widget body;
    switch (screen) {
      case AppScreen.onboarding:
        body = const OnboardingScreen();
        break;
      case AppScreen.home:
        body = const HomeScreen();
        break;
      case AppScreen.log:
        body = const LogScreen();
        break;
      case AppScreen.confirmMeal:
        body = const ConfirmMealScreen();
        break;
      case AppScreen.history:
        body = const HistoryScreen();
        break;
      case AppScreen.paywall:
        body = const PaywallScreen();
        break;
      case AppScreen.settings:
        body = const SettingsScreen();
        break;
    }

    final hideBanner = profile.isPro ||
        screen == AppScreen.onboarding ||
        screen == AppScreen.paywall;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
                begin: const Offset(0, 0.04), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(screen), child: body),
      ),
      bottomNavigationBar: hideBanner ? null : const AdBannerWidget(),
    );
  }
}
