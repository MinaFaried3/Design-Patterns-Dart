// AFTER: A director reuses assembly steps with different representations.

// 1. BUILDER CONTRACT
abstract class ReportBuilder {
  void start(String title);
  void addRow(String name, int quantity);
  void finish(int total);
  String build();
}

// 2. CONCRETE BUILDERS
class MarkdownReportBuilder implements ReportBuilder {
  final List<String> _lines = [];

  @override
  void start(String title) {
    _lines
      ..clear()
      ..add('# $title');
  }

  @override
  void addRow(String name, int quantity) => _lines.add('- $name: $quantity');

  @override
  void finish(int total) => _lines.add('Total: $total');

  @override
  String build() => _lines.join('\n');
}

class CsvReportBuilder implements ReportBuilder {
  final List<String> _lines = [];

  String _escape(String value) => '"${value.replaceAll('"', '""')}"';

  @override
  void start(String title) {
    _lines
      ..clear()
      ..add(_escape(title));
  }

  @override
  void addRow(String name, int quantity) {
    _lines.add('${_escape(name)},$quantity');
  }

  @override
  void finish(int total) => _lines.add('Total,$total');

  @override
  String build() => _lines.join('\n');
}

// 3. DIRECTOR: Owns order; does not know how either format is represented.
class InventoryReportDirector {
  String construct(ReportBuilder builder, Map<String, int> stock) {
    builder.start('Inventory');
    for (final entry in stock.entries) {
      builder.addRow(entry.key, entry.value);
    }
    builder.finish(stock.values.fold(0, (total, value) => total + value));
    return builder.build();
  }
}

// 4. USAGE
void main() {
  final director = InventoryReportDirector();
  final stock = {'Pen': 10, 'Book': 5};
  final markdownBuilder = MarkdownReportBuilder();
  final markdown = director.construct(markdownBuilder, stock);
  final csv = director.construct(CsvReportBuilder(), stock);

  assert(markdown.endsWith('Total: 15'));
  assert(csv.endsWith('Total,15'));
  assert(
    director.construct(markdownBuilder, {'Eraser': 2}) ==
        '# Inventory\n- Eraser: 2\nTotal: 2',
  );
  print(markdown);
  print(csv);
}
