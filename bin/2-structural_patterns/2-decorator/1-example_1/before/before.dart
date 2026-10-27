// BEFORE: Each combination needs another subclass.
class Coffee {
  String get description => 'Coffee';
  int get cost => 20;
}

class CoffeeWithMilk extends Coffee {
  @override
  String get description => 'Coffee + milk';
  @override
  int get cost => 25;
}

class CoffeeWithMilkAndSugar extends Coffee {
  @override
  String get description => 'Coffee + milk + sugar';
  @override
  int get cost => 27;
}

void main() {
  final coffee = CoffeeWithMilkAndSugar();
  print('${coffee.description}: ${coffee.cost}');
  // Sugar-only, double-milk, and other combinations need more subclasses.
}
