class Invoice {
  String customerName;
  int quantity;
  double unitPrice;
  double discount;

  Invoice({
    required this.customerName,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
  });

  double get total => quantity * unitPrice * (1 - discount / 100);
}

class InvoiceEditor {
  final Invoice invoice;

  final List<Map<String, dynamic>> _history = [];

  InvoiceEditor(this.invoice);

  void saveHistory() {
    _history.add({
      'customerName': invoice.customerName,
      'quantity': invoice.quantity,
      'unitPrice': invoice.unitPrice,
      'discount': invoice.discount,
    });
  }

  void changeQuantity(int quantity) {
    saveHistory();
    invoice.quantity = quantity;
  }

  void changeDiscount(double discount) {
    saveHistory();
    invoice.discount = discount;
  }

  void changeCustomer(String name) {
    saveHistory();
    invoice.customerName = name;
  }

  void undo() {
    if (_history.isEmpty) return;

    final previous = _history.removeLast();

    invoice.customerName = previous['customerName'];
    invoice.quantity = previous['quantity'];
    invoice.unitPrice = previous['unitPrice'];
    invoice.discount = previous['discount'];
  }
}

void main() {
  final invoice = Invoice(customerName: 'Ahmed', quantity: 2, unitPrice: 100);

  final editor = InvoiceEditor(invoice);

  editor.changeQuantity(5);
  editor.changeDiscount(10);

  print(invoice.total); // 450.0

  editor.undo();

  print(invoice.total); // 500.0
}
