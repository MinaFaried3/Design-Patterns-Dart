import 'api.dart';
import 'models.dart';

// =====================================================
// 5. COMMAND ABSTRACTION
// =====================================================

abstract class InventoryCommand {
  final String performedBy;

  const InventoryCommand({required this.performedBy});

  String get description;

  Future<void> execute(InventoryTransaction tx);

  Future<void> undo(InventoryTransaction tx);
}

// =====================================================
// 6. RECEIVE STOCK COMMAND
// =====================================================

class ReceiveStockCommand extends InventoryCommand {
  final String warehouseId;
  final String sku;
  final int quantity;

  const ReceiveStockCommand({
    required super.performedBy,
    required this.warehouseId,
    required this.sku,
    required this.quantity,
  });

  @override
  String get description => 'Receive $quantity $sku in $warehouseId';

  @override
  Future<void> execute(InventoryTransaction tx) async {
    requirePositive(quantity);

    changeInventory(
      tx,
      warehouseId: warehouseId,
      sku: sku,
      stockDelta: quantity,
    );
  }

  @override
  Future<void> undo(InventoryTransaction tx) async {
    changeInventory(
      tx,
      warehouseId: warehouseId,
      sku: sku,
      stockDelta: -quantity,
    );
  }
}

// =====================================================
// 7. TRANSFER STOCK COMMAND
// =====================================================

class TransferStockCommand extends InventoryCommand {
  final String sourceWarehouseId;
  final String targetWarehouseId;
  final String sku;
  final int quantity;

  const TransferStockCommand({
    required super.performedBy,
    required this.sourceWarehouseId,
    required this.targetWarehouseId,
    required this.sku,
    required this.quantity,
  });

  @override
  String get description =>
      'Transfer $quantity $sku from '
      '$sourceWarehouseId to $targetWarehouseId';

  @override
  Future<void> execute(InventoryTransaction tx) async {
    requirePositive(quantity);

    if (sourceWarehouseId == targetWarehouseId) {
      throw const InventoryException('Cannot transfer to the same warehouse');
    }

    // Validate destination before staging modifications.
    tx.read(targetWarehouseId, sku);

    // Deduct from source.
    changeInventory(
      tx,
      warehouseId: sourceWarehouseId,
      sku: sku,
      stockDelta: -quantity,
    );

    // Add to destination.
    changeInventory(
      tx,
      warehouseId: targetWarehouseId,
      sku: sku,
      stockDelta: quantity,
    );
  }

  @override
  Future<void> undo(InventoryTransaction tx) async {
    // Inverse transfer.
    // If stock was subsequently reserved or consumed,
    // this may fail instead of corrupting inventory.

    changeInventory(
      tx,
      warehouseId: targetWarehouseId,
      sku: sku,
      stockDelta: -quantity,
    );

    changeInventory(
      tx,
      warehouseId: sourceWarehouseId,
      sku: sku,
      stockDelta: quantity,
    );
  }
}

// =====================================================
// 8. RESERVE STOCK COMMAND
// =====================================================

class ReserveStockCommand extends InventoryCommand {
  final String warehouseId;
  final String sku;
  final int quantity;

  const ReserveStockCommand({
    required super.performedBy,
    required this.warehouseId,
    required this.sku,
    required this.quantity,
  });

  @override
  String get description => 'Reserve $quantity $sku in $warehouseId';

  @override
  Future<void> execute(InventoryTransaction tx) async {
    requirePositive(quantity);

    changeInventory(
      tx,
      warehouseId: warehouseId,
      sku: sku,
      reservedDelta: quantity,
    );
  }

  @override
  Future<void> undo(InventoryTransaction tx) async {
    changeInventory(
      tx,
      warehouseId: warehouseId,
      sku: sku,
      reservedDelta: -quantity,
    );
  }
}

// =====================================================
// 9. RELEASE RESERVATION COMMAND
// =====================================================

class ReleaseReservationCommand extends InventoryCommand {
  final String warehouseId;
  final String sku;
  final int quantity;

  const ReleaseReservationCommand({
    required super.performedBy,
    required this.warehouseId,
    required this.sku,
    required this.quantity,
  });

  @override
  String get description => 'Release $quantity reserved $sku in $warehouseId';

  @override
  Future<void> execute(InventoryTransaction tx) async {
    requirePositive(quantity);

    changeInventory(
      tx,
      warehouseId: warehouseId,
      sku: sku,
      reservedDelta: -quantity,
    );
  }

  @override
  Future<void> undo(InventoryTransaction tx) async {
    changeInventory(
      tx,
      warehouseId: warehouseId,
      sku: sku,
      reservedDelta: quantity,
    );
  }
}

// =====================================================
// 10. ADJUST STOCK COMMAND
// =====================================================

class AdjustStockCommand extends InventoryCommand {
  final String warehouseId;
  final String sku;
  final int adjustment;

  const AdjustStockCommand({
    required super.performedBy,
    required this.warehouseId,
    required this.sku,
    required this.adjustment,
  });

  @override
  String get description => 'Adjust $sku by $adjustment in $warehouseId';

  @override
  Future<void> execute(InventoryTransaction tx) async {
    if (adjustment == 0) {
      throw const InventoryException('Adjustment cannot be zero');
    }

    changeInventory(
      tx,
      warehouseId: warehouseId,
      sku: sku,
      stockDelta: adjustment,
    );
  }

  @override
  Future<void> undo(InventoryTransaction tx) async {
    changeInventory(
      tx,
      warehouseId: warehouseId,
      sku: sku,
      stockDelta: -adjustment,
    );
  }
}
