// AFTER: Report specialization and delivery implementations evolve separately.
// Deliveries are deterministic in-memory simulations.

// 1. IMPLEMENTOR CONTRACT
abstract class ReportDelivery {
  Future<String> deliver(String content);
}

class EmailDelivery implements ReportDelivery {
  final String recipient;
  final List<String> outbox = [];
  EmailDelivery(this.recipient);

  @override
  Future<String> deliver(String content) async {
    outbox.add(content);
    return 'Email to $recipient: $content';
  }
}

class ArchiveDelivery implements ReportDelivery {
  final Map<String, String> documents = {};

  @override
  Future<String> deliver(String content) async {
    final id = 'REPORT-${documents.length + 1}';
    documents[id] = content;
    return 'Archive $id: $content';
  }
}

// 2. ABSTRACTION: A useful high-level publishing workflow.
abstract class StockReport {
  final ReportDelivery delivery;
  StockReport(this.delivery);

  String compose(List<int> quantities);

  Future<String> publish(List<int> quantities) {
    if (quantities.any((quantity) => quantity < 0)) {
      throw ArgumentError('Stock cannot be negative');
    }
    return delivery.deliver(compose(List.unmodifiable(quantities)));
  }
}

// 3. REFINED ABSTRACTIONS
class SummaryReport extends StockReport {
  SummaryReport(super.delivery);

  @override
  String compose(List<int> quantities) =>
      'Total stock: ${quantities.fold(0, (total, value) => total + value)}';
}

class LowStockReport extends StockReport {
  final int threshold;
  LowStockReport(super.delivery, {this.threshold = 5});

  @override
  String compose(List<int> quantities) =>
      'Low stock: ${quantities.where((value) => value < threshold).join(', ')}';
}

// 4. USAGE: Four combinations from two report types and two backends.
Future<void> main() async {
  final email = EmailDelivery('Mona');
  final archive = ArchiveDelivery();
  final stock = [10, 2, 4];

  for (final delivery in <ReportDelivery>[email, archive]) {
    print(await SummaryReport(delivery).publish(stock));
    print(await LowStockReport(delivery).publish(stock));
  }

  assert(email.outbox.length == 2 && archive.documents.length == 2);
  assert(email.outbox[0] == archive.documents['REPORT-1']);
  assert(email.outbox[1] == archive.documents['REPORT-2']);
}
