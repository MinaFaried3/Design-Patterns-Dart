import '1-prototype.dart';
import '2-temp_employee.dart';
import 'address.dart';

void main() {
  EmployeePrototype tempEmp1 = TempEmployee();
  tempEmp1.name = "temp1";
  tempEmp1.id = 1;
  tempEmp1.empAddress =
      Address(city: "city 1", building: "B1", street: "street 1 ");

  ///try deep and shallow here
  EmployeePrototype tempEmp2 = tempEmp1.deepCopy();

  print("emp1 hash code ${tempEmp1.hashCode}");
  print("emp2 hash code ${tempEmp2.hashCode}");

  print("================ Temp Emp 1 Original Values ==============");
  print(tempEmp1.toString());
  print("================ Temp Emp 2 Copy ==============");
  print(tempEmp2.toString());

  print("===============Change1+=================");
  tempEmp2.empAddress?.street = "new Street1";
  tempEmp2.id = 2;
  tempEmp2.name = "temp 2";
  print("================ Temp Emp 1 after change==============");
  print(tempEmp1.toString());
  print("================ Temp Emp 2  ==============");
  print(tempEmp2.toString());
  print("emp1 hash code ${tempEmp1.hashCode}");
  print("emp2 hash code ${tempEmp2.hashCode}");
}
