// BEFORE: Every caller manually assembles SQL text and parameter order.

// 1. USAGE: Demonstration only; no database is contacted.
void main() {
  var sql = 'SELECT * FROM inventory';
  final parameters = <Object>[];
  sql += ' WHERE warehouse = ?';
  parameters.add('CAIRO');
  sql += ' AND quantity = ?';
  parameters.add(10);
  sql += ' LIMIT 5';

  print(sql);
  print(parameters);
  // Another caller must repeat these ordering and separator rules.
}
