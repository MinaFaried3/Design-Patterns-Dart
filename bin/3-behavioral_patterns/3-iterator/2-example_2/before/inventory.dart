class StockBatch {
  final String id;
  final String sku;
  final int onHand;
  final int reserved;
  final DateTime? expiresAt;

  const StockBatch({
    required this.id,
    required this.sku,
    required this.onHand,
    required this.reserved,
    this.expiresAt,
  });

  int get available => onHand - reserved;
}

// ======================================
// STORAGE LOCATION
// ======================================

class StorageLocation {
  final String id;
  final String name;
  final bool isActive;

  final List<StorageLocation> children;
  final List<StockBatch> batches;

  const StorageLocation({
    required this.id,
    required this.name,
    this.isActive = true,
    this.children = const [],
    this.batches = const [],
  });
}

// ======================================
// EXPIRING BATCH REPORT
// ======================================

class ExpiringBatchReport {
  final String locationPath;
  final StockBatch batch;

  const ExpiringBatchReport({required this.locationPath, required this.batch});
}

// ======================================
// MONOLITHIC INVENTORY REPORT SERVICE
// ======================================

class InventoryReportService {
  // ------------------------------------
  // 1. CALCULATE AVAILABLE QUANTITY
  // ------------------------------------

  int calculateAvailableStock(List<StorageLocation> warehouses, String sku) {
    int total = 0;

    void visit(StorageLocation location) {
      if (!location.isActive) return;

      for (final batch in location.batches) {
        if (batch.sku == sku) {
          total += batch.available;
        }
      }

      for (final child in location.children) {
        visit(child);
      }
    }

    for (final warehouse in warehouses) {
      visit(warehouse);
    }

    return total;
  }

  // ------------------------------------
  // 2. FIND EXPIRING BATCHES
  // ------------------------------------

  List<ExpiringBatchReport> findExpiringBatches(
    List<StorageLocation> warehouses, {
    required DateTime today,
    required int withinDays,
  }) {
    final result = <ExpiringBatchReport>[];

    final cutoff = today.add(Duration(days: withinDays));

    void visit(StorageLocation location, String path) {
      if (!location.isActive) return;

      final currentPath = path.isEmpty
          ? location.name
          : '$path/${location.name}';

      for (final batch in location.batches) {
        final expiration = batch.expiresAt;

        if (expiration != null &&
            !expiration.isBefore(today) &&
            !expiration.isAfter(cutoff) &&
            batch.available > 0) {
          result.add(
            ExpiringBatchReport(locationPath: currentPath, batch: batch),
          );
        }
      }

      for (final child in location.children) {
        visit(child, currentPath);
      }
    }

    for (final warehouse in warehouses) {
      visit(warehouse, '');
    }

    result.sort((a, b) => a.batch.expiresAt!.compareTo(b.batch.expiresAt!));

    return result;
  }

  // ------------------------------------
  // 3. FIND BATCH BY ID
  // ------------------------------------

  StockBatch? findBatchById(List<StorageLocation> warehouses, String batchId) {
    StockBatch? search(StorageLocation location) {
      if (!location.isActive) return null;

      for (final batch in location.batches) {
        if (batch.id == batchId) {
          return batch;
        }
      }

      for (final child in location.children) {
        final found = search(child);

        if (found != null) {
          return found;
        }
      }

      return null;
    }

    for (final warehouse in warehouses) {
      final found = search(warehouse);

      if (found != null) {
        return found;
      }
    }

    return null;
  }

  // ------------------------------------
  // 4. EXPORT INVENTORY TO CSV
  // ------------------------------------

