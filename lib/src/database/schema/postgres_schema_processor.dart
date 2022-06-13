import 'package:tunder/_common.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/database/schema/column_schema.dart';
import 'package:tunder/src/database/schema/data_type.dart';
import 'package:tunder/src/database/schema/index_schema.dart';
import 'package:tunder/src/database/schema/schema_processor.dart';
import 'package:tunder/src/database/schema/table_schema.dart';
import 'package:tunder/src/exceptions/unknown_data_type_exception.dart';

class PostgresSchemaProcessor implements SchemaProcessor {
  String createSql(TableSchema table) {
    var columns = compileColumnsForCreate(table);
    var indexes = compileIndexesForCreate(table);
    var createTableSql = 'CREATE TABLE "${table.name}" ($columns)';

    return '$createTableSql; $indexes'.trim();
  }

  String compileColumnsForCreate(TableSchema table) {
    var columns = table.columns.map(_compileCreateColumn);

    return columns.join(', ');
  }

  String _compileCreateColumn(ColumnSchema column) {
    var datatype = _parseDatatype(column);
    String sql = '"${column.name}" $datatype'.removeExtraSpaces;

    if (column.isPrimary) sql = getPrimarySql(column);
    if (column.isUnique == true) sql += ' UNIQUE';
    if (column.isAutoIncrement) {
      if (column.datatype == DataType.integer)
        sql = sql.replaceAll(datatype, 'SERIAL');
      if (column.datatype == DataType.bigInteger)
        sql = sql.replaceAll(datatype, 'BIGSERIAL');
      if (column.datatype == DataType.smallInteger)
        sql = sql.replaceAll(datatype, 'SMALLSERIAL');
    }
    sql += column.isNullable == true ? ' NULL' : ' NOT NULL';
    sql += _getDefaultValue(column);
    if (column.isUnsigned) sql += ' CHECK ("${column.name}" >= 0)';

    return sql;
  }

  String getPrimarySql(ColumnSchema column) {
    var columnName = '"${column.name}"';

    if (column.datatype == DataType.integer)
      return '$columnName BIGSERIAL PRIMARY KEY';
    if (column.datatype == DataType.string)
      return '$columnName VARCHAR(${column.length}) PRIMARY KEY';

    return columnName;
  }

  String _getDefaultValue(ColumnSchema column) {
    if (column.realDefaultValue != null)
      return column.realDefaultValue is String
          ? " DEFAULT '${column.realDefaultValue}'"
          : ' DEFAULT ${column.realDefaultValue}';

    if (column.rawDefaultValue.isNotEmpty)
      return " DEFAULT ${column.rawDefaultValue}";

    if (column.defaultsToNow)
      return ' DEFAULT CURRENT_TIMESTAMP(${column.precision})';

    return '';
  }

  String compileIndexesForCreate(TableSchema table) {
    var addingIndex = (ColumnSchema column) => column.addIndex;
    var toIndexSchema = (ColumnSchema column) =>
        IndexSchema(column: column.name, table: table.name);
    var columnIndexes =
        table.columns.where(addingIndex).map(toIndexSchema).toList();

    var indexes = columnIndexes + table.indexes;

    return indexes.map(_compileCreateIndex).join('; ');
  }

  String _compileCreateIndex(IndexSchema index) {
    var columns = ([index.column] + index.columns).map((column) => '"$column"');

    return 'CREATE INDEX "${index.name}" ON "${index.table}" (${columns.join(', ')})';
  }

  String _parseDatatype(ColumnSchema column) {
    switch (column.datatype) {
      case DataType.integer:
        return 'INTEGER';
      case DataType.bigInteger:
        return 'BIGINT';
      case DataType.smallInteger:
        return 'SMALLINT';
      case DataType.decimal:
        return 'DECIMAL(${column.precision}, ${column.scale})';
      case DataType.string:
        return 'VARCHAR(${column.length})';
      case DataType.text:
        return 'TEXT';
      case DataType.timestamp:
      case DataType.dateTime:
        return 'TIMESTAMP';
      case DataType.date:
        return 'DATE';
      case DataType.boolean:
        return 'BOOLEAN';
      case DataType.double:
        return 'DOUBLE PRECISION';
      case DataType.json:
        return 'JSON';
      case DataType.jsonb:
        return 'JSONB';
    }

    throw UnknownDataTypeException(column.datatype, DatabaseDriver.postgres);
  }
}
