import 'package:tunder/_common.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/database/schema/data_type.dart';
import 'package:tunder/src/database/schema/table_schema.dart';
import 'package:tunder/src/exceptions/unknown_data_type_exception.dart';
import 'package:tunder/src/exceptions/unknown_database_driver_exception.dart';

class ColumnSchema {
  final String name;
  final String datatype;
  final TableSchema table;
  bool addIndex = false;
  bool isUpdating = false;
  bool isPrimary = false;
  bool? isNullable;
  bool? isUnique;
  bool isUnsigned = false;
  bool isAutoIncrement = false;
  bool defaultsToNow = false;
  dynamic realDefaultValue;
  String rawDefaultValue = '';
  int length;
  int precision = 12;
  int scale = 2;

  ColumnSchema(this.name, this.datatype, this.table, [this.length = 255]);

  ColumnSchema get primary => this
    ..isPrimary = true
    ..notNull;
  ColumnSchema get notNull => this..isNullable = false;
  ColumnSchema get nullable => this..isNullable = true;
  ColumnSchema get unique => this..isUnique = true;
  ColumnSchema get notUnique => this..isUnique = false;
  ColumnSchema get unsigned => this..isUnsigned = true;
  ColumnSchema get autoIncrement => this..isAutoIncrement = true;
  ColumnSchema defaultValue(value) => this..realDefaultValue = value;
  ColumnSchema defaultRaw(value) => this..rawDefaultValue = value;

  ColumnSchema defaultToNow([int precision = 6]) => this
    ..defaultsToNow = true
    ..precision = precision;
  // Alias of [defaultToNow]
  ColumnSchema defaultToCurrent([int precision = 6]) => defaultToNow(precision);
  // Alias of [defaultToNow]
  ColumnSchema useCurrent([int precision = 6]) => defaultToNow(precision);

  ColumnSchema get index => this..addIndex = true;
  /**
   * Use this method to indicate that this is a column change operation.
   */
  ColumnSchema get update => this..isUpdating = true;
  /**
   * Use this method to indicate that this is a column change operation. Alias of [update].
   */
  ColumnSchema get updateTo => update;
  /**
   * Use this method to indicate that this is a column change operation. Alias of [update].
   */
  ColumnSchema get change => update;
  /**
   * Use this method to indicate that this is a column change operation. Alias of [update].
   */
  ColumnSchema get changeTo => update;

  List<String> get changes {
    final changes = <String>[];

    if (isNullable == true) changes.add('ALTER COLUMN "$name" DROP NOT NULL');
    if (isNullable == false) changes.add('ALTER COLUMN "$name" SET NOT NULL');

    changes.add('ALTER COLUMN "$name" TYPE ${_parsedDatatype}');

    if (isUnique == true)
      changes.add(
          'ADD CONSTRAINT "${table.name}_${name}_unique" UNIQUE ("$name")');
    if (isUnique == false)
      changes.add('DROP CONSTRAINT "${table.name}_${name}_unique"');

    return changes;
  }

  String toString() {
    String sql = '"$name" $_parsedDatatype'.removeExtraSpaces;

    if (isPrimary && datatype == DataType.integer)
      sql = '"$name" BIGSERIAL PRIMARY KEY';
    if (isUnique == true) sql += ' UNIQUE';
    if (isAutoIncrement) sql += ' AUTO_INCREMENT';
    sql += isNullable == true ? ' NULL' : ' NOT NULL';
    if (realDefaultValue != null) sql += ' DEFAULT ${realDefaultValue}';
    if (isUnsigned) sql += ' CHECK ("$name" >= 0)';

    return sql;
  }

  String get _parsedDatatype {
    if (table.connection.driver == DatabaseDriver.postgres)
      return _postgresDatatype;

    throw UnknownDatabaseDriverException(DB.driver);
  }

  String get _postgresDatatype {
    switch (datatype) {
      case DataType.integer:
        return 'INTEGER';
      case DataType.string:
        return 'VARCHAR($length)';
      case DataType.text:
        return 'TEXT';
      case DataType.timestamp:
        return 'TIMESTAMP';
      case DataType.boolean:
        return 'BOOLEAN';
      case DataType.double:
        return 'DOUBLE PRECISION';
    }
    throw UnknownDataTypeException(datatype, DatabaseDriver.postgres);
  }
}
