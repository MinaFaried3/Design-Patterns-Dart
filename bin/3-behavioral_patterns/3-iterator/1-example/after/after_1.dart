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
// 2. CONCRETE ITERATOR (DFS)
// ==========================================

// Implements Dart's built-in Iterator<Account>.
// No need to declare a custom Iterator interface.

class AccountDfsIterator implements Iterator<Account> {
  final List<Account> _stack;

  Account? _current;

  AccountDfsIterator(List<Account> roots) : _stack = roots.reversed.toList();

  @override
  Account get current {
    final account = _current;

    if (account == null) {
      throw StateError('No current account');
    }

    return account;
  }

  @override
  bool moveNext() {
    if (_stack.isEmpty) {
      _current = null;
      return false;
    }

    // Remove the next account from the stack.
    final account = _stack.removeLast();

    // Push children in reverse order so that
    // DFS preserves the original child order.
    _stack.addAll(account.children.reversed);

    _current = account;

    return true;
  }
}

// ==========================================
// 3. ITERABLE COLLECTION
// ==========================================

class AccountTree extends IterableBase<Account> {
  final List<Account> roots;

  AccountTree(List<Account> roots) : roots = List.unmodifiable(roots);

  @override
  Iterator<Account> get iterator {
    return AccountDfsIterator(roots);
  }
}

// ==========================================
// 4. REPORT SERVICE
// ==========================================

class AccountReportService {
  // Print active leaf accounts.
  void printAccounts(Iterable<Account> accounts) {
    for (final account in accounts) {
      if (account.isActiveLeaf) {
        print('${account.code}: ${account.name}');
      }
    }
  }

  // Calculate total active leaf balance.
  double calculateBalance(Iterable<Account> accounts) {
    return accounts
        .where((account) => account.isActiveLeaf)
        .fold<double>(0, (total, account) => total + account.balance);
  }

  // Export active leaf accounts.
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

  // Create iterable collection.
  final tree = AccountTree(accounts);

  // Create report service.
  final report = AccountReportService();

  // ======================================
  // Example 1: Print active accounts
  // ======================================

  print('--- Active Leaf Accounts ---');

  report.printAccounts(tree);

  // ======================================
  // Example 2: Calculate balance
  // ======================================

  print('\n--- Total Balance ---');

  final total = report.calculateBalance(tree);

  print('Total: $total');

  // ======================================
  // Example 3: Export accounts
  // ======================================

  print('\n--- CSV Export ---');

  final csvRows = report.exportToCsv(tree);

  for (final row in csvRows) {
    print(row);
  }

  // ======================================
  // Example 4: Manual iterator
  // ======================================

  print('\n--- Manual DFS Traversal ---');

  final iterator = tree.iterator;

  while (iterator.moveNext()) {
    final account = iterator.current;

    print('Visited: ${account.name}');
  }

  // ======================================
  // Example 5: Dart for-in
  // ======================================

  print('\n--- Using for-in ---');

  for (final account in tree) {
    print('${account.code}: ${account.name}');
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
