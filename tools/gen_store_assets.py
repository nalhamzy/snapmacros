"""SnapMacros - full store-asset generator.

Emits to `store_assets/`:
  feature_graphic_1024x500.png
  og_card_1200x630.png
  phone/01_home.png ... 05_paywall.png
  tablet/01_home.png ... 05_paywall.png
  android/icon-512.png

Dark theme with signature green + blue + macro accents.
"""
from __future__ import annotations
import os
import math
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT = os.path.join(ROOT, "store_assets")
ICON_PATH = os.path.join(
    ROOT, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset",
    "Icon-App-1024x1024@1x.png",
)

BG = (15, 17, 20)
BG_ELEV = (24, 27, 32)
CARD = (30, 33, 40)
BORDER = (42, 46, 54)
TEXT = (245, 246, 248)
T2 = (159, 164, 176)
MUTE = (94, 100, 112)
GREEN = (0, 217, 128)       # signature
BLUE = (92, 155, 255)
PROTEIN = (255, 92, 138)
CARBS = (255, 200, 92)
FAT = (139, 92, 255)
GOLD = (255, 199, 95)
WARN = (255, 181, 71)

PHONE_W, PHONE_H = 1290, 2796
TABLET_W, TABLET_H = 2064, 2752


def _font(size, bold=False):
    candidates = [
        "C:/Windows/Fonts/seguibl.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
    ]
    for c in candidates:
        if os.path.exists(c):
            try:
                return ImageFont.truetype(c, size)
            except Exception:
                pass
    return ImageFont.load_default()


