abstract class ImageEvent {}

class LoadImage extends ImageEvent {
  final String assetPath;
  LoadImage(this.assetPath);
}