// AFTER: A builder accumulates steps and publishes a validated snapshot.

// 1. IMMUTABLE PRODUCT
class Sandwich {
  final String bread;
  final List<String> fillings;

  Sandwich._(this.bread, List<String> fillings)
      : fillings = List.unmodifiable(fillings);
}

// 2. BUILDER
class SandwichBuilder {
  String _bread = 'White';
  final List<String> _fillings = [];

  SandwichBuilder bread(String value) {
    _bread = value;
    return this;
  }

  SandwichBuilder add(String filling) {
    _fillings.add(filling);
    return this;
  }

  Sandwich build() {
    if (_bread.isEmpty || _fillings.isEmpty) {
      throw StateError('Bread and at least one filling are required');
    }
    return Sandwich._(_bread, _fillings);
  }
}

// 3. USAGE
void main() {
  final builder = SandwichBuilder()
    ..bread('Whole wheat')
    ..add('Cheese')
    ..add('Tomato');
  final lunch = builder.build();
  builder.add('Olives');

  assert(lunch.fillings.length == 2);
  print('${lunch.bread}: ${lunch.fillings}');
}
