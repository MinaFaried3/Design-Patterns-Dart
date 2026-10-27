// AFTER: Expression nodes evaluate their children through one contract.

// 1. COMPONENT
abstract class Expression {
  double evaluate();
  String describe();
}

// 2. LEAF
class Number implements Expression {
  final double value;
  Number(this.value);
  @override
  double evaluate() => value;
  @override
  String describe() => value.toString();
}

// 3. COMPOSITES
class Sum implements Expression {
  final List<Expression> children;
  Sum(List<Expression> children) : children = List.unmodifiable(children);

  @override
  double evaluate() => children.fold(0, (sum, child) => sum + child.evaluate());
  @override
  String describe() => '(${children.map((e) => e.describe()).join(' + ')})';
}

class Product implements Expression {
  final List<Expression> children;
  Product(List<Expression> children) : children = List.unmodifiable(children);

  @override
  double evaluate() =>
      children.fold(1, (product, child) => product * child.evaluate());
  @override
  String describe() => '(${children.map((e) => e.describe()).join(' * ')})';
}

// 4. USAGE
void main() {
  final Expression expression = Product([
    Sum([Number(3), Number(2)]),
    Number(4),
  ]);
  assert(expression.evaluate() == 20);
  print(expression.describe());
  print(expression.evaluate());
}
