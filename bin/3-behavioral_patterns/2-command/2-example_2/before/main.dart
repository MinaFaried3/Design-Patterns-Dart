import 'api.dart';
import 'models.dart';

Future<void> main() async {
  final service = InventoryService(
    api: InventoryApi(),
    warehouses: {
      'WH-A': Warehouse(
        id: 'WH-A',
        stock: {'LAPTOP': 20},
        reserved: {'LAPTOP': 4},
      ),
      'WH-B': Warehouse(id: 'WH-B', stock: {'LAPTOP': 5}, reserved: {}),
    },
  );

  // 1. Transfer 6 laptops.
  await service.execute(
    const InventoryOperation(
      action: InventoryAction.transfer,
      sku: 'LAPTOP',
      warehouseId: 'WH-A',
      targetWarehouseId: 'WH-B',
      quantity: 6,
      performedBy: 'Admin',
    ),
  );

  // 2. Reserve 3 laptops in WH-B.
  await service.execute(
    const InventoryOperation(
      action: InventoryAction.reserve,
      sku: 'LAPTOP',
      warehouseId: 'WH-B',
      quantity: 3,
      performedBy: 'Sales',
    ),
  );

  // 3. Adjust physical stock in WH-A.
  await service.execute(
    const InventoryOperation(
      action: InventoryAction.adjust,
      sku: 'LAPTOP',
      warehouseId: 'WH-A',
      quantity: 2,
      performedBy: 'InventoryManager',
    ),
  );

  print('--- Current Inventory ---');
  service.printInventory('LAPTOP');

  // 4. Undo adjustment.
  await service.undo();

  // 5. Undo reservation.
  await service.undo();

  print('--- After Two Undos ---');
  service.printInventory('LAPTOP');

  // 6. Redo reservation.
  await service.redo();

  print('--- After Redo ---');
  service.printInventory('LAPTOP');

  // 7. Inspect audit history.
  print('--- Audit Logs ---');

  for (final log in service.auditLogs) {
    print(log);
  }
}
