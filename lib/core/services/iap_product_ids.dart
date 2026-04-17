class IapProductIds {
  // Suggested pricing (undercuts MacroFactor, transparently shown pre-install):
  //   proWeekly  — $3.99 / week   (3-day free trial)
  //   proMonthly — $7.99 / month  (7-day trial)
  //   proYearly  — $29.99 / year  (67% off weekly equivalent)
  //   lifetime   — $49.99 one-time
  static const proWeekly = 'snapmacros_pro_weekly';
  static const proMonthly = 'snapmacros_pro_monthly';
  static const proYearly = 'snapmacros_pro_yearly';
  static const lifetime = 'snapmacros_lifetime';

  static const subscriptions = {proWeekly, proMonthly, proYearly};
  static const nonConsumables = {lifetime};
  static const all = {proWeekly, proMonthly, proYearly, lifetime};
}
