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
    var createTableSql = 'create table "${table.name}" ($columns)';

    return '$createTableSql; $indexes'.trim();
  }

  String updateSql(TableSchema table) {
    var columns = compileColumnsForUpdate(table);
    // var indexes = compileIndexesForUpdate(table);

    return columns;
  }

  String compileColumnsForCreate(TableSchema table) {
    var columns = table.columns.map(_compileCreateColumn);

    return columns.join(', ');
  }

  String _compileCreateColumn(ColumnSchema column) {
    var datatype = _parseDatatype(column);
    String sql = '"${column.name}" $datatype'.removeExtraSpaces;

    if (column.isPrimary) sql = getPrimarySql(column);
    if (column.isUnique == true) sql += ' unique';
    if (column.isAutoIncrement) {
      if (column.datatype == DataType.integer)
        sql = sql.replaceAll(datatype, 'serial');
      if (column.datatype == DataType.bigInteger)
        sql = sql.replaceAll(datatype, 'bigserial');
      if (column.datatype == DataType.smallInteger)
        sql = sql.replaceAll(datatype, 'smallserial');
    }
    if (column.isNullable == true) sql += ' null';
    if (column.isNullable == false) sql += ' not null';
    sql += _getDefaultValue(column);
    if (column.isUnsigned) sql += ' check ("${column.name}" >= 0)';

    return sql;
  }

  String compileColumnsForUpdate(TableSchema table) {
    List parsedColumns = table.columns.map((column) {
      if (!column.isUpdating) {
        var createColumn = _compileCreateColumn(column);
        return ['alter table "${table.name}" add column $createColumn'];
      }

      return getChanges(column);
    }).flatten();

    var columnIndexes = table.columns
        .where((column) => column.addIndex != null)
        .map((column) => _compileCreateIndex(column.addIndex!))
        .toList();

    return [
      parsedColumns + table.droppings + columnIndexes + table.indexes,
    ].flatten().unique().join('; ');
  }

  List<String> getChanges(ColumnSchema column) {
    final changes = <String>[];
    final table = column.table;
    final parsedDatatype = _parseDatatype(column);
    final castUsing = _getCastFor(column);

    changes.add(
        'alter table "$table" alter column "$column" type $parsedDatatype $castUsing'
            .trim());
    if (column.isAutoIncrement)
      changes
        ..add(
            'create sequence "${table}_${column}_seq" owned by "${table}"."${column}"')
        ..add(
            'select setval(\'"${table}_${column}_seq"\', (select max("${column}") from "${table}"), false)');

    if (column.isNullable == true)
      changes.add('alter table "$table" alter column "$column" drop not null');
    if (column.isNullable == false)
      changes.add('alter table "$table" alter column "$column" set not null');

    if (column.isUnique == true)
      changes.add(
          'alter table "$table" add constraint "${table}_${column}_unique" unique ("$column")');
    if (column.isPrimary)
      changes.add(
          'alter table "$table" add constraint "${table}_${column}_pkey" primary key ("$column")');
    if (column.isUnique == false)
      changes.add(
          'alter table "$table" drop constraint "${table}_${column}_unique"');

    var defaultValue = _getDefaultValue(column).trim();
    if (defaultValue.isNotEmpty) {
      changes
          .add('alter table "$table" alter column "$column" set $defaultValue');
    }

    return changes;
  }

  String getPrimarySql(ColumnSchema column) {
    var columnName = '"${column.name}"';

    if (column.datatype == DataType.integer)
      return '$columnName bigserial primary key';
    if (column.datatype == DataType.string)
      return '$columnName varchar(${column.length}) primary key';

    return columnName;
  }

  String _getDefaultValue(ColumnSchema column) {
    if (column.realDefaultValue != null)
      return column.realDefaultValue is String
          ? " default '${column.realDefaultValue}'"
          : ' default ${column.realDefaultValue}';

    if (column.rawDefaultValue.isNotEmpty)
      return " default ${column.rawDefaultValue}";

    if (column.defaultsToNow)
      return ' default current_timestamp(${column.precision})';

    return '';
  }

  String compileIndexesForCreate(TableSchema table) {
    var addingIndex = (ColumnSchema column) => column.addIndex != null;
    var toIndexSchema = (ColumnSchema column) =>
        IndexSchema(column: column.name, table: table.name);
    var columnIndexes =
        table.columns.where(addingIndex).map(toIndexSchema).toList();

    var indexes = columnIndexes + table.indexes;

    return indexes.map(_compileCreateIndex).join('; ');
  }

  String _compileCreateIndex(IndexSchema index) {
    var columns = ([index.column] + index.columns).map((column) => '"$column"');

    return 'create index "${index.name}" on "${index.table}" (${columns.join(', ')})';
  }

  String _parseDatatype(ColumnSchema column) {
    switch (column.datatype) {
      case DataType.integer:
        return 'integer';
      case DataType.bigInteger:
        return 'bigint';
      case DataType.smallInteger:
        return 'smallint';
      case DataType.decimal:
        return 'decimal(${column.precision}, ${column.scale})';
      case DataType.string:
        return 'varchar(${column.length})';
      case DataType.text:
        return 'text';
      case DataType.timestamp:
      case DataType.dateTime:
        return 'timestamp';
      case DataType.date:
        return 'date';
      case DataType.boolean:
        return 'boolean';
      case DataType.double:
        return 'double precision';
      case DataType.json:
        return 'json';
      case DataType.jsonb:
        return 'jsonb';
    }

    throw UnknownDataTypeException(column.datatype, DatabaseDriver.postgres);
  }

  String _getCastFor(ColumnSchema column) {
    switch (column.datatype) {
      case DataType.integer:
        return 'using (trim("$column")::integer)';
      case DataType.bigInteger:
        return 'using (trim("$column")::bigint)';
      case DataType.smallInteger:
        return 'using (trim("$column")::smallint)';
      case DataType.decimal:
        return 'using (trim("$column")::decimal)';
      case DataType.boolean:
        return 'using (trim("$column")::boolean)';
      case DataType.timestamp:
      case DataType.dateTime:
        return 'using (trim("$column")::timestamp)';
      case DataType.date:
        return 'using (trim("$column")::date)';
      case DataType.json:
        return 'using (trim("$column")::json)';
      case DataType.jsonb:
        return 'using (trim("$column")::jsonb)';
    }

    return '';
  }
}
