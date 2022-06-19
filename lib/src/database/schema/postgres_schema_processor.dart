import 'package:tunder/_common.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/database/schema/column_schema.dart';
import 'package:tunder/src/database/schema/constraints.dart';
import 'package:tunder/src/database/schema/data_type.dart';
import 'package:tunder/src/database/schema/index_schema.dart';
import 'package:tunder/src/database/schema/schema_processor.dart';
import 'package:tunder/src/database/schema/table_schema.dart';
import 'package:tunder/src/exceptions/unknown_data_type_exception.dart';

class PostgresSchemaProcessor
    with SchemaProcessorMethods
    implements SchemaProcessor {
  String createSql(TableSchema table) {
    var columns = compileColumnsForCreate(table);
    var indexes = compileIndexesForCreate(table);
    var createTableSql = 'create table "$table" ($columns)';

    return '$createTableSql; $indexes'.trimWith(';');
  }

  String updateSql(TableSchema table) {
    var columns = compileColumnsForUpdate(table);
    var indexes = compileIndexesForUpdate(table);

    return '$columns; $indexes'.trimWith(';');
  }

  String compileColumnsForCreate(TableSchema table) {
    var columns = table.columns.map(_compileCreateColumn);

    return columns.join(', ');
  }

  String _compileCreateColumn(ColumnSchema column) {
    var datatype = compileDatatype(column);
    String sql = '"$column" $datatype'.removeExtraSpaces;

    sql += compileConstraintsForCreate(column);
    if (column.isUnique == true) sql += ' unique';
    if (column.isNullable == true) sql += ' null';
    if (column.isNullable == false) sql += ' not null';
    sql += _getDefaultValue(column);
    if (column.isUnsigned) sql += ' check ("$column" >= 0)';

    return sql.removeExtraSpaces.trim();
  }

  String compileConstraintsForCreate(ColumnSchema column) {
    var primaryConstraints = compilePrimaryForCreate(column);
    // TODO:
    // var foreignConstraints = compileForeignForCreate(column);
    // var uniqueConstraints = compileUniqueForCreate(column);
    // var checkConstraints = compileCheckForCreate(column);
    // var notNullConstraints = compileNotNullForCreate(column);

    return ' $primaryConstraints'.removeExtraSpaces;
  }

  String compilePrimaryForCreate(ColumnSchema column) {
    return column.constraints.whereType<PrimaryConstraint>().isNotEmpty
        ? 'primary key'
        : '';
  }

  String compileConstraint(Constraint constraint) {
    var constraintSql = constraint.name != null
        ? ' constraint "${constraint.name}" ${constraint.type}'
        : ' ${constraint.type}';

    if (constraint.columns.isNotEmpty) {
      var columns = constraint.columns.map((c) => '"$c"').join(', ');
      return ' $constraintSql ($columns)';
    }

    if (constraint.expression != null)
      return ' $constraintSql (${constraint.expression})';

    return ' $constraintSql';
  }

  String compileColumnsForUpdate(TableSchema table) {
    List<dynamic> parsedColumns = getUpdateColumnCommands(table);
    List<String> droppings = getDroppingCommands(table);
    List<String> columnIndexes = getCreateIndexCommands(table);
    List<String> constraints = getAddConstraintCommands(table);

    return [
      parsedColumns + droppings + columnIndexes + constraints,
    ].flatten().unique().join('; ');
  }

  List<dynamic> getUpdateColumnCommands(TableSchema table) {
    return table.columns.map((column) {
      if (!column.isUpdating) {
        var createColumn = _compileCreateColumn(column);
        return ['alter table "$table" add column $createColumn'];
      }

      return getChanges(column);
    }).flatten();
  }

  List<String> getCreateIndexCommands(TableSchema table) {
    return table.columns
        .where((column) => column.addIndex != null)
        .map((column) => _compileCreateIndex(column.addIndex!))
        .toList();
  }

  List<String> getAddConstraintCommands(TableSchema table) {
    return table.constraints.map(_compileAddConstraint).toList();
  }

  List<String> getDroppingCommands(TableSchema table) {
    List<String> droppingColumns = getDroppingColumnCommands(table);
    List<String> droppingIndexes = getDroppingIndexCommands(table);
    List<String> droppingUnique = getDroppingUniqueCommands(table);
    List<String> droppingPrimary = getDroppingPrimaryCommands(table);

    return droppingColumns + droppingIndexes + droppingUnique + droppingPrimary;
  }

  List<String> getDroppingUniqueCommands(TableSchema table) {
    var droppingUniqueConstraints = table.droppings
        .where(isUniqueConstraint)
        .map(
            (unique) => 'alter table "$table" drop constraint "${unique.name}"')
        .toList();
    return droppingUniqueConstraints;
  }

  List<String> getDroppingPrimaryCommands(TableSchema table) {
    var droppingPrimaryConstraints = table.droppings
        .whereType<PrimaryConstraint>()
        .map((primary) =>
            'alter table "$table" drop constraint "${primary.name}"')
        .toList();
    return droppingPrimaryConstraints;
  }

  List<String> getDroppingIndexCommands(TableSchema table) {
    var droppingIndexes = table.droppings
        .where(isIndex)
        .map((index) => 'drop index "$index"')
        .toList();
    return droppingIndexes;
  }

  List<String> getDroppingColumnCommands(TableSchema table) {
    var droppingColumns = table.droppings
        .where(isColumn)
        .map((column) => 'alter table "$table" drop column "$column"')
        .toList();
    return droppingColumns;
  }

  List<String> getChanges(ColumnSchema column) {
    final changes = <String>[];
    final table = column.table;
    final parsedDatatype = compileDatatype(column);
    final castUsing = _getCastFor(column);

    changes.add(
        'alter table "$table" alter column "$column" type $parsedDatatype $castUsing'
            .trim());
    if (column.isAutoIncrement)
      changes
        ..add(
            'create sequence "${table}_${column}_seq" owned by "$table"."$column"')
        ..add(
            'select setval(\'"${table}_${column}_seq"\', (select max("$column") from "$table"), false)');

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

  String compileIndexesForUpdate(TableSchema table) {
    return table.indexes.map(_compileCreateIndex).join('; ');
  }

  String _compileCreateIndex(IndexSchema index) {
    var columns = ([index.column] + index.columns).map((column) => '"$column"');

    return 'create index "${index.name}" on "${index.table}" (${columns.join(', ')})';
  }

  String _compileAddConstraint(Constraint constraint) {
    var compiledConstraint = compileConstraint(constraint).trim();

    return 'alter table "${constraint.table}" add $compiledConstraint';
  }

  String compileDatatype(ColumnSchema column) {
    switch (column.datatype) {
      case DataType.integer:
        return column.isAutoIncrement && !column.isUpdating
            ? 'serial'
            : 'integer';
      case DataType.bigInteger:
        return column.isAutoIncrement && !column.isUpdating
            ? 'bigserial'
            : 'bigint';
      case DataType.smallInteger:
        return column.isAutoIncrement && !column.isUpdating
            ? 'smallserial'
            : 'smallint';
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
