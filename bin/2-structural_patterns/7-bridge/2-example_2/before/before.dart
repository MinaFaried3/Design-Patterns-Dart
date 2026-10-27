// BEFORE: Every shape is coupled to a renderer-specific subclass.
class VectorCircle {
  String draw() => 'Vector circle radius=5';
}

class RasterCircle {
  String draw() => 'Raster circle radius=5';
}

class VectorRectangle {
  String draw() => 'Vector rectangle 3x4';
}

class RasterRectangle {
  String draw() => 'Raster rectangle 3x4';
}

void main() {
  print(VectorCircle().draw());
  print(RasterCircle().draw());
  print(VectorRectangle().draw());
  print(RasterRectangle().draw());
}
