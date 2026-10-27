// AFTER: Share intrinsic metadata; keep each tree's position separate.

// 1. FLYWEIGHT: Immutable intrinsic state.
class TreeType {
  final String species;
  final String color;
  TreeType(this.species, this.color);
}

// 2. FACTORY: Reuses a flyweight with exactly the same intrinsic state.
class TreeTypeFactory {
  final Map<(String, String), TreeType> _types = {};

  TreeType get(String species, String color) =>
      _types.putIfAbsent((species, color), () => TreeType(species, color));

  int get count => _types.length;
}

// 3. CONTEXT: Extrinsic state varies per occurrence.
class Tree {
  final int x;
  final int y;
  final TreeType type;
  Tree(this.x, this.y, this.type);
}

// 4. USAGE
void main() {
  final types = TreeTypeFactory();
  final forest = [
    Tree(1, 2, types.get('Oak', 'Green')),
    Tree(3, 4, types.get('Oak', 'Green')),
    Tree(5, 6, types.get('Pine', 'Dark green')),
  ];
  assert(identical(forest[0].type, forest[1].type));
  assert(!identical(forest[0], forest[1]));
  assert(types.count == 2);
  print('Trees: ${forest.length}');
  print('Metadata groups allocated: ${types.count}');
}
