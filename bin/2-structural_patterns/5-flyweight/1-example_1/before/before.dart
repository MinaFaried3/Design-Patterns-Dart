// BEFORE: Every tree duplicates the same species metadata.
class Tree {
  final int x;
  final int y;
  final String species;
  final String color;
  Tree(this.x, this.y, this.species, this.color);
}

void main() {
  final forest = [
    Tree(1, 2, 'Oak', 'Green'),
    Tree(3, 4, 'Oak', 'Green'),
    Tree(5, 6, 'Pine', 'Dark green'),
  ];
  print('Trees: ${forest.length}');
  print('Metadata groups allocated: ${forest.length}');
}
