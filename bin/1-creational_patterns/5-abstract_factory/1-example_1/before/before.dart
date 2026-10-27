// BEFORE: Clients independently choose products and can mix families.

// 1. PRODUCTS
class Button {
  final String theme;
  Button(this.theme);
  String render() => '$theme button';
}

class Checkbox {
  final String theme;
  Checkbox(this.theme);
  String render() => '$theme checkbox';
}

// 2. USAGE: A screen accidentally mixes themes.
void main() {
  final button = Button('Light');
  final checkbox = Checkbox('Dark');
  print(button.render());
  print(checkbox.render());
  print('Matching theme: ${button.theme == checkbox.theme}');
}
