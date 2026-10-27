// BEFORE: The client owns orchestration and forgets partial-failure cleanup.
class Inventory {
  int stock = 10;
  void reserve(int quantity) => stock -= quantity;
}

class PaymentService {
  int balance = 50;
  void charge(int cents) {
    if (cents > balance) throw StateError('Payment declined');
    balance -= cents;
  }
}

void main() {
  final inventory = Inventory();
  final payment = PaymentService();
  try {
    inventory.reserve(2);
    payment.charge(100);
    print('Order completed');
  } on StateError catch (error) {
    print(error.message);
  }
  print('Stock after failed order: ${inventory.stock}'); // Incorrectly stays 8.
}
