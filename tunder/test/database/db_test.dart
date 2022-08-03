import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/exceptions/unknown_database_driver_exception.dart';
import 'package:tunder/src/providers/database_service_provider.dart';
import 'package:tunder/test.dart';
import 'package:tunder/utils.dart';

import '../feature.dart';

main() {
  group('DB', () {
    useDatabaseTransactions();

    setUpAll(() => DatabaseServiceProvider().boot(app()));

    setUp(() async {
      await Schema.create('users', (table) {
        table.id();
        table.string('name').notNullable();
      });
    });

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
          expect(results.length, 2);

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
      await DB.execute("INSERT INTO users (name) VALUES ('Marco')");
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
      DB.driver = #fake;
      expect(() => Schema.createSql('test', (table) => table.string('name')),
          toThrow(UnknownDatabaseDriverException, 'Unknown driver [fake]'));
    });
  });
}

class SomeException implements Exception {
  final String message;

  SomeException(this.message);
}
