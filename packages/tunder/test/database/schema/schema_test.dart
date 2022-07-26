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
        create table "testing_table" ("custom_id" bigserial constraint "testing_table_custom_id_pkey" primary key not null,
          "name" varchar(255),
          "age" integer check ("age" >= 0),
          "body" text null,
          "published_at" timestamp null,
          "is_active" boolean null,
          "price" double precision null,
          "created_at" timestamp not null default current_timestamp(6),
          "updated_at" timestamp not null default current_timestamp(6),
          "deleted_at" timestamp null)
        ''';

      var createSql = Schema.createSql('testing_table', (table) {
        table
          ..id('custom_id')
          ..string('name')
          ..integer('age').unsigned
          ..text('body').nullable()
          ..timestamp('published_at').nullable()
          ..boolean('is_active').nullable()
          ..double('price').nullable()
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
        table.string('name').notNullable();
        table.text('body').nullable();
        table.timestamp('published_at');
        table.boolean('is_active');
        table.timestamps();
        table.softDeletes();
      });

      expect(await DB.tableExists('testing_table'), isTrue);
    });

    group('constraints', () {
      setUp(() async {
        await Schema.create('test', (table) {
          table.integer('id');
        });
      });

      test('index(name)', () async {
        var updateSql = Schema.updateSql('test', (table) {
          table.index(column: 'id');
          table.index(column: 'id', name: 'custom_name');
        });
        expect(
          updateSql,
          'create index "test_id_index" on "test" ("id"); '
          'create index "custom_name" on "test" ("id")',
        );
        expect(await DB.execute(updateSql), isNotNull);
      });
      test('table.primary(column)', () async {
        var sql = Schema.updateSql('test', (table) {
          table.primary(['id']);
        });

        expect(sql,
            'alter table "test" add constraint "test_id_pkey" primary key ("id")');
        expect(await DB.execute(sql), isNotNull);
      });
    });

    group('droppings', () {
      setUp(() async {
        await Schema.create('test', (table) {
          table.id();
          table.string('name');
          table.timestamps();
          table.softDeletes();
        });
      });

      test('.drop(table) and .dropIfExists(table)', () async {
        expect(Schema.dropSql('test'), 'drop table "test"');
        expect(Schema.drop('test'), isNotNull);
        expect(Schema.dropIfExistsSql('test'), 'drop table if exists "test"');
        expect(Schema.dropIfExists('test'), isNotNull);
      });

      test('.dropColumn(name) and .dropColumns([name1, name2])', () {
        expect(
          Schema.updateSql('test', (table) {
            table.dropColumn('name');
            table.dropColumns(['second', 'third']);
          }),
          'alter table "test" drop column "name"; '
          'alter table "test" drop column "second"; '
          'alter table "test" drop column "third"',
        );
      });

      test('dropTimestamps() / dropTimestamps(createdColumn, updatedColumn)',
          () {
        expect(
          Schema.updateSql('test', (table) => table.dropTimestamps()),
          'alter table "test" drop column "created_at"; '
          'alter table "test" drop column "updated_at"',
        );
        expect(
          Schema.updateSql('test',
              (table) => table.dropTimestamps(createdColumn: 'created_date')),
          'alter table "test" drop column "created_date"; '
          'alter table "test" drop column "updated_at"',
        );
        expect(
          Schema.updateSql(
              'test',
              (table) => table.dropTimestamps(
                  updatedColumn: 'updatedDate', camelCase: true)),
          'alter table "test" drop column "createdAt"; '
          'alter table "test" drop column "updatedDate"',
        );
      });

      test('dropSoftDeletes', () {
        expect(
          Schema.updateSql('test', (table) => table.dropSoftDeletes()),
          'alter table "test" drop column "deleted_at"',
        );
        expect(
          Schema.updateSql(
              'test', (table) => table.dropSoftDeletes('removed_at')),
          'alter table "test" drop column "removed_at"',
        );
      });

      test('dropIndex(column, name) / dropIndexes(columns, names)', () {
        expect(
          Schema.updateSql('test', (table) {
            table.dropIndex(column: 'name');
            table.dropIndexes(columns: ['second', 'third']);
            table.dropIndex(name: 'custom_name');
            table.dropIndexes(names: ['custom_name_1', 'custom_name_2']);
          }),
          'drop index "test_name_index"; '
          'drop index "test_second_index"; '
          'drop index "test_third_index"; '
          'drop index "custom_name"; '
          'drop index "custom_name_1"; '
          'drop index "custom_name_2"',
        );
      });

      test('dropUnique(column, name) / dropUniques(columns, names)', () {
        expect(
          Schema.updateSql('test', (table) {
            table.dropUnique(column: 'name');
            table.dropUniques(columns: ['second', 'third']);
            table.dropUnique(name: 'custom_name');
            table.dropUniques(names: ['custom_name_1', 'custom_name_2']);
          }),
          'alter table "test" drop constraint "test_name_unique"; '
          'alter table "test" drop constraint "test_second_unique"; '
          'alter table "test" drop constraint "test_third_unique"; '
          'alter table "test" drop constraint "custom_name"; '
          'alter table "test" drop constraint "custom_name_1"; '
          'alter table "test" drop constraint "custom_name_2"',
        );
      });

      test('dropPrimary()', () async {
        // Act and Assert
        var sql = Schema.updateSql('test', (table) {
          table.dropPrimary(columns: ['id']);
        });
        expect(sql, 'alter table "test" drop constraint "test_id_pkey"');
        expect(await DB.execute(sql), isNotNull);
      });
      test('dropPrimary(name)', () async {
        // Act and Assert
        var sql = Schema.updateSql('test', (table) {
          table.dropPrimary(name: 'custom_pkey_name');
        });
        expect(sql, 'alter table "test" drop constraint "custom_pkey_name"');
      });
    });

    group('renames', () {
      setUp(() async {
        await Schema.create('test', (table) {
          table.id();
          table.string('name').index();
          table.timestamps();
          table.softDeletes();
        });
      });

      test('Schema.rename(from, to) renames a table', () async {
        var sql = Schema.renameSql('test', 'test_new');
        expect(sql, 'alter table "test" rename to "test_new"');

        expect(await DB.execute(sql), isNotNull);
        expect(await DB.tableExists('test_new'), isTrue);

        await Schema.rename('test_new', 'test');
        expect(await DB.tableExists('test'), isTrue);
      });

      test('table.renameColumn(from, to) renames a column', () async {
        var sql = Schema.updateSql('test', (table) {
          table.renameColumn('name', 'email');
        });
        expect(sql, 'alter table "test" rename column "name" to "email"');
        expect(await DB.execute(sql), isNotNull);
      });

      test('table.renameIndex(from, to) renames an index', () async {
        var sql = Schema.updateSql('test', (table) {
          table.renameIndex('test_name_index', 'email_index');
        });
        expect(sql, 'alter index "test_name_index" rename to "email_index"');
        expect(await DB.execute(sql), isNotNull);
      });
    });
  });
}
