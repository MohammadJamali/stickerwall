import 'dart:ui' as ui;
import 'dart:typed_data' show Uint8List;

ui.Path mooreNeighborTracingAlgorithm(Uint8List pixels, int width, int height) {
  final path = ui.Path();

  List<int> directionsX = [0, 1, 1, 1, 0, -1, -1, -1];
  List<int> directionsY = [-1, -1, 0, 1, 1, 1, 0, -1];

  bool isTransparent(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) return true;
    int index = (y * width + x) * 4;
    return pixels[index + 3] == 0;
  }

  Set<String> visited = {};

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      if (!isTransparent(x, y) && !visited.contains("$x,$y")) {
        int startX = x, startY = y;
        int cx = x, cy = y;
        int previousDirection = 7;

        path.moveTo(cx.toDouble(), cy.toDouble());

        do {
          visited.add("$cx,$cy");
          bool foundNext = false;

          for (int i = 0; i < 8; i++) {
            int direction = (previousDirection + i) % 8;
            int nx = cx + directionsX[direction];
            int ny = cy + directionsY[direction];

            if (!isTransparent(nx, ny)) {
              cx = nx;
              cy = ny;
              path.lineTo(cx.toDouble(), cy.toDouble());
              previousDirection = (direction + 5) % 8;
              foundNext = true;
              break;
            }
          }

          if (!foundNext) break; // No next pixel found, stop tracing.
        } while (cx != startX || cy != startY);
        path.close();
        return path;
      }
    }
  }

  return path;
}
