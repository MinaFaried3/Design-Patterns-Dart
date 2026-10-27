// AFTER: Shape geometry and rendering backend form two independent axes.

// 1. IMPLEMENTOR
abstract class Renderer {
  String circle(double radius);
  String rectangle(double width, double height);
}

class VectorRenderer implements Renderer {
  @override
  String circle(double radius) => 'Vector circle radius=$radius';
  @override
  String rectangle(double width, double height) =>
      'Vector rectangle ${width}x$height';
}

class RasterRenderer implements Renderer {
  @override
  String circle(double radius) => 'Raster circle radius=$radius';
  @override
  String rectangle(double width, double height) =>
      'Raster rectangle ${width}x$height';
}

// 2. ABSTRACTION AND REFINEMENTS
abstract class Shape {
  final Renderer renderer;
  Shape(this.renderer);
  String draw();
}

class Circle extends Shape {
  final double radius;
  Circle(super.renderer, this.radius);
  @override
  String draw() => renderer.circle(radius);
}

class Rectangle extends Shape {
  final double width;
  final double height;
  Rectangle(super.renderer, this.width, this.height);
  @override
  String draw() => renderer.rectangle(width, height);
}

// 3. USAGE: Every shape works with either renderer.
void main() {
  for (final renderer in <Renderer>[VectorRenderer(), RasterRenderer()]) {
    final shapes = <Shape>[Circle(renderer, 5), Rectangle(renderer, 3, 4)];
    for (final shape in shapes) {
      print(shape.draw());
    }
  }
  assert(Circle(RasterRenderer(), 5).draw() == 'Raster circle radius=5.0');
}
