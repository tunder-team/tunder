import 'package:tunder/extensions.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/database/operations/postgres/postgres_query_operation.dart';

abstract class QueryOperation {
  factory QueryOperation.forDatabase(Symbol driver) {
    switch (driver) {
      case DatabaseDriver.postgres:
        return PostgresQueryOperation();
      default:
        throw UnsupportedError(
            'Query operation not implemented for driver [${driver.name}]');
    }
  }

  Future<List<MappedRow>> process(Query query);
  String toSql(Query query);
}
