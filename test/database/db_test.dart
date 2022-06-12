import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/database/schema/column_schema.dart';
import 'package:tunder/src/database/schema/data_type.dart';
import 'package:tunder/src/database/schema/table_schema.dart';
import 'package:tunder/src/exceptions/unknown_database_driver_exception.dart';
import 'package:tunder/src/providers/database_service_provider.dart';
import 'package:tunder/utils.dart';

import '../feature.dart';

main() {
  group('DB', () {
    setUpAll(() => DatabaseServiceProvider().boot(app()));
    test('is an instance of DatabaseConnection', () async {
      expect(DB.connection, isA<DatabaseConnection>());
    });

    test('transaction(function) executes a function inside a transaction',
        () async {
      var queryJose = "SELECT * FROM users WHERE name = 'Jose'";
      var connection = DB.connection;

      try {
        await DB.transaction(() async {
          var insertJose = "INSERT INTO users (name) VALUES ('Jose')";
          var insertAnna = "INSERT INTO users (name) VALUES ('Anna')";
          var affectedRows = await connection.execute(insertJose);
          expect(affectedRows, 1);
          affectedRows = await connection.execute(insertAnna);
          expect(affectedRows, 1);
          var results = await connection.query(queryJose);
          expect(results, isNotEmpty);

          results = await connection.query('SELECT * FROM users');
          expect(results.length, 4);

          throw SomeException('Some error');
        });
      } on SomeException catch (e) {
        expect(e.message, 'Some error');
      }

      var results = await connection.query(queryJose);
      expect(results, isEmpty);
    });

    test('execute returns number of affected rows', () async {
      var insert = "INSERT INTO users (name) VALUES ('Jane')";
      var affectedRows = await DB.execute(insert);
      expect(affectedRows, 1);
      var delete = "DELETE FROM users WHERE name = 'Jane'";
      affectedRows = await DB.execute(delete);
      expect(affectedRows, 1);
    });

    test('query returns a list of mapped rows', () async {
      var query = "SELECT * FROM users WHERE name = 'Marco'";
      var results = await DB.query(query);
      expect(results, isNotEmpty);
      expect(results.first, isA<MappedRow>());
    });

    test('begin() and rollback()', () async {
      await DB.begin();
      var insertJane = "INSERT INTO users (name) VALUES ('Jane')";
      var findJane = "SELECT * FROM users WHERE name = 'Jane'";
      var affectedRows = await DB.execute(insertJane);
      expect(affectedRows, 1);

      var results = await DB.query(findJane);
      expect(results, isNotEmpty);

      await DB.rollback();
      results = await DB.query(findJane);
      expect(results, isEmpty);
    });

    test('begin() and commit()', () async {
      await DB.begin();
      var insertJane = "INSERT INTO users (name) VALUES ('Jane')";
      var findJane = "SELECT * FROM users WHERE name = 'Jane'";
      var deleteJane = "DELETE FROM users WHERE name = 'Jane'";
      var affectedRows = await DB.execute(insertJane);
      expect(affectedRows, 1);

      var results = await DB.query(findJane);
      expect(results, isNotEmpty);

      await DB.commit();
      results = await DB.query(findJane);
      expect(results, isNotEmpty);

      // Cleanup
      affectedRows = await DB.execute(deleteJane);
      expect(affectedRows, 1);

      results = await DB.query(findJane);
      expect(results, isEmpty);
    });

    test('if trying to connect to an unexisting driver it throws an error', () {
      app().bind(
        DatabaseConnection,
        (_) => FakeConnection(
          host: env('DB_HOST') ?? "localhost",
          port: int.parse(env('DB_PORT') ?? '5432'),
          database: env('DB_DATABASE') ?? "tunder_test",
          username: env('DB_USERNAME') ?? "postgres",
          password: env('DB_PASSWORD') ?? "docker",
        ),
      );
      var column = ColumnSchema(
          'name', DataType.string, TableSchema('test', DB.newConnection));
      expect(() => column.toString(),
          toThrow(UnknownDatabaseDriverException, 'Unknown driver [fake]'));
    });
  });
}

class FakeConnection implements DatabaseConnection {
  late String host;
  late int port;
  late String database;
  late String username;
  late String password;
  late final String driver;

  FakeConnection({
    this.host = 'localhost',
    this.port = 5432,
    required this.database,
    required this.username,
    required this.password,
  }) : driver = 'fake';

  @override
  Future begin() {
    // TODO: implement begin
    throw UnimplementedError();
  }

  @override
  void close() {
    // TODO: implement close
  }

  @override
  Future commit() {
    // TODO: implement commit
    throw UnimplementedError();
  }

  @override
  Future<int> execute(String query) {
    // TODO: implement execute
    throw UnimplementedError();
  }

  @override
  Future<void> open() {
    // TODO: implement open
    throw UnimplementedError();
  }

  @override
  Future<List<MappedRow>> query(String query) {
    // TODO: implement query
    throw UnimplementedError();
  }

  @override
  Future rollback() {
    // TODO: implement rollback
    throw UnimplementedError();
  }

  @override
  Future<bool> tableExists(String table) {
    // TODO: implement tableExists
    throw UnimplementedError();
  }

  @override
  Future<T> transaction<T>(Future<T> Function() function) {
    // TODO: implement transaction
    throw UnimplementedError();
  }
}

class SomeException implements Exception {
  final String message;

  SomeException(this.message);
}
