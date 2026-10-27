// AFTER: Compose optional responsibilities around one component.

// 1. COMPONENT AND CONCRETE COMPONENT
abstract class Drink {
  String get description;
  int get cost;
}

class Coffee implements Drink {
  @override
  String get description => 'Coffee';
  @override
  int get cost => 20;
}

// 2. DECORATOR: Has the same contract and wraps another Drink.
abstract class DrinkDecorator implements Drink {
  final Drink inner;
  DrinkDecorator(this.inner);
}

class Milk extends DrinkDecorator {
  Milk(super.inner);
  @override
  String get description => '${inner.description} + milk';
  @override
  int get cost => inner.cost + 5;
}

class Sugar extends DrinkDecorator {
  Sugar(super.inner);
  @override
  String get description => '${inner.description} + sugar';
  @override
  int get cost => inner.cost + 2;
}

// 3. USAGE
void main() {
  final Drink drink = Sugar(Milk(Coffee()));
  final Drink doubleMilk = Milk(Milk(Coffee()));
  assert(drink.cost == 27 && doubleMilk.cost == 30);
  print('${drink.description}: ${drink.cost}');
  print('${doubleMilk.description}: ${doubleMilk.cost}');
}
