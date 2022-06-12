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
        table.string('name').nullable.update;
      });
      var insertQuery = 'INSERT INTO test (id) VALUES (1)';
      expect(await DB.execute(insertQuery), 1);
      expect(await DB.query('SELECT * FROM test'), isNotEmpty);
    });

    test('Schema class defines a database table schema', () async {
      // Create table sql
      final createTableSql =
          'CREATE TABLE IF NOT EXISTS test (id INTEGER, name TEXT)';
      // create a table sql with columns id, name, body, created_at and updated_at
      final createTableSql2 = '''
        CREATE TABLE IF NOT EXISTS posts (
          id BIGSERIAL PRIMARY KEY,
          title VARCHAR(255) NOT NULL,
          body TEXT NOT NULL,
          created_at TIMESTAMP NOT NULL DEFAULT NOW(),
          updated_at TIMESTAMP NOT NULL DEFAULT NOW()
        );
      ''';
      final updateTableAddColumnSql = '''
        ALTER TABLE posts ADD COLUMN IF NOT EXISTS body TEXT NOT NULL;
      ''';
      final updateTableUpdateColumnSql = '''
        ALTER TABLE posts ALTER COLUMN body SET NOT NULL;
      ''';
      final deleteTableColumnSql = '''
        ALTER TABLE posts DROP COLUMN body;
      ''';
      final createIndexSql = '''
        CREATE INDEX IF NOT EXISTS test_idx ON test (id)
      ''';
      final dropIndexSql = '''
        DROP INDEX IF EXISTS test_idx
      ''';
      final describeTableSql = 'SELECT * FROM posts LIMIT 1';
    });
  });
}
