import '1-prototype.dart';
import 'address.dart';

class TempEmployee extends EmployeePrototype {
  @override
  EmployeePrototype shallowCopy() {
    return this;
  }

  @override
  EmployeePrototype deepCopy() {
    TempEmployee emp = TempEmployee();
    //this address is reference type
    emp.empAddress = Address(
      building: empAddress?.building,
      street: empAddress?.street,
      city: empAddress?.city,
    );
    emp.name = name;
    emp.id = id;
    return emp;
  }
}
