import 'package:tunder/src/database/database_connection.dart';
import 'package:tunder/src/utils/functions.dart';

class DB {
  static String get driver => connection.driver;
  static final drivers = _Drivers();
  static DatabaseConnection? _connection;
  static DatabaseConnection get connection =>
      _connection ??= app(DatabaseConnection);

  static DatabaseConnection get newConnection {
    _connection = null;

    return connection;
  }

  static Future<T> transaction<T>(Future<T> Function() function) async {
    return connection.transaction(function);
  }

  static Future<int> execute(String query) async {
    return connection.execute(query);
  }

  static Future<List<MappedRow>> query(String query) async {
    return connection.query(query);
  }

  static Future<bool> tableExists(String table) async {
    return connection.tableExists(table);
  }

  static Future begin() {
    return connection.begin();
  }

  static Future commit() {
    return connection.commit();
  }

  static Future rollback() {
    return connection.rollback();
  }
}

class _Drivers {
  final String postgres = 'postgres';
  // TODO: final String mysql = 'mysql';
  // TODO: final String sqlite = 'sqlite';

  const _Drivers();
}
