import 'api.dart';
import 'commands.dart';
import 'models.dart';

Future<void> main() async {
  // 1. Initialize repository
  final repository = InventoryRepository(
    warehouses: [
      Warehouse(
        id: 'WH-A',
        products: {'LAPTOP': const StockBalance(onHand: 20, reserved: 4)},
      ),
      Warehouse(
        id: 'WH-B',
        products: {'LAPTOP': const StockBalance(onHand: 5, reserved: 0)},
      ),
    ],
  );

  // 2. Initialize Command Manager
  final manager = InventoryCommandManager(repository: repository);

  void printInventory(String title) {
    print('\n--- $title ---');

    for (final id in ['WH-A', 'WH-B']) {
      final stock = repository.getBalance(id, 'LAPTOP');

      print(
        '$id: OnHand=${stock.onHand}, '
        'Reserved=${stock.reserved}, '
        'Available=${stock.available}',
      );
    }
  }

  printInventory('Initial Inventory');

  // 3. Execute transfer command
  await manager.execute(
    TransferStockCommand(
      performedBy: 'Admin',
      sourceWarehouseId: 'WH-A',
      targetWarehouseId: 'WH-B',
      sku: 'LAPTOP',
      quantity: 6,
    ),
  );

  printInventory('After Transfer');

  // 4. Execute reserve command
  await manager.execute(
    ReserveStockCommand(
      performedBy: 'Sales',
      warehouseId: 'WH-B',
      sku: 'LAPTOP',
      quantity: 3,
    ),
  );

  printInventory('After Reservation');

  // 5. Execute adjustment command
  await manager.execute(
    AdjustStockCommand(
      performedBy: 'InventoryManager',
      warehouseId: 'WH-A',
      sku: 'LAPTOP',
      adjustment: 2,
    ),
  );

  printInventory('After Adjustment');

  // 6. Undo adjustment
  await manager.undo(performedBy: 'Admin');

  printInventory('After First Undo');

  // 7. Undo reservation
  await manager.undo(performedBy: 'Admin');

  printInventory('After Second Undo');

  // 8. Redo reservation
  await manager.redo(performedBy: 'Admin');

  printInventory('After Redo');

  // 9. Execute multiple commands as one batch
  await manager.executeBatch([
    ReceiveStockCommand(
      performedBy: 'Admin',
      warehouseId: 'WH-A',
      sku: 'LAPTOP',
      quantity: 5,
    ),
    ReleaseReservationCommand(
      performedBy: 'Admin',
      warehouseId: 'WH-B',
      sku: 'LAPTOP',
      quantity: 2,
    ),
    AdjustStockCommand(
      performedBy: 'Admin',
      warehouseId: 'WH-A',
      sku: 'LAPTOP',
      adjustment: -3,
    ),
  ]);

  printInventory('After Batch Execution');

  // 10. Undo entire batch as one operation
  await manager.undo(performedBy: 'Admin');

  printInventory('After Batch Undo');

  // 11. Simulate API persistence failure
  repository.failNextSave = true;

  try {
    await manager.execute(
      ReceiveStockCommand(
        performedBy: 'Admin',
        warehouseId: 'WH-A',
        sku: 'LAPTOP',
        quantity: 10,
      ),
    );
  } catch (error) {
    print('\nExpected failure: $error');
  }

  printInventory('After Failed Persistence');

  // 12. Check Undo/Redo history
  print('\n--- Command History ---');
  print('Undo count: ${manager.undoCount}');
  print('Redo count: ${manager.redoCount}');
  print('Can Undo: ${manager.canUndo}');
  print('Can Redo: ${manager.canRedo}');

  // 13. Print audit logs
  print('\n--- Audit Logs ---');

  for (final audit in repository.auditLogs) {
    print(
      '[${audit.action.name}] '
      '${audit.description} '
      'by ${audit.performedBy}',
    );
  }
}
