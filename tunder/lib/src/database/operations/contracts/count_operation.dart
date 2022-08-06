import 'package:tunder/extensions.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/database/operations/postgres/postgres_count_operation.dart';

abstract class CountOperation {
  factory CountOperation.forDatabase(Symbol driver) {
    switch (driver) {
      case DatabaseDriver.postgres:
        return PostgresCountOperation();
      default:
        throw UnsupportedError(
            'Count operation not implemented for driver [${driver.name}]');
    }
  }

  Future<int> process(Query query);
  String toSql(Query query);
}
