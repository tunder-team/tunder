import 'package:tunder/database.dart';
import 'package:tunder/src/database/schema/column_schema.dart';
import 'package:tunder/src/database/schema/data_type.dart';
import 'package:tunder/extensions.dart';
import 'package:tunder/src/database/schema/index_schema.dart';

class TableSchema {
  final String name;
  final DatabaseConnection connection;
  final List<ColumnSchema> columns = [];
  final List<IndexSchema> _indexes = [];
  final List<String> _dropping = [];

  TableSchema(this.name, this.connection);

  void id([String name = 'id']) => _add(name, DataType.integer).primary;

  ColumnSchema string(String name, [int length = 255]) =>
      _add(name, DataType.string, length);

  ColumnSchema text(String name) => _add(name, DataType.text);
  ColumnSchema double(String name) => _add(name, DataType.double);

  ColumnSchema integer(String name) => _add(name, DataType.integer);
  ColumnSchema timestamp(String name) => _add(name, DataType.timestamp);
  ColumnSchema boolean(String name) => _add(name, DataType.boolean);

  void timestamps() => this
    .._add('created_at', DataType.timestamp).notNull.defaultValue('NOW()')
    .._add('updated_at', DataType.timestamp).notNull.defaultValue('NOW()');

  void softDeletes() => _add('deleted_at', DataType.timestamp).nullable;

  void index({required String column, String? name = null}) {
    // 'CREATE INDEX $indexName ON $table ($columnName)'
    var index = IndexSchema(column: column, table: this, name: name);
    _indexes.add(index);
  }

  String createSql() {
    var createTableSql = 'CREATE TABLE "$name" (${columns.join(", ")})';

    return '$createTableSql; ${_indexes.join("; ")}'.trim();
  }

  String alterSql() {
    List parsedColumns = columns.map((column) {
      if (!column.isUpdating) return ['ALTER TABLE "$name" ADD COLUMN $column'];

      return column.changes
          .map((change) => 'ALTER TABLE "$name" $change')
          .toList();
    }).flatten();

    var columnIndexes = columns
        .where((column) => column.addIndex)
        .map((column) => IndexSchema(column: column.name, table: this))
        .toList();

    return [
      parsedColumns + _dropping + columnIndexes + _indexes,
    ].flatten().unique().join('; ');
  }

  void dropColumn(String column) {
    _dropping.add('ALTER TABLE "$name" DROP COLUMN "$column"');
  }

  void dropColumns(List<String> columns) {
    columns.forEach((column) => dropColumn(column));
  }

  void dropPrimary(String key) {
    throw UnimplementedError();
  }

  void dropUnique(String key) {
    _dropping.add('ALTER TABLE "$name" DROP CONSTRAINT "$key"');
  }

  void dropIndex(String key) {
    _dropping.add('DROP INDEX "$key"');
  }

  ColumnSchema _add(String name, String datatype, [int length = 255]) {
    var column = ColumnSchema(name, datatype, this, length);
    columns.add(column);

    return column;
  }
}
