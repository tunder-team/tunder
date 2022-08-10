import 'dart:math';

import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/test.dart';

const testTable = 'update_test';

main() {
  group('Query(table)', () {
    useDatabaseTransactions();

    test('update(map) without where clauses updates all records', () async {
      // Arrange
      final table = await createTable();
      await insertTestRecord(table, 'record1');
      await insertTestRecord(table, 'record2');

      // Act
      final affectedRows = await Query(table).update({'name': 'same name'});
      final results = await Query(table).all();

      // Assert
      expect(affectedRows, 2);
      expect(results.length, 2);
      results.forEach((result) {
        expect(result['id'], TypeMatcher<int>());
        expect(result['name'], 'same name');
        expect(result['age'], 20);
        expect(result['active'], true);
        expect(result['created_at'], TypeMatcher<DateTime>());
        expect(result['updated_at'], TypeMatcher<DateTime>());
      });
    });

    test('update(map) with where clauses updates only some records', () async {
      // Arrange
      final table = await createTable();
      await insertTestRecord(table, 'record1');
      await insertTestRecord(table, 'record2');
      var record2 =
          await (Query(table)..where('name').equals('record2')).first();

      // Act
      final affectedRows = await (Query(table)..where('name').equals('record2'))
          .update({'name': 'updated'});
      record2 = await Query(table).find(record2['id']);

      // Assert
      expect(affectedRows, 1);
      expect(record2['id'], TypeMatcher<int>());
      expect(record2['name'], 'updated');
      expect(record2['age'], 20);
      expect(record2['active'], true);
      expect(record2['created_at'], TypeMatcher<DateTime>());
      expect(record2['updated_at'], TypeMatcher<DateTime>());
    });
  });
}

Future insertTestRecord(String table, [String name = 'test']) =>
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
