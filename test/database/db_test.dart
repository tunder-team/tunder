import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/providers/database_service_provider.dart';
import 'package:tunder/utils.dart';

main() {
  group('DB', () {
    setUpAll(() => DatabaseServiceProvider().boot(app()));
    test('DB is an instance of DatabaseConnection', () async {
      expect(DB.connection, isA<DatabaseConnection>());
    });

    test('DB.transaction(function) opens a transaction', () async {
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

    test('DB.execute returns number of affected rows', () async {
      var insert = "INSERT INTO users (name) VALUES ('Jane')";
      var affectedRows = await DB.execute(insert);
      expect(affectedRows, 1);
      var delete = "DELETE FROM users WHERE name = 'Jane'";
      affectedRows = await DB.execute(delete);
      expect(affectedRows, 1);
    });

    test('DB.query returns a list of mapped rows', () async {
      var query = "SELECT * FROM users WHERE name = 'Marco'";
      var results = await DB.query(query);
      expect(results, isNotEmpty);
      expect(results.first, isA<MappedRow>());
    });
  });
}

class SomeException implements Exception {
  final String message;

  SomeException(this.message);
}
