import 'package:tunder/src/database/database_connection.dart';
import 'package:tunder/src/utils/functions.dart';

class DB {
  static DatabaseConnection? _connection;
  static DatabaseConnection get connection =>
      _connection ??= app(DatabaseConnection);

  static Future<T> transaction<T>(Future<T> Function() function) async {
    return connection.transaction(function);
  }

  static Future<int> execute(String query) async {
    return connection.execute(query);
  }

  static Future<List<MappedRow>> query(String query) async {
    return connection.query(query);
  }
}
