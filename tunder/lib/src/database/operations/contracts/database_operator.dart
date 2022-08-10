import 'package:tunder/database.dart';
import 'package:tunder/src/database/operations/postgres/postgres_operator.dart';
import 'package:tunder/utils.dart';

abstract class DatabaseOperator {
  factory DatabaseOperator.forDriver(Symbol driver) {
    if (driver == #postgres) return app(PostgresDatabaseOperator);

    throw UnsupportedError('Driver [${driver.name}] is not supported');
  }

  Future insert(MappedRow row, {required String table});
  Future<int> count(Query query);
  Future<int> delete(Query query);
  Future<int> drop(String table);
  Future<int> dropIfExists(String table);
  Future<int> dropAllTables();
  Future<int> update(Query query, MappedRow row);
  Future<List<MappedRow>> process(Query query);
  String toSql(Query query);
}
