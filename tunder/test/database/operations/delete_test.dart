import 'dart:math';

import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/test.dart';

const testTable = 'delete_test';

main() {
  group('Query(table)', () {
    useDatabaseTransactions();

    test('delete() without where clauses updates all records', () async {
      // Arrange
      final table = await createTable();
      await insertTestRecord(table, 'record1');
      await insertTestRecord(table, 'record2');

      // Act
      final affectedRows = await Query(table).delete();
      final results = await Query(table).all();

      // Assert
      expect(affectedRows, 2);
      expect(results.length, 0);
    });

    test('delete() with where clauses deletes only some records', () async {
      // Arrange
      final table = await createTable();
      await insertTestRecord(table, 'record1');
      await insertTestRecord(table, 'record2');

      // Act
      final affectedRows =
          await (Query(table)..where('name').equals('record2')).delete();
      final results = await Query(table).all();

      // Assert
      expect(affectedRows, 1);
      expect(results.length, 1);
    });
  });
}

Future<int> insertTestRecord(String table, [String name = 'test']) =>
    Query(table).insert({'name': name, 'age': 20, 'active': true});

Future<String> createTable() async {
  final int randomNumber = Random().nextInt(1000000);
  final table = '${testTable}_$randomNumber';

  await Schema.create(table, (table) {
    table
      ..id()
      ..string('name')
      ..integer('age')
      ..boolean('active')
      ..timestamps();
  });

  return table;
}
