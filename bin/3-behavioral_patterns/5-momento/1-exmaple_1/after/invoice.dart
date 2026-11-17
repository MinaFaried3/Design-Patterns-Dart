class InvoiceMemento {
  final String _customerName;
  final int _quantity;
  final double _unitPrice;
  final double _discount;

  const InvoiceMemento._({
    required this._customerName,
    required this._quantity,
    required this._unitPrice,
    required this._discount,
  });
}

class Invoice {
  String _customerName;
  int _quantity;
  double _unitPrice;
  double _discount;

  Invoice({
    required this._customerName,
    required this._quantity,
    required this._unitPrice,
    this._discount = 0,
  });

  String get customerName => _customerName;

  int get quantity => _quantity;

  double get discount => _discount;

  double get total => _quantity * _unitPrice * (1 - _discount / 100);

  void changeQuantity(int value) {
    if (value <= 0) {
      throw ArgumentError('Invalid quantity');
    }
    _quantity = value;
  }

  void changeDiscount(double value) {
    if (!value.isFinite || value < 0 || value > 100) {
      throw ArgumentError('Invalid discount');
    }
    _discount = value;
  }

  void changeCustomer(String value) {
    if (value.trim().isEmpty) {
      throw ArgumentError('Invalid customer');
    }
    _customerName = value;
  }

  // Create snapshot
  InvoiceMemento save() {
    return InvoiceMemento._(
      customerName: _customerName,
      quantity: _quantity,
      unitPrice: _unitPrice,
      discount: _discount,
    );
  }

  // Restore snapshot
  void restore(InvoiceMemento memento) {
    _customerName = memento._customerName;
    _quantity = memento._quantity;
    _unitPrice = memento._unitPrice;
    _discount = memento._discount;
  }
}

class InvoiceHistory {
  final Invoice invoice;

  final List<InvoiceMemento> _undoStack = [];
  final List<InvoiceMemento> _redoStack = [];

  InvoiceHistory(this.invoice);

  void execute(void Function() action) {
    final previousState = invoice.save();

    try {
      action();
    } catch (_) {
      invoice.restore(previousState);
      rethrow;
    }

    _undoStack.add(previousState);

    // New change invalidates redo history.
    _redoStack.clear();
  }

  void undo() {
    if (_undoStack.isEmpty) return;

    final previousState = _undoStack.removeLast();

    // Preserve current state for redo.
    _redoStack.add(invoice.save());

    invoice.restore(previousState);
  }

  void redo() {
    if (_redoStack.isEmpty) return;

    final nextState = _redoStack.removeLast();

    // Preserve current state for undo.
    _undoStack.add(invoice.save());

    invoice.restore(nextState);
  }

  bool get canUndo => _undoStack.isNotEmpty;

  bool get canRedo => _redoStack.isNotEmpty;
}

void main() {
  final invoice = Invoice(customerName: 'Ahmed', quantity: 2, unitPrice: 100);

  final history = InvoiceHistory(invoice);

  print('Initial: ${invoice.total}'); // 200

  // Change quantity.
  history.execute(() {
    invoice.changeQuantity(5);
  });

  print('After quantity: ${invoice.total}'); // 500

  // Apply discount.
  history.execute(() {
    invoice.changeDiscount(10);
  });

  print('After discount: ${invoice.total}'); // 450

  // Undo discount.
  history.undo();

  print('Undo discount: ${invoice.total}'); // 500

  // Undo quantity.
  history.undo();

  print('Undo quantity: ${invoice.total}'); // 200

  // Redo quantity.
  history.redo();

  print('Redo quantity: ${invoice.total}'); // 500

  // Redo discount.
  history.redo();

  print('Redo discount: ${invoice.total}'); // 450
}
