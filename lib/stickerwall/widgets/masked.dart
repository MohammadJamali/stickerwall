import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stickerwall/stickerwall/stickerwall.dart';

class MaskedImagePainter extends CustomPainter {
  final MaskedImageData maskedData;
  final Path precomputedDotLayer;
  final double animationValue;

  MaskedImagePainter({
    required this.maskedData,
    required this.precomputedDotLayer,
    required this.animationValue,
  });

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
    final rainbowGradient = LinearGradient(
      colors: [
        Colors.red.withOpacity(0),
        Colors.red.withOpacity(opacity),
        Colors.yellow.withOpacity(opacity),
        Colors.white.withOpacity(opacity),
        // Colors.blue.withOpacity(opacity),
        Colors.purple.withOpacity(opacity),
        Colors.purple.withOpacity(0),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(
      Rect.fromLTWH(
        -maskedData.imageSize.height * 0.2,
        animationValue,
        maskedData.imageSize.width,
        maskedData.imageSize.height * 1.2,
      ),
    );

    // Draw combined overlay with gradients
    canvas.save();
    canvas.transform(transformMatrix.storage);
    canvas.clipPath(maskedData.mask);

    // Apply rainbow gradient
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        maskedData.imageSize.width,
        maskedData.imageSize.height,
      ),
      Paint()..shader = rainbowGradient,
    );

    // Apply fade-out gradient overlay
    final fadeGradient = LinearGradient(
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.8),
        Colors.white.withOpacity(0.0),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(
      Rect.fromLTWH(
        0,
        animationValue,
        maskedData.imageSize.width,
        maskedData.imageSize.height,
      ),
    );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        maskedData.imageSize.width,
        maskedData.imageSize.height,
      ),
      Paint()
        ..shader = fadeGradient
        ..blendMode = BlendMode.dst,
    );

    // Draw precomputed dot layer with fade-out effect
    canvas.drawPath(
      precomputedDotLayer,
      Paint()
        ..shader = fadeGradient
        ..blendMode = BlendMode.overlay
        ..style = PaintingStyle.fill,
    );

    canvas.restore();

    // Draw mask overlay
    canvas.save();
    canvas.transform(transformMatrix.storage);
    canvas.drawPath(
      maskedData.mask,
      Paint()
        ..shader = fadeGradient
        ..color = Colors.white.withOpacity(0.1)
        ..blendMode = BlendMode.overlay
        ..style = PaintingStyle.fill,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

Path computeDotLayer({
  required MaskedImageData maskedData,
  required int dotCount,
  required double minRadius,
  required double maxRadius,
  required int randomSeed,
}) {
  final Random random = Random(randomSeed);
  Path dotPath = Path();

  final imageSize = maskedData.imageSize;

  for (int i = 0; i < dotCount; i++) {
    final Offset randomCenter = Offset(
      random.nextDouble() * imageSize.width,
      random.nextDouble() * imageSize.height,
    );

    dotPath.addOval(
      Rect.fromCircle(
        center: randomCenter,
        radius: random.nextDouble() * maxRadius + minRadius,
      ),
    );
  }

  return dotPath;
}
