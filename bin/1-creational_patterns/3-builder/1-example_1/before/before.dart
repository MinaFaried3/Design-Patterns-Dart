// BEFORE: Callers assemble a mutable product and can use it unfinished.

// 1. PRODUCT
class Sandwich {
  String? bread;
  final List<String> fillings = [];
}

// 2. USAGE
void main() {
  final lunch = Sandwich();
  lunch.bread = 'Whole wheat';
  lunch.fillings.add('Cheese');
  lunch.fillings.add('Tomato');
  print('${lunch.bread}: ${lunch.fillings}');
  print('An unfinished sandwich is possible: ${Sandwich().bread}');
}
