import 'dart:collection';

// ==========================================
// 1. ACCOUNT MODEL
// ==========================================

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

  bool get isLeaf => children.isEmpty;

  bool get isActiveLeaf => isActive && isLeaf;
}

// ==========================================
// 2. DFS GENERATOR USING sync* AND yield*
// ==========================================

Iterable<Account> traverseAccounts(Iterable<Account> accounts) sync* {
  for (final account in accounts) {
    // Return current account.
    yield account;

    // Recursively traverse children.
    yield* traverseAccounts(account.children);
  }
}

// ==========================================
// 3. ACCOUNT TREE (ITERABLE COLLECTION)
// ==========================================

class AccountTree extends IterableBase<Account> {
  final List<Account> roots;

  AccountTree(List<Account> roots) : roots = List.unmodifiable(roots);

  @override
  Iterator<Account> get iterator => traverseAccounts(roots).iterator;
}

// ==========================================
// 4. ACCOUNT REPORT SERVICE
// ==========================================

class AccountReportService {
  void printAccounts(Iterable<Account> accounts) {
    for (final account in accounts) {
      if (account.isActiveLeaf) {
        print('${account.code}: ${account.name}');
      }
    }
  }

  double calculateBalance(Iterable<Account> accounts) {
    return accounts
        .where((account) => account.isActiveLeaf)
        .fold<double>(0, (total, account) => total + account.balance);
  }

  List<String> exportToCsv(Iterable<Account> accounts) {
    return accounts
        .where((account) => account.isActiveLeaf)
        .map((account) => '${account.code},${account.name},${account.balance}')
        .toList();
  }
}

// ==========================================
// 5. MAIN
// ==========================================

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

  final tree = AccountTree(accounts);
  final report = AccountReportService();

  // ======================================
  // Example 1: Print active leaf accounts
  // ======================================

  print('--- Active Leaf Accounts ---');

  report.printAccounts(tree);

  // ======================================
  // Example 2: Calculate total balance
  // ======================================

  print('\n--- Total Balance ---');

  print('Total: ${report.calculateBalance(tree)}');

  // ======================================
  // Example 3: Export to CSV
  // ======================================

  print('\n--- CSV Export ---');

  for (final row in report.exportToCsv(tree)) {
    print(row);
  }

  // ======================================
  // Example 4: DFS traversal using for-in
  // ======================================

  print('\n--- DFS Traversal ---');

  for (final account in tree) {
    print('${account.code}: ${account.name}');
  }

  // ======================================
  // Example 5: Manual iterator
  // ======================================

  print('\n--- Manual Iterator ---');

  final iterator = tree.iterator;

  while (iterator.moveNext()) {
    print('Visited: ${iterator.current.name}');
  }

  // ======================================
  // Example 6: Functional operations
  // ======================================

  print('\n--- Active Account Names ---');

  final activeNames = tree
      .where((account) => account.isActiveLeaf)
      .map((account) => account.name)
      .toList();

  print(activeNames);

  // ======================================
  // Example 7: Independent iterators
  // ======================================

  print('\n--- Independent Iterators ---');

  final iterator1 = tree.iterator;
  final iterator2 = tree.iterator;

  iterator1.moveNext();
  iterator1.moveNext();

  iterator2.moveNext();

  print('Iterator 1: ${iterator1.current.name}');
  print('Iterator 2: ${iterator2.current.name}');
}
