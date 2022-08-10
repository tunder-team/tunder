import 'package:tunder/database.dart';
import 'package:tunder/src/database/operations/postgres/mixins/where_compiler.dart';

class PostgresDeleteOperation with WhereCompiler {
  Future<int> process(Query query) async {
    return DB.execute(toSql(query));
  }

  String toSql(Query query) {
    final wheres = compileWhereClauses(query.wheres);

    return wheres.isEmpty
        ? 'delete from ${query.table}'
        : 'delete from ${query.table} where $wheres';
  }
}
