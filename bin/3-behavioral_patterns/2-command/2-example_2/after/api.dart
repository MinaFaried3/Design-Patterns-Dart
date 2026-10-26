import 'dart:async';

import 'commands.dart';
import 'models.dart';

// =====================================================
// 3. REPOSITORY AND TRANSACTION
// =====================================================

// Changes remain private until persistence succeeds.

class InventoryRepository {
  final Set<String> _warehouseIds = {};

  final Map<StockKey, StockBalance> _balances = {};
  final List<InventoryAudit> _auditLogs = [];

  final SerialExecutor _executor = SerialExecutor();

  final Duration persistenceDelay;
  bool failNextSave = false;

  InventoryRepository({
    required List<Warehouse> warehouses,
    this.persistenceDelay = const Duration(milliseconds: 100),
  }) {
    for (final warehouse in warehouses) {
      if (warehouse.id.trim().isEmpty || !_warehouseIds.add(warehouse.id)) {
        throw ArgumentError('Invalid or duplicate warehouse');
      }

      for (final entry in warehouse.products.entries) {
        if (entry.key.trim().isEmpty) {
          throw ArgumentError('Invalid SKU');
        }

        _validateBalance(entry.value);

        _balances[(warehouseId: warehouse.id, sku: entry.key)] = entry.value;
      }
    }
  }

  void _validateBalance(StockBalance balance) {
    if (balance.onHand < 0 ||
        balance.reserved < 0 ||
        balance.reserved > balance.onHand) {
      throw const InventoryException('Invalid inventory balance');
    }
  }

  void _validateKey(String warehouseId, String sku) {
    if (!_warehouseIds.contains(warehouseId)) {
      throw InventoryException('Warehouse $warehouseId does not exist');
    }

    if (sku.trim().isEmpty) {
      throw const InventoryException('Invalid SKU');
    }
  }

  StockBalance getBalance(String warehouseId, String sku) {
    _validateKey(warehouseId, sku);

    return _balances[(warehouseId: warehouseId, sku: sku)] ??
        const StockBalance(onHand: 0, reserved: 0);
  }

  List<InventoryAudit> get auditLogs => List.unmodifiable(_auditLogs);

  Future<T> transaction<T>(Future<T> Function(InventoryTransaction tx) work) {
    return _executor.run(() async {
      final tx = InventoryTransaction._(this);

      // Calculate all changes without publishing them.
      final result = await work(tx);

      // Simulated asynchronous database persistence.
      await Future<void>.delayed(persistenceDelay);

      if (failNextSave) {
        failNextSave = false;
        throw const InventoryException('Persistence failed: Server 500');
      }

      // Atomic in-memory commit.
      // All staged writes and audit entries become visible.
      _balances.addAll(tx._changes);
      _auditLogs.addAll(tx._auditEntries);

      return result;
    });
  }
}

class InventoryTransaction {
  final InventoryRepository _repository;

  final Map<StockKey, StockBalance> _changes = {};
  final List<InventoryAudit> _auditEntries = [];

  InventoryTransaction._(this._repository);

  StockBalance read(String warehouseId, String sku) {
    _repository._validateKey(warehouseId, sku);

    return _changes[(warehouseId: warehouseId, sku: sku)] ??
        _repository.getBalance(warehouseId, sku);
  }

  void write(String warehouseId, String sku, StockBalance balance) {
    _repository._validateKey(warehouseId, sku);
    _repository._validateBalance(balance);

    _changes[(warehouseId: warehouseId, sku: sku)] = balance;
  }

  void addAudit(InventoryAudit audit) {
    _auditEntries.add(audit);
  }
}

// =====================================================
// 4. COMMON INVENTORY OPERATIONS
// =====================================================

// Reusable stock invariants. Business commands decide
// which deltas to apply.

void requirePositive(int quantity) {
  if (quantity <= 0) {
    throw const InventoryException('Quantity must be greater than zero');
  }
}

void changeInventory(
  InventoryTransaction tx, {
  required String warehouseId,
  required String sku,
  int stockDelta = 0,
  int reservedDelta = 0,
}) {
  final current = tx.read(warehouseId, sku);

  final newBalance = StockBalance(
    onHand: current.onHand + stockDelta,
    reserved: current.reserved + reservedDelta,
  );

  tx.write(warehouseId, sku, newBalance);
}

// =====================================================
// 11. COMMAND MANAGER (INVOKER)
// =====================================================

class InventoryCommandManager {
  final InventoryRepository repository;

  // Each entry represents an atomic operation or batch.
  final List<List<InventoryCommand>> _undoStack = [];
  final List<List<InventoryCommand>> _redoStack = [];

  final SerialExecutor _executor = SerialExecutor();

  InventoryCommandManager({required this.repository});

  bool get canUndo => _undoStack.isNotEmpty;

  bool get canRedo => _redoStack.isNotEmpty;

  int get undoCount => _undoStack.length;

  int get redoCount => _redoStack.length;

  // -------------------------------------
  // Execute one command
  // -------------------------------------

  Future<void> execute(InventoryCommand command) {
    return executeBatch([command]);
  }

  // -------------------------------------
  // Execute batch atomically
  // -------------------------------------

  Future<void> executeBatch(List<InventoryCommand> commands) {
    final batch = List<InventoryCommand>.unmodifiable(commands);

    return _executor.run(() async {
      if (batch.isEmpty) {
        throw ArgumentError('Batch cannot be empty');
      }

      await repository.transaction((tx) async {
        for (final command in batch) {
          if (command.performedBy.trim().isEmpty) {
            throw const InventoryException('Performer is required');
          }

          await command.execute(tx);

          tx.addAudit(
            InventoryAudit(
              action: AuditAction.execute,
              description: command.description,
              performedBy: command.performedBy,
            ),
          );
        }
      });

      // Update history only after successful commit.
      _undoStack.add(batch);

      // A new operation creates a new history branch.
      _redoStack.clear();
    });
  }

  // -------------------------------------
  // Undo last operation or batch
  // -------------------------------------

  Future<bool> undo({required String performedBy}) {
    return _executor.run(() async {
      if (_undoStack.isEmpty) return false;

      if (performedBy.trim().isEmpty) {
        throw ArgumentError('Performer is required');
      }

      final batch = _undoStack.last;

      await repository.transaction((tx) async {
        // Reverse execution order.
        for (final command in batch.reversed) {
          await command.undo(tx);

          tx.addAudit(
            InventoryAudit(
              action: AuditAction.undo,
              description: command.description,
              performedBy: performedBy,
            ),
          );
        }
      });

      // Only move history after persistence succeeds.
      _undoStack.removeLast();
      _redoStack.add(batch);

      return true;
    });
  }

  // -------------------------------------
  // Redo last undone operation or batch
  // -------------------------------------

  Future<bool> redo({required String performedBy}) {
    return _executor.run(() async {
      if (_redoStack.isEmpty) return false;

      if (performedBy.trim().isEmpty) {
        throw ArgumentError('Performer is required');
      }

      final batch = _redoStack.last;

      await repository.transaction((tx) async {
        for (final command in batch) {
          await command.execute(tx);

          tx.addAudit(
            InventoryAudit(
              action: AuditAction.redo,
              description: command.description,
              performedBy: performedBy,
            ),
          );
        }
      });

      _redoStack.removeLast();
      _undoStack.add(batch);

      return true;
    });
  }
}
