# SnapMacros — Google Play Console Ready-to-Paste Listing

---

## Create app

| Field | Value |
|---|---|
| **App name** | `SnapMacros: AI Calorie Tracker` |
| **Default language** | English (US) |
| **App or game** | App |
| **Free or paid** | Free |

## Main store listing

| Field | Value |
|---|---|
| **App name** | `SnapMacros: AI Calorie Tracker` |
| **Short description** (80 chars) | `Snap a meal, see calories and macros. AI-powered, editable, honest.` |

### Full description (≤ 4000 chars)

```
Snap a meal. Get instant macros. Fine-tune with a tap. That's it.

SnapMacros uses Google Gemini AI to recognize food in your photos and break it down into calories, protein, carbs and fat — per item, not just one blurry total. Every estimate is editable: tap any item, drag the grams slider, and macros rescale in real time. Never silently misled, never over-count.

WHY SNAPMACROS IS DIFFERENT
✓ Transparent pricing — 3 AI scans/day free, all paid tiers shown upfront.
✓ Honest AI — every scan editable, confidence shown; no pretending to be more accurate than we are.
✓ Adaptive macros — Mifflin-St Jeor TDEE + goal-aware macro split (lose / recomp / maintain / gain).
✓ Offline fallback — AI unavailable? You get a baseline estimate + clear note instead of being blocked.
✓ Local food library — 40+ common foods for quick add.
✓ 7-day trend chart with target line.
✓ Rewarded ads unlock extra scans — no paywall ambush.

WHAT'S FREE
• 3 AI photo scans per day
• Manual entry + search library
• Adaptive macro targets with TDEE
• Unlimited history
• 7-day trends

SNAPMACROS PRO UNLOCKS
• Unlimited AI scans
• No ads
• Weekly insights + long-term trends
• Priority AI model
Plans: $3.99/wk · $7.99/mo · $29.99/yr (best value) · $49.99 lifetime

PRIVACY
Photos are sent to Google Gemini for analysis and discarded after response. Weight, goals, and history stored only on your device.

Download SnapMacros and log your first meal in under 10 seconds.
```

### Graphics

| Asset | Spec | Source |
|---|---|---|
| App icon | 512×512 PNG | generate from `assets/icon/icon_source.png` |
| Feature graphic | 1024×500 PNG | design with gradient + "See your macros" |
| Phone screenshots | min 320px, max 3840px | `store_assets/android/01_home.png` … `05_paywall.png` |

Minimum 2 phone screenshots required; we ship 5.

### Categorization

| Field | Value |
|---|---|
| **Category** | Health & Fitness |
| **Tags** | diet, nutrition, fitness |
| **Contact email** | `nalhamzy@gmail.com` |

## App content

### Privacy policy URL
```
https://github.com/nalhamzy/snapmacros/blob/main/PRIVACY.md
```

### Ads
Yes, contains ads (Google AdMob).

### Data safety

**Collected**:
- **Photos and videos** → collected temporarily during AI analysis (sent to Google Gemini), **not retained by us**.
- **Advertising ID** → collected, shared with Google AdMob, purpose: advertising or marketing.
- **Health & Fitness** (meal macros, weight, goals) → stored on-device only, NOT collected server-side by us.

**Data encrypted in transit**: Yes (HTTPS)
**Users can request data deletion**: Yes (in-app delete meals, uninstall for full reset)

### Content rating

All answers **None** → ESRB Everyone / PEGI 3.

### Target audience

- Ages: 13+
- Not designed for families

## Monetization → Subscriptions

| Product ID | Name | Plan | Price | Trial |
|---|---|---|---|---|
| `snapmacros_pro_weekly` | SnapMacros Pro · Weekly | weekly-auto | $3.99 | 3 days |
| `snapmacros_pro_monthly` | SnapMacros Pro · Monthly | monthly-auto | $7.99 | 7 days |
| `snapmacros_pro_yearly` | SnapMacros Pro · Yearly | yearly-auto | $29.99 | none |

## Monetization → In-app products

| Product ID | Type | Name | Price |
|---|---|---|---|
| `snapmacros_lifetime` | Managed | SnapMacros Lifetime | $49.99 |

**Product description** (reuse):

```
SnapMacros Pro unlocks unlimited AI scans, removes all ads, provides weekly insights and long-term trends, and routes to the priority AI model for higher accuracy.
```

## Release → Production

- Release name: `1.0.0 (1)`
- Release notes:

```
• First release of SnapMacros
• AI-powered meal photo analysis
• Tap-to-adjust portions
• Adaptive macro targets
• 7-day trend charts
```

## Submission checklist

- [ ] All content declarations complete
- [ ] ≥ 2 phone screenshots + feature graphic uploaded
- [ ] Privacy policy URL live
- [ ] Subscriptions + lifetime product created
- [ ] Service account invited (Release manager)
- [ ] First AAB uploaded as DRAFT by Codemagic
- [ ] Start rollout to Production
