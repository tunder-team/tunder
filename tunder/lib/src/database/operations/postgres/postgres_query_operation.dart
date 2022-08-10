import 'package:tunder/database.dart';
import 'package:tunder/src/database/operations/postgres/mixins/where_compiler.dart';

class PostgresQueryOperation with WhereCompiler {
  late final Query query;

  Future<List<MappedRow>> process(Query query) async {
    return DB.query(toSql(query));
  }

  String toSql(Query query) {
    this.query = query;
    final wheres = compileWhereClauses(query.wheres);
    final columns = compileSelectedColumns(query.table, query.columns);
    final table = query.table;
    final _orderBy = query.getOrderBy();
    final offset = query.offset;
    final limit = query.limit;

    var sql = wheres.isEmpty
        ? 'SELECT $columns FROM "$table"'
        : 'SELECT $columns FROM "$table" WHERE $wheres';

    if (_orderBy != null) sql += ' $_orderBy';
    if (offset != null) sql += ' OFFSET $offset';
    if (limit != null) sql += ' LIMIT $limit';

    return sql;
  }
}
