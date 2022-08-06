import 'package:tunder/database.dart';
import 'package:tunder/src/database/operations/contracts/count_operation.dart';
import 'package:tunder/src/database/operations/postgres/mixins/where_compiler.dart';

class PostgresCountOperation with WhereCompiler implements CountOperation {
  @override
  Future<int> process(Query query) async {
    final rows = await DB.query(toSql(query));
    return rows.first['total'];
  }

  @override
  String toSql(Query query) {
    String wheres = compileWhereClauses(query.wheres);
    String countQuery = 'SELECT COUNT(*) AS TOTAL FROM "${query.table}"';

    return wheres.isEmpty ? countQuery : '$countQuery WHERE $wheres';
  }
}
