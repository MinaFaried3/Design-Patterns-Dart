// AFTER: Construction rules stay in the builder; values stay parameters.

// 1. PRODUCT
class SelectQuery {
  final String sql;
  final List<Object> parameters;
  SelectQuery(this.sql, List<Object> values)
    : parameters = List.unmodifiable(values);
}

// 2. BUILDER: Supports a deliberately small SELECT grammar.
class SelectQueryBuilder {
  final String table;
  final List<String> _conditions = [];
  final List<Object> _parameters = [];
  int? _limit;

  SelectQueryBuilder(this.table) {
    _validateIdentifier(table);
  }

  void whereEquals(String column, Object value) {
    _validateIdentifier(column);
    _conditions.add('$column = ?');
    _parameters.add(value);
  }

  void limit(int count) {
    if (count <= 0) throw ArgumentError.value(count, 'count');
    _limit = count;
  }

  SelectQuery build() {
    final sql = StringBuffer('SELECT * FROM $table');
    if (_conditions.isNotEmpty) {
      sql.write(' WHERE ${_conditions.join(' AND ')}');
    }
    if (_limit != null) sql.write(' LIMIT $_limit');
    return SelectQuery(sql.toString(), _parameters);
  }

  static void _validateIdentifier(String value) {
    if (!RegExp(r'^[a-z_]+$').hasMatch(value)) {
      throw ArgumentError('Use lowercase identifiers: $value');
    }
  }
}

// 3. USAGE
void main() {
  final builder = SelectQueryBuilder('inventory')
    ..whereEquals('warehouse', 'CAIRO')
    ..whereEquals('quantity', 10)
    ..limit(5);
  final query = builder.build();
  builder.whereEquals('status', 'active');

  assert(query.parameters.length == 2);
  assert(
    query.sql ==
        'SELECT * FROM inventory WHERE warehouse = ? AND quantity = ? LIMIT 5',
  );
  print(query.sql);
  print(query.parameters);
}
