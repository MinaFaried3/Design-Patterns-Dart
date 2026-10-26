enum InventoryAction { receive, transfer, reserve, release, adjust }

class Warehouse {
  final String id;

  final Map<String, int> stock;
  final Map<String, int> reserved;

  Warehouse({required this.id, required this.stock, required this.reserved});

  int available(String sku) {
    return (stock[sku] ?? 0) - (reserved[sku] ?? 0);
  }

  Warehouse copy() {
    return Warehouse(id: id, stock: Map.of(stock), reserved: Map.of(reserved));
  }
}

class InventoryOperation {
  final InventoryAction action;
  final String sku;
  final String warehouseId;
  final String? targetWarehouseId;
  final int quantity;
  final String performedBy;

  const InventoryOperation({
    required this.action,
    required this.sku,
    required this.warehouseId,
    this.targetWarehouseId,
    required this.quantity,
    required this.performedBy,
  });
}

class InventorySnapshot {
  final Map<String, Warehouse> warehouses;

  InventorySnapshot(Map<String, Warehouse> source)
    : warehouses = {
        for (final entry in source.entries) entry.key: entry.value.copy(),
      };
}

class InventoryHistory {
  final InventoryOperation operation;
  final InventorySnapshot before;
  final InventorySnapshot after;

  InventoryHistory({
    required this.operation,
    required this.before,
    required this.after,
  });
}
