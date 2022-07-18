import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/test.dart';

main() {
  group('Nullable/NotNullable Constraints', () {
    useDatabaseTransactions();

    group('Creation', () {
      test('table.string(name) use database defaults when not specified',
          () async {
        var sql = Schema.createSql('test', (table) {
          table.string('name');
        });
        expect(sql, 'create table "test" ("name" varchar(255))');
        expect(await DB.execute(sql), isNotNull);
      });

      test('table.string(name).nullable()', () async {
        var sql = Schema.createSql('test', (table) {
          table.string('name').nullable();
        });

        expect(sql, 'create table "test" ("name" varchar(255) null)');
        expect(await DB.execute(sql), isNotNull);
      });

      test('table.string(name).notNullable()', () async {
        var sql = Schema.createSql('test', (table) {
          table.string('name').notNullable();
        });
        expect(sql, 'create table "test" ("name" varchar(255) not null)');
        expect(await DB.execute(sql), isNotNull);
      });
    });

    group('Update: ', () {
      setUp(() async {
        await Schema.create('test', (table) {
          table.id();
          table.string('name');
        });
      });

      test('table.string(name).nullable().change()', () async {
        var sql = Schema.updateSql('test', (table) {
          table.string('name').nullable().change();
        });
        expect(
          sql,
          'alter table "test" alter column "name" type varchar(255); '
          'alter table "test" alter column "name" drop not null',
        );
        expect(await DB.execute(sql), isNotNull);
      });
      test('table.string(name).notNullable().change()', () async {
        var sql = Schema.updateSql('test', (table) {
          table.string('name').notNullable().change();
        });
        expect(
          sql,
          'alter table "test" alter column "name" type varchar(255); '
          'alter table "test" alter column "name" set not null',
        );
        expect(await DB.execute(sql), isNotNull);
      });
    });

    group('Integrations: ', () {
      setUp(() async {
        await Schema.create('test', (table) {
          table.id();
          table.string('name');
        });
      });

      test('table.string(email).notNullable().unique().change()', () async {
        var sql = Schema.updateSql('test', (table) {
          table.string('name').notNullable().unique().change();
        });
        expect(
          sql,
          'alter table "test" alter column "name" type varchar(255); '
          'alter table "test" alter column "name" set not null; '
          'alter table "test" add constraint "test_name_unique" unique ("name")',
        );
        expect(await DB.execute(sql), isNotNull);
      });

      test('table.string(email).notNullable().unique()', () async {
        var sql = Schema.updateSql('test', (table) {
          table.string('email').notNullable().unique();
        });
        expect(sql,
            'alter table "test" add column "email" varchar(255) not null constraint "test_email_unique" unique');
        expect(await DB.execute(sql), isNotNull);
      });
    });
  });
}
