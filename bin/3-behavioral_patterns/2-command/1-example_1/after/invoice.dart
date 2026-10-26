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

abstract class Command {
  void execute();

  void undo();
}

class UpdateQuantityCommand extends Command {
  final Invoice invoice;
  final int newQuantity;
  late int previousQuantity;

  UpdateQuantityCommand(this.invoice, this.newQuantity);

  @override
  void execute() {
    if (newQuantity <= 0 || newQuantity != newQuantity.truncateToDouble()) {
      throw ArgumentError('Invalid quantity');
    }

    previousQuantity = invoice.quantity;
    invoice.quantity = newQuantity;
  }

  @override
  void undo() {
    invoice.quantity = previousQuantity;
  }
}

class ApplyDiscountCommand extends Command {
  final Invoice invoice;
  final double newDiscount;
  late double previousDiscount;

  ApplyDiscountCommand(this.invoice, this.newDiscount);

  @override
  void execute() {
    if (newDiscount < 0 || newDiscount > 100) {
      throw ArgumentError('Invalid discount');
    }

    previousDiscount = invoice.discountPercent;
    invoice.discountPercent = newDiscount;
  }

  @override
  void undo() {
    invoice.discountPercent = previousDiscount;
  }
}

class InvoiceEditor {
  final List<Command> undoStack = [];
  final List<Command> redoStack = [];
  

  void execute(Command command) {
    command.execute();
    undoStack.add(command);
    redoStack.clear();
  }

  void undo() {
    if (undoStack.isEmpty) return;
    final command = undoStack.removeLast();
    command.undo();
    redoStack.add(command);
  }

  void redo() {
    if (redoStack.isEmpty) return;
    final command = redoStack.removeLast();
    command.execute();
    undoStack.add(command);
  }
}

void main() {
  final invoice = Invoice(quantity: 2, unitPrice: 100);

  final manager = InvoiceEditor();

  // Execute first command
  manager.execute(UpdateQuantityCommand(invoice, 3));

  print(invoice.total); // 300.0

  // Execute second command
  manager.execute(ApplyDiscountCommand(invoice, 10));

  print(invoice.total); // 270.0

  // Undo discount
  manager.undo();

  print(invoice.total); // 300.0

  // Undo quantity
  manager.undo();

  print(invoice.total); // 200.0

  // Redo quantity
  manager.redo();

  print(invoice.total); // 300.0
}
