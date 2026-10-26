class Invoice {
  int quantity;
  double unitPrice;
  double discountPercent;

  Invoice({
    required this.quantity,
    required this.unitPrice,
    this.discountPercent = 0,
  });

  double get total {
    final subtotal = quantity * unitPrice;
    return subtotal * (1 - discountPercent / 100);
  }
}

class InvoiceEditor {
  final Invoice invoice;

  InvoiceEditor(this.invoice);

  void executeAction(String action, double value) {
    switch (action) {
      case 'updateQuantity':
        if (value <= 0 || value != value.truncateToDouble()) {
          throw ArgumentError('Invalid quantity');
        }

        invoice.quantity = value.toInt();
        break;

      case 'applyDiscount':
        if (value < 0 || value > 100) {
          throw ArgumentError('Invalid discount');
        }

        invoice.discountPercent = value;
        break;

      default:
        throw Exception('Unknown action');
    }

    print('Invoice total: ${invoice.total}');
  }
}

void main() {
  final invoice = Invoice(quantity: 2, unitPrice: 100);

  final editor = InvoiceEditor(invoice);

  editor.executeAction('updateQuantity', 3);
  editor.executeAction('applyDiscount', 10);

  print(invoice.total); // 270.0
}
