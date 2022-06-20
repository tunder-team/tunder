import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/test.dart';

main() {
  useDatabaseTransactions();

  group('Postgres Schema.create', () {
    group('datatype string ->', () {
      var stringTestCases = {
        "table.string('name')": {
          'action': () => Schema.createSql('test', (t) => t.string('name')),
          'result': 'create table "test" ("name" varchar(255))'
        },
        "table.string('name').notNullable()": {
          'action': () =>
              Schema.createSql('test', (t) => t.string('name').notNullable()),
          'result': 'create table "test" ("name" varchar(255) not null)'
        },
        "table.string('status').defaultValue('active')": {
          'action': () => Schema.createSql(
              'test', (t) => t.string('status').defaultValue('active')),
          'result':
              'create table "test" ("status" varchar(255) default \'active\')'
        },
        "table.string('name').unique()": {
          'action': () =>
              Schema.createSql('test', (t) => t.string('name').unique()),
          'result':
              'create table "test" ("name" varchar(255) constraint "test_name_unique" unique)'
        },
        "table.string('name').unique('custom_name')": {
          'action': () => Schema.createSql(
              'test', (t) => t.string('name').unique('custom_name')),
          'result':
              'create table "test" ("name" varchar(255) constraint "custom_name" unique)'
        },
        "table.string('name').nullable()": {
          'action': () =>
              Schema.createSql('test', (t) => t.string('name').nullable()),
          'result': 'create table "test" ("name" varchar(255) null)'
        },
        "table.string('name', 123)": {
          'action': () =>
              Schema.createSql('test', (t) => t.string('name', 123)),
          'result': 'create table "test" ("name" varchar(123))'
        },
        "table.string('name', 123).index()": {
          'action': () =>
              Schema.createSql('test', (t) => t.string('name', 123).index()),
          'result': 'create table "test" ("name" varchar(123)); '
              'create index "test_name_index" on "test" ("name")'
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
        "table.text('name')": {
          'action': () => Schema.createSql('test', (t) => t.text('name')),
          'result': 'create table "test" ("name" text)'
        },
        "table.text('name').defaultValue('jetete')": {
          'action': () => Schema.createSql(
              'test', (t) => t.text('name').defaultValue('jetete')),
          'result': 'create table "test" ("name" text default \'jetete\')'
        },
        "table.text('name').unique()": {
          'action': () =>
              Schema.createSql('test', (t) => t.text('name').unique()),
          'result':
              'create table "test" ("name" text constraint "test_name_unique" unique)'
        },
        "table.text('name').nullable()": {
          'action': () =>
              Schema.createSql('test', (t) => t.text('name').nullable()),
          'result': 'create table "test" ("name" text null)'
        },
        "table.text('name').index()": {
          'action': () =>
              Schema.createSql('test', (t) => t.text('name').index()),
          'result': 'create table "test" ("name" text); '
              'create index "test_name_index" on "test" ("name")'
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
        "table.integer('number')": {
          'action': () => Schema.createSql('test', (t) => t.integer('number')),
          'result': 'create table "test" ("number" integer)'
        },
        "table.integer('number').defaultValue(12)": {
          'action': () => Schema.createSql(
              'test', (t) => t.integer('number').defaultValue(12)),
          'result': 'create table "test" ("number" integer default 12)'
        },
        "table.integer('number').unique()": {
          'action': () =>
              Schema.createSql('test', (t) => t.integer('number').unique()),
          'result':
              'create table "test" ("number" integer constraint "test_number_unique" unique)'
        },
        "table.integer('number').nullable()": {
          'action': () =>
              Schema.createSql('test', (t) => t.integer('number').nullable()),
          'result': 'create table "test" ("number" integer null)'
        },
        "table.integer('number').autoIncrement.unique()": {
          'action': () => Schema.createSql(
              'test', (t) => t.integer('number').autoIncrement.unique()),
          'result':
              'create table "test" ("number" serial constraint "test_number_unique" unique)'
        },
        "table.integer('number').index()": {
          'action': () =>
              Schema.createSql('test', (t) => t.integer('number').index()),
          'result': 'create table "test" ("number" integer); '
              'create index "test_number_index" on "test" ("number")'
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
        "table.bigInteger('number')": {
          'action': () =>
              Schema.createSql('test', (t) => t.bigInteger('number')),
          'result': 'create table "test" ("number" bigint)'
        },
        "table.bigInteger('number').defaultValue(12)": {
          'action': () => Schema.createSql(
              'test', (t) => t.bigInteger('number').defaultValue(12)),
          'result': 'create table "test" ("number" bigint default 12)'
        },
        "table.bigInteger('number').unique()": {
          'action': () =>
              Schema.createSql('test', (t) => t.bigInteger('number').unique()),
          'result':
              'create table "test" ("number" bigint constraint "test_number_unique" unique)'
        },
        "table.bigInteger('number').nullable()": {
          'action': () => Schema.createSql(
              'test', (t) => t.bigInteger('number').nullable()),
          'result': 'create table "test" ("number" bigint null)'
        },
        "table.bigInteger('number').autoIncrement.unique()": {
          'action': () => Schema.createSql(
              'test', (t) => t.bigInteger('number').autoIncrement.unique()),
          'result':
              'create table "test" ("number" bigserial constraint "test_number_unique" unique)'
        },
        "table.bigInteger('number').index()": {
          'action': () =>
              Schema.createSql('test', (t) => t.bigInteger('number').index()),
          'result': 'create table "test" ("number" bigint); '
              'create index "test_number_index" on "test" ("number")'
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
        "table.smallInteger('number')": {
          'action': () =>
              Schema.createSql('test', (t) => t.smallInteger('number')),
          'result': 'create table "test" ("number" smallint)'
        },
        "table.smallInteger('number').defaultValue(12)": {
          'action': () => Schema.createSql(
              'test', (t) => t.smallInteger('number').defaultValue(12)),
          'result': 'create table "test" ("number" smallint default 12)'
        },
        "table.smallInteger('number').unique()": {
          'action': () => Schema.createSql(
              'test', (t) => t.smallInteger('number').unique()),
          'result':
              'create table "test" ("number" smallint constraint "test_number_unique" unique)'
        },
        "table.smallInteger('number').nullable()": {
          'action': () => Schema.createSql(
              'test', (t) => t.smallInteger('number').nullable()),
          'result': 'create table "test" ("number" smallint null)'
        },
        "table.smallInteger('number').autoIncrement.unique()": {
          'action': () => Schema.createSql(
              'test', (t) => t.smallInteger('number').autoIncrement.unique()),
          'result':
              'create table "test" ("number" smallserial constraint "test_number_unique" unique)'
        },
        "table.smallInteger('number').index()": {
          'action': () =>
              Schema.createSql('test', (t) => t.smallInteger('number').index()),
          'result': 'create table "test" ("number" smallint); '
              'create index "test_number_index" on "test" ("number")'
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
        "table.decimal('number') -> defaults to decimal(12, 2)": {
          'action': () => Schema.createSql('test', (t) => t.decimal('number')),
          'result': 'create table "test" ("number" decimal(12, 2))'
        },
        "table.decimal('number').defaultValue(10.2)": {
          'action': () => Schema.createSql(
              'test', (t) => t.decimal('number').defaultValue(10.2)),
          'result': 'create table "test" ("number" decimal(12, 2) default 10.2)'
        },
        "table.decimal('number', precision: 20) -> decimal(20, 2)": {
          'action': () => Schema.createSql(
              'test', (t) => t.decimal('number', precision: 20)),
          'result': 'create table "test" ("number" decimal(20, 2))'
        },
        "table.decimal('number', precision: 20, scale: 5) -> decimal(20, 5)": {
          'action': () => Schema.createSql(
              'test', (t) => t.decimal('number', precision: 20, scale: 5)),
          'result': 'create table "test" ("number" decimal(20, 5))'
        },
        "table.decimal('number', scale: 5) -> decimal(12, 5)": {
          'action': () =>
              Schema.createSql('test', (t) => t.decimal('number', scale: 5)),
          'result': 'create table "test" ("number" decimal(12, 5))'
        },
        "table.decimal('number').unique()": {
          'action': () =>
              Schema.createSql('test', (t) => t.decimal('number').unique()),
          'result':
              'create table "test" ("number" decimal(12, 2) constraint "test_number_unique" unique)'
        },
        "table.decimal('number').nullable()": {
          'action': () =>
              Schema.createSql('test', (t) => t.decimal('number').nullable()),
          'result': 'create table "test" ("number" decimal(12, 2) null)'
        },
        "table.decimal('number').autoIncrement.unique()": {
          'action': () => Schema.createSql(
              'test', (t) => t.decimal('number').autoIncrement.unique()),
          'result':
              'create table "test" ("number" decimal(12, 2) constraint "test_number_unique" unique)'
        },
        "table.decimal('number').index()": {
          'action': () =>
              Schema.createSql('test', (t) => t.decimal('number').index()),
          'result': 'create table "test" ("number" decimal(12, 2)); '
              'create index "test_number_index" on "test" ("number")'
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
        "table.boolean('name')": {
          'action': () => Schema.createSql('test', (t) => t.boolean('name')),
          'result': 'create table "test" ("name" boolean)'
        },
        "table.boolean('name').defaultValue(true)": {
          'action': () => Schema.createSql(
              'test', (t) => t.boolean('name').defaultValue(true)),
          'result': 'create table "test" ("name" boolean default true)'
        },
        "table.boolean('name').unique()": {
          'action': () =>
              Schema.createSql('test', (t) => t.boolean('name').unique()),
          'result':
              'create table "test" ("name" boolean constraint "test_name_unique" unique)'
        },
        "table.boolean('name').nullable()": {
          'action': () =>
              Schema.createSql('test', (t) => t.boolean('name').nullable()),
          'result': 'create table "test" ("name" boolean null)'
        },
        "table.boolean('name').index()": {
          'action': () =>
              Schema.createSql('test', (t) => t.boolean('name').index()),
          'result': 'create table "test" ("name" boolean); '
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
        "table.timestamp('created_at')": {
          'action': () =>
              Schema.createSql('test', (t) => t.timestamp('created_at')),
          'result': 'create table "test" ("created_at" timestamp)'
        },
        "table.timestamp('created_at').defaultToNow() -> defaults to precision 6":
            {
          'action': () => Schema.createSql(
              'test', (t) => t.timestamp('created_at').defaultToNow()),
          'result':
              'create table "test" ("created_at" timestamp default current_timestamp(6))'
        },
        "table.timestamp('created_at').defaultToNow(3)": {
          'action': () => Schema.createSql(
              'test', (t) => t.timestamp('created_at').defaultToNow(3)),
          'result':
              'create table "test" ("created_at" timestamp default current_timestamp(3))'
        },
        "table.timestamp('created_at').defaultToCurrent()": {
          'action': () => Schema.createSql(
              'test', (t) => t.timestamp('created_at').defaultToCurrent()),
          'result':
              'create table "test" ("created_at" timestamp default current_timestamp(6))'
        },
        "table.timestamp('created_at').useCurrent()": {
          'action': () => Schema.createSql(
              'test', (t) => t.timestamp('created_at').useCurrent()),
          'result':
              'create table "test" ("created_at" timestamp default current_timestamp(6))'
        },
        "table.timestamp('created_at').defaultRaw('now()') runs accordingly": {
          'action': () => Schema.createSql(
              'test', (t) => t.timestamp('created_at').defaultRaw('now()')),
          'result': 'create table "test" ("created_at" timestamp default now())'
        },
        "table.timestamp('created_at').unique()": {
          'action': () => Schema.createSql(
              'test', (t) => t.timestamp('created_at').unique()),
          'result':
              'create table "test" ("created_at" timestamp constraint "test_created_at_unique" unique)'
        },
        "table.timestamp('created_at').nullable()": {
          'action': () => Schema.createSql(
              'test', (t) => t.timestamp('created_at').nullable()),
          'result': 'create table "test" ("created_at" timestamp null)'
        },
        "table.timestamp('created_at').index()": {
          'action': () => Schema.createSql(
              'test', (t) => t.timestamp('created_at').index()),
          'result': 'create table "test" ("created_at" timestamp); '
              'create index "test_created_at_index" on "test" ("created_at")'
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
        "table.dateTime('created_at')": {
          'action': () =>
              Schema.createSql('test', (t) => t.dateTime('created_at')),
          'result': 'create table "test" ("created_at" timestamp)'
        },
        "table.dateTime('created_at').defaultToNow() -> defaults to precision 6":
            {
          'action': () => Schema.createSql(
              'test', (t) => t.dateTime('created_at').defaultToNow()),
          'result':
              'create table "test" ("created_at" timestamp default current_timestamp(6))'
        },
        "table.dateTime('created_at').defaultToCurrent()": {
          'action': () => Schema.createSql(
              'test', (t) => t.dateTime('created_at').defaultToCurrent()),
          'result':
              'create table "test" ("created_at" timestamp default current_timestamp(6))'
        },
        "table.dateTime('created_at').useCurrent()": {
          'action': () => Schema.createSql(
              'test', (t) => t.dateTime('created_at').useCurrent()),
          'result':
              'create table "test" ("created_at" timestamp default current_timestamp(6))'
        },
        "table.dateTime('created_at').defaultRaw('NOW()') runs accordingly": {
          'action': () => Schema.createSql(
              'test', (t) => t.dateTime('created_at').defaultRaw('NOW()')),
          'result': 'create table "test" ("created_at" timestamp default NOW())'
        },
        "table.dateTime('created_at').unique()": {
          'action': () => Schema.createSql(
              'test', (t) => t.dateTime('created_at').unique()),
          'result':
              'create table "test" ("created_at" timestamp constraint "test_created_at_unique" unique)'
        },
        "table.dateTime('created_at').nullable()": {
          'action': () => Schema.createSql(
              'test', (t) => t.dateTime('created_at').nullable()),
          'result': 'create table "test" ("created_at" timestamp null)'
        },
        "table.dateTime('created_at').index()": {
          'action': () =>
              Schema.createSql('test', (t) => t.dateTime('created_at').index()),
          'result': 'create table "test" ("created_at" timestamp); '
              'create index "test_created_at_index" on "test" ("created_at")'
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
        "table.date('created_at')": {
          'action': () => Schema.createSql('test', (t) => t.date('created_at')),
          'result': 'create table "test" ("created_at" date)'
        },
        "table.date('created_at').defaultToNow(3)": {
          'action': () => Schema.createSql(
              'test', (t) => t.date('created_at').defaultToNow(3)),
          'result':
              'create table "test" ("created_at" date default current_timestamp(3))'
        },
        "table.date('created_at').defaultToCurrent(3)": {
          'action': () => Schema.createSql(
              'test', (t) => t.date('created_at').defaultToCurrent(3)),
          'result':
              'create table "test" ("created_at" date default current_timestamp(3))'
        },
        "table.date('created_at').useCurrent(3)": {
          'action': () => Schema.createSql(
              'test', (t) => t.date('created_at').useCurrent(3)),
          'result':
              'create table "test" ("created_at" date default current_timestamp(3))'
        },
        "table.date('created_at').defaultRaw('NOW()')": {
          'action': () => Schema.createSql(
              'test', (t) => t.date('created_at').defaultRaw('NOW()')),
          'result': 'create table "test" ("created_at" date default NOW())'
        },
        "table.date('created_at').unique()": {
          'action': () =>
              Schema.createSql('test', (t) => t.date('created_at').unique()),
          'result':
              'create table "test" ("created_at" date constraint "test_created_at_unique" unique)'
        },
        "table.date('created_at').nullable()": {
          'action': () =>
              Schema.createSql('test', (t) => t.date('created_at').nullable()),
          'result': 'create table "test" ("created_at" date null)'
        },
        "table.date('created_at').index()": {
          'action': () =>
              Schema.createSql('test', (t) => t.date('created_at').index()),
          'result': 'create table "test" ("created_at" date); '
              'create index "test_created_at_index" on "test" ("created_at")'
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
        "table.json('address')": {
          'action': () => Schema.createSql('test', (t) => t.json('address')),
          'result': 'create table "test" ("address" json)'
        },
        "table.json('address').defaultValue('[]')": {
          'action': () => Schema.createSql(
              'test', (t) => t.json('address').defaultValue('[]')),
          'result': 'create table "test" ("address" json default \'[]\')'
        },
        "table.json('address').nullable": {
          'action': () =>
              Schema.createSql('test', (t) => t.json('address').nullable()),
          'result': 'create table "test" ("address" json null)'
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
        "table.jsonb('address')": {
          'action': () => Schema.createSql('test', (t) => t.jsonb('address')),
          'result': 'create table "test" ("address" jsonb)'
        },
        "table.jsonb('address').defaultValue('[]')": {
          'action': () => Schema.createSql(
              'test', (t) => t.jsonb('address').defaultValue('[]')),
          'result': 'create table "test" ("address" jsonb default \'[]\')'
        },
        "table.jsonb('address').nullable": {
          'action': () =>
              Schema.createSql('test', (t) => t.jsonb('address').nullable()),
          'result': 'create table "test" ("address" jsonb null)'
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

    group('compound types -> ', () {
      var compoundTestCases = {
        // ID
        "table.id() generates bigserial primary key": {
          'action': () => Schema.createSql('test', (t) => t.id()),
          'result': 'create table "test" ("id" bigserial primary key)'
        },
        "table.id(name)": {
          'action': () => Schema.createSql('test', (t) => t.id('mid')),
          'result': 'create table "test" ("mid" bigserial primary key)'
        },

        // String ID
        "table.stringId() generates varchar(16) primary key": {
          'action': () => Schema.createSql('test', (t) => t.stringId()),
          'result': 'create table "test" ("id" varchar(16) primary key)'
        },
        "table.stringId(name)": {
          'action': () => Schema.createSql('test', (t) => t.stringId('msid')),
          'result': 'create table "test" ("msid" varchar(16) primary key)'
        },

        // Timestamps
        "table.timestamps()": {
          'action': () => Schema.createSql('test', (t) => t.timestamps()),
          'result': 'create table "test" ('
              '"created_at" timestamp not null default current_timestamp(6), '
              '"updated_at" timestamp not null default current_timestamp(6))'
        },
        "table.timestamps(createdColumn: 'createdAt', updatedColumn: 'updatedAt')":
            {
          'action': () => Schema.createSql(
              'test',
              (t) => t.timestamps(
                  createdColumn: 'createdAt', updatedColumn: 'updatedAt')),
          'result': 'create table "test" ('
              '"createdAt" timestamp not null default current_timestamp(6), '
              '"updatedAt" timestamp not null default current_timestamp(6))'
        },
        "table.timestamps(camelCase: true)": {
          'action': () =>
              Schema.createSql('test', (t) => t.timestamps(camelCase: true)),
          'result': 'create table "test" ('
              '"createdAt" timestamp not null default current_timestamp(6), '
              '"updatedAt" timestamp not null default current_timestamp(6))'
        },
        "table.timestamps(camelCase: true, updatedColumn: 'updatedDate')": {
          'action': () => Schema.createSql(
              'test',
              (t) =>
                  t.timestamps(camelCase: true, updatedColumn: 'updatedDate')),
          'result': 'create table "test" ('
              '"createdAt" timestamp not null default current_timestamp(6), '
              '"updatedDate" timestamp not null default current_timestamp(6))'
        },

        // Soft Deletes
        "table.softDeletes()": {
          'action': () => Schema.createSql('test', (t) => t.softDeletes()),
          'result': 'create table "test" ("deleted_at" timestamp null)'
        },
        "table.softDeletes('deletedAt')": {
          'action': () =>
              Schema.createSql('test', (t) => t.softDeletes('deletedAt')),
          'result': 'create table "test" ("deletedAt" timestamp null)'
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
