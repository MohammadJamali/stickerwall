import 'dart:typed_data';
import 'dart:ui' show Image, Path, Size;

class MaskedImageData {
  final Path mask;
  final Size imageSize;
  final Image image;
  final ByteData byteData;

  const MaskedImageData({
    required this.mask,
    required this.imageSize,
    required this.image,
    required this.byteData,
  });
}
