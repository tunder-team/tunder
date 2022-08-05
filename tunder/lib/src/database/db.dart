import 'package:tunder/src/database/database_connection.dart';
import 'package:tunder/src/utils/functions.dart';

class DB {
  static Symbol get driver => connection.driver;
  static set driver(Symbol driver) => connection.driver = driver;
  static DatabaseConnection? _connection;
  static DatabaseConnection get connection =>
      _connection ??= app(DatabaseConnection);

  static DatabaseConnection get newConnection {
    _connection = null;
    return connection;
  }

  static Future<T> transaction<T>(Future<T> Function() function) =>
      connection.transaction(function);

  static Future<int> execute(String query) => connection.execute(query);

  static Future<List<MappedRow>> query(String query) => connection.query(query);

  static Future<bool> tableExists(String table) =>
      connection.tableExists(table);

  static Future begin() => connection.begin();

  static Future commit() => connection.commit();

  static Future rollback() => connection.rollback();
}

class DatabaseDriver {
  static const postgres = #postgres;
  // static const sqlite = #sqlite;
  // static const mysql = #mysql;
}
