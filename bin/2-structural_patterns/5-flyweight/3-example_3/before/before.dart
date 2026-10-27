// BEFORE: Every tile duplicates a simulated 1024-byte texture.
class Tile {
  final int x;
  final int y;
  int durability = 100;
  final String terrain;
  final List<int> texture;
  Tile(this.x, this.y, this.terrain) : texture = List.filled(1024, 1);
}

void main() {
  final tiles = [
    for (var y = 0; y < 10; y++)
      for (var x = 0; x < 10; x++)
        Tile(x, y, (x + y).isEven ? 'grass' : 'stone'),
  ];
  tiles.first.durability -= 10;
  print('Tiles: ${tiles.length}; textures: ${tiles.length}');
  print('Texture payload bytes: ${tiles.length * 1024}');
}
