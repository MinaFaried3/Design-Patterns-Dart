import 'dart:convert';

// AFTER: Preparation is reused while subclasses create output formatters.

// 1. PRODUCTS
abstract class StockFormatter {
  String format(Map<String, int> stock);
}

class TextFormatter implements StockFormatter {
  @override
  String format(Map<String, int> stock) =>
      stock.entries.map((e) => '${e.key}: ${e.value}').join('\n');
}

class JsonFormatter implements StockFormatter {
  @override
  String format(Map<String, int> stock) => jsonEncode(stock);
}

// 2. CREATOR
abstract class ReportExporter {
  StockFormatter createFormatter();

  String export(Map<String, int> stock) {
    if (stock.values.any((quantity) => quantity < 0)) {
      throw ArgumentError('Stock cannot be negative');
    }
    final sorted = stock.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return createFormatter().format(Map.fromEntries(sorted));
  }
}

// 3. CONCRETE CREATORS
class TextReportExporter extends ReportExporter {
  @override
  StockFormatter createFormatter() => TextFormatter();
}

class JsonReportExporter extends ReportExporter {
  @override
  StockFormatter createFormatter() => JsonFormatter();
}

// 4. USAGE
void main() {
  final stock = {'Pen': 10, 'Book': 5};
  print(TextReportExporter().export(stock));
  final json = JsonReportExporter().export(stock);
  assert(json == '{"Book":5,"Pen":10}');
  print(json);
}
