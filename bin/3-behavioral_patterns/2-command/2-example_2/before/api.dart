import 'models.dart';

class InventoryApi {
  bool failNextRequest = false;

  Future<void> saveInventory(InventorySnapshot snapshot) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (failNextRequest) {
      failNextRequest = false;

      throw Exception('Server error 500');
    }

    print('Inventory persisted successfully');
  }
}

class InventoryService {
  final InventoryApi api;

  final Map<String, Warehouse> warehouses;

  final List<InventoryHistory> _undoStack = [];
  final List<InventoryHistory> _redoStack = [];
  final List<String> auditLogs = [];

  InventoryService({required this.api, required this.warehouses});

  Future<void> execute(InventoryOperation operation) async {
    final before = InventorySnapshot(warehouses);

    final warehouse = warehouses[operation.warehouseId];

    if (warehouse == null) {
      throw Exception('Warehouse not found');
    }

    if (operation.sku.isEmpty || operation.quantity == 0) {
      throw Exception('Invalid operation');
    }

    try {
      switch (operation.action) {
        case InventoryAction.receive:
          if (operation.quantity < 0) {
            throw Exception('Invalid received quantity');
          }

          warehouse.stock[operation.sku] =
              (warehouse.stock[operation.sku] ?? 0) + operation.quantity;

          break;

        case InventoryAction.transfer:
          final targetId = operation.targetWarehouseId;

          final target = warehouses[targetId];

          if (target == null || targetId == warehouse.id) {
            throw Exception('Invalid target warehouse');
          }

          if (operation.quantity < 0 ||
              warehouse.available(operation.sku) < operation.quantity) {
            throw Exception('Insufficient stock for transfer');
          }

          warehouse.stock[operation.sku] =
              (warehouse.stock[operation.sku] ?? 0) - operation.quantity;

          target.stock[operation.sku] =
              (target.stock[operation.sku] ?? 0) + operation.quantity;

          break;

        case InventoryAction.reserve:
          if (operation.quantity < 0 ||
              warehouse.available(operation.sku) < operation.quantity) {
            throw Exception('Insufficient stock for reservation');
          }

          warehouse.reserved[operation.sku] =
              (warehouse.reserved[operation.sku] ?? 0) + operation.quantity;

          break;

        case InventoryAction.release:
          final reserved = warehouse.reserved[operation.sku] ?? 0;

          if (operation.quantity < 0 || reserved < operation.quantity) {
            throw Exception('Invalid reservation release');
          }

          warehouse.reserved[operation.sku] = reserved - operation.quantity;

          break;

        case InventoryAction.adjust:
          final currentStock = warehouse.stock[operation.sku] ?? 0;

          final newStock = currentStock + operation.quantity;

          final reserved = warehouse.reserved[operation.sku] ?? 0;

          if (newStock < reserved) {
            throw Exception('Adjustment conflicts with reservations');
          }

          warehouse.stock[operation.sku] = newStock;

          break;
      }

      // Persist entire inventory state.
      await api.saveInventory(InventorySnapshot(warehouses));

      final after = InventorySnapshot(warehouses);

      _undoStack.add(
        InventoryHistory(operation: operation, before: before, after: after),
      );

      _redoStack.clear();

      auditLogs.add(
        '${operation.performedBy} executed '
        '${operation.action.name} '
        'for ${operation.sku}',
      );

      print('${operation.action.name} executed successfully');
    } catch (error) {
      // Restore local state if anything fails.
      _restore(before);
      rethrow;
    }
  }

  Future<void> undo() async {
    if (_undoStack.isEmpty) {
      print('Nothing to undo');
      return;
    }

    final history = _undoStack.last;

    await api.saveInventory(history.before);

    _restore(history.before);

    _undoStack.removeLast();
    _redoStack.add(history);

    auditLogs.add('Undo ${history.operation.action.name}');

    print('Undo completed');
  }

  Future<void> redo() async {
    if (_redoStack.isEmpty) {
      print('Nothing to redo');
      return;
    }

    final history = _redoStack.last;

    await api.saveInventory(history.after);

    _restore(history.after);

    _redoStack.removeLast();
    _undoStack.add(history);

    auditLogs.add('Redo ${history.operation.action.name}');

    print('Redo completed');
  }

  void _restore(InventorySnapshot snapshot) {
    warehouses
      ..clear()
      ..addAll({
        for (final entry in snapshot.warehouses.entries)
          entry.key: entry.value.copy(),
      });
  }

  void printInventory(String sku) {
    for (final warehouse in warehouses.values) {
      print(
        '${warehouse.id}: '
        'Stock=${warehouse.stock[sku] ?? 0}, '
        'Reserved=${warehouse.reserved[sku] ?? 0}, '
        'Available=${warehouse.available(sku)}',
      );
    }
  }
}
