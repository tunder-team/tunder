import 'package:tunder/database.dart';
import 'package:tunder/src/database/schema/postgres_schema_processor.dart';
import 'package:tunder/src/database/schema/table_schema.dart';
import 'package:tunder/src/exceptions/unknown_database_driver_exception.dart';

abstract class SchemaProcessor {
  factory SchemaProcessor.forDatabase(Symbol driver) {
    switch (driver) {
      case DatabaseDriver.postgres:
        return PostgresSchemaProcessor();
    }
    throw UnknownDatabaseDriverException(driver);
  }

  String createSql(TableSchema table);
}
