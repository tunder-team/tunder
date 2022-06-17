import 'package:test/test.dart';
import 'package:tunder/tunder.dart';
import 'package:tunder/database.dart';
import 'package:tunder/test.dart';

main() {
  group('Schema', () {
    useDatabaseTransactions();

    test('.createSql(table, define) returns the table schema for creation',
        () async {
      final expectedSql = '''
        create table "testing_table" ("custom_id" bigserial primary key,
          "name" varchar(255),
          "age" integer check ("age" >= 0),
          "body" text null,
          "published_at" timestamp null,
          "is_active" boolean null,
          "price" double precision null,
          "created_at" timestamp not null default current_timestamp(6),
          "updated_at" timestamp not null default current_timestamp(6),
          "deleted_at" timestamp null);
        ''';

      var createSql = Schema.createSql('testing_table', (table) {
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
      });
      expect(createSql, expectedSql.linerized.trim());
      expect(await DB.execute(createSql), isNotNull);
    });

    test('.create(table, define) creates a table', () async {
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
