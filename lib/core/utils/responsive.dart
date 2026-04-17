import 'package:flutter/widgets.dart';

extension ResponsiveContext on BuildContext {
  double s(double value) {
    final shortest = MediaQuery.sizeOf(this).shortestSide;
    final factor = shortest >= 600 ? 1.4 : 1.0;
    return value * factor;
  }

  double get screenW => MediaQuery.sizeOf(this).width;
  double get screenH => MediaQuery.sizeOf(this).height;
}

class ResponsiveContentBox extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const ResponsiveContentBox({
    super.key,
    required this.child,
    this.maxWidth = 540,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
