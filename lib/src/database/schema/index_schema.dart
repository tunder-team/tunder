import 'package:tunder/src/database/schema/table_schema.dart';

class IndexSchema {
  String? name;
  final String column;
  final TableSchema table;

  IndexSchema({
    required this.column,
    required this.table,
    name,
  }) : this.name = name ?? '${table.name}_${column}_index';

  String toString() {
    return 'CREATE INDEX "$name" ON "${table.name}" ("$column")';
  }
}
