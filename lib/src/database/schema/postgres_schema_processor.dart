import 'package:tunder/_common.dart';
import 'package:tunder/src/database/schema/column_schema.dart';
import 'package:tunder/src/database/schema/constraints.dart';
import 'package:tunder/src/database/schema/data_type.dart';
import 'package:tunder/src/database/schema/index_schema.dart';
import 'package:tunder/src/database/schema/renames.dart';
import 'package:tunder/src/database/schema/schema_processor.dart';
import 'package:tunder/src/database/schema/table_schema.dart';

class PostgresSchemaProcessor
    with SchemaProcessorMethods
    implements SchemaProcessor {
  String createSql(TableSchema table) {
    var columns = compileColumnsForCreate(table);
    var indexes = compileIndexesForCreate(table);
    var constraints = compileTableConstraintsForCreate(table);
    var createTableSql = constraints.isEmpty
        ? 'create table "$table" ($columns)'
        : 'create table "$table" ($columns, $constraints)';

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
    // if (column.isUnique == true) sql += ' unique';
    sql += _getDefaultValue(column);
    if (column.isUnsigned) sql += ' check ("$column" >= 0)';

    return sql.removeExtraSpaces.trim();
  }

  void toIdentity(c) => '"$c"';

  String compileTableConstraintsForCreate(TableSchema table) {
    return table.constraints
        .map((constraint) {
          if (constraint is UniqueConstraint)
            return compileUniqueConstraint(constraint, withColumns: true);
          if (constraint is PrimaryConstraint)
            return compilePrimaryConstraint(constraint, withColumns: true);
          if (constraint is CheckConstraint)
            return compileCheckConstraint(constraint);
          if (constraint is ForeignKeyConstraint)
            return compileForeignConstraint(constraint);

          return compileConstraint(constraint);
        })
        .join(', ')
        .removeExtraSpaces
        .trim();
  }

  String compileConstraintsForCreate(ColumnSchema column) {
    var primaryConstraint = column.isPrimary
        ? compilePrimaryConstraint(
            column.constraints.whereType<PrimaryConstraint>().first)
        : '';
    var notNullConstraint = column.isNotNullable ? 'not null' : '';
    var nullConstraint = column.isNullable ? 'null' : '';
    var uniqueConstraint = column.isUnique
        ? compileUniqueConstraint(
            column.constraints.whereType<UniqueConstraint>().first)
        : '';
    var foreignConstraint = column.hasForeignKey
        ? compileForeignConstraint(column.foreignKey!, inLine: true)
        : '';
    var checkConstraint = column.constraints
        .whereType<CheckConstraint>()
        .map(compileCheckConstraint)
        .join(', ');

    return ' $primaryConstraint $notNullConstraint $nullConstraint $uniqueConstraint $foreignConstraint $checkConstraint'
        .removeExtraSpaces;
  }

  String compileConstraint(Constraint constraint) {
    var constraintSql = constraint.name != null
        ? ' constraint "${constraint.name}" ${constraint.type}'
        : ' ${constraint.type}';

    if (constraint.columns.isNotEmpty) {
      var columns = constraint.columns.map(toIdentity).join(', ');
      return ' $constraintSql ($columns)';
    }

    if (constraint.expression != null)
      return ' $constraintSql (${constraint.expression})';

    return ' $constraintSql';
  }

  String compileUniqueConstraint(
    UniqueConstraint constraint, {
    bool withColumns = false,
  }) {
    var columns =
        withColumns ? constraint.columns.map(toIdentity).join(', ') : null;
    var name = constraint.name ??
        '${constraint.table}_${constraint.columns.join('_')}_unique';

    return withColumns
        ? 'constraint "$name" unique ($columns)'
        : 'constraint "$name" unique';
  }

  String compilePrimaryConstraint(
    PrimaryConstraint constraint, {
    bool withColumns = false,
  }) {
    var columns = constraint.columns.map(toIdentity).join(', ');
    var name = constraint.name ??
        '${constraint.table}_${constraint.columns.join('_')}_pkey';

    return withColumns
        ? 'constraint "$name" primary key ($columns)'
        : 'constraint "$name" primary key';
  }

  String compileCheckConstraint(CheckConstraint constraint) {
    var defaultName = constraint.columns.isEmpty
        ? '${constraint.table}_check'
        : '${constraint.table}_${constraint.columns.join('_')}_check';
    var name = constraint.name ?? defaultName;

    return 'constraint "$name" check (${constraint.expression})';
  }

  String compileForeignConstraint(
    ForeignKeyConstraint constraint, {
    bool inLine = false,
  }) {
    var name = constraint.name ??
        '${constraint.table}_${constraint.columns.join('_')}_fkey';

    var onDelete = constraint.onDeleteAction != null
        ? ' on delete ${constraint.onDeleteAction}'
        : '';

    var onUpdate = constraint.onUpdateAction != null
        ? ' on update ${constraint.onUpdateAction}'
        : '';

    return inLine
        ? 'constraint "$name" references "${constraint.referencedTable}"("${constraint.referencedColumn}") $onDelete $onUpdate'
            .removeExtraSpaces
        : 'constraint "$name" foreign key (${constraint.columns.map(toIdentity).join(', ')}) references "${constraint.referencedTable}"("${constraint.referencedColumn}") $onDelete $onUpdate'
            .removeExtraSpaces;
  }

  String compileColumnsForUpdate(TableSchema table) {
    List<dynamic> parsedColumns = getUpdateColumnCommands(table);
    List<String> droppings = getDroppingCommands(table);
    List<String> columnIndexes = getCreateIndexCommands(table);
    List<String> constraints = getAddConstraintCommands(table);
    List<String> renames = getRenameCommands(table);

    return [
      parsedColumns + droppings + columnIndexes + constraints + renames,
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
    return table.constraints.map(compileConstraintForUpdate).toList();
  }

  List<String> getRenameCommands(TableSchema table) {
    return table.renames.map((rename) {
      if (rename is RenameIndex)
        return 'alter index "${rename.from}" rename to "${rename.to}"';
      if (rename is RenamePrimary)
        return 'alter table "$table" rename constraint "${rename.from}" to "${rename.to}"';

      return 'alter table "$table" rename column "${rename.from}" to "${rename.to}"';
    }).toList();
  }

  List<String> getDroppingCommands(TableSchema table) {
    List<String> droppingColumns = getDroppingColumnCommands(table);
    List<String> droppingIndexes = getDroppingIndexCommands(table);
    List<String> droppingUnique = getDroppingUniqueCommands(table);
    List<String> droppingPrimary = getDroppingPrimaryCommands(table);
    List<String> droppingChecks = getDroppingCheckCommands(table);
    List<String> droppingForeign = getDroppingForeignCommands(table);

    return droppingColumns +
        droppingIndexes +
        droppingUnique +
        droppingPrimary +
        droppingChecks +
        droppingForeign;
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

  List<String> getDroppingCheckCommands(TableSchema table) {
    var droppingCheckConstraints = table.droppings
        .whereType<CheckConstraint>()
        .map((check) => 'alter table "$table" drop constraint "${check.name}"')
        .toList();
    return droppingCheckConstraints;
  }

  List<String> getDroppingForeignCommands(TableSchema table) {
    var droppingForeignConstraints = table.droppings
        .whereType<ForeignKeyConstraint>()
        .map((foreign) =>
            'alter table "$table" drop constraint "${foreign.name}"')
        .toList();
    return droppingForeignConstraints;
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

    if (column.isNullable)
      changes.add('alter table "$table" alter column "$column" drop not null');
    if (column.isNotNullable)
      changes.add('alter table "$table" alter column "$column" set not null');

    if (column.isUnique) {
      var compiled = compileUniqueConstraint(
          column.constraints.whereType<UniqueConstraint>().first,
          withColumns: true);
      changes.add('alter table "$table" add $compiled');
    }
    if (column.isPrimary) {
      var compiled = compilePrimaryConstraint(
          column.constraints.whereType<PrimaryConstraint>().first,
          withColumns: true);
      changes.add('alter table "$table" add $compiled');
    }
    if (column.hasCheck) {
      var compiled = compileCheckConstraint(
          column.constraints.whereType<CheckConstraint>().first);
      changes.add('alter table "$table" add $compiled');
    }
    var defaultValue = _getDefaultValue(column).trim();
    if (defaultValue.isNotEmpty) {
      changes
          .add('alter table "$table" alter column "$column" set $defaultValue');
    }

    if (column.hasForeignKey) {
      var compiled = compileForeignConstraint(column.foreignKey!);
      changes.add('alter table "$table" add $compiled');
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

  String compileConstraintForUpdate(Constraint constraint) {
    // Generic constraint compilation
    var compiledConstraint = compileConstraint(constraint).trim();

    if (constraint is UniqueConstraint)
      compiledConstraint =
          compileUniqueConstraint(constraint, withColumns: true).trim();
    if (constraint is PrimaryConstraint)
      compiledConstraint =
          compilePrimaryConstraint(constraint, withColumns: true).trim();
    if (constraint is CheckConstraint)
      compiledConstraint = compileCheckConstraint(constraint).trim();
    if (constraint is ForeignKeyConstraint)
      compiledConstraint = compileForeignConstraint(constraint).trim();

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

    return column.datatype;
  }

  String _getCastFor(ColumnSchema column) {
    switch (column.datatype) {
      case DataType.integer:
        return 'using ("$column"::integer)';
      case DataType.bigInteger:
        return 'using ("$column"::bigint)';
      case DataType.smallInteger:
        return 'using ("$column"::smallint)';
      case DataType.decimal:
        return 'using ("$column"::decimal)';
      case DataType.boolean:
        return 'using ("$column"::boolean)';
      case DataType.timestamp:
      case DataType.dateTime:
        return 'using ("$column"::timestamp)';
      case DataType.date:
        return 'using ("$column"::date)';
      case DataType.json:
        return 'using ("$column"::json)';
      case DataType.jsonb:
        return 'using ("$column"::jsonb)';
    }

    return '';
  }

  @override
  String renameSql(String from, String to) {
    return 'alter table "$from" rename to "$to"';
  }
}
