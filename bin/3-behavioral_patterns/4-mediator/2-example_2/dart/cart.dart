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
// 5. CART ITEM
// ======================================

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});
}

// ======================================
// 6. CART SERVICE
// ======================================

// Responsible ONLY for cart state.
// Does not know about inventory, notifications,
// or discount calculation rules.

final class CartService {
  final Map<String, CartItem> _items = {};

  double _discount = 0;

  double get discount => _discount;

  double get subtotal => _items.values.fold(
    0.0,
    (total, item) => total + item.product.price * item.quantity,
  );

  double get total => subtotal - discount;

  int quantityOf(Product product) => _items[product.id]?.quantity ?? 0;

  void _addItem(Product product, int quantity) {
    final current = quantityOf(product);

    _items[product.id] = CartItem(
      product: product,
      quantity: current + quantity,
    );
  }

  void _removeItem(Product product, int quantity) {
    final remaining = quantityOf(product) - quantity;

    if (remaining == 0) {
      _items.remove(product.id);
    } else {
      _items[product.id] = CartItem(product: product, quantity: remaining);
    }
  }

  void _updateDiscount(double value) {
    _discount = value;
  }

  void printCart() {
    print('\n--- Shopping Cart ---');

    for (final item in _items.values) {
      print(
        '${item.product.name} x${item.quantity} '
        '= ${item.product.price * item.quantity}',
      );
    }

    print('Subtotal: $subtotal');
    print('Discount: $discount');
    print('Total: $total');
  }
}

// ======================================
// 7. MEDIATOR INTERFACE
// ======================================

abstract interface class ICartMediator {
  void onAddProduct(Product product, int quantity);

  void onRemoveProduct(Product product, int quantity);
}

// ======================================
// 8. CONCRETE MEDIATOR
// ======================================

// Coordinates communication between all services.

final class ShoppingCartMediator implements ICartMediator {
  final CartService cartService;
  final InventoryService inventoryService;
  final DiscountService discountService;
  final NotificationService notificationService;

  const ShoppingCartMediator({
    required this.cartService,
    required this.inventoryService,
    required this.discountService,
    required this.notificationService,
  });

  @override
  void onAddProduct(Product product, int quantity) {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }

    // 1. Validate stock availability.
    if (!inventoryService.isAvailable(product.id, quantity)) {
      print('Cart: Product out of stock');
      return;
    }

    // 2. Reserve stock.
    inventoryService.reserve(product.id, quantity);

    // 3. Update cart.
    try {
      cartService._addItem(product, quantity);

      // 4. Recalculate discount.
      final discount = discountService.calculateDiscount(cartService.subtotal);

      cartService._updateDiscount(discount);
    } catch (_) {
      // Compensate if the cart update fails.
      inventoryService.release(product.id, quantity);
      rethrow;
    }

    // 5. Notify customer.
    notificationService.notifyCustomer('${product.name} added to cart');

    print('Cart total: ${cartService.total}');
  }

  @override
  void onRemoveProduct(Product product, int quantity) {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be positive');
    }

    // 1. Validate existing cart quantity.
    final currentQuantity = cartService.quantityOf(product);

    if (currentQuantity < quantity) {
      print('Cart: Cannot remove requested quantity');
      return;
    }

    // 2. Release reserved stock.
    inventoryService.release(product.id, quantity);

    // 3. Update cart.
    cartService._removeItem(product, quantity);

    // 4. Recalculate discount.
    final discount = discountService.calculateDiscount(cartService.subtotal);

    cartService._updateDiscount(discount);

    // 5. Notify customer.
    notificationService.notifyCustomer('${product.name} removed from cart');

    print('Cart total: ${cartService.total}');
  }
}

// ======================================
// 9. MAIN
// ======================================

void main() {
  final laptop = Product(id: 'P-001', name: 'Laptop', price: 800);

  final mouse = Product(id: 'P-002', name: 'Mouse', price: 100);

  final inventory = InventoryService({'P-001': 5, 'P-002': 10});

  final cart = CartService();

  // Configure mediator dependencies.
  final ICartMediator mediator = ShoppingCartMediator(
    cartService: cart,
    inventoryService: inventory,
    discountService: DiscountService(),
    notificationService: NotificationService(),
  );

  // Add laptop.
  mediator.onAddProduct(laptop, 1);

  // Add two mice.
  mediator.onAddProduct(mouse, 2);

  // Remove one mouse.
  mediator.onRemoveProduct(mouse, 1);

  // Print final cart.
  cart.printCart();
}
