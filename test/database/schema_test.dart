import 'package:test/test.dart';
import 'package:tunder/src/database/schema/table_schema.dart';
import 'package:tunder/tunder.dart';
import 'package:tunder/database.dart';
import 'package:tunder/test.dart';

main() {
  group('Schema', () {
    useDatabaseTransactions();

    test('TableSchema createSql returns the table schema for creation',
        () async {
      final table = TableSchema('testing_table', DB.connection);
      final expectedSql = '''
        CREATE TABLE "testing_table" ("custom_id" BIGSERIAL PRIMARY KEY NOT NULL,
          "name" VARCHAR(255) NOT NULL,
          "age" INTEGER NOT NULL CHECK ("age" >= 0),
          "body" TEXT NULL,
          "published_at" TIMESTAMP NULL,
          "is_active" BOOLEAN NULL,
          "price" DOUBLE PRECISION NULL,
          "created_at" TIMESTAMP NOT NULL DEFAULT NOW(),
          "updated_at" TIMESTAMP NOT NULL DEFAULT NOW(),
          "deleted_at" TIMESTAMP NULL);
        ''';

      table
        ..id('custom_id')
        ..string('name')
        ..integer('age').unsigned
        ..text('body').nullable
        ..timestamp('published_at').nullable
        ..boolean('is_active').nullable
        ..double('price').nullable
        ..timestamps()
        ..softDeletes();

      expect(table.createSql(), expectedSql.linerized.trim());
      expect(await DB.execute(table.createSql()), isNotNull);
    });

    test('.create(table, function) creates a table', () async {
      var exists = await DB.tableExists('testing_table');
      expect(exists, isFalse);

      await Schema.create('testing_table', (table) {
        table.id('custom_id');
        table.string('name').notNull;
        table.text('body').nullable;
        table.timestamp('published_at');
        table.boolean('is_active');
        table.timestamps();
        table.softDeletes();
      });

      expect(await DB.tableExists('testing_table'), isTrue);
    });
  });
}
