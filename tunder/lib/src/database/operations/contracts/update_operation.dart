import 'package:tunder/database.dart';
import 'package:tunder/_common.dart';
import 'package:tunder/src/database/operations/postgres/postgres_update_operation.dart';

abstract class UpdateOperation {
  factory UpdateOperation.forDatabase(Symbol driver) {
    switch (driver) {
      case DatabaseDriver.postgres:
        return PostgresUpdateOperation();
      default:
        throw UnsupportedError(
            'Update operation not implemented for driver [${driver.name}]');
    }
  }

  Future<int> process(Query query, Map<String, dynamic> row);
  String toSql(Query query, Map<String, dynamic> row);
}
