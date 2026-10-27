// BEFORE: Report clients repeat a multi-step subsystem workflow.
class StockRepository {
  Map<String, int> read() => {'Pen': 10, 'Book': 5};
}

class ReportRenderer {
  String render(Map<String, int> rows) =>
      rows.entries.map((e) => '${e.key}: ${e.value}').join('\n');
}

class ReportArchive {
  final Map<String, String> reports = {};
  String save(String content) {
    final id = 'REPORT-${reports.length + 1}';
    reports[id] = content;
    return id;
  }
}

class ReportDelivery {
  String send(String recipient, String reportId) =>
      'Sent $reportId to $recipient';
}

void main() {
  final rows = StockRepository().read();
  final content = ReportRenderer().render(rows);
  final id = ReportArchive().save(content);
  print(ReportDelivery().send('Mona', id));
}
