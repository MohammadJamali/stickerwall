import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stickerwall/stickerwall/stickerwall.dart';

class MaskedImagePainter extends CustomPainter {
  final MaskedImageData maskedData;
  final int randomSeed;
  final int dotCount;
  final double minRadius;
  final double maxRadius;

  final Random _random;
  final Paint _paint;

  double _randomRadius() {
    return _random.nextDouble() * maxRadius + minRadius;
  }

  Paint _randomOpacityPaint() {
    return _paint
      ..color = Colors.blue.shade50.withOpacity(
        _random.nextDouble(),
      );
  }

  Path scalePath(Path originalPath, double scaleX, double scaleY) {
    // Create a new path to hold the scaled path
    Path scaledPath = Path();

    // Apply scaling transformation to the original path
    final scaleMatrix = Matrix4.identity()
      ..scale(scaleX, scaleY); // Scaling by the desired factors

    // Transform the original path by the scale matrix
    scaledPath.addPath(originalPath, Offset.zero);
    scaledPath = scaledPath.transform(scaleMatrix.storage);

    return scaledPath;
  }

  MaskedImagePainter({
    required this.maskedData,
    this.randomSeed = 42,
    this.dotCount = 100,
    this.minRadius = 1,
    this.maxRadius = 3,
  })  : _random = Random(randomSeed),
        _paint = Paint()..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / maskedData.imageSize.width;

    final transformMatrix = Matrix4.identity()
      ..scale(scale, scale)
      ..translate(
        (size.width - maskedData.imageSize.width * scale) / 2,
        (size.height - maskedData.imageSize.height * scale) / 2,
      );

    canvas.save();
    canvas.transform(transformMatrix.storage);

    canvas.clipPath(maskedData.mask);
    canvas.drawImageRect(
      maskedData.image,
      Rect.fromLTWH(
        0,
        0,
        maskedData.image.width.toDouble(),
        maskedData.image.height.toDouble(),
      ),
      Rect.fromLTWH(
        0,
        0,
        maskedData.imageSize.width,
        maskedData.imageSize.height,
      ),
      Paint(),
    );
    canvas.restore();

    final opacity = 0.5;
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.red.withOpacity(opacity),
          Colors.yellow.withOpacity(opacity),
          Colors.white.withOpacity(opacity),
          Colors.blue.withOpacity(opacity),
          Colors.purple.withOpacity(opacity),
          Colors.purple.withOpacity(opacity),
          Colors.transparent
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          maskedData.imageSize.width,
          maskedData.imageSize.height*1.25,
        ),
      );
    canvas.save();

    canvas.transform(transformMatrix.storage);
    canvas.clipPath(maskedData.mask);
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        maskedData.imageSize.width,
        maskedData.imageSize.height,
      ),
      gradientPaint,
    );

    for (int i = 0; i < dotCount; i++) {
      final randomCenter = Offset(
        _random.nextDouble() * maskedData.imageSize.width,
        _random.nextDouble() * maskedData.imageSize.height,
      );

      canvas.drawCircle(
        randomCenter,
        _randomRadius(),
        _randomOpacityPaint(),
      );
    }

    canvas.restore();

    canvas.save();
    canvas.transform(transformMatrix.storage);
    canvas.drawPath(
        maskedData.mask,
        Paint()
          ..color = Colors.white.withOpacity(0.45)
          ..style = PaintingStyle.fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
