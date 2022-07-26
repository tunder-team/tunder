import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/test.dart';

main() {
  group('Check Constraint', () {
    useDatabaseTransactions();

    group('Creation', () {
      group('In Column', () {
        test('table.integer(price).check(price > 0)', () async {
          var sql = Schema.createSql('test', (table) {
            table.integer('price').check('price > 0');
          });
          expect(sql,
              'create table "test" ("price" integer constraint "test_price_check" check (price > 0))');
          expect(await DB.execute(sql), isNotNull);
        });

        test('table.integer(price).check(price > 0, name: custom_name)',
            () async {
          var sql = Schema.createSql('test', (table) {
            table.integer('price').check('price > 0', name: 'positive_price');
          });
          expect(sql,
              'create table "test" ("price" integer constraint "positive_price" check (price > 0))');
        });
      });

      group('In Table', () {
        test('table.check(price > 0)', () async {
          var sql = Schema.createSql('test', (table) {
            table.integer('price');
            table.check('price > 0');
          });
          expect(sql,
              'create table "test" ("price" integer, constraint "test_check" check (price > 0))');
          expect(await DB.execute(sql), isNotNull);
        });
        test('table.check(price > 0, name: positive_price)', () async {
          var sql = Schema.createSql('test', (table) {
            table.integer('price');
            table.check('price > 0', name: 'positive_price');
          });
          expect(sql,
              'create table "test" ("price" integer, constraint "positive_price" check (price > 0))');
        });
      });
    });

    group('Update', () {
      setUp(() async {
        await Schema.create('test', (table) {
          table.integer('price');
        });
      });

      group('In Column', () {
        test('table.integer(price).check(price > 0).change()', () async {
          var sql = Schema.updateSql('test', (table) {
            table.integer('price').check('price > 0').change();
          });
          expect(
            sql,
            'alter table "test" alter column "price" type integer using ("price"::integer); '
            'alter table "test" add constraint "test_price_check" check (price > 0)',
          );
          expect(await DB.execute(sql), isNotNull);
        });

        test(
            'table.integer(price).check(price > 0, name: custom_name).change()',
            () async {
          var sql = Schema.updateSql('test', (table) {
            table
                .integer('price')
                .check('price > 0', name: 'positive_price')
                .change();
          });
          expect(
            sql,
            'alter table "test" alter column "price" type integer using ("price"::integer); '
            'alter table "test" add constraint "positive_price" check (price > 0)',
          );
        });
      });

      group('In Table', () {
        test('table.check(price > 0)', () async {
          var sql = Schema.updateSql('test', (table) {
            table.check('price > 0');
          });
          expect(
            sql,
            'alter table "test" add constraint "test_check" check (price > 0)',
          );
          expect(await DB.execute(sql), isNotNull);
        });
        test('table.check(price > 0, name: positive_price)', () async {
          var sql = Schema.updateSql('test', (table) {
            table.check('price > 0', name: 'positive_price');
          });
          expect(
            sql,
            'alter table "test" add constraint "positive_price" check (price > 0)',
          );
          expect(await DB.execute(sql), isNotNull);
        });
      });
    });

    group('Drop', () {
      setUp(() async {
        await Schema.create('test', (table) {
          table.integer('price').check('price > 0');
        });
      });

      test('table.dropCheck(columns: [price])', () async {
        var sql = Schema.updateSql('test', (table) {
          table.dropCheck(columns: ['price']);
        });
        expect(
          sql,
          'alter table "test" drop constraint "test_price_check"',
        );
        expect(await DB.execute(sql), isNotNull);
      });
      test('table.dropCheck(names: [test_price_check])', () async {
        var sql = Schema.updateSql('test', (table) {
          table.dropCheck(names: ['test_price_check']);
        });
        expect(
          sql,
          'alter table "test" drop constraint "test_price_check"',
        );
        expect(await DB.execute(sql), isNotNull);
      });
    });
  });
}
