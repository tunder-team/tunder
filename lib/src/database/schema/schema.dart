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
    String name,
    void Function(TableSchema table) define,
  ) =>
      DB.execute(updateSql(name, define));

  static String createSql(
      String tableName, void Function(TableSchema table) define) {
    final table = TableSchema(tableName, DB.connection);
    define(table);
    return SchemaProcessor.forDatabase(DB.driver).createSql(table);
  }

  static String updateSql(
      String tableName, void Function(TableSchema table) define) {
    final table = TableSchema(tableName, DB.connection);
    define(table);
    return SchemaProcessor.forDatabase(DB.driver).updateSql(table);
  }

  static Future<int> rename(String from, String to) =>
      DB.execute(renameSql(from, to));

  static String renameSql(String from, String to) {
    return SchemaProcessor.forDatabase(DB.driver).renameSql(from, to);
  }

  static Future<int> drop(String table) async => DB.execute(dropSql(table));
  static String dropSql(String tableName) => 'drop table "$tableName"';

  static Future<int> dropIfExists(String table) async =>
      DB.execute(dropIfExistsSql(table));
  static String dropIfExistsSql(String tableName) =>
      'drop table if exists "$tableName"';
}
