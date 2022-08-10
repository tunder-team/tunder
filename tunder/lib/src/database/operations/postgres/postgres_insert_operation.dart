import 'package:tunder/database.dart';
import 'package:tunder/src/database/operations/postgres/mixins/value_transformer.dart';

class PostgresInsertOperation with PostgresTransformers {
  Future<int> process(String table, Map<String, dynamic> row) async {
    final columns = _columns(row);
    final values = _values(row);

    return DB.execute(
      'insert into ${table} ($columns) values ($values)',
    );
  }

  String _columns(Map<String, dynamic> row) {
    return row.keys.map((column) => '"$column"').join(', ');
  }

  String _values(Map<String, dynamic> row) {
    return row.values.map(transformValue).join(', ');
  }
}
