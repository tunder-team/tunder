import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/test.dart';

main() {
  useDatabaseTransactions();

  group('Postgres Schema.update', () {
    setUp(() async {
      await Schema.create('test', (table) {
        table.string('name');
      });
    });

    group('datatype string ->', () {
      var stringTestCases = {
        "table.string('email') -> should add a new column": {
          'action': () => Schema.updateSql('test', (t) => t.string('email')),
          'result': 'alter table "test" add column "email" varchar(255)'
        },
        "table.string('status', 123).defaultValue('active')": {
          'action': () => Schema.updateSql(
              'test', (t) => t.string('status', 123).defaultValue('active')),
          'result':
              'alter table "test" add column "status" varchar(123) default \'active\''
        },
        "table.string('name').defaultValue('inactive').change()": {
          'action': () => Schema.updateSql('test',
              (t) => t.string('name').defaultValue('inactive').change()),
          'result': 'alter table "test" alter column "name" type varchar(255); '
              'alter table "test" alter column "name" set default \'inactive\''
        },
        "table.string('name').primary().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.string('name').primary().change()),
          'result': 'alter table "test" alter column "name" type varchar(255); '
              'alter table "test" add constraint "test_name_pkey" primary key ("name")'
        },
        "table.string('name').primary().nullable().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.string('name').primary().nullable().change()),
          'result': 'alter table "test" alter column "name" type varchar(255); '
              'alter table "test" alter column "name" drop not null; '
              'alter table "test" add constraint "test_name_pkey" primary key ("name")'
        },
        "table.string('name').unique().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.string('name').unique().change()),
          'result': 'alter table "test" alter column "name" type varchar(255); '
              'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.string('name').nullable().unique().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.string('name').nullable().unique().change()),
          'result': 'alter table "test" alter column "name" type varchar(255); '
              'alter table "test" alter column "name" drop not null; '
              'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.string('name', 123).index().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.string('name', 123).index().change()),
          'result': 'alter table "test" alter column "name" type varchar(123); '
              'create index "test_name_index" on "test" ("name")'
        },
        "table.string('name', 321).index('custom_index_name').change()": {
          'action': () => Schema.updateSql('test',
              (t) => t.string('name', 123).index('custom_index_name').change()),
          'result': 'alter table "test" alter column "name" type varchar(123); '
              'create index "custom_index_name" on "test" ("name")'
        },
      };

      stringTestCases.forEach(
        (testCase, value) => {
          test(testCase, () async {
            var sql = (value['action'] as Function)();
            expect(sql, value['result']);
            expect(await DB.execute(sql), isNotNull);
          })
        },
      );
    });

    group('datatype text ->', () {
      var textTestCases = {
        "table.text('email') -> should add a new column": {
          'action': () => Schema.updateSql('test', (t) => t.text('email')),
          'result': 'alter table "test" add column "email" text'
        },
        "table.text('status').defaultValue('active')": {
          'action': () => Schema.updateSql(
              'test', (t) => t.text('status').defaultValue('active')),
          'result':
              'alter table "test" add column "status" text default \'active\''
        },
        "table.text('name').defaultValue('inactive').change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.text('name').defaultValue('inactive').change()),
          'result': 'alter table "test" alter column "name" type text; '
              'alter table "test" alter column "name" set default \'inactive\''
        },
        "table.text('name').primary().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.text('name').primary().change()),
          'result': 'alter table "test" alter column "name" type text; '
              'alter table "test" add constraint "test_name_pkey" primary key ("name")'
        },
        "table.text('name').primary().nullable().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.text('name').primary().nullable().change()),
          'result': 'alter table "test" alter column "name" type text; '
              'alter table "test" alter column "name" drop not null; '
              'alter table "test" add constraint "test_name_pkey" primary key ("name")'
        },
        "table.text('name').unique().change()": {
          'action': () =>
              Schema.updateSql('test', (t) => t.text('name').unique().change()),
          'result': 'alter table "test" alter column "name" type text; '
              'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.text('name').nullable().unique().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.text('name').nullable().unique().change()),
          'result': 'alter table "test" alter column "name" type text; '
              'alter table "test" alter column "name" drop not null; '
              'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.text('name').index().change()": {
          'action': () =>
              Schema.updateSql('test', (t) => t.text('name').index().change()),
          'result': 'alter table "test" alter column "name" type text; '
              'create index "test_name_index" on "test" ("name")'
        },
        "table.text('name').index('custom_index_name').change()": {
          'action': () => Schema.updateSql('test',
              (t) => t.text('name').index('custom_index_name').change()),
          'result': 'alter table "test" alter column "name" type text; '
              'create index "custom_index_name" on "test" ("name")'
        },
      };

      textTestCases.forEach(
        (testCase, value) => {
          test(testCase, () async {
            var sql = (value['action'] as Function)();
            expect(sql, value['result']);
            expect(await DB.execute(sql), isNotNull);
          })
        },
      );
    });

    group('datatype integer ->', () {
      var integerTestCases = {
        "table.integer('email') -> should add a new column": {
          'action': () => Schema.updateSql('test', (t) => t.integer('email')),
          'result': 'alter table "test" add column "email" integer'
        },
        "table.integer('status').defaultValue(123)": {
          'action': () => Schema.updateSql(
              'test', (t) => t.integer('status').defaultValue(123)),
          'result': 'alter table "test" add column "status" integer default 123'
        },
        "table.integer('name').defaultValue(123).change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.integer('name').defaultValue(123).change()),
          'result':
              'alter table "test" alter column "name" type integer using ("name"::integer); '
                  'alter table "test" alter column "name" set default 123'
        },
        "table.integer('name').primary().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.integer('name').primary().change()),
          'result':
              'alter table "test" alter column "name" type integer using ("name"::integer); '
                  'alter table "test" add constraint "test_name_pkey" primary key ("name")'
        },
        "table.integer('name').primary().nullable().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.integer('name').primary().nullable().change()),
          'result':
              'alter table "test" alter column "name" type integer using ("name"::integer); '
                  'alter table "test" alter column "name" drop not null; '
                  'alter table "test" add constraint "test_name_pkey" primary key ("name")'
        },
        "table.integer('name').unique().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.integer('name').unique().change()),
          'result':
              'alter table "test" alter column "name" type integer using ("name"::integer); '
                  'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.integer('name').nullable().unique().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.integer('name').nullable().unique().change()),
          'result':
              'alter table "test" alter column "name" type integer using ("name"::integer); '
                  'alter table "test" alter column "name" drop not null; '
                  'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.integer('name').index().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.integer('name').index().change()),
          'result':
              'alter table "test" alter column "name" type integer using ("name"::integer); '
                  'create index "test_name_index" on "test" ("name")'
        },
        "table.integer('name').index('custom_index_name').change()": {
          'action': () => Schema.updateSql('test',
              (t) => t.integer('name').index('custom_index_name').change()),
          'result':
              'alter table "test" alter column "name" type integer using ("name"::integer); '
                  'create index "custom_index_name" on "test" ("name")'
        },
        "table.integer('name').autoIncrement().unique().change()": {
          'action': () => Schema.updateSql('test',
              (t) => t.integer('name').autoIncrement().unique().change()),
          'result': 'alter table "test" alter column "name" type integer using ("name"::integer); '
              'create sequence "test_name_seq" owned by "test"."name"; '
              'select setval(\'"test_name_seq"\', (select max("name") from "test"), false); '
              'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
      };

      integerTestCases.forEach(
        (testCase, value) => {
          test(testCase, () async {
            var sql = (value['action'] as Function)();
            expect(sql, value['result']);
            expect(await DB.execute(sql), isNotNull);
          })
        },
      );
    });

    group('datatype bigInteger ->', () {
      var bigIntegerTestCases = {
        "table.bigInteger('email') -> should add a new column": {
          'action': () =>
              Schema.updateSql('test', (t) => t.bigInteger('email')),
          'result': 'alter table "test" add column "email" bigint'
        },
        "table.bigInteger('status').defaultValue(123)": {
          'action': () => Schema.updateSql(
              'test', (t) => t.bigInteger('status').defaultValue(123)),
          'result': 'alter table "test" add column "status" bigint default 123'
        },
        "table.bigInteger('name').defaultValue(123).change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.bigInteger('name').defaultValue(123).change()),
          'result':
              'alter table "test" alter column "name" type bigint using ("name"::bigint); '
                  'alter table "test" alter column "name" set default 123'
        },
        "table.bigInteger('name').primary().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.bigInteger('name').primary().change()),
          'result':
              'alter table "test" alter column "name" type bigint using ("name"::bigint); '
                  'alter table "test" add constraint "test_name_pkey" primary key ("name")'
        },
        "table.bigInteger('name').primary().nullable().change()": {
          'action': () => Schema.updateSql('test',
              (t) => t.bigInteger('name').primary().nullable().change()),
          'result':
              'alter table "test" alter column "name" type bigint using ("name"::bigint); '
                  'alter table "test" alter column "name" drop not null; '
                  'alter table "test" add constraint "test_name_pkey" primary key ("name")'
        },
        "table.bigInteger('name').unique().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.bigInteger('name').unique().change()),
          'result':
              'alter table "test" alter column "name" type bigint using ("name"::bigint); '
                  'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.bigInteger('name').nullable().unique().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.bigInteger('name').nullable().unique().change()),
          'result':
              'alter table "test" alter column "name" type bigint using ("name"::bigint); '
                  'alter table "test" alter column "name" drop not null; '
                  'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.bigInteger('name').index().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.bigInteger('name').index().change()),
          'result':
              'alter table "test" alter column "name" type bigint using ("name"::bigint); '
                  'create index "test_name_index" on "test" ("name")'
        },
        "table.bigInteger('name').index('custom_index_name').change()": {
          'action': () => Schema.updateSql('test',
              (t) => t.bigInteger('name').index('custom_index_name').change()),
          'result':
              'alter table "test" alter column "name" type bigint using ("name"::bigint); '
                  'create index "custom_index_name" on "test" ("name")'
        },
        "table.bigInteger('name').autoIncrement().unique().change()": {
          'action': () => Schema.updateSql('test',
              (t) => t.bigInteger('name').autoIncrement().unique().change()),
          'result': 'alter table "test" alter column "name" type bigint using ("name"::bigint); '
              'create sequence "test_name_seq" owned by "test"."name"; '
              'select setval(\'"test_name_seq"\', (select max("name") from "test"), false); '
              'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
      };

      bigIntegerTestCases.forEach(
        (testCase, value) => {
          test(testCase, () async {
            var sql = (value['action'] as Function)();
            expect(sql, value['result']);
            expect(await DB.execute(sql), isNotNull);
          })
        },
      );
    });

    group('datatype smallInteger ->', () {
      var smallIntegerTestCases = {
        "table.smallInteger('email') -> should add a new column": {
          'action': () =>
              Schema.updateSql('test', (t) => t.smallInteger('email')),
          'result': 'alter table "test" add column "email" smallint'
        },
        "table.smallInteger('status').defaultValue(123)": {
          'action': () => Schema.updateSql(
              'test', (t) => t.smallInteger('status').defaultValue(123)),
          'result':
              'alter table "test" add column "status" smallint default 123'
        },
        "table.smallInteger('name').defaultValue(123).change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.smallInteger('name').defaultValue(123).change()),
          'result':
              'alter table "test" alter column "name" type smallint using ("name"::smallint); '
                  'alter table "test" alter column "name" set default 123'
        },
        "table.smallInteger('name').primary().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.smallInteger('name').primary().change()),
          'result':
              'alter table "test" alter column "name" type smallint using ("name"::smallint); '
                  'alter table "test" add constraint "test_name_pkey" primary key ("name")'
        },
        "table.smallInteger('name').primary().nullable().change()": {
          'action': () => Schema.updateSql('test',
              (t) => t.smallInteger('name').primary().nullable().change()),
          'result':
              'alter table "test" alter column "name" type smallint using ("name"::smallint); '
                  'alter table "test" alter column "name" drop not null; '
                  'alter table "test" add constraint "test_name_pkey" primary key ("name")'
        },
        "table.smallInteger('name').unique().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.smallInteger('name').unique().change()),
          'result':
              'alter table "test" alter column "name" type smallint using ("name"::smallint); '
                  'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.smallInteger('name').nullable().unique().change()": {
          'action': () => Schema.updateSql('test',
              (t) => t.smallInteger('name').nullable().unique().change()),
          'result':
              'alter table "test" alter column "name" type smallint using ("name"::smallint); '
                  'alter table "test" alter column "name" drop not null; '
                  'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.smallInteger('name').index().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.smallInteger('name').index().change()),
          'result':
              'alter table "test" alter column "name" type smallint using ("name"::smallint); '
                  'create index "test_name_index" on "test" ("name")'
        },
        "table.smallInteger('name').index('custom_index_name').change()": {
          'action': () => Schema.updateSql(
              'test',
              (t) =>
                  t.smallInteger('name').index('custom_index_name').change()),
          'result':
              'alter table "test" alter column "name" type smallint using ("name"::smallint); '
                  'create index "custom_index_name" on "test" ("name")'
        },
        "table.smallInteger('name').autoIncrement().unique().change()": {
          'action': () => Schema.updateSql('test',
              (t) => t.smallInteger('name').autoIncrement().unique().change()),
          'result': 'alter table "test" alter column "name" type smallint using ("name"::smallint); '
              'create sequence "test_name_seq" owned by "test"."name"; '
              'select setval(\'"test_name_seq"\', (select max("name") from "test"), false); '
              'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
      };

      smallIntegerTestCases.forEach(
        (testCase, value) => {
          test(testCase, () async {
            var sql = (value['action'] as Function)();
            expect(sql, value['result']);
            expect(await DB.execute(sql), isNotNull);
          })
        },
      );
    });

    group('datatype decimal ->', () {
      var decimalTestCases = {
        "table.decimal('email') -> should add a new column": {
          'action': () => Schema.updateSql('test', (t) => t.decimal('email')),
          'result': 'alter table "test" add column "email" decimal(12, 2)'
        },
        "table.decimal('status').defaultValue(123)": {
          'action': () => Schema.updateSql(
              'test', (t) => t.decimal('status').defaultValue(12.3)),
          'result':
              'alter table "test" add column "status" decimal(12, 2) default 12.3'
        },
        "table.decimal('name').defaultValue(123).change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.decimal('name').defaultValue(12.3).change()),
          'result':
              'alter table "test" alter column "name" type decimal(12, 2) using ("name"::decimal); '
                  'alter table "test" alter column "name" set default 12.3'
        },
        "table.decimal('name').primary().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.decimal('name').primary().change()),
          'result':
              'alter table "test" alter column "name" type decimal(12, 2) using ("name"::decimal); '
                  'alter table "test" add constraint "test_name_pkey" primary key ("name")'
        },
        "table.decimal('name').primary().nullable().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.decimal('name').primary().nullable().change()),
          'result':
              'alter table "test" alter column "name" type decimal(12, 2) using ("name"::decimal); '
                  'alter table "test" alter column "name" drop not null; '
                  'alter table "test" add constraint "test_name_pkey" primary key ("name")'
        },
        "table.decimal('name').unique().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.decimal('name').unique().change()),
          'result':
              'alter table "test" alter column "name" type decimal(12, 2) using ("name"::decimal); '
                  'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.decimal('name').nullable().unique().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.decimal('name').nullable().unique().change()),
          'result':
              'alter table "test" alter column "name" type decimal(12, 2) using ("name"::decimal); '
                  'alter table "test" alter column "name" drop not null; '
                  'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.decimal('name').index().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.decimal('name').index().change()),
          'result':
              'alter table "test" alter column "name" type decimal(12, 2) using ("name"::decimal); '
                  'create index "test_name_index" on "test" ("name")'
        },
        "table.decimal('name').index('custom_index_name').change()": {
          'action': () => Schema.updateSql('test',
              (t) => t.decimal('name').index('custom_index_name').change()),
          'result':
              'alter table "test" alter column "name" type decimal(12, 2) using ("name"::decimal); '
                  'create index "custom_index_name" on "test" ("name")'
        },
        "table.decimal('name', precision: 14, scale: 3).index('custom_index_name').change()":
            {
          'action': () => Schema.updateSql(
              'test',
              (t) => t
                  .decimal('name', precision: 14, scale: 3)
                  .index('custom_index_name')
                  .change()),
          'result':
              'alter table "test" alter column "name" type decimal(14, 3) using ("name"::decimal); '
                  'create index "custom_index_name" on "test" ("name")'
        },
      };

      decimalTestCases.forEach(
        (testCase, value) => {
          test(testCase, () async {
            var sql = (value['action'] as Function)();
            expect(sql, value['result']);
            expect(await DB.execute(sql), isNotNull);
          })
        },
      );
    });

    group('datatype boolean ->', () {
      var booleanTestCases = {
        "table.boolean('name').change()": {
          'action': () =>
              Schema.updateSql('test', (t) => t.boolean('name').change()),
          'result':
              'alter table "test" alter column "name" type boolean using ("name"::boolean)'
        },
        "table.boolean('name').defaultValue(true).change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.boolean('name').defaultValue(true).change()),
          'result':
              'alter table "test" alter column "name" type boolean using ("name"::boolean); '
                  'alter table "test" alter column "name" set default true'
        },
        "table.boolean('name').unique().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.boolean('name').unique().change()),
          'result':
              'alter table "test" alter column "name" type boolean using ("name"::boolean); '
                  'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.boolean('name').nullable().unique().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.boolean('name').nullable().unique().change()),
          'result':
              'alter table "test" alter column "name" type boolean using ("name"::boolean); '
                  'alter table "test" alter column "name" drop not null; '
                  'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.boolean('name').index().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.boolean('name').index().change()),
          'result':
              'alter table "test" alter column "name" type boolean using ("name"::boolean); '
                  'create index "test_name_index" on "test" ("name")'
        },
      };

      booleanTestCases.forEach(
        (testCase, value) => {
          test(testCase, () async {
            var sql = (value['action'] as Function)();
            expect(sql, value['result']);
            expect(await DB.execute(sql), isNotNull);
          })
        },
      );
    });

    group('datatype timestamp ->', () {
      var timestampTestCases = {
        "table.timestamp('name').change()": {
          'action': () =>
              Schema.updateSql('test', (t) => t.timestamp('name').change()),
          'result':
              'alter table "test" alter column "name" type timestamp using ("name"::timestamp)'
        },
        "table.timestamp('name').defaultToNow().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.timestamp('name').defaultToNow().change()),
          'result':
              'alter table "test" alter column "name" type timestamp using ("name"::timestamp); '
                  'alter table "test" alter column "name" set default current_timestamp(6)'
        },
        "table.timestamp('name').defaultToNow(3).change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.timestamp('name').defaultToNow(3).change()),
          'result':
              'alter table "test" alter column "name" type timestamp using ("name"::timestamp); '
                  'alter table "test" alter column "name" set default current_timestamp(3)'
        },
        "table.timestamp('name').defaultToCurrent().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.timestamp('name').defaultToCurrent().change()),
          'result':
              'alter table "test" alter column "name" type timestamp using ("name"::timestamp); '
                  'alter table "test" alter column "name" set default current_timestamp(6)'
        },
        "table.timestamp('name').useCurrent().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.timestamp('name').useCurrent().change()),
          'result':
              'alter table "test" alter column "name" type timestamp using ("name"::timestamp); '
                  'alter table "test" alter column "name" set default current_timestamp(6)'
        },
        "table.timestamp('name').defaultRaw('NOW()').change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.timestamp('name').defaultRaw('NOW()').change()),
          'result':
              'alter table "test" alter column "name" type timestamp using ("name"::timestamp); '
                  'alter table "test" alter column "name" set default NOW()'
        },
        "table.timestamp('name').unique().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.timestamp('name').unique().change()),
          'result':
              'alter table "test" alter column "name" type timestamp using ("name"::timestamp); '
                  'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.timestamp('name').nullable().unique().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.timestamp('name').nullable().unique().change()),
          'result':
              'alter table "test" alter column "name" type timestamp using ("name"::timestamp); '
                  'alter table "test" alter column "name" drop not null; '
                  'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.timestamp('name').index().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.timestamp('name').index().change()),
          'result':
              'alter table "test" alter column "name" type timestamp using ("name"::timestamp); '
                  'create index "test_name_index" on "test" ("name")'
        },
      };

      timestampTestCases.forEach(
        (testCase, value) => {
          test(testCase, () async {
            var sql = (value['action'] as Function)();
            expect(sql, value['result']);
            expect(await DB.execute(sql), isNotNull);
          })
        },
      );
    });

    group('datatype dateTime (same as timestamp)  ->', () {
      var dateTimeTestCases = {
        "table.dateTime('name').change()": {
          'action': () =>
              Schema.updateSql('test', (t) => t.dateTime('name').change()),
          'result':
              'alter table "test" alter column "name" type timestamp using ("name"::timestamp)'
        },
        "table.dateTime('name').defaultToNow().change() -> defaults to precision 6":
            {
          'action': () => Schema.updateSql(
              'test', (t) => t.dateTime('name').defaultToNow().change()),
          'result':
              'alter table "test" alter column "name" type timestamp using ("name"::timestamp); '
                  'alter table "test" alter column "name" set default current_timestamp(6)'
        },
        "table.dateTime('name').defaultToCurrent().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.dateTime('name').defaultToCurrent().change()),
          'result':
              'alter table "test" alter column "name" type timestamp using ("name"::timestamp); '
                  'alter table "test" alter column "name" set default current_timestamp(6)'
        },
        "table.dateTime('name').useCurrent().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.dateTime('name').useCurrent().change()),
          'result':
              'alter table "test" alter column "name" type timestamp using ("name"::timestamp); '
                  'alter table "test" alter column "name" set default current_timestamp(6)'
        },
        "table.dateTime('name').defaultRaw('NOW()').change() runs accordingly":
            {
          'action': () => Schema.updateSql(
              'test', (t) => t.dateTime('name').defaultRaw('NOW()').change()),
          'result':
              'alter table "test" alter column "name" type timestamp using ("name"::timestamp); '
                  'alter table "test" alter column "name" set default NOW()'
        },
        "table.dateTime('name').unique().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.dateTime('name').unique().change()),
          'result':
              'alter table "test" alter column "name" type timestamp using ("name"::timestamp); '
                  'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.dateTime('name').nullable().unique().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.dateTime('name').nullable().unique().change()),
          'result':
              'alter table "test" alter column "name" type timestamp using ("name"::timestamp); '
                  'alter table "test" alter column "name" drop not null; '
                  'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.dateTime('name').index().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.dateTime('name').index().change()),
          'result':
              'alter table "test" alter column "name" type timestamp using ("name"::timestamp); '
                  'create index "test_name_index" on "test" ("name")'
        },
      };

      dateTimeTestCases.forEach(
        (testCase, value) => {
          test(testCase, () async {
            var sql = (value['action'] as Function)();
            expect(sql, value['result']);
            expect(await DB.execute(sql), isNotNull);
          })
        },
      );
    });

    group('datatype date -> ', () {
      var dateTestCases = {
        "table.date('name').change()": {
          'action': () =>
              Schema.updateSql('test', (t) => t.date('name').change()),
          'result':
              'alter table "test" alter column "name" type date using ("name"::date)'
        },
        "table.date('name').defaultToNow(3).change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.date('name').defaultToNow(3).change()),
          'result':
              'alter table "test" alter column "name" type date using ("name"::date); '
                  'alter table "test" alter column "name" set default current_timestamp(3)'
        },
        "table.date('name').defaultToCurrent(3).change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.date('name').defaultToCurrent(3).change()),
          'result':
              'alter table "test" alter column "name" type date using ("name"::date); '
                  'alter table "test" alter column "name" set default current_timestamp(3)'
        },
        "table.date('name').useCurrent(3).change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.date('name').useCurrent(3).change()),
          'result':
              'alter table "test" alter column "name" type date using ("name"::date); '
                  'alter table "test" alter column "name" set default current_timestamp(3)'
        },
        "table.date('name').defaultRaw('NOW()').change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.date('name').defaultRaw('NOW()').change()),
          'result':
              'alter table "test" alter column "name" type date using ("name"::date); '
                  'alter table "test" alter column "name" set default NOW()'
        },
        "table.date('name').unique().change()": {
          'action': () =>
              Schema.updateSql('test', (t) => t.date('name').unique().change()),
          'result':
              'alter table "test" alter column "name" type date using ("name"::date); '
                  'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.date('name').nullable().unique().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.date('name').nullable().unique().change()),
          'result':
              'alter table "test" alter column "name" type date using ("name"::date); '
                  'alter table "test" alter column "name" drop not null; '
                  'alter table "test" add constraint "test_name_unique" unique ("name")'
        },
        "table.date('name').index().change()": {
          'action': () =>
              Schema.updateSql('test', (t) => t.date('name').index().change()),
          'result':
              'alter table "test" alter column "name" type date using ("name"::date); '
                  'create index "test_name_index" on "test" ("name")'
        },
      };

      dateTestCases.forEach(
        (testCase, value) => {
          test(testCase, () async {
            var sql = (value['action'] as Function)();
            expect(sql, value['result']);
            expect(await DB.execute(sql), isNotNull);
          })
        },
      );
    });

    group('datatype json -> ', () {
      var jsonTestCases = {
        "table.json('name').change()": {
          'action': () =>
              Schema.updateSql('test', (t) => t.json('name').change()),
          'result':
              'alter table "test" alter column "name" type json using ("name"::json)'
        },
        "table.json('name').defaultValue('[]').change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.json('name').defaultValue('[]').change()),
          'result':
              'alter table "test" alter column "name" type json using ("name"::json); '
                  'alter table "test" alter column "name" set default \'[]\''
        },
        "table.json('name').nullable().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.json('name').nullable().change()),
          'result':
              'alter table "test" alter column "name" type json using ("name"::json); '
                  'alter table "test" alter column "name" drop not null'
        },
      };

      jsonTestCases.forEach(
        (testCase, value) => {
          test(testCase, () async {
            var sql = (value['action'] as Function)();
            expect(sql, value['result']);
            expect(await DB.execute(sql), isNotNull);
          })
        },
      );
    });

    group('datatype jsonb -> ', () {
      var jsonbTestCases = {
        "table.jsonb('name').change()": {
          'action': () =>
              Schema.updateSql('test', (t) => t.jsonb('name').change()),
          'result':
              'alter table "test" alter column "name" type jsonb using ("name"::jsonb)'
        },
        "table.jsonb('name').defaultValue('[]').change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.jsonb('name').defaultValue('[]').change()),
          'result':
              'alter table "test" alter column "name" type jsonb using ("name"::jsonb); '
                  'alter table "test" alter column "name" set default \'[]\''
        },
        "table.jsonb('name').nullable().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.jsonb('name').nullable().change()),
          'result':
              'alter table "test" alter column "name" type jsonb using ("name"::jsonb); '
                  'alter table "test" alter column "name" drop not null'
        },
      };

      jsonbTestCases.forEach(
        (testCase, value) => {
          test(testCase, () async {
            var sql = (value['action'] as Function)();
            expect(sql, value['result']);
            expect(await DB.execute(sql), isNotNull);
          })
        },
      );
    });

    group('compound types ->', () {
      var compoundTestCases = {
        // ID
        "table.id() generates bigserial primary key not null": {
          'action': () => Schema.updateSql('test', (t) => t.id()),
          'result':
              'alter table "test" add column "id" bigserial constraint "test_id_pkey" primary key not null'
        },
        "table.id(name)": {
          'action': () => Schema.updateSql('test', (t) => t.id('mid')),
          'result':
              'alter table "test" add column "mid" bigserial constraint "test_mid_pkey" primary key not null'
        },

        // String ID
        "table.stringId() generates varchar(16) primary key not null": {
          'action': () => Schema.updateSql('test', (t) => t.stringId()),
          'result':
              'alter table "test" add column "id" varchar(16) constraint "test_id_pkey" primary key not null'
        },
        "table.stringId(name)": {
          'action': () => Schema.updateSql('test', (t) => t.stringId('msid')),
          'result':
              'alter table "test" add column "msid" varchar(16) constraint "test_msid_pkey" primary key not null'
        },

        // Timestamps
        "table.timestamps()": {
          'action': () => Schema.updateSql('test', (t) => t.timestamps()),
          'result':
              'alter table "test" add column "created_at" timestamp not null default current_timestamp(6); '
                  'alter table "test" add column "updated_at" timestamp not null default current_timestamp(6)'
        },
        "table.timestamps(createdColumn: 'createdAt', updatedColumn: 'updatedAt')":
            {
          'action': () => Schema.updateSql(
              'test',
              (t) => t.timestamps(
                  createdColumn: 'createdAt', updatedColumn: 'updatedAt')),
          'result':
              'alter table "test" add column "createdAt" timestamp not null default current_timestamp(6); '
                  'alter table "test" add column "updatedAt" timestamp not null default current_timestamp(6)'
        },
        "table.timestamps(camelCase: true)": {
          'action': () =>
              Schema.updateSql('test', (t) => t.timestamps(camelCase: true)),
          'result':
              'alter table "test" add column "createdAt" timestamp not null default current_timestamp(6); '
                  'alter table "test" add column "updatedAt" timestamp not null default current_timestamp(6)'
        },
        "table.timestamps(camelCase: true, updatedColumn: 'updatedDate')": {
          'action': () => Schema.updateSql(
              'test',
              (t) =>
                  t.timestamps(camelCase: true, updatedColumn: 'updatedDate')),
          'result':
              'alter table "test" add column "createdAt" timestamp not null default current_timestamp(6); '
                  'alter table "test" add column "updatedDate" timestamp not null default current_timestamp(6)'
        },

        // Soft Deletes
        "table.softDeletes()": {
          'action': () => Schema.updateSql('test', (t) => t.softDeletes()),
          'result': 'alter table "test" add column "deleted_at" timestamp null'
        },
        "table.softDeletes('deletedAt')": {
          'action': () =>
              Schema.updateSql('test', (t) => t.softDeletes('deletedAt')),
          'result': 'alter table "test" add column "deletedAt" timestamp null'
        },
      };

      compoundTestCases.forEach(
        (testCase, value) => {
          test(testCase, () async {
            var sql = (value['action'] as Function)();
            expect(sql, value['result']);
            expect(await DB.execute(sql), isNotNull);
          })
        },
      );
    });
  });
}
