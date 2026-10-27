// BEFORE: One routine interleaves assembly order with output formatting.

// 1. REPORT ROUTINE
String buildReport(String format, Map<String, int> stock) {
  final lines = <String>[];
  if (format == 'markdown') {
    lines.add('# Inventory');
    for (final entry in stock.entries) {
      lines.add('- ${entry.key}: ${entry.value}');
    }
    lines.add('Total: ${stock.values.fold(0, (a, b) => a + b)}');
  } else if (format == 'csv') {
    lines.add('Inventory');
    for (final entry in stock.entries) {
      lines.add('${entry.key},${entry.value}');
    }
    lines.add('Total,${stock.values.fold(0, (a, b) => a + b)}');
  } else {
    throw ArgumentError('Unknown format');
  }
  return lines.join('\n');
}

// 2. USAGE
void main() {
  final stock = {'Pen': 10, 'Book': 5};
  print(buildReport('markdown', stock));
  print(buildReport('csv', stock));
}
