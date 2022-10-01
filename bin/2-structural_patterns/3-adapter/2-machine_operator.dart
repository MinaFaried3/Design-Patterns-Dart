class MachineOperator {
  String? _name;
  String? _shiftCode;
  double? _basicSalary;

  String get name => _name!;

  String get shiftCode => _shiftCode!;

  double get basicSalary => _basicSalary!;

  set name(String value) {
    _name = value;
  }

  set basicSalary(double value) {
    _basicSalary = value;
  }

  set shiftCode(String value) {
    _shiftCode = value;
  }
}
