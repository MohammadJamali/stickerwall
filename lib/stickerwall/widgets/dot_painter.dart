import 'dart:math' show Random;

import 'package:flutter/material.dart'
    show Canvas, Colors, CustomPainter, Offset, Paint, PaintingStyle, Path, Size;

class DotPainter extends CustomPainter {
  final int randomSeed;
  final int dotCount;
  final double minRadius;
  final double maxRadius;
  final Path? mask;

  final Random _random;
  final Paint _paint;

  DotPainter({
    this.randomSeed = 42,
    this.dotCount = 100,
    this.minRadius = 1,
    this.maxRadius = 3,
    this.mask,
  })  : _random = Random(randomSeed),
        _paint = Paint()..style = PaintingStyle.fill;

  Offset _randomCenter(Size size) {
    return Offset(
      _random.nextDouble() * size.width,
      _random.nextDouble() * size.height,
    );
  }

  double _randomRadius() {
    return _random.nextDouble() * maxRadius + minRadius;
  }

  Paint _randomOpacityPaint() {
    return _paint
      ..color = Colors.white.withOpacity(
        _random.nextDouble(),
      );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < dotCount; i++) {
      canvas.drawCircle(
        _randomCenter(size),
        _randomRadius(),
        _randomOpacityPaint(),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
