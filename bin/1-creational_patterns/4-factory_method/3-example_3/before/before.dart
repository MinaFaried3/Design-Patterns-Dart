import 'dart:convert';

// BEFORE: Parsing selection and the import workflow live together.
class InventoryImportJob {
  Map<String, int> run(String format, String source) {
    final List<(String, int)> rows;
    if (format == 'json') {
      final data = jsonDecode(source) as List<dynamic>;
      rows = data.map((value) {
        final row = value as Map<String, dynamic>;
        return (row['sku'] as String, row['quantity'] as int);
      }).toList();
    } else if (format == 'pipe') {
      rows = source.split('\n').map((line) {
        final parts = line.split('|');
        return (parts[0], int.parse(parts[1]));
      }).toList();
    } else {
      throw ArgumentError('Unknown format');
    }

    final totals = <String, int>{};
    for (final (sku, quantity) in rows) {
      if (sku.isEmpty || quantity <= 0) throw FormatException('Invalid row');
      totals.update(sku, (value) => value + quantity, ifAbsent: () => quantity);
    }
    return totals;
  }
}

void main() {
  final job = InventoryImportJob();
  print(job.run('pipe', 'PEN|2\nPEN|3\nBOOK|1'));
  print(job.run('json', '[{"sku":"PEN","quantity":5}]'));
}
