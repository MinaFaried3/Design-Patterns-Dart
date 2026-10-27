// BEFORE: Payroll knows incompatible employee APIs.
class Employee {
  final String name;
  final int monthlyCents;
  Employee(this.name, this.monthlyCents);
}

class LegacyOperator {
  final String fullName;
  final int dailyCents;
  final int workedDays;
  LegacyOperator(this.fullName, this.dailyCents, this.workedDays);
}

int calculatePayroll(List<Object> workers) {
  var total = 0;
  for (final worker in workers) {
    if (worker is Employee) {
      total += worker.monthlyCents;
    } else if (worker is LegacyOperator) {
      total += worker.dailyCents * worker.workedDays;
    } else {
      throw ArgumentError('Unknown worker');
    }
  }
  return total;
}

void main() {
  print(
    'Payroll cents: ${calculatePayroll([Employee('Mona', 100000), LegacyOperator('Omar', 5000, 20)])}',
  );
}
