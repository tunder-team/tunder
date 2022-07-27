import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/test.dart';

main() {
  useDatabaseTransactions();

  group('TableSchema method', () {
    // late TableSchema table;

    // setUp(() async {
    //   table = TableSchema('test', DB.connection);
    //   await Schema.create('test', (tb) {
    //     tb.id();
    //     tb.string('name');
    //     tb.string('email');
    //     tb.integer('price').unsigned;
    //     tb.timestamp('published_at');
    //     tb.timestamps();
    //     tb.softDeletes();
    //   });
    // });

    // test('Removing a column', () async {
    //   table
    //     ..dropColumn('price')
    //     ..dropColumns(['name', 'email']);

    //   expect(
    //     table.alterSql(),
    //     'ALTER TABLE "test" DROP COLUMN "price"; '
    //     'ALTER TABLE "test" DROP COLUMN "name"; '
    //     'ALTER TABLE "test" DROP COLUMN "email"',
    //   );
    //   expect(await alter(table), isNotNull);
    // });

    // test('Adding unique constraint to a new column', () async {
    //   // Arrange
    //   await dropColumn('test', 'email');
    //   // Act
    //   table.string('email', 123).unique;

    //   expect(table.alterSql(),
    //       'ALTER TABLE "test" ADD COLUMN "email" VARCHAR(123) UNIQUE NOT NULL');
    //   expect(await alter(table), isNotNull);
    // });

    // test('Adding unique constraint to an existing column', () async {
    //   table.string('email').notNull().unique().change();
    //   expect(
    //     table.alterSql(),
    //     'ALTER TABLE "test" ALTER COLUMN "email" SET NOT NULL; '
    //     'ALTER TABLE "test" ALTER COLUMN "email" TYPE VARCHAR(255); '
    //     'ALTER TABLE "test" ADD CONSTRAINT "test_email_unique" UNIQUE ("email")',
    //   );

    //   expect(await alter(table), isNotNull);
    // });

    // test('Adding not null constraint', () async {
    //   table.string('email').notNull().update();

    //   expect(
    //     table.alterSql(),
    //     'ALTER TABLE "test" ALTER COLUMN "email" SET NOT NULL; '
    //     'ALTER TABLE "test" ALTER COLUMN "email" TYPE VARCHAR(255)',
    //   );

    //   expect(await alter(table), isNotNull);
    // });

    // test('Removing not null constraint', () async {
    //   table.string('email').nullable().update();
    //   table.string('email').nullable().update();
    //   expect(
    //     table.alterSql(),
    //     'ALTER TABLE "test" ALTER COLUMN "email" DROP NOT NULL; '
    //     'ALTER TABLE "test" ALTER COLUMN "email" TYPE VARCHAR(255)',
    //   );

    //   expect(await alter(table), isNotNull);
    // });

    // test('Removing unique constraint', () async {
    //   table.string('email').unique().change();
    //   table.dropUnique('test_email_unique');

    //   expect(
    //     table.alterSql(),
    //     'ALTER TABLE "test" ALTER COLUMN "email" TYPE VARCHAR(255); '
    //     'ALTER TABLE "test" ADD CONSTRAINT "test_email_unique" UNIQUE ("email"); '
    //     'ALTER TABLE "test" DROP CONSTRAINT "test_email_unique"',
    //   );

    //   expect(await alter(table), isNotNull);
    // });

    // test('Alternative way to remove a unique constraint', () async {
    //   table.string('email').unique().update();
    //   table.string('email').unique().update();
    //   table.string('email').notUnique.change();

    //   expect(
    //     table.alterSql(),
    //     'ALTER TABLE "test" ALTER COLUMN "email" TYPE VARCHAR(255); '
    //     'ALTER TABLE "test" ADD CONSTRAINT "test_email_unique" UNIQUE ("email"); '
    //     'ALTER TABLE "test" DROP CONSTRAINT "test_email_unique"',
    //   );

    //   expect(await alter(table), isNotNull);
    // });

    // test('Adding index to a new column', () async {
    //   table.string('custom_column').index;
    //   table.index(column: 'custom_column', name: 'custom_index');

    //   expect(
    //     table.alterSql(),
    //     'ALTER TABLE "test" ADD COLUMN "custom_column" VARCHAR(255) NOT NULL; '
    //     'CREATE INDEX "test_custom_column_index" ON "test" ("custom_column"); '
    //     'CREATE INDEX "custom_index" ON "test" ("custom_column")',
    //   );

    //   expect(await alter(table), isNotNull);
    // });

    // test('Adding index to a existing column', () async {
    //   table.string('email', 123).index().change();
    //   table.index(column: 'email', name: 'custom_email_index');
    //   table.index(column: 'name');

    //   expect(
    //     table.alterSql(),
    //     'ALTER TABLE "test" ALTER COLUMN "email" TYPE VARCHAR(123); '
    //     'CREATE INDEX "test_email_index" ON "test" ("email"); '
    //     'CREATE INDEX "custom_email_index" ON "test" ("email"); '
    //     'CREATE INDEX "test_name_index" ON "test" ("name")',
    //   );
    //   expect(await alter(table), isNotNull);
    // });

    // test('Removing index', () async {
    //   await DB.execute('CREATE INDEX "test_email_index" ON "test" ("email")');
    //   // Act
    //   table.dropIndex('test_email_index');

    //   expect(
    //     table.alterSql(),
    //     'DROP INDEX "test_email_index"',
    //   );

    //   expect(await alter(table), isNotNull);
    // });
  });
}

Future<bool> dropColumn(String table, String column) async {
  final sql = 'ALTER TABLE $table DROP COLUMN $column';
  await DB.execute(sql);

  return true;
}

// Future<int> alter(TableSchema table) {
//   return DB.execute(table.alterSql());
// }
