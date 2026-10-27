// AFTER: One store owns stock; clients receive it explicitly.

// 1. SINGLETON
class InventoryStore {
  InventoryStore._();
  static final InventoryStore instance = InventoryStore._();

  int _stock = 10;
  int get stock => _stock;

  void reserve(int quantity) {
    if (quantity <= 0 || quantity > _stock) {
      throw StateError('Cannot reserve $quantity items');
    }
    _stock -= quantity;
  }
}

// 2. CLIENTS: Sharing policy is chosen in main, not hidden in each method.
class Checkout {
  final InventoryStore store;
  Checkout(this.store);
  void buy(int quantity) => store.reserve(quantity);
}

class StockReport {
  final InventoryStore store;
  StockReport(this.store);
  int get available => store.stock;
}

// 3. USAGE
void main() {
  final checkout = Checkout(InventoryStore.instance);
  final report = StockReport(InventoryStore.instance);
  checkout.buy(3);

  assert(identical(checkout.store, report.store));
  assert(report.available == 7);
  print('Checkout stock: ${checkout.store.stock}');
  print('Reported stock: ${report.available}');
}
