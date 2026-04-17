@Tags(['assets'])
library;

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;

void main() {
  setUpAll(() async {
    GoogleFonts.config.allowRuntimeFetching = false;
    Future<void> loadFamily(String family, String ttfPath) async {
      final bytes = File(ttfPath).readAsBytesSync();
      final loader = FontLoader(family)
        ..addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
    }
    final base = Directory.current.path;
    await loadFamily('Inter', '$base/assets/fonts/Inter-Regular.ttf');
    await loadFamily('SpaceGrotesk', '$base/assets/fonts/SpaceGrotesk-Regular.ttf');
  });

  testWidgets('icon 1024', (tester) async {
    await _writeIcon(tester, size: 1024,
        outPath: _resolve('assets/icon/icon_source.png'));
  });

  testWidgets('icon 512', (tester) async {
    await _writeIcon(tester, size: 512,
        outPath: _resolve('store_assets/play/icon_512.png'));
  });

  testWidgets('feature 1024x500', (tester) async {
    await _writeFeature(tester,
        outPath: _resolve('store_assets/play/feature.png'));
  });
}

String _resolve(String rel) {
  final out = p.join(Directory.current.path, rel);
  Directory(p.dirname(out)).createSync(recursive: true);
  return out;
}

Future<void> _writeIcon(
  WidgetTester tester, {
  required double size,
  required String outPath,
}) async {
  final key = GlobalKey();
  await tester.binding.setSurfaceSize(Size(size, size));
  tester.view.physicalSize = Size(size, size);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RepaintBoundary(
        key: key,
        child: _SnapIcon(size: size),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  final bytes = await _capture(tester, key, 1.0);
  File(outPath).writeAsBytesSync(bytes);
}

Future<void> _writeFeature(
  WidgetTester tester, {
  required String outPath,
}) async {
  const w = 1024.0, h = 500.0;
  final key = GlobalKey();
  await tester.binding.setSurfaceSize(const Size(w, h));
  tester.view.physicalSize = const Size(w, h);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RepaintBoundary(
        key: key,
        child: const _SnapFeature(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  final bytes = await _capture(tester, key, 1.0);
  File(outPath).writeAsBytesSync(bytes);
}

Future<Uint8List> _capture(
  WidgetTester tester,
  GlobalKey key,
  double pixelRatio,
) async {
  late Uint8List bytes;
  await tester.runAsync(() async {
    final ro = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await ro.toImage(pixelRatio: pixelRatio);
    final bd = await image.toByteData(format: ui.ImageByteFormat.png);
    bytes = Uint8List.fromList(bd!.buffer.asUint8List());
    image.dispose();
  });
  return bytes;
}

class _SnapIcon extends StatelessWidget {
  final double size;
  const _SnapIcon({required this.size});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00D980), Color(0xFF5C9BFF)],
        ),
      ),
      child: CustomPaint(painter: _SnapPainter(), size: Size(size, size)),
    );
  }
}

class _SnapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final cx = w / 2;
    final cy = s.height / 2;

    // Soft highlight
    canvas.drawCircle(
      Offset(w * 0.3, s.height * 0.25),
      w * 0.55,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withValues(alpha: 0.3), Colors.transparent],
        ).createShader(Rect.fromCircle(
            center: Offset(w * 0.3, s.height * 0.25), radius: w * 0.55)),
    );

    // White plate (big circle)
    final plateR = w * 0.34;
    canvas.drawCircle(Offset(cx, cy + w * 0.02), plateR + w * 0.02,
        Paint()..color = Colors.white.withValues(alpha: 0.25));
    canvas.drawCircle(Offset(cx, cy + w * 0.02), plateR,
        Paint()..color = Colors.white);

    // Food blobs (three colored ovals)
    final blobs = <List<Object>>[
      [const Color(0xFFFF5C8A), -plateR * 0.40, -plateR * 0.15, plateR * 0.5, plateR * 0.30],
      [const Color(0xFFFFC85C), plateR * 0.30, -plateR * 0.20, plateR * 0.40, plateR * 0.24],
      [const Color(0xFF8B5CFF), 0.0, plateR * 0.35, plateR * 0.55, plateR * 0.22],
    ];
    for (final b in blobs) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + (b[1] as double), cy + w * 0.02 + (b[2] as double)),
          width: (b[3] as double) * 2,
          height: (b[4] as double) * 2,
        ),
        Paint()..color = b[0] as Color,
      );
    }

    // Camera shutter accent (top-right)
    final camP = Paint()..color = Colors.black.withValues(alpha: 0.9);
    final camCx = w * 0.80;
    final camCy = s.height * 0.18;
    canvas.drawCircle(Offset(camCx, camCy), w * 0.07, camP);
    canvas.drawCircle(Offset(camCx, camCy), w * 0.04, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(camCx, camCy), w * 0.02, camP);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SnapFeature extends StatelessWidget {
  const _SnapFeature();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F1114), Color(0xFF0D2820), Color(0xFF0F3746)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 70,
            top: 170,
            width: 160, height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: const _SnapIcon(size: 160),
            ),
          ),
          Positioned(
            left: 270,
            right: 40,
            top: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SnapMacros',
                  style: TextStyle(
                    fontSize: 74,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Snap food · see macros in seconds',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFB0F0DA),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      Color(0xFFFFC75F),
                      Color(0xFFFF8A3D),
                    ]),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'HONEST · EDITABLE · FAST',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
