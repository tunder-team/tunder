import 'dart:mirrors';

import 'package:inflection3/inflection3.dart';
import 'package:postgres/postgres.dart';
import 'package:tunder/tunder.dart';
import 'package:tunder/database.dart';
import 'package:tunder/utils.dart';

class Query<T extends Model<T>> {
  late Application container;
  late PostgreSQLConnection connection;
  late String table;

  List<Where> _wheres = [];
  List<String> columns = ['*'];

  Query() {
    container = app();
    connection = app(DatabaseConnection);
    table = _inferTableNameByGenericType<T>();
  }

  Query<T> select(List<String> columns) {
    this.columns = columns;

    return this;
  }

  Future<List<T>> all() {
    return get();
  }

  Future<List<T>> get() async {
    var sql = toSql();
    return execute(sql);
  }

  Future<List<T>> execute(String sql) async {
    await connection.open();

    final results = await connection.mappedResultsQuery(sql);

    return _mapResultsToModel<T>(results);
  }

  String _inferTableNameByGenericType<M>() {
    var modelClass = reflectClass(M);
    return modelClass.simpleName.name.titleCase
        .split(' ')
        .map((word) => word.toLowerCase())
        .map(pluralize)
        .join(' ')
        .snakeCase;
  }

  List<M> _mapResultsToModel<M extends Model>(
      List<Map<String, Map<String, dynamic>>> results) {
    return results
        .map((r) => r[table])
        .map((r) => (app(M) as M).fill(r!) as M)
        .toList();
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

    return wheres.isEmpty
        ? 'SELECT $columns FROM $table'
        : 'SELECT $columns FROM $table WHERE $wheres';
  }

  String _compileColumns() {
    if (columns.length == 1 && columns.first == '*') return '*';

    return columns.map((c) => "$table.$c").join(', ');
  }

  String _compileWheres() {
    var sql = _wheres.map((w) => w.toSql()).join(' ').trim();
    if (sql.startsWith('AND ')) sql = sql.substring(4);
    if (sql.startsWith('OR ')) sql = sql.substring(3);

    return sql.trim();
  }
}
