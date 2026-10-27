// BEFORE: Each feature owns an independent stock counter.

// 1. STORE
class InventoryStore {
  int stock = 10;

  void reserve(int quantity) {
    if (quantity <= 0 || quantity > stock) {
      throw StateError('Cannot reserve $quantity items');
    }
    stock -= quantity;
  }
}

// 2. CLIENTS
class Checkout {
  final InventoryStore store = InventoryStore();
  void buy(int quantity) => store.reserve(quantity);
}

class StockReport {
  final InventoryStore store = InventoryStore();
  int get available => store.stock;
}

// 3. USAGE
void main() {
  final checkout = Checkout();
  final report = StockReport();
  checkout.buy(3);

  print('Checkout stock: ${checkout.store.stock}');
  print('Reported stock: ${report.available}'); // Still 10: separate state.
}
