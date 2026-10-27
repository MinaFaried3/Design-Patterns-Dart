// BEFORE: Every report kind duplicates every delivery mechanism.
class SummaryEmailReport {
  String publish(List<int> stock) =>
      'Email: Total stock: ${stock.fold(0, (a, b) => a + b)}';
}

class SummaryArchiveReport {
  String publish(List<int> stock) =>
      'Archive: Total stock: ${stock.fold(0, (a, b) => a + b)}';
}

class LowStockEmailReport {
  String publish(List<int> stock) =>
      'Email: Low stock: ${stock.where((quantity) => quantity < 5).join(', ')}';
}

class LowStockArchiveReport {
  String publish(List<int> stock) =>
      'Archive: Low stock: ${stock.where((quantity) => quantity < 5).join(', ')}';
}

void main() {
  final stock = [10, 2, 4];
  print(SummaryEmailReport().publish(stock));
  print(SummaryArchiveReport().publish(stock));
  print(LowStockEmailReport().publish(stock));
  print(LowStockArchiveReport().publish(stock));
}
