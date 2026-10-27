// AFTER: The facade names the application task and coordinates subsystems.

// 1. SUBSYSTEMS: All operations are in memory.
class StockRepository {
  Map<String, int> read() => {'Pen': 10, 'Book': 5};
}

class ReportRenderer {
  String render(Map<String, int> rows) =>
      rows.entries.map((e) => '${e.key}: ${e.value}').join('\n');
}

class ReportArchive {
  final Map<String, String> _reports = {};
  String save(String content) {
    final id = 'REPORT-${_reports.length + 1}';
    _reports[id] = content;
    return id;
  }

  String? find(String id) => _reports[id];
}

class ReportDelivery {
  String send(String recipient, String reportId) =>
      'Sent $reportId to $recipient';
}

// 2. FACADE
class StockReportFacade {
  final StockRepository repository;
  final ReportRenderer renderer;
  final ReportArchive archive;
  final ReportDelivery delivery;

  StockReportFacade(
    this.repository,
    this.renderer,
    this.archive,
    this.delivery,
  );

  String exportAndSend(String recipient) {
    final rows = repository.read();
    final content = renderer.render(rows);
    final id = archive.save(content);
    return delivery.send(recipient, id);
  }
}

// 3. USAGE
void main() {
  final archive = ReportArchive();
  final reports = StockReportFacade(
    StockRepository(),
    ReportRenderer(),
    archive,
    ReportDelivery(),
  );
  print(reports.exportAndSend('Mona'));
  assert(archive.find('REPORT-1') == 'Pen: 10\nBook: 5');
  print('Archived content: ${archive.find('REPORT-1')}');
}
