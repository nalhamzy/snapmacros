import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/constants/app_colors.dart';
import '../providers/ad_provider.dart';
import '../providers/profile_provider.dart';

class AdBannerWidget extends ConsumerWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    if (profile.isPro) return const SizedBox.shrink();

    final ad = ref.watch(adServiceProvider);
    final banner = ad.banner;
    if (banner == null || !ad.bannerReady) {
      return Container(height: 50, color: AppColors.bg);
    }
    return Container(
      color: AppColors.bg,
      alignment: Alignment.center,
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      child: AdWidget(ad: banner),
    );
  }
}
