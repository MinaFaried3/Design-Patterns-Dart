// BEFORE: A shallow copy shares nested mutable state.

// 1. MODELS
class Address {
  String city;
  Address(this.city);
}

class Employee {
  final String name;
  final Address address;
  final List<String> skills;
  Employee(this.name, this.address, this.skills);
}

// 2. USAGE
void main() {
  final template = Employee('Template', Address('Cairo'), ['Dart']);
  final employee = Employee('Mona', template.address, template.skills);
  employee.address.city = 'Alexandria';
  employee.skills.add('SQL');

  print('Template city: ${template.address.city}');
  print('Template skills: ${template.skills}'); // Unexpectedly changed.
}
