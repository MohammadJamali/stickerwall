
import 'package:stickerwall/stickerwall/stickerwall.dart';

abstract class ImageState {}

class ImageInitial extends ImageState {}

class ImageLoading extends ImageState {}

class ImageLoaded extends ImageState {
  final MaskedImageData data;
  ImageLoaded(this.data);
}

class ImageError extends ImageState {
  final String message;
  ImageError(this.message);
}