import 'dart:convert';

// AFTER: Reader creation varies; validation and aggregation stay reusable.

// 1. MODEL AND PRODUCT CONTRACT
class StockRow {
  final String sku;
  final int quantity;
  const StockRow(this.sku, this.quantity);
}

abstract class StockReader {
  Future<List<StockRow>> read(String source);
}

// 2. CONCRETE PRODUCTS: In-memory parsing, no external services.
class PipeStockReader implements StockReader {
  @override
  Future<List<StockRow>> read(String source) async {
    return source.split('\n').where((line) => line.isNotEmpty).map((line) {
      final parts = line.split('|');
      if (parts.length != 2) throw FormatException('Expected SKU|quantity');
      return StockRow(parts[0], int.parse(parts[1]));
    }).toList();
  }
}

class JsonStockReader implements StockReader {
  @override
  Future<List<StockRow>> read(String source) async {
    final data = jsonDecode(source) as List<dynamic>;
    return data.map((value) {
      final row = value as Map<String, dynamic>;
      return StockRow(row['sku'] as String, row['quantity'] as int);
    }).toList();
  }
}

// 3. CREATOR: This workflow knows only StockReader.
abstract class InventoryImportJob {
  StockReader createReader();

  Future<Map<String, int>> run(String source) async {
    final rows = await createReader().read(source);
    final totals = <String, int>{};
    for (final row in rows) {
      if (row.sku.isEmpty || row.quantity <= 0) {
        throw FormatException('SKU and positive quantity are required');
      }
      totals.update(
        row.sku,
        (value) => value + row.quantity,
        ifAbsent: () => row.quantity,
      );
    }
    return Map.unmodifiable(totals);
  }
}

// 4. CONCRETE CREATORS
class PipeImportJob extends InventoryImportJob {
  @override
  StockReader createReader() => PipeStockReader();
}

class JsonImportJob extends InventoryImportJob {
  @override
  StockReader createReader() => JsonStockReader();
}

// 5. USAGE
Future<void> main() async {
  final pipe = await PipeImportJob().run('PEN|2\nPEN|3\nBOOK|1');
  final json = await JsonImportJob().run(
    '[{"sku":"PEN","quantity":5},{"sku":"BOOK","quantity":1}]',
  );
  assert(pipe['PEN'] == 5 && json['PEN'] == 5);
  print('Pipe import: $pipe');
  print('JSON import: $json');

  try {
    await PipeImportJob().run('PEN|-1');
    throw StateError('Invalid quantities should be rejected');
  } on FormatException {
    print('Invalid quantity rejected by the common workflow');
  }
}