def _glow(w, h, cx, cy, color, max_r, alpha_peak=120, steps=24):
    layer = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    for i in range(steps):
        t = 1 - i / steps
        alpha = int(alpha_peak * t * t)
        rr = int(max_r * (1 - i / steps))
        d.ellipse([cx - rr, cy - rr, cx + rr, cy + rr],
                  fill=(color[0], color[1], color[2], alpha))
    return layer.filter(ImageFilter.GaussianBlur(max_r // 6))


def _bg(w, h):
    base = Image.new("RGBA", (w, h), BG + (255,))
    base.alpha_composite(_glow(w, h, int(w * 0.2), int(h * 0.15),
                               GREEN, max_r=w, alpha_peak=70))
    base.alpha_composite(_glow(w, h, int(w * 0.85), int(h * 0.85),
                               BLUE, max_r=w, alpha_peak=60))
    return base


def _rr(d, box, r, fill=None, outline=None, width=1):
    d.rounded_rectangle(box, radius=r, fill=fill, outline=outline, width=width)


def _wrap(text, font, max_w):
    words = text.split()
    lines, cur = [], ""
    d = ImageDraw.Draw(Image.new("RGB", (1, 1)))
    for w in words:
        trial = (cur + " " + w).strip()
        if d.textlength(trial, font=font) <= max_w:
            cur = trial
        else:
            if cur: lines.append(cur)
            cur = w
    if cur: lines.append(cur)
    return lines


def _text_center(img, text, y, font, fill, max_w):
    d = ImageDraw.Draw(img)
    for line in _wrap(text, font, max_w):
        bbox = d.textbbox((0, 0), line, font=font)
        tw = bbox[2] - bbox[0]
        d.text(((img.width - tw) // 2, y), line, font=font, fill=fill)
        y += int((bbox[3] - bbox[1]) * 1.25)


def _device(w, h):
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    r = int(min(w, h) * 0.09)
    _rr(d, [0, 0, w, h], r, fill=(18, 20, 24, 255))
    inset = 18
    _rr(d, [inset, inset, w - inset, h - inset], r - inset // 2, fill=BG + (255,))
    iw, ih = int(w * 0.32), int(w * 0.09)
    ix = (w - iw) // 2
    iy = int(w * 0.05)
    _rr(d, [ix, iy, ix + iw, iy + ih], ih // 2, fill=(8, 10, 14, 255))
    return img, (inset, inset, w - inset, h - inset)


def _header(canvas, title, subtitle=""):
    ft = _font(120, bold=True)
    fs = _font(56)
    y = int(canvas.height * 0.05)
    _text_center(canvas, title, y, ft, TEXT + (255,),
                 int(canvas.width * 0.86))
    if subtitle:
        d = ImageDraw.Draw(canvas)
        bbox = d.textbbox((0, 0), title, font=ft)
        lines = len(_wrap(title, ft, int(canvas.width * 0.86)))
        y += lines * int((bbox[3] - bbox[1]) * 1.25) + 20
        _text_center(canvas, subtitle, y, fs, GREEN + (255,),
                     int(canvas.width * 0.8))
    return int(canvas.height * 0.28)


def _macro_ring(ui, cx, cy, radius, pct, color, label, value_txt):
    d = ImageDraw.Draw(ui)
    stroke = int(radius * 0.18)
    d.ellipse([cx - radius, cy - radius, cx + radius, cy + radius],
              outline=BORDER + (255,), width=stroke)
    deg = 360 * min(pct, 1.0)
    for w_ in range(stroke):
        d.arc([cx - radius + w_ // 2, cy - radius + w_ // 2,
               cx + radius - w_ // 2, cy + radius - w_ // 2],
              start=-90, end=-90 + deg, fill=color + (255,), width=1)
    # Value
    f = _font(int(radius * 0.55), bold=True)
    tw = d.textlength(value_txt, font=f)
    bbox = d.textbbox((0, 0), value_txt, font=f)
    d.text((cx - tw / 2, cy - (bbox[3] - bbox[1]) / 2 - bbox[1] // 2 - 4),
           value_txt, font=f, fill=TEXT + (255,))
    f2 = _font(int(radius * 0.28), bold=True)
    lw = d.textlength(label, font=f2)
    d.text((cx - lw / 2, cy + radius + 16), label, font=f2, fill=T2 + (255,))


def _paint_home(ui):
    d = ImageDraw.Draw(ui)
    W, H = ui.size
    ui.paste(_bg(W, H), (0, 0))
    d = ImageDraw.Draw(ui)
    pad = int(W * 0.05)

    d.text((W - pad - 90, int(H * 0.025)), "9:41",
           font=_font(36, bold=True), fill=TEXT)

    y = int(H * 0.075)
    # Top bar: streak + Pro
    _rr(d, [pad, y, pad + 260, y + 80], 40, fill=CARD + (255,))
    d.text((pad + 30, y + 24), "STREAK", font=_font(22, bold=True), fill=T2)
    d.text((pad + 150, y + 18), "24", font=_font(42, bold=True), fill=GREEN)
    _rr(d, [W - pad - 180, y, W - pad, y + 80], 40, fill=GREEN + (255,))
    f = _font(22, bold=True)
    tw = d.textlength("SNAP PRO", font=f)
    d.text((W - pad - 180 + (180 - tw) / 2, y + 28),
           "SNAP PRO", font=f, fill=BG)
    y += 110

    # Hero summary card
    _rr(d, [pad, y, W - pad, y + 860], 36, fill=CARD + (255,),
        outline=BORDER + (255,), width=2)
    d.text((pad + 40, y + 30), "TODAY", font=_font(22, bold=True), fill=T2)
    d.text((pad + 40, y + 66), "Calories",
           font=_font(30, bold=True), fill=TEXT)
    # Big calorie number
    big_f = _font(110, bold=True)
    val = "1,482"
    d.text((pad + 40, y + 110), val, font=big_f, fill=TEXT)
    # Target
    d.text((pad + 40, y + 240), "of 2,100 target  -  618 left",
           font=_font(26), fill=T2)
    # Calorie bar
    bx = pad + 40
    by = y + 290
    bw = W - 2 * pad - 80
    _rr(d, [bx, by, bx + bw, by + 30], 15, fill=BORDER + (255,))
    _rr(d, [bx, by, bx + int(bw * 1482 / 2100), by + 30], 15, fill=GREEN + (255,))
    # 3 macro rings
    ring_y = y + 500
    ring_r = 130
    slots = [(W * 0.25, 0.68, PROTEIN, "PROTEIN", "142g"),
             (W * 0.5, 0.54, CARBS, "CARBS", "168g"),
             (W * 0.75, 0.42, FAT, "FAT", "52g")]
    for cx, pct, col, label, vt in slots:
        _macro_ring(ui, int(cx), ring_y, ring_r, pct, col, label, vt)
    d = ImageDraw.Draw(ui)
    y += 900

    # Meals list header
    d.text((pad, y), "TODAY'S MEALS",
           font=_font(24, bold=True), fill=T2)
    # Log button
    bw_ = 300
    _rr(d, [W - pad - bw_, y - 12, W - pad, y + 60], 36, fill=GREEN + (255,))
    f = _font(26, bold=True)
    tw = d.textlength("+ Snap meal", font=f)
    d.text((W - pad - bw_ + (bw_ - tw) / 2, y + 8),
           "+ Snap meal", font=f, fill=BG)
    y += 90

    # Meal tiles
    meals = [
        ("Greek yogurt bowl", "8:30 AM", 320, PROTEIN),
        ("Chicken + rice", "1:15 PM", 540, CARBS),
        ("Almonds", "3:45 PM", 180, FAT),
    ]
    for name, when, cal, col in meals:
        _rr(d, [pad, y, W - pad, y + 180], 28,
            fill=CARD + (255,), outline=BORDER + (255,), width=2)
        # Food icon blob
        _rr(d, [pad + 30, y + 30, pad + 150, y + 150], 30,
            fill=(col[0], col[1], col[2], 60))
        f1 = _font(50, bold=True)
        # Draw single initial letter in color
        initial = name[0]
        iw = d.textlength(initial, font=f1)
        d.text((pad + 90 - iw / 2, y + 50), initial, font=f1, fill=col)
        # Meal info
        d.text((pad + 180, y + 38), name,
               font=_font(34, bold=True), fill=TEXT)
        d.text((pad + 180, y + 90), when, font=_font(24), fill=T2)
        # Calories
        fc = _font(44, bold=True)
        cs = f"{cal} cal"
        cw = d.textlength(cs, font=fc)
        d.text((W - pad - 40 - cw, y + 66), cs, font=fc, fill=TEXT)
        y += 200


def _paint_scan(ui):
    d = ImageDraw.Draw(ui)
    W, H = ui.size
    ui.paste(_bg(W, H), (0, 0))
    d = ImageDraw.Draw(ui)
    pad = int(W * 0.05)

    d.text((W - pad - 90, int(H * 0.025)), "9:42",
           font=_font(36, bold=True), fill=TEXT)

    y = int(H * 0.075)
    d.text((pad, y), "< Back", font=_font(28, bold=True), fill=T2)
    y += 60
    d.text((pad, y), "Snap your plate",
           font=_font(68, bold=True), fill=TEXT)
    y += 110

    # Camera preview
    cam_h = 1700
    _rr(d, [pad, y, W - pad, y + cam_h], 40, fill=(18, 22, 26, 255))
    # Fake plate composition
    # plate circle
    cx, cy = W // 2, y + 750
    pr = 420
    ui.alpha_composite(_glow(W, H, cx, cy, GREEN, 560, alpha_peak=90), (0, 0))
    d = ImageDraw.Draw(ui)
    d.ellipse([cx - pr, cy - pr, cx + pr, cy + pr],
              fill=(245, 242, 236, 255))
    # food mound (chicken)
    d.pieslice([cx - pr + 40, cy - pr + 40, cx + pr - 40, cy + pr - 40],
               start=210, end=330, fill=(195, 142, 80, 255))
    # rice
    d.pieslice([cx - pr + 40, cy - pr + 40, cx + pr - 40, cy + pr - 40],
               start=330, end=450, fill=(236, 228, 204, 255))
    # veg
    d.pieslice([cx - pr + 40, cy - pr + 40, cx + pr - 40, cy + pr - 40],
               start=90, end=210, fill=(108, 168, 96, 255))
    # Corner brackets
    brack = 70
    corners = [(pad + 60, y + 60), (W - pad - 60 - brack, y + 60),
               (pad + 60, y + cam_h - 60 - brack),
               (W - pad - 60 - brack, y + cam_h - 60 - brack)]
    for bx, by_ in corners:
        d.line([bx, by_, bx + brack, by_], fill=GREEN + (255,), width=8)
        d.line([bx, by_, bx, by_ + brack], fill=GREEN + (255,), width=8)
    # AI detection pill overlay (top of preview)
    hint = "AI detecting... grilled chicken, rice, broccoli"
    f = _font(24, bold=True)
    hw = d.textlength(hint, font=f)
    _rr(d, [W // 2 - int(hw / 2) - 36, y + 80,
            W // 2 + int(hw / 2) + 36, y + 150], 35,
        fill=(0, 0, 0, 210), outline=GREEN + (255,), width=2)
    d.text((W // 2 - hw / 2, y + 96), hint, font=f, fill=GREEN)
    # Detection boxes around food
    _rr(d, [cx - 260, cy - 90, cx - 30, cy + 180], 20,
        outline=PROTEIN + (255,), width=5)
    d.text((cx - 250, cy - 130), "chicken",
           font=_font(22, bold=True), fill=PROTEIN)
    _rr(d, [cx + 10, cy - 180, cx + 280, cy + 60], 20,
        outline=CARBS + (255,), width=5)
    d.text((cx + 20, cy - 220), "rice",
           font=_font(22, bold=True), fill=CARBS)
    _rr(d, [cx - 150, cy - 300, cx + 150, cy - 120], 20,
        outline=GREEN + (255,), width=5)
    d.text((cx - 140, cy - 340), "broccoli",
           font=_font(22, bold=True), fill=GREEN)
    y += cam_h + 40

    # Capture button
    cap_r = 90
    ccx, ccy = W // 2, y + cap_r + 20
    ui.alpha_composite(_glow(W, H, ccx, ccy, GREEN, 250, alpha_peak=150), (0, 0))
    d = ImageDraw.Draw(ui)
    d.ellipse([ccx - cap_r - 14, ccy - cap_r - 14,
               ccx + cap_r + 14, ccy + cap_r + 14],
              outline=GREEN + (255,), width=8)
    d.ellipse([ccx - cap_r, ccy - cap_r, ccx + cap_r, ccy + cap_r],
              fill=GREEN + (255,))


def _paint_confirm(ui):
    """Confirm meal: editable macros, portion slider."""
    d = ImageDraw.Draw(ui)
    W, H = ui.size
    ui.paste(_bg(W, H), (0, 0))
    d = ImageDraw.Draw(ui)
    pad = int(W * 0.05)

    d.text((W - pad - 90, int(H * 0.025)), "9:43",
           font=_font(36, bold=True), fill=TEXT)

    y = int(H * 0.075)
    d.text((pad, y), "< Retake", font=_font(28, bold=True), fill=T2)
    y += 60
    d.text((pad, y), "Grilled chicken", font=_font(64, bold=True), fill=TEXT)
    d.text((pad, y + 80), "bowl", font=_font(64, bold=True), fill=TEXT)
    y += 200

    # Big calorie card
    _rr(d, [pad, y, W - pad, y + 260], 36, fill=CARD + (255,),
        outline=GREEN + (255,), width=3)
    d.text((pad + 40, y + 32), "ESTIMATED", font=_font(24, bold=True), fill=T2)
    big = _font(120, bold=True)
    val = "540"
    d.text((pad + 40, y + 68), val, font=big, fill=TEXT)
    # kcal
    d.text((pad + 280, y + 148), "kcal", font=_font(40, bold=True), fill=T2)
    # Confidence pill
    pill_w = 240
    _rr(d, [W - pad - 40 - pill_w, y + 70,
            W - pad - 40, y + 140], 35,
        fill=(GREEN[0], GREEN[1], GREEN[2], 60))
    f = _font(24, bold=True)
    tw = d.textlength("92% CONFIDENT", font=f)
    d.text((W - pad - 40 - pill_w + (pill_w - tw) / 2, y + 92),
           "92% CONFIDENT", font=f, fill=GREEN)
    y += 300

    # Macro rows
    macros = [
        ("Protein", "42g", 168, PROTEIN),
        ("Carbs", "58g", 232, CARBS),
        ("Fat", "16g", 144, FAT),
    ]
    for name, amount, kcal, col in macros:
        _rr(d, [pad, y, W - pad, y + 170], 28, fill=CARD + (255,),
            outline=BORDER + (255,), width=2)
        # Icon dot
        d.ellipse([pad + 40, y + 50, pad + 110, y + 120], fill=col + (255,))
        d.text((pad + 140, y + 36), name,
               font=_font(38, bold=True), fill=TEXT)
        d.text((pad + 140, y + 90), f"{kcal} kcal", font=_font(26), fill=T2)
        # Amount
        fa = _font(52, bold=True)
        aw = d.textlength(amount, font=fa)
        d.text((W - pad - 40 - aw, y + 60), amount, font=fa, fill=col)
        y += 190

    y += 20
    # Portion slider
    d.text((pad, y), "PORTION  -  1.0x",
           font=_font(24, bold=True), fill=T2)
    y += 50
    _rr(d, [pad, y, W - pad, y + 24], 12, fill=BORDER + (255,))
    _rr(d, [pad, y, pad + (W - 2 * pad) // 2, y + 24], 12, fill=GREEN + (255,))
    # Thumb
    thumb_x = pad + (W - 2 * pad) // 2
    d.ellipse([thumb_x - 30, y - 18, thumb_x + 30, y + 42], fill=GREEN + (255,))
    y += 80

    # Save button
    _rr(d, [pad, y, W - pad, y + 140], 34, fill=GREEN + (255,))
    f = _font(44, bold=True)
    tw = d.textlength("Log this meal", font=f)
    d.text(((W - tw) / 2, y + 46), "Log this meal", font=f, fill=BG)


def _paint_history(ui):
    d = ImageDraw.Draw(ui)
    W, H = ui.size
    ui.paste(_bg(W, H), (0, 0))
    d = ImageDraw.Draw(ui)
    pad = int(W * 0.05)

    d.text((W - pad - 90, int(H * 0.025)), "9:44",
           font=_font(36, bold=True), fill=TEXT)

    y = int(H * 0.075)
    d.text((pad, y), "HISTORY", font=_font(28, bold=True), fill=T2)
    y += 48
    d.text((pad, y), "Last 7 days", font=_font(72, bold=True), fill=TEXT)
    y += 130

    # 7-day bar chart card
    _rr(d, [pad, y, W - pad, y + 700], 36, fill=CARD + (255,),
        outline=BORDER + (255,), width=2)
    d.text((pad + 40, y + 32), "CALORIES / DAY",
           font=_font(22, bold=True), fill=T2)
    d.text((pad + 40, y + 68), "AVG 2,048 kcal",
           font=_font(40, bold=True), fill=TEXT)

    # Bars
    days = ["M", "T", "W", "T", "F", "S", "S"]
    vals = [0.82, 0.95, 0.88, 0.78, 1.02, 0.72, 0.90]
    chart_top = y + 180
    chart_bottom = y + 600
    chart_h = chart_bottom - chart_top
    bw = (W - 2 * pad - 80) // 7
    # target line
    tline_y = chart_top + int(chart_h * (1 - 0.88))
    d.line([pad + 40, tline_y, W - pad - 40, tline_y],
           fill=GREEN + (120,), width=3)
    f_day = _font(28, bold=True)
    for i, (day, v) in enumerate(zip(days, vals)):
        bx = pad + 40 + i * bw + bw // 4
        bh = int(chart_h * v)
        bt = chart_bottom - bh
        # Color: green if close to target, warn if over
        col = WARN if v > 1.0 else GREEN if v > 0.8 else BLUE
        _rr(d, [bx, bt, bx + bw // 2, chart_bottom], 14, fill=col + (255,))
        # Day label
        dw = d.textlength(day, font=f_day)
        d.text((bx + bw // 4 - dw / 2, chart_bottom + 20),
               day, font=f_day, fill=T2)
    y += 740

    # Avg macros card
    _rr(d, [pad, y, W - pad, y + 300], 36, fill=CARD + (255,),
        outline=BORDER + (255,), width=2)
    d.text((pad + 40, y + 32), "AVG MACROS / DAY",
           font=_font(22, bold=True), fill=T2)
    macros = [("Protein", "148g", PROTEIN),
              ("Carbs", "220g", CARBS),
              ("Fat", "68g", FAT)]
    mw = (W - 2 * pad - 80) // 3
    for i, (name, val, col) in enumerate(macros):
        mx = pad + 40 + i * mw
        f1 = _font(52, bold=True)
        vw = d.textlength(val, font=f1)
        d.text((mx + mw / 2 - vw / 2, y + 90), val, font=f1, fill=col)
        fl = _font(24, bold=True)
        lw = d.textlength(name, font=fl)
        d.text((mx + mw / 2 - lw / 2, y + 180), name, font=fl, fill=T2)


def _paint_paywall(ui):
    d = ImageDraw.Draw(ui)
    W, H = ui.size
    ui.paste(_bg(W, H), (0, 0))
    d = ImageDraw.Draw(ui)
    pad = int(W * 0.05)

    d.text((W - pad - 50, int(H * 0.03)), "X",
           font=_font(60, bold=True), fill=TEXT)

    y = int(H * 0.08)
    _rr(d, [pad, y, pad + 220, y + 64], 32,
        fill=(GREEN[0], GREEN[1], GREEN[2], 50))
    d.text((pad + 30, y + 16), "SNAP PRO",
           font=_font(26, bold=True), fill=GREEN)
    y += 100

    d.text((pad, y), "Unlimited", font=_font(96, bold=True), fill=TEXT)
    d.text((pad, y + 112), "snap scans.",
           font=_font(96, bold=True), fill=GREEN)
    y += 260
    d.text((pad, y), "No daily limits. Full history.",
           font=_font(30), fill=T2)
    d.text((pad, y + 44), "Zero ads. Ever.",
           font=_font(30), fill=T2)
    y += 130

    perks = [
        ("Unlimited AI meal scans", GREEN),
        ("Full 12-month trend history", BLUE),
        ("Custom macro targets + goals", PROTEIN),
        ("Export to CSV / Apple Health", CARBS),
        ("No ads. No trackers. Ever.", FAT),
    ]
    for title, col in perks:
        cx, cy = pad + 40, y + 40
        d.ellipse([cx - 28, cy - 28, cx + 28, cy + 28], fill=col + (255,))
        d.line([cx - 14, cy + 2, cx - 4, cy + 12], fill=BG, width=6)
        d.line([cx - 4, cy + 12, cx + 16, cy - 10], fill=BG, width=6)
        d.text((pad + 110, y + 20), title, font=_font(32, bold=True), fill=TEXT)
        y += 95
    y += 20

    tiers = [
        ("Pro Yearly", "Save 50%. Just $3.33/mo.", "$39.99", True, "BEST VALUE"),
        ("Pro Monthly", "Cancel anytime.", "$6.99", False, None),
        ("Pro Lifetime", "One payment. Forever.", "$59.99", False, None),
    ]
    for name, desc, price, selected, badge in tiers:
        fill = (GREEN[0], GREEN[1], GREEN[2], 40) if selected else CARD + (255,)
        _rr(d, [pad, y, W - pad, y + 160], 30, fill=fill,
            outline=GREEN + (255,) if selected else BORDER + (255,),
            width=4 if selected else 2)
        cx = pad + 50
        cy = y + 80
        d.ellipse([cx - 24, cy - 24, cx + 24, cy + 24],
                  fill=GREEN + (255,) if selected else CARD + (255,),
                  outline=GREEN + (255,) if selected else BORDER + (255,), width=4)
        if selected:
            d.line([cx - 10, cy + 2, cx - 2, cy + 10], fill=BG, width=5)
            d.line([cx - 2, cy + 10, cx + 12, cy - 7], fill=BG, width=5)
        name_x = pad + 110
        d.text((name_x, y + 36), name, font=_font(34, bold=True), fill=TEXT)
        if badge:
            nw = _font(34, bold=True).getlength(name)
            bw_ = _font(18, bold=True).getlength(badge) + 24
            _rr(d, [int(name_x + nw + 16), y + 40,
                    int(name_x + nw + 16 + bw_), y + 76], 18, fill=GREEN + (255,))
            d.text((int(name_x + nw + 28), y + 46), badge,
                   font=_font(18, bold=True), fill=BG)
        d.text((name_x, y + 88), desc, font=_font(22), fill=T2)
        pw_ = _font(38, bold=True).getlength(price)
        d.text((W - pad - 30 - int(pw_), y + 58), price,
               font=_font(38, bold=True), fill=TEXT)
        y += 180

    y += 30
    _rr(d, [pad, y, W - pad, y + 140], 34, fill=GREEN + (255,))
    f = _font(44, bold=True)
    tw = d.textlength("Unlock Snap Pro", font=f)
    d.text(((W - tw) / 2, y + 46), "Unlock Snap Pro", font=f, fill=BG)


def render_phone(title, sub, painter):
    canvas = _bg(PHONE_W, PHONE_H)
    content_y = _header(canvas, title, sub)
    dw = int(PHONE_W * 0.82)
    dh = int(dw * (19.5 / 9))
    device, inner = _device(dw, dh)
    ui = Image.new("RGBA", (inner[2] - inner[0], inner[3] - inner[1]), BG + (255,))
    painter(ui)
    device.paste(ui, (inner[0], inner[1]), ui)
    sh = Image.new("RGBA", device.size, (0, 0, 0, 0))
    ImageDraw.Draw(sh).rounded_rectangle(
        [20, 40, dw - 20, dh - 20],
        radius=int(min(dw, dh) * 0.09), fill=(0, 0, 0, 180))
    sh = sh.filter(ImageFilter.GaussianBlur(50))
    dx = (PHONE_W - dw) // 2
    dy = content_y
    canvas.alpha_composite(sh, (dx, dy))
    canvas.alpha_composite(device, (dx, dy))
    return canvas


def render_feature():
    w, h = 1024, 500
    canvas = _bg(w, h)
    d = ImageDraw.Draw(canvas)
    if os.path.exists(ICON_PATH):
        icon = Image.open(ICON_PATH).convert("RGBA").resize((220, 220), Image.LANCZOS)
        canvas.alpha_composite(_glow(w, h, 190, 250, GREEN, 300, alpha_peak=140))
        canvas.alpha_composite(icon, (80, 140))
    d = ImageDraw.Draw(canvas)
    d.text((340, 140), "SnapMacros", font=_font(78, bold=True), fill=TEXT)
    d.text((340, 230), "Snap a meal. See the macros.",
           font=_font(32, bold=True), fill=GREEN)
    d.text((340, 300), "AI macro tracking - no typing.",
           font=_font(28), fill=TEXT)
    d.text((340, 350), "Protein, carbs, fat. In seconds.",
           font=_font(28), fill=T2)
    return canvas


def render_og():
    w, h = 1200, 630
    canvas = _bg(w, h)
    if os.path.exists(ICON_PATH):
        icon = Image.open(ICON_PATH).convert("RGBA").resize((260, 260), Image.LANCZOS)
        canvas.alpha_composite(_glow(w, h, 230, 310, GREEN, 400, alpha_peak=160))
        canvas.alpha_composite(icon, (100, 180))
    d = ImageDraw.Draw(canvas)
    d.text((400, 190), "SnapMacros", font=_font(84, bold=True), fill=TEXT)
    d.text((400, 290), "Snap. Tap. Logged.",
           font=_font(48, bold=True), fill=GREEN)
    d.text((400, 360), "AI macro tracking. No typing.",
           font=_font(36), fill=TEXT)
    d.text((400, 500), "nalhamzy.github.io/snapmacros",
           font=_font(28, bold=True), fill=T2)
    return canvas


def main():
    os.makedirs(os.path.join(OUT, "phone"), exist_ok=True)
    os.makedirs(os.path.join(OUT, "tablet"), exist_ok=True)
    os.makedirs(os.path.join(OUT, "android"), exist_ok=True)

    print("> feature graphic")
    render_feature().convert("RGB").save(
        os.path.join(OUT, "feature_graphic_1024x500.png"))
    print("> og card")
    render_og().convert("RGB").save(
        os.path.join(OUT, "og_card_1200x630.png"))

    shots = [
        ("01_home", "Your day at a glance.",
         "Calories, macros, streak.", _paint_home),
        ("02_scan", "Snap your plate.",
         "AI detects food in seconds.", _paint_scan),
        ("03_confirm", "Tune. Then log.",
         "AI guess + your quick edit.", _paint_confirm),
        ("04_history", "See the trend.",
         "7- and 30-day charts.", _paint_history),
        ("05_paywall", "Unlimited scans.",
         "Snap Pro unlocks everything. No ads.",
         _paint_paywall),
    ]
    for name, title, sub, painter in shots:
        print(f"> phone/{name}.png")
        img = render_phone(title, sub, painter)
        img.convert("RGB").save(
            os.path.join(OUT, "phone", f"{name}.png"), optimize=True)

    if os.path.exists(ICON_PATH):
        print("> android/icon-512.png")
        Image.open(ICON_PATH).convert("RGB").resize((512, 512), Image.LANCZOS).save(
            os.path.join(OUT, "android", "icon-512.png"))

    tablet_titles = {
        "01_home": "Your day at a glance",
        "02_scan": "Snap your plate",
        "03_confirm": "Tune. Then log",
        "04_history": "See the trend",
        "05_paywall": "Unlock Snap Pro",
    }
    for name, _t, _s, painter in shots:
        print(f"> tablet/{name}.png")
        canvas = _bg(TABLET_W, TABLET_H)
        d = ImageDraw.Draw(canvas)
        title = tablet_titles[name]
        f = _font(130, bold=True)
        tw = d.textlength(title, font=f)
        d.text(((TABLET_W - tw) // 2, int(TABLET_H * 0.05)),
               title, font=f, fill=TEXT)
        dw = int(TABLET_W * 0.58)
        dh = int(dw * (19.5 / 9))
        device, inner = _device(dw, dh)
        ui = Image.new("RGBA", (inner[2] - inner[0], inner[3] - inner[1]),
                       BG + (255,))
        painter(ui)
        device.paste(ui, (inner[0], inner[1]), ui)
        sh = Image.new("RGBA", device.size, (0, 0, 0, 0))
        ImageDraw.Draw(sh).rounded_rectangle(
            [20, 40, dw - 20, dh - 20],
            radius=int(min(dw, dh) * 0.09), fill=(0, 0, 0, 180))
        sh = sh.filter(ImageFilter.GaussianBlur(50))
        dx = (TABLET_W - dw) // 2
        dy = int(TABLET_H * 0.18)
        canvas.alpha_composite(sh, (dx, dy))
        canvas.alpha_composite(device, (dx, dy))
        canvas.convert("RGB").save(
            os.path.join(OUT, "tablet", f"{name}.png"), optimize=True)

    print("\nAll SnapMacros store assets emitted to:")
    print(f"  {OUT}")


if __name__ == "__main__":
    main()
