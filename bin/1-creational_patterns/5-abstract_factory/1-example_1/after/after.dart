// AFTER: One factory supplies a family of related products.

// 1. PRODUCT CONTRACTS
abstract class Button {
  String render();
}

abstract class Checkbox {
  String render();
}

// 2. CONCRETE PRODUCT FAMILIES
class LightButton implements Button {
  @override
  String render() => 'Light button';
}

class LightCheckbox implements Checkbox {
  @override
  String render() => 'Light checkbox';
}

class DarkButton implements Button {
  @override
  String render() => 'Dark button';
}

class DarkCheckbox implements Checkbox {
  @override
  String render() => 'Dark checkbox';
}

// 3. ABSTRACT FACTORY AND CONCRETE FACTORIES
abstract class UiFactory {
  Button createButton();
  Checkbox createCheckbox();
}

class LightUiFactory implements UiFactory {
  @override
  Button createButton() => LightButton();

  @override
  Checkbox createCheckbox() => LightCheckbox();
}

class DarkUiFactory implements UiFactory {
  @override
  Button createButton() => DarkButton();

  @override
  Checkbox createCheckbox() => DarkCheckbox();
}

// 4. CLIENT: Receives one family choice.
List<String> renderSettings(UiFactory factory) => [
  factory.createButton().render(),
  factory.createCheckbox().render(),
];

void main() {
  final light = renderSettings(LightUiFactory());
  final dark = renderSettings(DarkUiFactory());
  assert(light.every((text) => text.startsWith('Light')));
  assert(dark.every((text) => text.startsWith('Dark')));
  print(light);
  print(dark);
}
