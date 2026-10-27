class Account {
  final String code;
  final String name;
  final bool isActive;
  final double balance;
  final List<Account> children;

  const Account({
    required this.code,
    required this.name,
    this.isActive = true,
    this.balance = 0,
    this.children = const [],
  });
}

class AccountReportService {
  // 1. Display active leaf accounts
  void printAccounts(List<Account> roots) {
    void visit(Account account) {
      if (account.children.isEmpty && account.isActive) {
        print('${account.code}: ${account.name}');
      }

      for (final child in account.children) {
        visit(child);
      }
    }

    for (final root in roots) {
      visit(root);
    }
  }

  // 2. Calculate total balance
  double calculateBalance(List<Account> roots) {
    double total = 0;

    void visit(Account account) {
      if (account.children.isEmpty && account.isActive) {
        total += account.balance;
      }

      for (final child in account.children) {
        visit(child);
      }
    }

    for (final root in roots) {
      visit(root);
    }

    return total;
  }
}

void main() {
  final accounts = [
    const Account(
      code: '1000',
      name: 'Assets',
      children: [
        Account(code: '1100', name: 'Cash', balance: 15000),
        Account(code: '1200', name: 'Inventory', balance: 7000),
        Account(code: '1900', name: 'Archived', balance: 1200, isActive: false),
      ],
    ),
    const Account(
      code: '2000',
      name: 'Liabilities',
      children: [
        Account(code: '2100', name: 'Accounts Payable', balance: -4000),
      ],
    ),
  ];

  final service = AccountReportService();

  service.printAccounts(accounts);

  print(service.calculateBalance(accounts));
}