  List<String> exportToCsv(List<StorageLocation> warehouses) {
    final rows = <String>['Location,SKU,Batch,OnHand,Reserved,Available'];

    void visit(StorageLocation location, String path) {
      if (!location.isActive) return;

      final currentPath = path.isEmpty
          ? location.name
          : '$path/${location.name}';

      for (final batch in location.batches) {
        rows.add(
          '$currentPath,'
          '${batch.sku},'
          '${batch.id},'
          '${batch.onHand},'
          '${batch.reserved},'
          '${batch.available}',
        );
      }

      for (final child in location.children) {
        visit(child, currentPath);
      }
    }

    for (final warehouse in warehouses) {
      visit(warehouse, '');
    }

    return rows;
  }
}

// ======================================
// MAIN
// ======================================

void main() {
  final warehouses = [
    StorageLocation(
      id: 'WH-CAIRO',
      name: 'Cairo Warehouse',
      children: [
        StorageLocation(
          id: 'ZONE-ELECTRONICS',
          name: 'Electronics',
          children: [
            StorageLocation(
              id: 'RACK-A',
              name: 'Rack A',
              batches: [
                const StockBatch(
                  id: 'L-001',
                  sku: 'LAPTOP',
                  onHand: 20,
                  reserved: 4,
                ),
                StockBatch(
                  id: 'BAT-01',
                  sku: 'BATTERY',
                  onHand: 50,
                  reserved: 10,
                  expiresAt: DateTime.utc(2026, 11, 10),
                ),
              ],
            ),
            StorageLocation(
              id: 'RACK-B',
              name: 'Rack B',
              batches: [
                StockBatch(
                  id: 'L-002',
                  sku: 'LAPTOP',
                  onHand: 10,
                  reserved: 2,
                  expiresAt: DateTime.utc(2026, 11, 5),
                ),
              ],
            ),
          ],
        ),
        const StorageLocation(
          id: 'ZONE-ARCHIVED',
          name: 'Archived',
          isActive: false,
          children: [
            StorageLocation(
              id: 'RACK-OLD',
              name: 'Old Rack',
              batches: [
                StockBatch(
                  id: 'BAT-OLD',
                  sku: 'BATTERY',
                  onHand: 100,
                  reserved: 0,
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    StorageLocation(
      id: 'WH-GIZA',
      name: 'Giza Warehouse',
      children: [
        StorageLocation(
          id: 'GIZA-ELECTRONICS',
          name: 'Electronics',
          children: [
            StorageLocation(
              id: 'RACK-C',
              name: 'Rack C',
              batches: [
                const StockBatch(
                  id: 'L-003',
                  sku: 'LAPTOP',
                  onHand: 15,
                  reserved: 5,
                ),
                StockBatch(
                  id: 'BAT-02',
                  sku: 'BATTERY',
                  onHand: 30,
                  reserved: 5,
                  expiresAt: DateTime.utc(2026, 12, 20),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ];

  final service = InventoryReportService();

  // ------------------------------------
  // TEST 1: CALCULATE AVAILABLE STOCK
  // ------------------------------------

  print('--- Available Stock ---');

  final laptopStock = service.calculateAvailableStock(warehouses, 'LAPTOP');

  print('LAPTOP: $laptopStock');

  // ------------------------------------
  // TEST 2: EXPIRING BATCHES
  // ------------------------------------

  print('\n--- Expiring Batches ---');

  final expiring = service.findExpiringBatches(
    warehouses,
    today: DateTime.utc(2026, 10, 27),
    withinDays: 30,
  );

  for (final item in expiring) {
    print(
      '${item.batch.id} | '
      '${item.locationPath} | '
      'Available: ${item.batch.available}',
    );
  }

  // ------------------------------------
  // TEST 3: SEARCH BATCH
  // ------------------------------------

  print('\n--- Find Batch ---');

  final batch = service.findBatchById(warehouses, 'L-003');

  print(
    'Found: ${batch?.id}, '
    'Available: ${batch?.available}',
  );

  // ------------------------------------
  // TEST 4: EXPORT CSV
  // ------------------------------------

  print('\n--- CSV Export ---');

  final rows = service.exportToCsv(warehouses);

  for (final row in rows) {
    print(row);
  }
}
