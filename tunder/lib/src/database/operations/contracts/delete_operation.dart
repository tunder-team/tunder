import 'package:tunder/database.dart';
import 'package:tunder/src/database/operations/postgres/postgres_delete_operation.dart';

abstract class DeleteOperation {
  factory DeleteOperation.forDatabase(Symbol driver) {
    switch (driver) {
      case DatabaseDriver.postgres:
        return PostgresDeleteOperation();
      default:
        throw UnsupportedError(
            'Delete operation not implemented for driver [${driver.name}]');
    }
  }

  Future<int> process(Query query);
  String toSql(Query query);
}
