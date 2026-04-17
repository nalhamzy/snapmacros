# SnapMacros — Release Runbook

Production release pipeline to TestFlight + Play Production. Full pipeline is wired in `codemagic.yaml`.

---

## §0. Accounts

| Service | Purpose |
|---|---|
| Apple Developer Program | App Store ($99/yr) |
| Google Play Console | Play Store ($25 one-time) |
| Google AdMob | Ads |
| Google AI Studio / Google Cloud | Gemini API key |
| Codemagic | CI/CD |
| GitHub | Git remote |

---

## §1. Gemini API key

1. https://aistudio.google.com → API key.
2. Enable billing on the backing project (Gemini 1.5 Flash is dirt cheap: ~$0.00002/image, so 50k scans ≈ $1).
3. Copy the key, you'll inject it at build time.

**Local dev:**
```bash
flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY
```

**Codemagic:** add the key to the `snapmacros_secrets` env var group → variable `GEMINI_API_KEY` (secure).

---

## §2. App Store Connect

1. Register bundle ID `com.idealai.snapmacros` with **In-App Purchase** capability.
2. Create app record:
   - Name: `SnapMacros` or `SnapMacros: AI Calorie Tracker`
   - Bundle ID: `com.idealai.snapmacros`
   - SKU: `snapmacros-ios-001`
   - Primary category: **Health & Fitness**
3. IAPs (subscriptions in a single "SnapMacros Pro" group + one lifetime):
   - `snapmacros_pro_weekly` — Auto-Renewing — $3.99/wk — 3-day trial
   - `snapmacros_pro_monthly` — Auto-Renewing — $7.99/mo — 7-day trial
   - `snapmacros_pro_yearly` — Auto-Renewing — $29.99/yr
   - `snapmacros_lifetime` — Non-Consumable — $49.99
4. Privacy: declare *Health & Fitness* data (meal macros), photos (for AI analysis), advertising ID (AdMob).
5. App Store Connect API Key (Admin) → `.p8` for Codemagic `admin` integration.

---

## §3. Google Play Console

1. Create app `SnapMacros`.
2. **Data safety**:
   - Collected data: photos (processed in-memory + sent to Gemini during analysis, not retained by us), advertising ID.
   - Shared: image data with Google Gemini for the time needed to analyze a meal.
3. **Content rating**: complete questionnaire → ESRB Everyone / PEGI 3.
4. **IAP**: create subs + managed product matching the IDs above.
5. Enroll in Play App Signing.
6. Create GCP service account, grant **Release manager** in Play Console. JSON → Codemagic env var group `google_play` → `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` (secure).

---

## §4. Android signing

```bash
cd android/app
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
cp key.properties.template key.properties
# Fill the passwords
```

Keystore is committed; Google re-signs.

---

## §5. AdMob

Same flow as UMAX:
1. Create AdMob apps for iOS + Android.
2. Create Banner / Interstitial / Rewarded ad units.
3. Replace IDs in `lib/core/constants/ad_ids.dart`, `AndroidManifest.xml`, `Info.plist`.

---

## §6. Codemagic

1. Connect repo to codemagic.io.
2. Integrations → add App Store Connect API key (name: `admin`).
3. Env var groups:
   - `google_play` → `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` (secure).
   - `snapmacros_secrets` → `GEMINI_API_KEY` (secure).

---

## §7. Release

```bash
git commit -am "Release v1.0.0"
git tag v1.0.0
git push origin main
git push origin v1.0.0
```

Codemagic triggers `release-both` → IPA → TestFlight + AAB → Play Production DRAFT.

Post-build:
- **iOS**: add screenshots, attach IAPs, submit for review.
- **Android**: promote DRAFT → Production in Play Console.

---

## §8. Version bumps

Edit `pubspec.yaml`:

```yaml
version: 1.0.1+2
```

Tag `v1.0.1` and push.

---

## §9. Troubleshooting

- **Gemini returns 400/429**: check API key in Codemagic env group, check billing enabled, rate-limit exceeded → tell user in `note` field of the draft (already supported).
- **AI says "tikka masala" for an apple**: happens with low-quality prompts/models. We mitigate with (a) JSON-structured response, (b) user-editable confirm screen. For higher accuracy swap `gemini-1.5-flash` → `gemini-1.5-pro` in `food_analyzer.dart` (~5× cost, ~2× accuracy).
- **IAP sandbox fails**: ensure products are in "Ready to Submit" state (App Store Connect) / active (Play Console), and you're signed in with a sandbox tester.
