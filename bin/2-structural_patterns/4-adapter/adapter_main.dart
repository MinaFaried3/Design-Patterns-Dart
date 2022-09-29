import '1-employee.dart';
import '2-machine_operator.dart';
import '3-salary_calculator.dart';
import '4-salary_adapter.dart';

void main() {
  Employee employee = Employee();
  employee.name = "name";
  employee.basicSalary = 1000;

  SalaryCalculator calculator = SalaryCalculator();
  print(calculator.calcSalary(employee));

  MachineOperator operator = MachineOperator();
  operator.basicSalary = 2000;
  // print(calculator.calcSalary(operator)); //error

  SalaryAdapter adapter = SalaryAdapter();
  print(adapter.calcSalaryAdapter(operator));
}
