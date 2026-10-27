// AFTER: An object adapter makes the legacy type fit the payroll contract.

// 1. TARGET AND NATIVE IMPLEMENTATION
abstract class Payable {
  String get name;
  int get monthlyCents;
}

class Employee implements Payable {
  @override
  final String name;
  @override
  final int monthlyCents;
  Employee(this.name, this.monthlyCents);
}

// 2. ADAPTEE
class LegacyOperator {
  final String fullName;
  final int dailyCents;
  final int workedDays;
  LegacyOperator(this.fullName, this.dailyCents, this.workedDays);
}

// 3. ADAPTER: Converts names and daily pay into the target's semantics.
class OperatorPayrollAdapter implements Payable {
  final LegacyOperator operator;
  OperatorPayrollAdapter(this.operator);

  @override
  String get name => operator.fullName;
  @override
  int get monthlyCents => operator.dailyCents * operator.workedDays;
}

// 4. CLIENT: No type checks.
int calculatePayroll(Iterable<Payable> workers) =>
    workers.fold(0, (total, worker) => total + worker.monthlyCents);

void main() {
  final workers = <Payable>[
    Employee('Mona', 100000),
    OperatorPayrollAdapter(LegacyOperator('Omar', 5000, 20)),
  ];
  final total = calculatePayroll(workers);
  assert(total == 200000);
  print('Payroll cents: $total');
}
