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
          'result': 'CREATE TABLE "test" ("name" VARCHAR(255) NOT NULL);'
        },
        "table.string('status').defaultValue('active')": {
          'action': () => Schema.createSql(
              'test', (t) => t.string('status').defaultValue('active')),
          'result':
              'CREATE TABLE "test" ("status" VARCHAR(255) NOT NULL DEFAULT \'active\');'
        },
        "table.string('name').unique": {
          'action': () =>
              Schema.createSql('test', (t) => t.string('name').unique),
          'result': 'CREATE TABLE "test" ("name" VARCHAR(255) UNIQUE NOT NULL);'
        },
        "table.string('name').nullable.unique": {
          'action': () =>
              Schema.createSql('test', (t) => t.string('name').nullable.unique),
          'result': 'CREATE TABLE "test" ("name" VARCHAR(255) UNIQUE NULL);'
        },
        "table.string('name', 123)": {
          'action': () =>
              Schema.createSql('test', (t) => t.string('name', 123)),
          'result': 'CREATE TABLE "test" ("name" VARCHAR(123) NOT NULL);'
        },
        "table.string('name', 123).index": {
          'action': () =>
              Schema.createSql('test', (t) => t.string('name', 123).index),
          'result': 'CREATE TABLE "test" ("name" VARCHAR(123) NOT NULL); '
              'CREATE INDEX "test_name_index" ON "test" ("name")'
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
          'result': 'CREATE TABLE "test" ("name" TEXT NOT NULL);'
        },
        "table.text('name').defaultValue('jetete')": {
          'action': () => Schema.createSql(
              'test', (t) => t.text('name').defaultValue('jetete')),
          'result':
              'CREATE TABLE "test" ("name" TEXT NOT NULL DEFAULT \'jetete\');'
        },
        "table.text('name').unique": {
          'action': () =>
              Schema.createSql('test', (t) => t.text('name').unique),
          'result': 'CREATE TABLE "test" ("name" TEXT UNIQUE NOT NULL);'
        },
        "table.text('name').nullable.unique": {
          'action': () =>
              Schema.createSql('test', (t) => t.text('name').nullable.unique),
          'result': 'CREATE TABLE "test" ("name" TEXT UNIQUE NULL);'
        },
        "table.text('name').index": {
          'action': () => Schema.createSql('test', (t) => t.text('name').index),
          'result': 'CREATE TABLE "test" ("name" TEXT NOT NULL); '
              'CREATE INDEX "test_name_index" ON "test" ("name")'
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
          'result': 'CREATE TABLE "test" ("number" INTEGER NOT NULL);'
        },
        "table.integer('number').defaultValue(12)": {
          'action': () => Schema.createSql(
              'test', (t) => t.integer('number').defaultValue(12)),
          'result':
              'CREATE TABLE "test" ("number" INTEGER NOT NULL DEFAULT 12);'
        },
        "table.integer('number').unique": {
          'action': () =>
              Schema.createSql('test', (t) => t.integer('number').unique),
          'result': 'CREATE TABLE "test" ("number" INTEGER UNIQUE NOT NULL);'
        },
        "table.integer('number').nullable.unique": {
          'action': () => Schema.createSql(
              'test', (t) => t.integer('number').nullable.unique),
          'result': 'CREATE TABLE "test" ("number" INTEGER UNIQUE NULL);'
        },
        "table.integer('number').autoIncrement.unique": {
          'action': () => Schema.createSql(
              'test', (t) => t.integer('number').autoIncrement.unique),
          'result': 'CREATE TABLE "test" ("number" SERIAL UNIQUE NOT NULL);'
        },
        "table.integer('number').index": {
          'action': () =>
              Schema.createSql('test', (t) => t.integer('number').index),
          'result': 'CREATE TABLE "test" ("number" INTEGER NOT NULL); '
              'CREATE INDEX "test_number_index" ON "test" ("number")'
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
          'result': 'CREATE TABLE "test" ("number" BIGINT NOT NULL);'
        },
        "table.bigInteger('number').defaultValue(12)": {
          'action': () => Schema.createSql(
              'test', (t) => t.bigInteger('number').defaultValue(12)),
          'result': 'CREATE TABLE "test" ("number" BIGINT NOT NULL DEFAULT 12);'
        },
        "table.bigInteger('number').unique": {
          'action': () =>
              Schema.createSql('test', (t) => t.bigInteger('number').unique),
          'result': 'CREATE TABLE "test" ("number" BIGINT UNIQUE NOT NULL);'
        },
        "table.bigInteger('number').nullable.unique": {
          'action': () => Schema.createSql(
              'test', (t) => t.bigInteger('number').nullable.unique),
          'result': 'CREATE TABLE "test" ("number" BIGINT UNIQUE NULL);'
        },
        "table.bigInteger('number').autoIncrement.unique": {
          'action': () => Schema.createSql(
              'test', (t) => t.bigInteger('number').autoIncrement.unique),
          'result': 'CREATE TABLE "test" ("number" BIGSERIAL UNIQUE NOT NULL);'
        },
        "table.bigInteger('number').index": {
          'action': () =>
              Schema.createSql('test', (t) => t.bigInteger('number').index),
          'result': 'CREATE TABLE "test" ("number" BIGINT NOT NULL); '
              'CREATE INDEX "test_number_index" ON "test" ("number")'
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
          'result': 'CREATE TABLE "test" ("number" SMALLINT NOT NULL);'
        },
        "table.smallInteger('number').defaultValue(12)": {
          'action': () => Schema.createSql(
              'test', (t) => t.smallInteger('number').defaultValue(12)),
          'result':
              'CREATE TABLE "test" ("number" SMALLINT NOT NULL DEFAULT 12);'
        },
        "table.smallInteger('number').unique": {
          'action': () =>
              Schema.createSql('test', (t) => t.smallInteger('number').unique),
          'result': 'CREATE TABLE "test" ("number" SMALLINT UNIQUE NOT NULL);'
        },
        "table.smallInteger('number').nullable.unique": {
          'action': () => Schema.createSql(
              'test', (t) => t.smallInteger('number').nullable.unique),
          'result': 'CREATE TABLE "test" ("number" SMALLINT UNIQUE NULL);'
        },
        "table.smallInteger('number').autoIncrement.unique": {
          'action': () => Schema.createSql(
              'test', (t) => t.smallInteger('number').autoIncrement.unique),
          'result':
              'CREATE TABLE "test" ("number" SMALLSERIAL UNIQUE NOT NULL);'
        },
        "table.smallInteger('number').index": {
          'action': () =>
              Schema.createSql('test', (t) => t.smallInteger('number').index),
          'result': 'CREATE TABLE "test" ("number" SMALLINT NOT NULL); '
              'CREATE INDEX "test_number_index" ON "test" ("number")'
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
        "table.decimal('number') -> defaults to DECIMAL(12, 2)": {
          'action': () => Schema.createSql('test', (t) => t.decimal('number')),
          'result': 'CREATE TABLE "test" ("number" DECIMAL(12, 2) NOT NULL);'
        },
        "table.decimal('number').defaultValue(10.2)": {
          'action': () => Schema.createSql(
              'test', (t) => t.decimal('number').defaultValue(10.2)),
          'result':
              'CREATE TABLE "test" ("number" DECIMAL(12, 2) NOT NULL DEFAULT 10.2);'
        },
        "table.decimal('number', precision: 20) -> DECIMAL(20, 2)": {
          'action': () => Schema.createSql(
              'test', (t) => t.decimal('number', precision: 20)),
          'result': 'CREATE TABLE "test" ("number" DECIMAL(20, 2) NOT NULL);'
        },
        "table.decimal('number', precision: 20, scale: 5) -> DECIMAL(20, 5)": {
          'action': () => Schema.createSql(
              'test', (t) => t.decimal('number', precision: 20, scale: 5)),
          'result': 'CREATE TABLE "test" ("number" DECIMAL(20, 5) NOT NULL);'
        },
        "table.decimal('number', scale: 5) -> DECIMAL(12, 5)": {
          'action': () =>
              Schema.createSql('test', (t) => t.decimal('number', scale: 5)),
          'result': 'CREATE TABLE "test" ("number" DECIMAL(12, 5) NOT NULL);'
        },
        "table.decimal('number').unique": {
          'action': () =>
              Schema.createSql('test', (t) => t.decimal('number').unique),
          'result':
              'CREATE TABLE "test" ("number" DECIMAL(12, 2) UNIQUE NOT NULL);'
        },
        "table.decimal('number').nullable.unique": {
          'action': () => Schema.createSql(
              'test', (t) => t.decimal('number').nullable.unique),
          'result': 'CREATE TABLE "test" ("number" DECIMAL(12, 2) UNIQUE NULL);'
        },
        "table.decimal('number').autoIncrement.unique": {
          'action': () => Schema.createSql(
              'test', (t) => t.decimal('number').autoIncrement.unique),
          'result':
              'CREATE TABLE "test" ("number" DECIMAL(12, 2) UNIQUE NOT NULL);'
        },
        "table.decimal('number').index": {
          'action': () =>
              Schema.createSql('test', (t) => t.decimal('number').index),
          'result': 'CREATE TABLE "test" ("number" DECIMAL(12, 2) NOT NULL); '
              'CREATE INDEX "test_number_index" ON "test" ("number")'
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
          'result': 'CREATE TABLE "test" ("name" BOOLEAN NOT NULL);'
        },
        "table.boolean('name').defaultValue(true)": {
          'action': () => Schema.createSql(
              'test', (t) => t.boolean('name').defaultValue(true)),
          'result':
              'CREATE TABLE "test" ("name" BOOLEAN NOT NULL DEFAULT true);'
        },
        "table.boolean('name').unique": {
          'action': () =>
              Schema.createSql('test', (t) => t.boolean('name').unique),
          'result': 'CREATE TABLE "test" ("name" BOOLEAN UNIQUE NOT NULL);'
        },
        "table.boolean('name').nullable.unique": {
          'action': () => Schema.createSql(
              'test', (t) => t.boolean('name').nullable.unique),
          'result': 'CREATE TABLE "test" ("name" BOOLEAN UNIQUE NULL);'
        },
        "table.boolean('name').index": {
          'action': () =>
              Schema.createSql('test', (t) => t.boolean('name').index),
          'result': 'CREATE TABLE "test" ("name" BOOLEAN NOT NULL); '
              'CREATE INDEX "test_name_index" ON "test" ("name")'
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
          'result': 'CREATE TABLE "test" ("created_at" TIMESTAMP NOT NULL);'
        },
        "table.timestamp('created_at').defaultToNow() -> defaults to precision 6":
            {
          'action': () => Schema.createSql(
              'test', (t) => t.timestamp('created_at').defaultToNow()),
          'result':
              'CREATE TABLE "test" ("created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(6));'
        },
        "table.timestamp('created_at').defaultToNow(3)": {
          'action': () => Schema.createSql(
              'test', (t) => t.timestamp('created_at').defaultToNow(3)),
          'result':
              'CREATE TABLE "test" ("created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(3));'
        },
        "table.timestamp('created_at').defaultToCurrent()": {
          'action': () => Schema.createSql(
              'test', (t) => t.timestamp('created_at').defaultToCurrent()),
          'result':
              'CREATE TABLE "test" ("created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(6));'
        },
        "table.timestamp('created_at').useCurrent()": {
          'action': () => Schema.createSql(
              'test', (t) => t.timestamp('created_at').useCurrent()),
          'result':
              'CREATE TABLE "test" ("created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(6));'
        },
        "table.timestamp('created_at').defaultRaw('NOW()') runs accordingly": {
          'action': () => Schema.createSql(
              'test', (t) => t.timestamp('created_at').defaultRaw('NOW()')),
          'result':
              'CREATE TABLE "test" ("created_at" TIMESTAMP NOT NULL DEFAULT NOW());'
        },
        "table.timestamp('created_at').unique": {
          'action': () =>
              Schema.createSql('test', (t) => t.timestamp('created_at').unique),
          'result':
              'CREATE TABLE "test" ("created_at" TIMESTAMP UNIQUE NOT NULL);'
        },
        "table.timestamp('created_at').nullable.unique": {
          'action': () => Schema.createSql(
              'test', (t) => t.timestamp('created_at').nullable.unique),
          'result': 'CREATE TABLE "test" ("created_at" TIMESTAMP UNIQUE NULL);'
        },
        "table.timestamp('created_at').index": {
          'action': () =>
              Schema.createSql('test', (t) => t.timestamp('created_at').index),
          'result': 'CREATE TABLE "test" ("created_at" TIMESTAMP NOT NULL); '
              'CREATE INDEX "test_created_at_index" ON "test" ("created_at")'
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
          'result': 'CREATE TABLE "test" ("created_at" TIMESTAMP NOT NULL);'
        },
        "table.dateTime('created_at').defaultToNow() -> defaults to precision 6":
            {
          'action': () => Schema.createSql(
              'test', (t) => t.dateTime('created_at').defaultToNow()),
          'result':
              'CREATE TABLE "test" ("created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(6));'
        },
        "table.dateTime('created_at').defaultToCurrent()": {
          'action': () => Schema.createSql(
              'test', (t) => t.dateTime('created_at').defaultToCurrent()),
          'result':
              'CREATE TABLE "test" ("created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(6));'
        },
        "table.dateTime('created_at').useCurrent()": {
          'action': () => Schema.createSql(
              'test', (t) => t.dateTime('created_at').useCurrent()),
          'result':
              'CREATE TABLE "test" ("created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(6));'
        },
        "table.dateTime('created_at').defaultRaw('NOW()') runs accordingly": {
          'action': () => Schema.createSql(
              'test', (t) => t.dateTime('created_at').defaultRaw('NOW()')),
          'result':
              'CREATE TABLE "test" ("created_at" TIMESTAMP NOT NULL DEFAULT NOW());'
        },
        "table.dateTime('created_at').unique": {
          'action': () =>
              Schema.createSql('test', (t) => t.dateTime('created_at').unique),
          'result':
              'CREATE TABLE "test" ("created_at" TIMESTAMP UNIQUE NOT NULL);'
        },
        "table.dateTime('created_at').nullable.unique": {
          'action': () => Schema.createSql(
              'test', (t) => t.dateTime('created_at').nullable.unique),
          'result': 'CREATE TABLE "test" ("created_at" TIMESTAMP UNIQUE NULL);'
        },
        "table.dateTime('created_at').index": {
          'action': () =>
              Schema.createSql('test', (t) => t.dateTime('created_at').index),
          'result': 'CREATE TABLE "test" ("created_at" TIMESTAMP NOT NULL); '
              'CREATE INDEX "test_created_at_index" ON "test" ("created_at")'
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
          'result': 'CREATE TABLE "test" ("created_at" DATE NOT NULL);'
        },
        "table.date('created_at').defaultToNow(3)": {
          'action': () => Schema.createSql(
              'test', (t) => t.date('created_at').defaultToNow(3)),
          'result':
              'CREATE TABLE "test" ("created_at" DATE NOT NULL DEFAULT CURRENT_TIMESTAMP(3));'
        },
        "table.date('created_at').defaultToCurrent(3)": {
          'action': () => Schema.createSql(
              'test', (t) => t.date('created_at').defaultToCurrent(3)),
          'result':
              'CREATE TABLE "test" ("created_at" DATE NOT NULL DEFAULT CURRENT_TIMESTAMP(3));'
        },
        "table.date('created_at').useCurrent(3)": {
          'action': () => Schema.createSql(
              'test', (t) => t.date('created_at').useCurrent(3)),
          'result':
              'CREATE TABLE "test" ("created_at" DATE NOT NULL DEFAULT CURRENT_TIMESTAMP(3));'
        },
        "table.date('created_at').defaultRaw('NOW()')": {
          'action': () => Schema.createSql(
              'test', (t) => t.date('created_at').defaultRaw('NOW()')),
          'result':
              'CREATE TABLE "test" ("created_at" DATE NOT NULL DEFAULT NOW());'
        },
        "table.date('created_at').unique": {
          'action': () =>
              Schema.createSql('test', (t) => t.date('created_at').unique),
          'result': 'CREATE TABLE "test" ("created_at" DATE UNIQUE NOT NULL);'
        },
        "table.date('created_at').nullable.unique": {
          'action': () => Schema.createSql(
              'test', (t) => t.date('created_at').nullable.unique),
          'result': 'CREATE TABLE "test" ("created_at" DATE UNIQUE NULL);'
        },
        "table.date('created_at').index": {
          'action': () =>
              Schema.createSql('test', (t) => t.date('created_at').index),
          'result': 'CREATE TABLE "test" ("created_at" DATE NOT NULL); '
              'CREATE INDEX "test_created_at_index" ON "test" ("created_at")'
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
          'result': 'CREATE TABLE "test" ("address" JSON NOT NULL);'
        },
        "table.json('address').defaultValue('[]')": {
          'action': () => Schema.createSql(
              'test', (t) => t.json('address').defaultValue('[]')),
          'result':
              'CREATE TABLE "test" ("address" JSON NOT NULL DEFAULT \'[]\');'
        },
        "table.json('address').nullable": {
          'action': () =>
              Schema.createSql('test', (t) => t.json('address').nullable),
          'result': 'CREATE TABLE "test" ("address" JSON NULL);'
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
          'result': 'CREATE TABLE "test" ("address" JSONB NOT NULL);'
        },
        "table.jsonb('address').defaultValue('[]')": {
          'action': () => Schema.createSql(
              'test', (t) => t.jsonb('address').defaultValue('[]')),
          'result':
              'CREATE TABLE "test" ("address" JSONB NOT NULL DEFAULT \'[]\');'
        },
        "table.jsonb('address').nullable": {
          'action': () =>
              Schema.createSql('test', (t) => t.jsonb('address').nullable),
          'result': 'CREATE TABLE "test" ("address" JSONB NULL);'
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
        "table.id() generates BIGSERIAL PRIMARY KEY NOT NULL": {
          'action': () => Schema.createSql('test', (t) => t.id()),
          'result': 'CREATE TABLE "test" ("id" BIGSERIAL PRIMARY KEY NOT NULL);'
        },
        "table.id(name)": {
          'action': () => Schema.createSql('test', (t) => t.id('mid')),
          'result':
              'CREATE TABLE "test" ("mid" BIGSERIAL PRIMARY KEY NOT NULL);'
        },
        "table.stringId() generates VARCHAR(16) PRIMARY KEY NOT NULL": {
          'action': () => Schema.createSql('test', (t) => t.stringId()),
          'result':
              'CREATE TABLE "test" ("id" VARCHAR(16) PRIMARY KEY NOT NULL);'
        },
        "table.stringId(name)": {
          'action': () => Schema.createSql('test', (t) => t.stringId('msid')),
          'result':
              'CREATE TABLE "test" ("msid" VARCHAR(16) PRIMARY KEY NOT NULL);'
        },
        "table.timestamps()": {
          'action': () => Schema.createSql('test', (t) => t.timestamps()),
          'result': 'CREATE TABLE "test" ('
              '"created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(6), '
              '"updated_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(6));'
        },
        "table.timestamps(createdColumn: 'createdAt', updatedColumn: 'updatedAt')":
            {
          'action': () => Schema.createSql(
              'test',
              (t) => t.timestamps(
                  createdColumn: 'createdAt', updatedColumn: 'updatedAt')),
          'result': 'CREATE TABLE "test" ('
              '"createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(6), '
              '"updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(6));'
        },
        "table.timestamps(camelCase: true)": {
          'action': () =>
              Schema.createSql('test', (t) => t.timestamps(camelCase: true)),
          'result': 'CREATE TABLE "test" ('
              '"createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(6), '
              '"updatedAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(6));'
        },
        "table.timestamps(camelCase: true, updatedColumn: 'updatedDate')": {
          'action': () => Schema.createSql(
              'test',
              (t) =>
                  t.timestamps(camelCase: true, updatedColumn: 'updatedDate')),
          'result': 'CREATE TABLE "test" ('
              '"createdAt" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(6), '
              '"updatedDate" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP(6));'
        },
        "table.softDeletes()": {
          'action': () => Schema.createSql('test', (t) => t.softDeletes()),
          'result': 'CREATE TABLE "test" ("deleted_at" TIMESTAMP NULL);'
        },
        "table.softDeletes('deletedAt')": {
          'action': () =>
              Schema.createSql('test', (t) => t.softDeletes('deletedAt')),
          'result': 'CREATE TABLE "test" ("deletedAt" TIMESTAMP NULL);'
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
