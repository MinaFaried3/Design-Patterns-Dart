import '1-employee.dart';
import '2-machine_operator.dart';
import '3-salary_calculator.dart';

class SalaryAdapter extends SalaryCalculator {
  Employee? employee;

  double calcSalaryAdapter(MachineOperator operator) {
    employee ??= Employee();
    employee!.basicSalary = operator.basicSalary;
    return super.calcSalary(employee!);
  }
}
