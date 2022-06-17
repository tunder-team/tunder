import 'package:tunder/src/database/schema/index_schema.dart';
import 'package:tunder/src/database/schema/table_schema.dart';

class ColumnSchema {
  final String name;
  final String datatype;
  final TableSchema table;
  IndexSchema? addIndex;
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

  ColumnSchema get primary => this..isPrimary = true;
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

  ColumnSchema index([String? name]) => this
    ..addIndex = IndexSchema(column: this.name, table: table.name, name: name);
  /**
   * Use this method to indicate that this is a column change operation.
   */
  void update() => isUpdating = true;
  /**
   * Use this method to indicate that this is a column change operation. Alias of [update].
   */
  void change() => update();

  String toString() => name;
}
