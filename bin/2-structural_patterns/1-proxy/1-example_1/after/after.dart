// AFTER: A virtual proxy delays creating the expensive subject.

// 1. SUBJECT CONTRACT
abstract class ImageDisplay {
  String display();
}

// 2. REAL SUBJECT
class RealImage implements ImageDisplay {
  static int loads = 0;
  final String path;
  RealImage(this.path) {
    loads++; // Simulated expensive load.
  }

  @override
  String display() => 'Displaying $path';
}

// 3. PROXY: Same interface as the real subject.
class LazyImage implements ImageDisplay {
  final String path;
  RealImage? _image;
  LazyImage(this.path);

  @override
  String display() {
    _image ??= RealImage(path);
    return _image!.display();
  }
}

// 4. USAGE
void main() {
  final gallery = <ImageDisplay>[LazyImage('cover.png'), LazyImage('unused.png')];
  assert(RealImage.loads == 0);
  print(gallery.first.display());
  print(gallery.first.display());
  assert(RealImage.loads == 1);
  print('Loaded images: ${RealImage.loads}');
}
