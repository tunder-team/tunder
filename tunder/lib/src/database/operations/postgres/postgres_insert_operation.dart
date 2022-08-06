import 'package:tunder/database.dart';
import 'package:tunder/src/database/operations/contracts/insert_operation.dart';
import 'package:tunder/src/database/operations/postgres/mixins/escapable.dart';

class PostgresInsertOperation with ValueTransformer implements InsertOperation {
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
    return row.values.map(transform).join(', ');
  }
}
