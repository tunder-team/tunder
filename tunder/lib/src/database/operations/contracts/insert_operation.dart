import 'package:tunder/database.dart';
import 'package:tunder/src/database/operations/postgres/postgres_insert_operation.dart';

abstract class InsertOperation {
  factory InsertOperation.forDriver(Symbol driver) {
    switch (driver) {
      case DatabaseDriver.postgres:
        return PostgresInsertOperation();
      default:
        throw UnsupportedError(
            'Insert operation not implemented for driver [${driver.name}]');
    }
  }

  Future<int> process(String table, Map<String, dynamic> row);
}
