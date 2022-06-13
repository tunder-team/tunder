import 'package:tunder/database.dart';
import 'package:tunder/src/database/schema/schema_processor.dart';
import 'package:tunder/src/database/schema/table_schema.dart';

class Schema {
  /**
   * Create a new table with columns defined in [define] closure.
   */
  static Future<void> create(
    String name,
    void Function(TableSchema table) define,
  ) =>
      DB.execute(createSql(name, define));

  static Future<void> update(
      String name, void Function(TableSchema table) define) async {
    final table = TableSchema(name, DB.connection);
    define(table);
    await DB.execute(table.alterSql());
  }

  static String createSql(
      String tableName, void Function(TableSchema table) define) {
    final table = TableSchema(tableName, DB.connection);
    define(table);
    return SchemaProcessor.forDatabase(DB.driver).createSql(table);
  }
}
