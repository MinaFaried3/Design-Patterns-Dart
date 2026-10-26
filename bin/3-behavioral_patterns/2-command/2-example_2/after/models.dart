// =====================================================
// 1. DOMAIN MODELS
// =====================================================

typedef StockKey = ({String warehouseId, String sku});

class InventoryException implements Exception {
  final String message;

  const InventoryException(this.message);

  @override
  String toString() => 'InventoryException: $message';
}

class StockBalance {
  final int onHand;
  final int reserved;

  const StockBalance({required this.onHand, required this.reserved});

  int get available => onHand - reserved;
}

class Warehouse {
  final String id;
  final Map<String, StockBalance> products;

  const Warehouse({required this.id, required this.products});
}

enum AuditAction { execute, undo, redo }

class InventoryAudit {
  final AuditAction action;
  final String description;
  final String performedBy;
  final DateTime timestamp;

  InventoryAudit({
    required this.action,
    required this.description,
    required this.performedBy,
  }) : timestamp = DateTime.now().toUtc();
}

// =====================================================
// 2. SERIAL EXECUTOR
// =====================================================

// Prevents overlapping operations in a single instance.

class SerialExecutor {
  Future<void> _tail = Future<void>.value();

  Future<T> run<T>(Future<T> Function() action) {
    final result = _tail.then((_) => action());

    // An error must not block future operations.
    _tail = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {},
    );

    return result;
  }
}
