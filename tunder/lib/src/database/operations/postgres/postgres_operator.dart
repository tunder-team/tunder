import 'package:tunder/database.dart';
import 'package:tunder/src/database/operations/contracts/database_operator.dart';
import 'package:tunder/src/database/operations/postgres/postgres_count_operation.dart';
import 'package:tunder/src/database/operations/postgres/postgres_delete_operation.dart';
import 'package:tunder/src/database/operations/postgres/postgres_drop_all_tables_operation.dart';
import 'package:tunder/src/database/operations/postgres/postgres_drop_table_operation.dart';
import 'package:tunder/src/database/operations/postgres/postgres_insert_operation.dart';
import 'package:tunder/src/database/operations/postgres/postgres_query_operation.dart';
import 'package:tunder/src/database/operations/postgres/postgres_update_operation.dart';
import 'package:tunder/tunder.dart';

class PostgresDatabaseOperator implements DatabaseOperator {
  final Application app;

  const PostgresDatabaseOperator(this.app);

  @override
  Future<int> count(Query query) => PostgresCountOperation().process(query);

  @override
  Future<int> delete(Query query) => PostgresDeleteOperation().process(query);

  @override
  Future<int> drop(String table) => PostgresDropTableOperation().drop(table);

  @override
  Future<int> dropIfExists(String table) =>
      PostgresDropTableOperation().dropIfExists(table);

  @override
  Future<int> dropAllTables() => PostgresDropAllTablesOperation().execute();

  @override
  Future insert(MappedRow row, {required String table}) =>
      PostgresInsertOperation().process(table, row);

  @override
  Future<List<MappedRow>> process(Query query) =>
      PostgresQueryOperation().process(query);

  @override
  String toSql(Query query) => PostgresQueryOperation().toSql(query);

  @override
  Future<int> update(Query query, MappedRow row) =>
      PostgresUpdateOperation().process(query, row);
}
