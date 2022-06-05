import 'dart:mirrors';

import 'package:inflection3/inflection3.dart';
import 'package:tunder/tunder.dart';
import 'package:tunder/database.dart';
import 'package:tunder/utils.dart';

class Query<T> {
  late Application container;
  late String table;
  int? offset;
  int? limit;
  List<String> columns = ['*'];

  late bool _shouldMap = false;
  String? _orderBy;
  List<Where> _wheres = [];

  DatabaseConnection? _connectionInstance;
  DatabaseConnection get _connection => _connectionInstance ??=
      container.get<DatabaseConnection>(DatabaseConnection);

  Query([tableNameOrModelClass]) {
    container = app();

    if (tableNameOrModelClass is String) {
      this.table = tableNameOrModelClass;
      return;
    }

    if (tableNameOrModelClass == null) {
      _shouldMap = true;
      this.table = _inferTableNameVia(T);
      return;
    }

    this.table = _inferTableNameVia(tableNameOrModelClass);
  }

  Query<T> select(List<String> columns) {
    this.columns = columns;

    return this;
  }

  Future<List<T>> all() {
    return get();
  }

  Paginator<T> paginate({
    int page = 1,
    int perPage = 10,
  }) {
    return Paginator(
      query: this,
      page: page,
      perPage: perPage,
    );
  }

  Query<T> orderBy(String column, [String direction = 'asc']) {
    _orderBy = 'ORDER BY "$column" ${direction.toUpperCase()}';

    return this;
  }

  Future<List<T>> get() async {
    return execute(toSql());
  }

  Future<int> count() async {
    var rows = await executeRaw(toSqlCount());
    return rows.first['total'];
  }

  Future<List<MappedRow>> executeRaw(String sql) {
    return _connection.query(sql);
  }

  Future<List<T>> execute(String sql) async {
    return _transformRows<T>(await _connection.query(sql));
  }

  String _inferTableNameVia(type) {
    var modelClass = reflectClass(type);
    return modelClass.simpleName.name.titleCase
        .split(' ')
        .map((word) => word.toLowerCase())
        .map(pluralize)
        .join(' ')
        .snakeCase;
  }

  List<M> _transformRows<M>(List<MappedRow> rows) {
    if (!_shouldMap) return rows as List<M>;
    return rows.map((r) => (app(M) as Model).fill(r) as M).toList();
  }

  Query<T> add(Where where) {
    _wheres.add(where);
    return this;
  }

  Query<T> and(Where where) {
    return add(where..boolOperator = 'AND');
  }

  Query<T> or(Where where) {
    return add(where..boolOperator = 'OR');
  }

  Where where(String column) {
    var _where = Where(column);
    add(_where);

    return _where;
  }

  Where orWhere(String column) {
    var _where = Where(column);
    or(_where);

    return _where;
  }

  String toSql() {
    String wheres = _compileWheres();
    String columns = _compileColumns();

    var sql = wheres.isEmpty
        ? 'SELECT $columns FROM "$table"'
        : 'SELECT $columns FROM "$table" WHERE $wheres';

    if (_orderBy != null) sql += ' $_orderBy';
    if (offset != null) sql += ' OFFSET $offset';
    if (limit != null) sql += ' LIMIT $limit';

    return sql;
  }

  String toSqlCount() {
    String wheres = _compileWheres();
    String countQuery = 'SELECT COUNT(*) AS TOTAL FROM "$table"';

    return wheres.isEmpty ? countQuery : '$countQuery WHERE $wheres';
  }

  String _compileColumns() {
    if (columns.length == 1 && columns.first == '*') return '*';

    return columns.map((c) => '"$table"."$c"').join(', ');
  }

  String _compileWheres() {
    var sql = _wheres.map((w) => w.toSql()).join(' ').trim();
    if (sql.startsWith('AND ') || sql.startsWith('(AND'))
      sql = sql.replaceFirst('AND ', '');
    if (sql.startsWith('OR ') || sql.startsWith('(OR'))
      sql = sql.replaceFirst('OR ', '');

    return sql.trim();
  }
}
