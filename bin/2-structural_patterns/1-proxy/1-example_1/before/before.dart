// BEFORE: Constructing the gallery eagerly loads every image.
class RealImage {
  static int loads = 0;
  final String path;
  RealImage(this.path) {
    loads++;
  }
  String display() => 'Displaying $path';
}

void main() {
  final gallery = [RealImage('cover.png'), RealImage('unused.png')];
  print(gallery.first.display());
  print('Loaded images: ${RealImage.loads}'); // 2, although only 1 was used.
}
