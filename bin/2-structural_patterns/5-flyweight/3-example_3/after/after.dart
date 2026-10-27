// AFTER: Many mutable contexts share a small immutable texture pool.

// 1. FLYWEIGHT: Texture payload and season are intrinsic.
class TerrainTexture {
  final String terrain;
  final String season;
  final List<int> pixels;

  TerrainTexture(this.terrain, this.season)
    : pixels = List.unmodifiable(List<int>.filled(1024, 1));

  String drawAt(int x, int y, int durability) =>
      '$season $terrain at ($x, $y), durability=$durability';
}

// 2. FACTORY: The pool belongs to a map/session, not global state.
class TexturePool {
  final Map<(String, String), TerrainTexture> _textures = {};

  TerrainTexture get(String terrain, String season) {
    return _textures.putIfAbsent((
      terrain,
      season,
    ), () => TerrainTexture(terrain, season));
  }

  int get count => _textures.length;
  int get payloadBytes => _textures.values.fold(
    0,
    (total, texture) => total + texture.pixels.length,
  );
}

// 3. CONTEXT: Position and damage are extrinsic, never in the shared object.
class Tile {
  final int x;
  final int y;
  final TerrainTexture texture;
  int durability = 100;

  Tile(this.x, this.y, this.texture);

  void damage(int amount) {
    if (amount < 0) throw ArgumentError.value(amount, 'amount');
    durability = (durability - amount).clamp(0, 100);
  }

  String draw() => texture.drawAt(x, y, durability);
}

// 4. USAGE
void main() {
  final pool = TexturePool();
  final tiles = [
    for (var y = 0; y < 10; y++)
      for (var x = 0; x < 10; x++)
        Tile(x, y, pool.get((x + y).isEven ? 'grass' : 'stone', 'summer')),
  ];
  tiles.first.damage(10);
  assert(identical(tiles[0].texture, tiles[2].texture));
  assert(tiles[0].durability == 90 && tiles[2].durability == 100);
  assert(pool.count == 2 && pool.payloadBytes == 2048);

  print('Tiles: ${tiles.length}; textures: ${pool.count}');
  print('Texture payload bytes: ${pool.payloadBytes}');
  print(tiles[0].draw());
  print(tiles[2].draw());
}
