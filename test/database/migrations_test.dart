import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/test.dart';

main() {
  group('Migrations:', () {
    useDatabaseTransactions();

    test('Schema.create(table, function) creates a table', () async {
      await Schema.create('test', (table) {
        table.integer('id');
        table.string('name');
      });

      expect(await DB.query('SELECT * FROM test'), isNotNull);
    });

    test('Schema.update(table, function)', () async {
      expect(await DB.tableExists('test'), isFalse);
      await Schema.create('test', (table) {
        table.integer('id');
        table.string('name');
      });
      expect(await DB.tableExists('test'), isTrue);
      await Schema.update('test', (table) {
        table.string('name').nullable.update();
      });
      var insertQuery = 'INSERT INTO test (id) VALUES (1)';
      expect(await DB.execute(insertQuery), 1);
      expect(await DB.query('SELECT * FROM test'), isNotEmpty);
    });
  });
}
