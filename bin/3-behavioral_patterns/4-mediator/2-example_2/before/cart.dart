// ======================================
// 1. PRODUCT MODEL
// ======================================

class Product {
  final String id;
  final String name;
  final double price;

  const Product({required this.id, required this.name, required this.price});
}

// ======================================
// 2. INVENTORY SERVICE
// ======================================

class InventoryService {
  final Map<String, int> stock;

  InventoryService(this.stock);

  bool isAvailable(String productId, int quantity) {
    return (stock[productId] ?? 0) >= quantity;
  }

  void reserve(String productId, int quantity) {
    if (!isAvailable(productId, quantity)) {
      throw Exception('Insufficient stock');
    }

    stock[productId] = stock[productId]! - quantity;

    print('Inventory: Reserved $quantity of $productId');
  }

  void release(String productId, int quantity) {
    stock[productId] = (stock[productId] ?? 0) + quantity;

    print('Inventory: Released $quantity of $productId');
  }
}

// ======================================
// 3. DISCOUNT SERVICE
// ======================================

class DiscountService {
  double calculateDiscount(double subtotal) {
    if (subtotal >= 1000) {
      return subtotal * 0.10;
    }

    if (subtotal >= 500) {
      return subtotal * 0.05;
    }

    return 0;
  }
}

// ======================================
// 4. NOTIFICATION SERVICE
// ======================================

class NotificationService {
  void notifyCustomer(String message) {
    print('Notification: $message');
  }
}

// ======================================
// 5. CART SERVICE
// ======================================

class CartService {
  final InventoryService inventoryService;
  final DiscountService discountService;
  final NotificationService notificationService;

  final Map<Product, int> _items = {};

  double discount = 0;

  CartService({
    required this.inventoryService,
    required this.discountService,
    required this.notificationService,
  });

  double get subtotal {
    double total = 0;

    for (final entry in _items.entries) {
      total += entry.key.price * entry.value;
    }

    return total;
  }

  double get total => subtotal - discount;

  void addProduct(Product product, int quantity) {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }

    // Direct dependency 1: Inventory
    if (!inventoryService.isAvailable(product.id, quantity)) {
      print('Cart: Product out of stock');
      return;
    }

    inventoryService.reserve(product.id, quantity);

    // Update cart
    _items[product] = (_items[product] ?? 0) + quantity;

    // Direct dependency 2: Discount
    discount = discountService.calculateDiscount(subtotal);

    // Direct dependency 3: Notification
    notificationService.notifyCustomer('${product.name} added to cart');

    print('Cart total: $total');
  }

  void removeProduct(Product product, int quantity) {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }

    final currentQuantity = _items[product] ?? 0;

    if (currentQuantity < quantity) {
      print('Cart: Cannot remove requested quantity');
      return;
    }

    // Update cart
    final remaining = currentQuantity - quantity;

    if (remaining == 0) {
      _items.remove(product);
    } else {
      _items[product] = remaining;
    }

    // Direct dependency 1: Inventory
    inventoryService.release(product.id, quantity);

    // Direct dependency 2: Discount
    discount = discountService.calculateDiscount(subtotal);

    // Direct dependency 3: Notification
    notificationService.notifyCustomer('${product.name} removed from cart');

    print('Cart total: $total');
  }

  void printCart() {
    print('\n--- Shopping Cart ---');

    for (final entry in _items.entries) {
      print(
        '${entry.key.name} x${entry.value} '
        '= ${entry.key.price * entry.value}',
      );
    }

    print('Subtotal: $subtotal');
    print('Discount: $discount');
    print('Total: $total');
  }
}

// ======================================
// 6. MAIN
// ======================================

void main() {
  final laptop = Product(id: 'P-001', name: 'Laptop', price: 800);

  final mouse = Product(id: 'P-002', name: 'Mouse', price: 100);

  final inventory = InventoryService({'P-001': 5, 'P-002': 10});

  final cart = CartService(
    inventoryService: inventory,
    discountService: DiscountService(),
    notificationService: NotificationService(),
  );

  // Add laptop
  cart.addProduct(laptop, 1);

  // Add two mice
  cart.addProduct(mouse, 2);

  // Remove one mouse
  cart.removeProduct(mouse, 1);

  // Print final cart
  cart.printCart();
}
