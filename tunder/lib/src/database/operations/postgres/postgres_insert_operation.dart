import 'package:tunder/database.dart';
import 'package:tunder/src/database/operations/contracts/insert_operation.dart';

class PostgresInsertOperation implements InsertOperation {
  @override
  Future<int> process(Query query, Map<String, dynamic> row) async {
    final columns = _columns(row);
    final values = _values(row);

    return DB.execute(
      'insert into ${query.table} ($columns) values ($values)',
    );
  }

  String _columns(Map<String, dynamic> row) {
    return row.keys.map((column) => '"$column"').join(', ');
  }

  String _values(Map<String, dynamic> row) {
    return row.values.map(_escape).join(', ');
  }

  String _escape(value) {
    if (value is DateTime) return "'${value.toIso8601String()}'";
    if (value is num) return '$value';
    if (value is bool) return value ? 'true' : 'false';

    return "'$value'";
  }
}
