# SnapMacros — App Store Connect Ready-to-Paste Listing

---

## App Information

| Field | Value |
|---|---|
| **Name** | `SnapMacros: AI Calorie Tracker` |
| **Subtitle** | `Snap food, see macros` |
| **Privacy Policy URL** | `https://github.com/nalhamzy/snapmacros/blob/main/PRIVACY.md` *(deploy after first release)* |
| **Primary Category** | Health & Fitness |
| **Secondary Category** | Food & Drink |
| **Bundle ID** | `com.idealai.snapmacros` |
| **SKU** | `SNAPMACROS-IOS-001` |

## Pricing and Availability

- **Price Tier**: Free (tier 0)
- **Availability**: All territories
- **Pre-orders**: off

## Version (1.0.0) → What's New

```
First release — the honest AI macro tracker.

• Snap meals · see calories + macros instantly
• Every item is editable — never trust a bad AI guess
• 3 free AI scans per day
• Adaptive macro targets (Mifflin-St Jeor TDEE)
• 7-day trend chart
```

## Version → Promotional Text (170 chars)

```
The honest AI macro tracker. Snap a meal, instantly see calories + protein/carbs/fat — then tap any item to adjust. Transparent pricing. Real free tier.
```

## Version → Description (≤ 4000 chars)

```
Snap a meal. Get instant macros. Fine-tune with a tap. That's it.

SnapMacros uses Google Gemini AI to recognize food in your photos and break it down into calories, protein, carbs and fat — per item, not just one blurry total. Every estimate is editable: tap any item, drag the grams slider, and macros rescale in real time. No silent misidentification, no over-counting.

WHY SNAPMACROS IS DIFFERENT
— Transparent pricing — free tier with 3 AI scans/day. Weekly / monthly / yearly / lifetime all shown up front.
— Honest AI — every scan is editable with confidence shown; we don't pretend to be more accurate than we are.
— Adaptive macros — Mifflin-St Jeor TDEE + goal-aware protein/carb/fat split (lose / recomp / maintain / gain). Update your weight, targets auto-recompute.
— Offline fallback — if AI is unavailable, SnapMacros gives you a baseline estimate + clear note, instead of blocking you.
— Local food library — 40+ common foods with per-100g macros for quick add.
— 7-day trend chart with target line — see your weekly average vs goal.
— Streak tracker + daily scan tokens reset at midnight.
— Rewarded ads unlock extra scans. You're never forced into a subscription to continue.

WHAT'S FREE
• 3 AI photo scans per day (refill daily)
• Full meal logging with manual entry + local food library
• Adaptive macro targets with TDEE calculation
• Unlimited history
• 7-day trends

SNAPMACROS PRO UNLOCKS
• Unlimited AI photo scans
• No ads, ever
• Weekly insights & longer-term trend analysis
• Priority AI model routing for higher accuracy
Plans: $3.99/wk · $7.99/mo · $29.99/yr (best value) · $49.99 lifetime

PRIVACY
Meal photos are sent to Google Gemini for analysis and discarded after response — not retained. Your weight, goals, and meal history are stored only on your device. No account, no email required.

Built because we were tired of opaque AI-tracking apps that lied about accuracy and buried pricing. SnapMacros is what a macro tracker should be: honest, fast, and fair.
```

## Version → Keywords (100 chars)

```
calorie,macros,food,tracker,ai,photo,snap,protein,carbs,fat,diet,weight,nutrition,meal
```

## Version → Support URL

```
https://github.com/nalhamzy/snapmacros
```

## Version → App Review Information

- **Sign-in required**: No
- **Contact**: `nalhamzy@gmail.com`
- **Review notes**:

```
SnapMacros sends meal photos to Google Gemini AI for macro analysis. Photos are not retained by us. In-app purchases can be tested via sandbox tester account. No login required.
```

## Screenshots → iPhone 6.9" (1290×2796)

Upload from `store_assets/ios/` (generated via `flutter test --update-goldens --tags=screenshot`).

| Slot | File | Caption |
|---|---|---|
| 1 | `01_home.png` | `See your calories + macros at a glance.` |
| 2 | `02_log.png` | `Snap, pick, or search — your choice.` |
| 3 | `03_confirm.png` | `Tap any item to fine-tune grams.` |
| 4 | `04_history.png` | `7-day trends with your target line.` |
| 5 | `05_paywall.png` | `Transparent pricing. Real free tier.` |

## In-App Purchases

Subscription group: **SnapMacros Pro**

| Product ID | Type | Price | Trial |
|---|---|---|---|
| `snapmacros_pro_weekly` | Auto-Renewable | $3.99 / wk | 3 days |
| `snapmacros_pro_monthly` | Auto-Renewable | $7.99 / mo | 7 days |
| `snapmacros_pro_yearly` | Auto-Renewable | $29.99 / yr | none |
| `snapmacros_lifetime` | Non-Consumable | $49.99 | n/a |

**IAP description** (reuse for each):

```
SnapMacros Pro unlocks:
• Unlimited AI photo scans
• No ads
• Weekly insights & long-term trends
• Priority AI model routing
```

## App Privacy

- **Data Used to Track You** → Device ID (via AdMob) → yes
- **Data Linked to You** → None
- **Data Not Linked to You** → Health & Fitness (meal macros, weight goal — stored on-device), Photos (sent to Google Gemini for analysis, not retained by us), Diagnostics
- **Photos collected**: No (transmitted to Google Gemini only at moment of scan; discarded after response)

## Age Rating → 4+

All answers to content questions: **None** → 4+.

## Submission checklist

- [ ] All fields pasted
- [ ] 5 iPhone 6.9" screenshots uploaded
- [ ] 4 IAPs in Ready to Submit state
- [ ] Build uploaded via Codemagic
- [ ] Paid Apps agreement signed
- [ ] Submit for Review
