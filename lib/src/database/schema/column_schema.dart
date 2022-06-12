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
  bool _primary = false;
  bool? _nullable;
  bool? _unique;
  bool _unsigned = false;
  bool _autoIncrement = false;
  dynamic _defaultValue;
  int _length;

  ColumnSchema(this.name, this.datatype, this.table, [this._length = 255]);

  ColumnSchema get primary => this
    .._primary = true
    ..notNull;
  ColumnSchema get notNull => this.._nullable = false;
  ColumnSchema get nullable => this.._nullable = true;
  ColumnSchema get unique => this.._unique = true;
  ColumnSchema get notUnique => this.._unique = false;
  ColumnSchema get unsigned => this.._unsigned = true;
  ColumnSchema get autoIncrement => this.._autoIncrement = true;
  ColumnSchema defaultValue(value) => this.._defaultValue = value;

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

    if (_nullable == true) changes.add('ALTER COLUMN "$name" DROP NOT NULL');
    if (_nullable == false) changes.add('ALTER COLUMN "$name" SET NOT NULL');

    changes.add('ALTER COLUMN "$name" TYPE ${_parsedDatatype}');

    if (_unique == true)
      changes.add(
          'ADD CONSTRAINT "${table.name}_${name}_unique" UNIQUE ("$name")');
    if (_unique == false)
      changes.add('DROP CONSTRAINT "${table.name}_${name}_unique"');

    return changes;
  }

  String toString() {
    String sql = '"$name" $_parsedDatatype'.removeExtraSpaces;

    if (_primary && datatype == DataType.integer)
      sql = '"$name" BIGSERIAL PRIMARY KEY';
    if (_unique == true) sql += ' UNIQUE';
    if (_autoIncrement) sql += ' AUTO_INCREMENT';
    sql += _nullable == true ? ' NULL' : ' NOT NULL';
    if (_defaultValue != null) sql += ' DEFAULT ${_defaultValue}';
    if (_unsigned) sql += ' CHECK ("$name" >= 0)';

    return sql;
  }

  String get _parsedDatatype {
    if (table.connection.driver == DB.drivers.postgres)
      return _postgresDatatype;

    throw UnknownDatabaseDriverException(DB.driver);
  }

  String get _postgresDatatype {
    switch (datatype) {
      case DataType.integer:
        return 'INTEGER';
      case DataType.string:
        return 'VARCHAR($_length)';
      case DataType.text:
        return 'TEXT';
      case DataType.timestamp:
        return 'TIMESTAMP';
      case DataType.boolean:
        return 'BOOLEAN';
      case DataType.double:
        return 'DOUBLE PRECISION';
    }
    throw UnknownDataTypeException(datatype, DB.drivers.postgres);
  }
}
