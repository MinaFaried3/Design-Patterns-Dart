// AFTER: The prototype defines which mutable objects must be copied.

// 1. NESTED PROTOTYPE
class Address {
  String city;
  Address(this.city);
  Address clone() => Address(city);
}

// 2. PROTOTYPE
class Employee {
  String name;
  final Address address;
  final List<String> skills;
  Employee(this.name, this.address, this.skills);

  Employee clone() => Employee(name, address.clone(), List.of(skills));
}

// 3. USAGE
void main() {
  final template = Employee('Template', Address('Cairo'), ['Dart']);
  final employee = template.clone()
    ..name = 'Mona'
    ..address.city = 'Alexandria'
    ..skills.add('SQL');

  assert(template.address.city == 'Cairo');
  assert(template.skills.length == 1);
  assert(!identical(template.address, employee.address));
  print('Template: ${template.address.city}, ${template.skills}');
  print('Employee: ${employee.address.city}, ${employee.skills}');
}
