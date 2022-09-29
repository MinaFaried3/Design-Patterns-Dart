class Employee {
  String? _name;
  double? _basicSalary;

  String get name => _name!;

  set name(String value) {
    _name = value;
  }

  double get basicSalary => _basicSalary!;

  set basicSalary(double value) {
    _basicSalary = value;
  }
}
