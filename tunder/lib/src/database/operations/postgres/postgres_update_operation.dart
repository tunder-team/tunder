import 'package:tunder/database.dart';
import 'package:tunder/src/database/operations/contracts/update_operation.dart';
import 'package:tunder/src/database/operations/postgres/mixins/escapable.dart';
import 'package:tunder/src/database/operations/postgres/mixins/where_compiler.dart';

class PostgresUpdateOperation
    with WhereCompiler, ValueTransformer
    implements UpdateOperation {
  @override
  Future<int> process(Query query, Map<String, dynamic> row) async {
    return DB.execute(toSql(query, row));
  }

  @override
  String toSql(Query query, Map<String, dynamic> row) {
    final values = _values(row);
    final wheres = compileWhereClauses(query.wheres);
    final select = compileSelectedColumns(query.table, query.columns);
    final columns = select == '*' ? '' : 'returning $select';

    final sql = wheres.isEmpty
        ? 'update ${query.table} set $values $columns'
        : 'update ${query.table} set $values where $wheres $columns';

    return sql.trim();
  }

  String _values(Map<String, dynamic> row) {
    return row.entries
        .map((field) => '"${field.key}" = ${transform(field.value)}')
        .join(', ');
  }
}
