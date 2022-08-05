import 'package:tunder/database.dart';
import 'package:tunder/src/database/schema/column_schema.dart';
import 'package:tunder/src/database/schema/constraints.dart';
import 'package:tunder/src/database/schema/index_schema.dart';
import 'package:tunder/src/database/schema/postgres_schema_processor.dart';
import 'package:tunder/src/database/schema/table_schema.dart';
import 'package:tunder/src/exceptions/unknown_database_driver_exception.dart';

abstract class SchemaProcessor {
  factory SchemaProcessor.forDatabase(Symbol driver) {
    switch (driver) {
      case DatabaseDriver.postgres:
        return PostgresSchemaProcessor();
      default:
        throw UnknownDatabaseDriverException(driver);
    }
  }

  String createSql(TableSchema table);
  String updateSql(TableSchema table);
  String renameSql(String from, String to);
}

mixin SchemaProcessorMethods {
  var isColumn = (column) => column is ColumnSchema;
  var isIndex = (column) => column is IndexSchema;
  var isUniqueConstraint = (column) => column is UniqueConstraint;
}
