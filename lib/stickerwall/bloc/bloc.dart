import 'package:stickerwall/stickerwall/algorithms/moore_neighbor_tracing.dart';
import 'package:stickerwall/stickerwall/stickerwall.dart';

import 'package:flutter/material.dart'
    show BuildContext, Colors, DefaultAssetBundle;
import 'package:flutter_bloc/flutter_bloc.dart' show Bloc, Emitter;
import 'dart:ui';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  ImageBloc(this.context) : super(ImageInitial()) {
    on<LoadImage>(_onLoadImage);
  }

  final BuildContext context;

  Future<void> _onLoadImage(
    LoadImage event,
    Emitter<ImageState> emit,
  ) async {
    emit(ImageLoading());
    try {
      final data = await _processImage(event.assetPath);
      emit(ImageLoaded(data));
    } catch (e) {
      emit(ImageError(e.toString()));
    }
  }

  Future<MaskedImageData> _processImage(String asset) async {
    // Load the image asset
    final data = await DefaultAssetBundle.of(context).load(asset);
    final bytes = data.buffer.asUint8List();
    final codec = await instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    // Convert the image to raw RGBA byte data
    final byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
    if (byteData == null) {
      throw Exception("Failed to decode image bytes.");
    }

    final width = image.width;
    final height = image.height;
    final pixels = byteData.buffer.asUint8List();
    final originalMask = mooreNeighborTracingAlgorithm(pixels, width, height);

    // Step 1: Add a border to the image
    final borderWidth = 20; // Define the border width
    final borderedImage =
        await _addBorderToImage(image, originalMask, borderWidth);

    // Step 2: Save the new image and byte data
    final byteDataWithBorder =
        await borderedImage.toByteData(format: ImageByteFormat.rawRgba);
    if (byteDataWithBorder == null) {
      throw Exception("Failed to encode image bytes with border.");
    }

    // Step 3: Run the Moore Neighbor Tracing Algorithm on the bordered image
    final borderedPixels = byteDataWithBorder.buffer.asUint8List();
    final mask = mooreNeighborTracingAlgorithm(
        borderedPixels, borderedImage.width, borderedImage.height);

    // Return the MaskedImageData with the new bordered image
    return MaskedImageData(
      image: borderedImage,
      byteData: byteDataWithBorder,
      mask: mask,
      imageSize:
          Size(borderedImage.width.toDouble(), borderedImage.height.toDouble()),
    );
  }

  /// Function to add a border around the image
  Future<Image> _addBorderToImage(
      Image originalImage, Path mask, int borderWidth) async {
    final width = originalImage.width + 2 * borderWidth;
    final height = originalImage.height + 2 * borderWidth;

    // Create a new canvas to draw the bordered image
    final recorder = PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromPoints(
        Offset(0, 0),
        Offset(
          width.toDouble(),
          height.toDouble(),
        ),
      ),
    );

    // Draw a white border around the image (you can change the color or style of the border)
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 80;
    canvas.drawPath(mask, borderPaint);

    // Draw the original image on top of the border
    final imagePaint = Paint();
    canvas.drawImage(
      originalImage,
      Offset(
        borderWidth.toDouble() - borderWidth,
        borderWidth.toDouble() - borderWidth,
      ),
      imagePaint,
    );

    // End the recording and convert it to an Image
    final picture = recorder.endRecording();
    final borderedImage = await picture.toImage(width, height);

    return borderedImage;
  }
}
