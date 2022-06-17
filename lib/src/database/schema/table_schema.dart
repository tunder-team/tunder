import 'package:tunder/database.dart';
import 'package:tunder/src/database/schema/column_schema.dart';
import 'package:tunder/src/database/schema/data_type.dart';
import 'package:tunder/src/database/schema/index_schema.dart';

class TableSchema {
  final String name;
  final DatabaseConnection connection;
  final List<ColumnSchema> columns = [];
  final List<IndexSchema> indexes = [];
  final List<ColumnSchema> droppings = [];

  TableSchema(this.name, this.connection);

  /**
   * Generates a string primary key column with 16 characters long.
   */
  void stringId([String name = 'id']) =>
      _add(name, DataType.string).primary..length = 16;

  /**
   * Generates a serial big integer primary key column with auto incement.
   */
  void id([String name = 'id']) => _add(name, DataType.integer).primary;

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
            .notNull
            .useCurrent()
        .._add(
                camelCase
                    ? (updatedColumn ?? 'updatedAt')
                    : (updatedColumn ?? 'updated_at'),
                DataType.timestamp)
            .notNull
            .useCurrent();

  void softDeletes([String name = 'deleted_at']) =>
      _add(name, DataType.timestamp).nullable;

  void index({required String column, String? name = null}) {
    // 'CREATE INDEX $indexName ON $table ($columnName)'
    var index = IndexSchema(column: column, table: this.name, name: name);
    indexes.add(index);
  }

  void dropColumn(String column) {
    droppings.add(ColumnSchema(column, DataType.string, this));
  }

  void dropColumns(List<String> columns) {
    columns.forEach((column) => dropColumn(column));
  }

  void dropPrimary(String key) {
    throw UnimplementedError();
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

  void dropUnique(String key) {
    // droppings.add('ALTER TABLE "$name" DROP CONSTRAINT "$key"');
  }

  void dropIndex(String key) {
    // droppings.add('DROP INDEX "$key"');
  }

  ColumnSchema _add(String name, String datatype, [int length = 255]) {
    var column = ColumnSchema(name, datatype, this, length);
    columns.add(column);

    return column;
  }

  String toString() => name;
}
