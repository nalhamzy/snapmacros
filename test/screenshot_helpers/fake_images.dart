import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

Directory? _demoDir;
Directory _ensureDemoDir() {
  _demoDir ??= Directory.systemTemp.createTempSync('snapmacros_demo_');
  return _demoDir!;
}

/// Generates a stylized "plate of food" placeholder using pure-Dart PNG
/// encoding. Returns the absolute path.
Future<String> writeDemoMealImage({
  required String filename,
  required List<Color> palette,
  int size = 512,
}) async {
  final image = img.Image(width: size, height: size);

  final c1 = _rgba(palette[0]);
  final c2 = _rgba(palette[1]);
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      final t = ((x + y) / (size * 2)).clamp(0.0, 1.0);
      image.setPixelRgba(
        x, y,
        _lerp(c1[0], c2[0], t),
        _lerp(c1[1], c2[1], t),
        _lerp(c1[2], c2[2], t),
        255,
      );
    }
  }

  // White plate
  final cx = size ~/ 2;
  final cy = size ~/ 2;
  final plateR = (size * 0.38).round();
  _fillCircle(image, cx, cy, plateR + 12, 255, 255, 255, 60);
  _fillCircle(image, cx, cy, plateR, 255, 255, 255, 255);

  // Three food blobs on plate
  final blobs = [
    [_rgba(palette[2]), -plateR ~/ 3, -plateR ~/ 8, (plateR * 0.38).round(), (plateR * 0.28).round()],
    [_rgba(palette[3]), plateR ~/ 3, -plateR ~/ 6, (plateR * 0.32).round(), (plateR * 0.24).round()],
    [_rgba(palette[4]), 0, plateR ~/ 3, (plateR * 0.44).round(), (plateR * 0.22).round()],
  ];
  for (final b in blobs) {
    final color = b[0] as List<int>;
    final ox = b[1] as int;
    final oy = b[2] as int;
    final rx = b[3] as int;
    final ry = b[4] as int;
    _fillEllipse(image, cx + ox, cy + oy, rx, ry,
        color[0], color[1], color[2], 240);
  }

  final bytes = Uint8List.fromList(img.encodePng(image));
  final outPath = p.join(_ensureDemoDir().path, filename);
  File(outPath).writeAsBytesSync(bytes);
  return outPath;
}

List<int> _rgba(Color c) => [
      (c.r * 255).round(),
      (c.g * 255).round(),
      (c.b * 255).round(),
      (c.a * 255).round(),
    ];

int _lerp(int a, int b, double t) => (a + (b - a) * t).round();

void _fillCircle(img.Image image, int cx, int cy, int radius,
    int r, int g, int b, int a) {
  _fillEllipse(image, cx, cy, radius, radius, r, g, b, a);
}

void _fillEllipse(img.Image image, int cx, int cy, int rx, int ry,
    int r, int g, int b, int a) {
  for (int y = -ry; y <= ry; y++) {
    for (int x = -rx; x <= rx; x++) {
      final dx = x / rx;
      final dy = y / ry;
      if (dx * dx + dy * dy <= 1.0) {
        final px = cx + x;
        final py = cy + y;
        if (px < 0 || py < 0 || px >= image.width || py >= image.height) continue;
        final existing = image.getPixel(px, py);
        final aF = a / 255.0;
        image.setPixelRgba(
          px, py,
          (existing.r * (1 - aF) + r * aF).round(),
          (existing.g * (1 - aF) + g * aF).round(),
          (existing.b * (1 - aF) + b * aF).round(),
          255,
        );
      }
    }
  }
  // Silence unused in case math was imported for other utilities
  math.pi;
}
