import 'address.dart';

abstract class EmployeePrototype {
  int? id;
  String? name;
  Address? empAddress;

  EmployeePrototype shallowCopy();
  EmployeePrototype deepCopy();

  @override
  String toString() {
    return 'EmployeePrototype {\nid: $id,\nname: $name,\nempAddress: ${empAddress.toString()}\n}';
  }
}
