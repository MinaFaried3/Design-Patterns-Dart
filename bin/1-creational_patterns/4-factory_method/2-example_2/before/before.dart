import 'dart:convert';

// BEFORE: Export workflow contains a branch for every product format.
class ReportExporter {
  String export(String format, Map<String, int> stock) {
    final sorted = stock.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    if (format == 'text') {
      return sorted.map((e) => '${e.key}: ${e.value}').join('\n');
    }
    if (format == 'json') {
      return jsonEncode(Map.fromEntries(sorted));
    }
    throw ArgumentError('Unknown format');
  }
}

void main() {
  final exporter = ReportExporter();
  final stock = {'Pen': 10, 'Book': 5};
  print(exporter.export('text', stock));
  print(exporter.export('json', stock));
}
