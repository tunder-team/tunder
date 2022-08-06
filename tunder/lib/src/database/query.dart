import 'dart:async';
import 'dart:mirrors';

import 'package:inflection3/inflection3.dart';
import 'package:tunder/src/database/operations/contracts/count_operation.dart';
import 'package:tunder/src/database/operations/contracts/insert_operation.dart';
import 'package:tunder/src/database/operations/contracts/query_operation.dart';
import 'package:tunder/src/database/operations/contracts/update_operation.dart';
import 'package:tunder/src/exceptions/record_not_found_exception.dart';
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
  List<Where> wheres = [];

  QueryOperation get _operation => QueryOperation.forDatabase(DB.driver);

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

  Future<int> insert(Map<String, dynamic> row) =>
      InsertOperation.forDatabase(DB.driver).process(this, row);
  Future<int> update(Map<String, dynamic> row) =>
      UpdateOperation.forDatabase(DB.driver).process(this, row);

  Query<T> select(List<String> columns) {
    this.columns = columns;

    return this;
  }

  Future<List<T>> all() => get();

  Future<T> findBy(column, value) => this
      .add(where(column).equals(value))
      .first()
      .catchError((e) => throw RecordNotFoundException());

  Future<T?> findByOrNull(column, value) =>
      this.add(where(column).equals(value)).firstOrNull();

  Future<T> find(value) => findBy('id', value);

  Future<T?> findOrNull(value) => findByOrNull('id', value);

  Future<T> first() => get().then((result) => result.first);

  Future<T?> firstOrNull() =>
      get().then((result) => result.isEmpty ? null : result.first);

  Paginator<T> paginate({
    int page = 1,
    int perPage = 10,
  }) =>
      Paginator(
        query: this,
        page: page,
        perPage: perPage,
      );

  // TODO: refactor: delegate this to query operation and use data objects instead of strings
  Query<T> orderBy(String column, [String direction = 'asc']) {
    _orderBy = 'ORDER BY "$column" ${direction.toUpperCase()}';

    return this;
  }

  Future<List<T>> get() async => _transformRows(await _operation.process(this));

  Future<int> count() => CountOperation.forDatabase(DB.driver).process(this);

  String _inferTableNameVia(type) {
    final modelClass = reflectClass(type);
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
    wheres.add(where);
    return this;
  }

  Query<T> and(Where where) => add(where..boolOperator = 'AND');

  Query<T> or(Where where) => add(where..boolOperator = 'OR');

  Where where(String column) {
    final _where = Where(column);
    add(_where);

    return _where;
  }

  Where orWhere(String column) {
    final _where = Where(column);
    or(_where);

    return _where;
  }

  getOrderBy() => _orderBy;

  String toSql() => _operation.toSql(this);
}
