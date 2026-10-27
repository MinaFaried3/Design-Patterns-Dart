import 'dart:collection';

// AFTER: One traversal serves every report through Iterable<LocatedBatch>.
// Input is an acyclic location tree; do not mutate its lists during iteration.

// ======================================
// 1. MODELS
// ======================================

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
// 2. ITERATION VALUE: BATCH + LOCATION CONTEXT
// ======================================

// Reports need both a batch and the path where it was found.
class LocatedBatch {
  final String locationPath;
  final StockBatch batch;

  const LocatedBatch({required this.locationPath, required this.batch});
}

// ======================================
// 3. EXPLICIT DFS ITERATOR
// ======================================

// One pending location visit, including the path needed to reach it.
class _LocationVisit {
  final StorageLocation location;
  final String path;

  const _LocationVisit(this.location, this.path);
}

class InventoryIterator implements Iterator<LocatedBatch> {
  final List<_LocationVisit> _pending;
  Iterator<StockBatch>? _batches;
  String _locationPath = '';
  LocatedBatch? _current;

  InventoryIterator(Iterable<StorageLocation> warehouses)
    : _pending = warehouses
          .map((location) => _LocationVisit(location, location.name))
          .toList()
          .reversed
          .toList();

  @override
  LocatedBatch get current {
    final value = _current;
    if (value == null) throw StateError('No current batch');
    return value;
  }

  @override
  bool moveNext() {
    _current = null;

    while (true) {
      // Finish a location's batches before descending into its children.
      final batches = _batches;
      if (batches != null && batches.moveNext()) {
        _current = LocatedBatch(
          locationPath: _locationPath,
          batch: batches.current,
        );
        return true;
      }

      if (_pending.isEmpty) return false;

      final visit = _pending.removeLast();
      final location = visit.location;

      // Prune the entire subtree, even if its descendants are marked active.
      if (!location.isActive) continue;

      _locationPath = visit.path;
      _batches = location.batches.iterator;

      // A stack removes from the end; reverse children to preserve input order.
      for (final child in location.children.reversed) {
        _pending.add(_LocationVisit(child, '${visit.path}/${child.name}'));
      }
      // Loop again: empty locations still lead to their nonempty descendants.
    }
  }
}

// ======================================
// 4. ITERABLE: A FRESH CURSOR FOR EACH TRAVERSAL
// ======================================

class Inventory extends IterableBase<LocatedBatch> {
  final List<StorageLocation> warehouses;

  Inventory(Iterable<StorageLocation> warehouses)
    : warehouses = List.unmodifiable(warehouses);

  @override
  Iterator<LocatedBatch> get iterator => InventoryIterator(warehouses);
}

// ======================================
// 5. GENERATOR ALTERNATIVE: THE SAME ITERABLE CONTRACT
// ======================================

// Calling this returns a lazy Iterable. Iteration runs the body.
// yield emits one LocatedBatch; yield* delegates to each child's traversal.
Iterable<LocatedBatch> traverseBatches(
  Iterable<StorageLocation> locations, [
  String parentPath = '',
]) sync* {
  for (final location in locations) {
    if (!location.isActive) continue;

    final path = parentPath.isEmpty
        ? location.name
        : '$parentPath/${location.name}';

    for (final batch in location.batches) {
      yield LocatedBatch(locationPath: path, batch: batch);
    }
    yield* traverseBatches(location.children, path);
  }
}

// ======================================
// 6. REPORT SERVICE: CONSUMES VALUES, NOT TREE STRUCTURE
// ======================================

class InventoryReportService {
  int calculateAvailableStock(Iterable<LocatedBatch> inventory, String sku) {
    return inventory
        .where((entry) => entry.batch.sku == sku)
        .fold(0, (total, entry) => total + entry.batch.available);
  }

  List<LocatedBatch> findExpiringBatches(
    Iterable<LocatedBatch> inventory, {
    required DateTime today,
    required int withinDays,
  }) {
    if (withinDays < 0) {
      throw ArgumentError.value(
        withinDays,
        'withinDays',
        'Must not be negative',
      );
    }
    final cutoff = today.add(Duration(days: withinDays));
    final result = inventory.where((entry) {
      final expiration = entry.batch.expiresAt;
      return expiration != null &&
          !expiration.isBefore(today) &&
          !expiration.isAfter(cutoff) &&
          entry.batch.available > 0;
    }).toList();

    // Expiry order is a reporting decision, separate from DFS visit order.
    result.sort((a, b) => a.batch.expiresAt!.compareTo(b.batch.expiresAt!));
    return result;
  }

  StockBatch? findBatchById(Iterable<LocatedBatch> inventory, String batchId) {
    for (final entry in inventory) {
      // Returning here stops pulling values from the iterator immediately.
      if (entry.batch.id == batchId) return entry.batch;
    }
    return null;
  }

  List<String> exportToCsv(Iterable<LocatedBatch> inventory) {
    return [
      'Location,SKU,Batch,OnHand,Reserved,Available',
      for (final entry in inventory)
        '${_csvField(entry.locationPath)},'
            '${_csvField(entry.batch.sku)},'
            '${_csvField(entry.batch.id)},'
            '${entry.batch.onHand},'
            '${entry.batch.reserved},'
            '${entry.batch.available}',
    ];
  }
}

String _csvField(String value) {
  if (value.contains(',') ||
      value.contains('"') ||
      value.contains('\n') ||
      value.contains('\r')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

// ======================================
// 7. MAIN: SAME DATA AND REPORT OUTPUT AS BEFORE
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
  final inventory = Inventory(warehouses);
  // Generator alternative: final inventory = traverseBatches(warehouses);

  // ------------------------------------
  // TEST 1: CALCULATE AVAILABLE STOCK
  // ------------------------------------

  print('--- Available Stock ---');

  final laptopStock = service.calculateAvailableStock(inventory, 'LAPTOP');

  print('LAPTOP: $laptopStock');

  // ------------------------------------
  // TEST 2: EXPIRING BATCHES
  // ------------------------------------

  print('\n--- Expiring Batches ---');

  final expiring = service.findExpiringBatches(
    inventory,
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

  final batch = service.findBatchById(inventory, 'L-003');

  print(
    'Found: ${batch?.id}, '
    'Available: ${batch?.available}',
  );

  // ------------------------------------
  // TEST 4: EXPORT CSV
  // ------------------------------------

  print('\n--- CSV Export ---');

  final rows = service.exportToCsv(inventory);

  for (final row in rows) {
    print(row);
  }
}
