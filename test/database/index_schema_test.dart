import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/database/schema/index_schema.dart';
import 'package:tunder/src/database/schema/table_schema.dart';
import 'package:tunder/test.dart';

main() {
  group('IndexSchema', () {
    useDatabaseTransactions();

    late TableSchema table;

    setUp(() async {
      await Schema.create('test', (table) {
        table.id();
        table.string('name');
        table.string('email');
      });
      table = TableSchema('test', DB.connection);
    });

    test('create index and generates a name based on column and table names',
        () async {
      final index = IndexSchema(column: 'name', table: table);
      expect(index.name, equals('test_name_index'));
      expect(index.column, 'name');
      expect(index.table.name, 'test');

      expect(
        '$index',
        'CREATE INDEX "test_name_index" ON "test" ("name")',
      );
      expect(await DB.execute(index.toString()), isNotNull);
    });

    test('create index with a custom name when name param is given', () async {
      final index = IndexSchema(column: 'name', table: table, name: 'custom');
      expect(index.name, equals('custom'));
      expect(
        '$index',
        'CREATE INDEX "custom" ON "test" ("name")',
      );
      expect(await DB.execute(index.toString()), isNotNull);
    });
  });
}
