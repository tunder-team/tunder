import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/providers/database_service_provider.dart';
import 'package:tunder/utils.dart';

main() {
  group('PostgresConnection', () {
    late DatabaseConnection connection;

    setUpAll(() {
      DatabaseServiceProvider().boot(app());
      connection = app(DatabaseConnection);
    });
    test('open() and close() connections', () async {
      await connection.open();
      connection.close();
    });

    test('query(sql) executes a query and return as map', () async {
      var rows = await connection.query(
        'SELECT * FROM users',
      );
      expect(rows, isNotEmpty);
      expect(rows.length, 2);
      expect(rows.first, TypeMatcher<Map>());
      expect(rows.first['id'], TypeMatcher<int>());
    });

    test('execute(sql) returns the number of affected rows', () async {
      var affectedRows = await connection.execute(
        "UPDATE users SET name = 'John' WHERE id = 1",
      );
      expect(affectedRows, 1);
      affectedRows = await connection.execute(
        "UPDATE users SET name = 'Marco' WHERE id = 1",
      );
      expect(affectedRows, 1);
    });

    test('transaction(function) executes a function in a transaction',
        () async {
      var queryJose = "SELECT * FROM users WHERE name = 'Jose'";

      try {
        await connection.transaction(() async {
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
  });
}

class SomeException implements Exception {
  final String message;

  SomeException(this.message);
}
