import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/test.dart';

main() {
  group('ForeignKeyConstraint', () {
    useDatabaseTransactions();

    setUp(() async {
      await Schema.create('users', (table) => table.id());
      await Schema.create('customers', (table) => table.id());
    });

    group('Creation', () {
      group('In Column', () {
        test('table.bigInteger(user_id).references(id).on(users)', () async {
          var sql = Schema.createSql('test', (table) {
            table
              ..bigInteger('user_id')
                  .references('id')
                  .on('users')
                  .onDelete('cascade')
                  .onUpdate('cascade');
          });
          expect(sql,
              'create table "test" ("user_id" bigint constraint "test_user_id_fkey" references "users"("id") on delete cascade on update cascade)');
          expect(await DB.execute(sql), isNotNull);
        });
      });

      group('In Table', () {
        test('table.foreign(user_id).references(id).on(users)', () async {
          var sql = Schema.createSql('test', (table) {
            table.bigInteger('user_id');
            table.foreign('user_id').references('id').on('users');
          });
          expect(sql,
              'create table "test" ("user_id" bigint, constraint "test_user_id_fkey" foreign key ("user_id") references "users"("id"))');
          expect(await DB.execute(sql), isNotNull);
        });
      });
    });

    group('Update', () {
      setUp(() async {
        await Schema.create('test', (table) {
          table.integer('user_id');
        });
      });
      group('In Column', () {
        test('table.bigInteger(user_id).references(id).on(users).change()',
            () async {
          var sql = Schema.updateSql('test', (table) {
            table
              ..bigInteger('user_id')
                  .references('id')
                  .on('users')
                  .onDelete('cascade')
                  .onUpdate('cascade')
                  .change();
          });
          expect(
            sql,
            'alter table "test" alter column "user_id" type bigint using ("user_id"::bigint); '
            'alter table "test" add constraint "test_user_id_fkey" foreign key ("user_id") references "users"("id") on delete cascade on update cascade',
          );
          expect(await DB.execute(sql), isNotNull);
        });
      });

      group('In Table', () {
        test('table.foreign(user_id).references(id).on(users)', () async {
          var sql = Schema.updateSql('test', (table) {
            table.bigInteger('user_id').change();
            table.foreign('user_id').references('id').on('users');
          });
          expect(
            sql,
            'alter table "test" alter column "user_id" type bigint using ("user_id"::bigint); '
            'alter table "test" add constraint "test_user_id_fkey" foreign key ("user_id") references "users"("id")',
          );
          expect(await DB.execute(sql), isNotNull);
        });
      });
    });

    group('Drop', () {
      setUp(() async {
        await Schema.create('test', (table) {
          table.bigInteger('user_id').references('id').on('users');
        });
      });

      test('table.dropForeign(columns: [user_id])', () async {
        var sql = Schema.updateSql('test', (table) {
          table.dropForeign(columns: ['user_id']);
        });
        expect(
          sql,
          'alter table "test" drop constraint "test_user_id_fkey"',
        );
        expect(await DB.execute(sql), isNotNull);
      });

      test('table.dropForeign(names: [test_user_id_fkey])', () async {
        var sql = Schema.updateSql('test', (table) {
          table.dropForeign(names: ['test_user_id_fkey']);
        });
        expect(
          sql,
          'alter table "test" drop constraint "test_user_id_fkey"',
        );
        expect(await DB.execute(sql), isNotNull);
      });
    });
  });
}
