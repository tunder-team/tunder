import 'package:tunder/database.dart';
import 'package:tunder/src/database/schema/column_schema.dart';
import 'package:tunder/src/database/schema/constraints.dart';
import 'package:tunder/src/database/schema/data_type.dart';
import 'package:tunder/src/database/schema/index_schema.dart';
import 'package:tunder/src/database/schema/renames.dart';

class TableSchema {
  final String name;
  final DatabaseConnection connection;
  final List<ColumnSchema> columns = [];
  final List<IndexSchema> indexes = [];
  final List<dynamic> droppings = [];
  final List<Constraint> constraints = [];
  final List<Rename> renames = [];

  TableSchema(this.name, this.connection);

  /**
   * Generates a string primary key column with 16 characters long.
   */
  void stringId([String columnName = 'id']) =>
      string(columnName).primary().notNullable()..length = 16;

  /**
   * Generates a serial big integer primary key column with auto incement.
   */
  void id([String columnName = 'id']) =>
      bigInteger(columnName).primary().notNullable().autoIncrement();

  ColumnSchema string(String name, [int length = 255]) =>
      _add(name, DataType.string, length);

  ColumnSchema text(String name) => _add(name, DataType.text);
  ColumnSchema double(String name) => _add(name, DataType.double);

  ColumnSchema integer(String name) => _add(name, DataType.integer);
  ColumnSchema bigInteger(String name) => _add(name, DataType.bigInteger);
  ColumnSchema smallInteger(String name) => _add(name, DataType.smallInteger);
  ColumnSchema decimal(String name, {int precision = 12, int scale = 2}) =>
      _add(name, DataType.decimal)
        ..precision = precision
        ..scale = scale;
  ColumnSchema timestamp(String name) => _add(name, DataType.timestamp);
  ColumnSchema dateTime(String name) => _add(name, DataType.dateTime);
  ColumnSchema date(String name) => _add(name, DataType.date);
  ColumnSchema boolean(String name) => _add(name, DataType.boolean);
  ColumnSchema json(String name) => _add(name, DataType.json);
  ColumnSchema jsonb(String name) => _add(name, DataType.jsonb);

  void timestamps({
    String? createdColumn,
    String? updatedColumn,
    bool camelCase = false,
  }) =>
      this
        .._add(
                camelCase
                    ? (createdColumn ?? 'createdAt')
                    : (createdColumn ?? 'created_at'),
                DataType.timestamp)
            .notNullable()
            .useCurrent()
        .._add(
                camelCase
                    ? (updatedColumn ?? 'updatedAt')
                    : (updatedColumn ?? 'updated_at'),
                DataType.timestamp)
            .notNullable()
            .useCurrent();

  void softDeletes([String name = 'deleted_at']) =>
      _add(name, DataType.timestamp).nullable();

  void index({required String column, String? name = null}) {
    indexes.add(IndexSchema(column: column, table: this.name, name: name));
  }

  void unique(List<String> columns, {String? name}) => constraints
      .add(UniqueConstraint(columns: columns, table: this.name, name: name));

  void primary(List<String> columns, {String? name}) => constraints
      .add(PrimaryConstraint(columns: columns, table: this.name, name: name));

  void dropColumn(String column) {
    droppings.add(ColumnSchema(column, DataType.string, this));
  }

  void dropColumns(List<String> columns) {
    columns.forEach((column) => dropColumn(column));
  }

  void dropTimestamps({
    String? createdColumn,
    String? updatedColumn,
    bool camelCase = false,
  }) {
    dropColumns([
      createdColumn ?? (camelCase ? 'createdAt' : 'created_at'),
      updatedColumn ?? (camelCase ? 'updatedAt' : 'updated_at'),
    ]);
  }

  void dropSoftDeletes([String name = 'deleted_at']) => dropColumn(name);

  void dropIndex({String? column, String? name}) {
    droppings
        .add(IndexSchema(column: column ?? '', table: this.name, name: name));
  }

  void dropIndexes(
      {List<String> columns = const [], List<String> names = const []}) {
    columns.forEach((column) => dropIndex(column: column));
    names.forEach((name) => dropIndex(name: name));
  }

  void dropUnique({String? column, String? name}) {
    name ??= '${this.name}_${column!}_unique';

    droppings.add(UniqueConstraint(
      columns: column != null ? [column] : [],
      table: this.name,
      name: name,
    ));
  }

  void dropUniques(
      {List<String> columns = const [], List<String> names = const []}) {
    columns.forEach((column) => dropUnique(column: column));
    names.forEach((name) => dropUnique(name: name));
  }

  void dropPrimary({List<String>? columns, String? name}) {
    name ??= '${this.name}_${columns!.join('_')}_pkey';
    droppings.add(
      PrimaryConstraint(table: this.name, name: name, columns: columns ?? []),
    );
  }

  void renameColumn(String from, String to) {
    renames.add(RenameColumn(from, to));
  }

  void renameIndex(String from, String to) {
    renames.add(RenameIndex(from, to));
  }

  void renamePrimary(String from, String to) {
    renames.add(RenamePrimary(from, to));
  }

  ColumnSchema _add(String name, String datatype, [int length = 255]) {
    var column = ColumnSchema(name, datatype, this, length);
    columns.add(column);

    return column;
  }

  String toString() => name;
}
