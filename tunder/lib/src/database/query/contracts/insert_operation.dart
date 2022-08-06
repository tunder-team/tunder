import 'package:tunder/database.dart';
import 'package:tunder/_common.dart';
import 'package:tunder/src/database/query/postgres_insert_operation.dart';

abstract class InsertOperation {
  factory InsertOperation.forDatabase(Symbol driver) {
    switch (driver) {
      case DatabaseDriver.postgres:
        return PostgresInsertOperation();
      default:
        throw UnimplementedError(
            'Insert processor not implemented for ${driver.name}');
    }
  }

  Future<int> process(Query query, Map<String, dynamic> row);
}
