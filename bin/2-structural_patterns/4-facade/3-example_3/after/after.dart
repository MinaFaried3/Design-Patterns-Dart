// AFTER: One task-oriented facade owns sequencing and compensation.
// This synchronous in-memory demonstration is not a distributed transaction.

// 1. SUBSYSTEMS
class Inventory {
  int _stock;
  Inventory(this._stock);
  int get stock => _stock;

  void reserve(int quantity) {
    if (quantity <= 0 || quantity > _stock) {
      throw StateError('Insufficient stock or invalid quantity');
    }
    _stock -= quantity;
  }

  void release(int quantity) => _stock += quantity;
}

class PaymentService {
  int _balance;
  PaymentService(this._balance);
  int get balance => _balance;

  void charge(int cents) {
    if (cents <= 0 || cents > _balance) throw StateError('Payment declined');
    _balance -= cents;
  }

  void refund(int cents) => _balance += cents;
}

class ShippingService {
  bool failNext = false;
  int _nextId = 0;

  String createShipment() {
    if (failNext) {
      failNext = false;
      throw StateError('Shipping unavailable');
    }
    return 'SHIP-${++_nextId}';
  }
}

// 2. APPLICATION RESULT
class OrderResult {
  final bool success;
  final String message;
  const OrderResult(this.success, this.message);
}

// 3. FACADE: Client sees one operation; subsystem roles remain separate.
class CheckoutFacade {
  final Inventory inventory;
  final PaymentService payments;
  final ShippingService shipping;
  CheckoutFacade(this.inventory, this.payments, this.shipping);

  OrderResult placeOrder({required int quantity, required int totalCents}) {
    if (quantity <= 0 || totalCents <= 0) {
      return const OrderResult(false, 'Positive quantity and total required');
    }
    var reserved = false;
    var charged = false;
    try {
      inventory.reserve(quantity);
      reserved = true;
      payments.charge(totalCents);
      charged = true;
      return OrderResult(true, shipping.createShipment());
    } on StateError catch (error) {
      // Undo only successful steps, in reverse order.
      if (charged) payments.refund(totalCents);
      if (reserved) inventory.release(quantity);
      return OrderResult(false, error.message.toString());
    }
  }
}

// 4. USAGE: Success, failure after reservation, failure after payment.
void main() {
  final inventory = Inventory(10);
  final payments = PaymentService(1000);
  final shipping = ShippingService();
  final checkout = CheckoutFacade(inventory, payments, shipping);

  final success = checkout.placeOrder(quantity: 2, totalCents: 200);
  assert(success.success && inventory.stock == 8 && payments.balance == 800);
  print('Success: ${success.message}');

  final declined = checkout.placeOrder(quantity: 2, totalCents: 2000);
  assert(!declined.success && inventory.stock == 8 && payments.balance == 800);
  print('Declined: ${declined.message}');

  shipping.failNext = true;
  final failedShipping = checkout.placeOrder(quantity: 1, totalCents: 100);
  assert(
    !failedShipping.success && inventory.stock == 8 && payments.balance == 800,
  );
  print('Shipping failure: ${failedShipping.message}');
  print('Final stock: ${inventory.stock}; balance cents: ${payments.balance}');
}
