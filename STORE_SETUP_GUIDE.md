# SnapMacros — Store Setup Guide

Everything you (or a browser AI agent) need to list the app on App Store + Play Store.

---

## §1. Identity

- **App name**: SnapMacros
- **Subtitle / short desc**: AI Calorie & Macro Tracker
- **Bundle ID (iOS)**: `com.idealai.snapmacros`
- **Application ID (Android)**: `com.idealai.snapmacros`
- **Support email**: nalhamzy@gmail.com

## §2. Store listing copy

### Short description (80 chars, Play Store)

> Snap a meal, instantly see calories and macros. AI-powered, editable, honest.

### iOS subtitle (30 chars)

> AI Calorie & Macro Tracker

### Promotional text (170 chars, iOS)

> The honest AI macro tracker. Snap a meal, get calories + protein/carbs/fat — then tap to adjust portions. Transparent pricing. Real free tier.

### Full description (~3500 chars)

> Snap a meal. Get instant macros. Fine-tune with a tap. That's it.
>
> SnapMacros uses Google Gemini to recognize food in your photos and break it down into calories, protein, carbs and fat — broken out per-item, not just one blurry total. Every estimate is editable: tap any item, drag the grams slider, and macros rescale in real time. Never silently misled, never over-count.
>
> WHY SNAPMACROS IS DIFFERENT
> ✓ Transparent pricing — free tier with 3 AI scans/day, weekly/monthly/yearly/lifetime all shown up front.
> ✓ Honest AI — every scan is editable, with confidence shown; no pretending to be more accurate than it is.
> ✓ Adaptive macros — Mifflin-St Jeor TDEE + goal-aware protein/carb/fat split (lose / recomp / maintain / gain). Update your weight → targets auto-recompute.
> ✓ Offline fallback — if the AI is unavailable, SnapMacros still gives you an estimate + a clear note, instead of blocking you.
> ✓ Local food library — 40+ common foods with per-100g macros for quick add.
> ✓ 7-day trend chart with target line so you can see your weekly average vs your goal.
> ✓ Streak tracker + daily scan tokens reset at midnight.
> ✓ Reward ads unlock extra scans. You're never forced into a subscription to continue.
>
> WHAT'S FREE
> • 3 AI photo scans per day (refill daily)
> • Full meal logging with manual entry + local food library
> • Adaptive macro targets with TDEE calculation
> • Unlimited history
> • 7-day trends
>
> PRO UNLOCKS
> • Unlimited AI photo scans
> • No ads, ever
> • Weekly insights & longer-term trend analysis
> • Priority Gemini-Pro model routing for higher accuracy
> Plans: $3.99/wk · $7.99/mo · $29.99/yr (best value) · $49.99 lifetime
>
> PRIVACY
> Photos are sent to Google Gemini for macro analysis and discarded after response — not retained. You can delete any meal (and its local image) with one tap. No account, no email login required. See full policy at [privacy URL].
>
> Built by a small team that was frustrated with opaque AI-tracking apps that lied about accuracy and buried pricing. SnapMacros is what a macro tracker should be: honest, fast, and fair.

### Keywords (iOS, 100 chars)

```
calorie,macros,food,tracker,ai,photo,snap,protein,carbs,fat,diet,weight,nutrition,meal
```

## §3. Screenshots

Same matrix as UMAX. Capture:
1. Home (today's summary with calorie ring + macro bars)
2. Log screen (AI-snap CTA + search)
3. Confirm meal screen (tap-to-adjust portions)
4. 7-day trend chart in History
5. Paywall (shows transparent pricing)

## §4. Content rating

- **Apple age**: 4+
- **Google Play age**: 13+ (data safety — photos sent to Google Gemini)
- No violence, no UGC, no gambling, no profanity.

## §5. Data safety (Play Store declarations)

- **Photos**: sent to Google's AI for macro analysis; not retained by us.
- **Weight / health metrics**: stored on device; not collected by us.
- **Advertising ID**: collected for AdMob personalization.
- **Data encrypted in transit**: yes (HTTPS to Google APIs).
- **Users can request deletion**: yes (delete meals or uninstall).

## §6. Privacy policy (template)

> **SnapMacros Privacy Policy** (last updated YYYY-MM-DD)
>
> **What we collect**:
> - Meal photos are sent to Google Gemini for macro analysis at the moment of scan. We do not retain them server-side; we only receive the AI response and discard the photo.
> - Weight, age, goal and meal history are stored **only on your device**.
> - Advertising identifiers are used by Google AdMob for ad personalization (unless you opt out via OS-level settings).
>
> **What we do NOT do**:
> - No account, no email login, no cloud sync.
> - We do not sell data.
>
> **Third parties**:
> - Google Gemini API ([policy](https://ai.google.dev/terms)).
> - Google AdMob ([policy](https://policies.google.com/privacy)).
>
> **Your rights**: delete any meal in-app, or uninstall to wipe all local data. Contact nalhamzy@gmail.com for questions.

## §7. Assistant instructions

> 1. App Store Connect → Register bundle `com.idealai.snapmacros` with IAP capability.
> 2. Create app record, primary category Health & Fitness.
> 3. Create 4 IAPs: `snapmacros_pro_weekly`, `snapmacros_pro_monthly`, `snapmacros_pro_yearly`, `snapmacros_lifetime`.
> 4. Paste store copy from §2.
> 5. Set privacy policy URL from §6.
> 6. Repeat on Play Console with application ID `com.idealai.snapmacros`.
