import 'dart:math';

import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/test.dart';

main() {
  group('Query(table)', () {
    useDatabaseTransactions();

    test('insert(map)', () async {
      final table = await createTable();
      final int affectedRows = await Query(table).insert({
        'name': 'test',
        'age': 20,
        'active': true,
      });

      final results = await Query(table).get();

      expect(affectedRows, 1);
      expect(results.length, 1);
      expect(results.first['id'], TypeMatcher<int>());
      expect(results.first['name'], 'test');
      expect(results.first['age'], 20);
      expect(results.first['active'], true);
      expect(results.first['created_at'], TypeMatcher<DateTime>());
    });
  });
}

Future<String> createTable() async {
  final int randomNumber = Random().nextInt(1000000);
  final table = 'insert_test_$randomNumber';

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
