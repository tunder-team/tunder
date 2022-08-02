// import 'package:test/test.dart';
// import 'package:tunder/database.dart';
// import 'package:tunder/test.dart';

main() {
//   group('Primary Constraint', () {
//     useDatabaseTransactions();

//     group('Creation', () {
//       group('In Column', () {
//         test('table.integer(id).primary()', () async {
//           var sql = Schema.createSql('test', (table) {
//             table.integer('id').primary();
//           });

//           expect(sql,
//               'create table "test" ("id" integer constraint "test_id_pkey" primary key)');
//           expect(await DB.execute(sql), isNotNull);
//         });

//         test(
//             'table.integer(id).primary(custom_name) for create creates with custom name for the constraint',
//             () async {
//           var sql = Schema.createSql('test', (table) {
//             table.integer('id').primary('custom_name');
//           });
//           expect(sql,
//               'create table "test" ("id" integer constraint "custom_name" primary key)');
//           expect(await DB.execute(sql), isNotNull);
//         });
//       });

//       group('In Table', () {
//         test('table.primary(columns) with one column', () async {
//           var sql = Schema.createSql('test', (table) {
//             table.integer('id');
//             table.string('email');
//             table.primary(['id']);
//           });
//           expect(sql,
//               'create table "test" ("id" integer, "email" varchar(255), constraint "test_id_pkey" primary key ("id"))');
//           expect(await DB.execute(sql), isNotNull);
//         });
//         test('table.primary(columns) with multiple columns', () async {
//           var sql = Schema.createSql('test', (table) {
//             table.integer('id');
//             table.string('email');
//             table.primary(['id', 'email']);
//           });
//           expect(sql,
//               'create table "test" ("id" integer, "email" varchar(255), constraint "test_id_email_pkey" primary key ("id", "email"))');
//           expect(await DB.execute(sql), isNotNull);
//         });

//         test('table.primary(column, name:) with a custom name', () async {
//           var sql = Schema.createSql('test', (table) {
//             table.integer('id');
//             table.string('email');
//             table.primary(['id', 'email'], name: 'custom_pkey_name');
//           });

//           expect(sql,
//               'create table "test" ("id" integer, "email" varchar(255), constraint "custom_pkey_name" primary key ("id", "email"))');
//           expect(await DB.execute(sql), isNotNull);
//         });
//       });
//     });

//     group('Update: ', () {
//       setUp(() async {
//         await Schema.create('test', (table) {
//           table.integer('id');
//           table.string('email');
//         });
//       });

//       group('In Column', () {
//         test('table.bigInteger(id).primary() adds a primary column', () async {
//           var sql = Schema.updateSql('test', (table) {
//             table.bigInteger('sid').primary();
//           });

//           expect(sql,
//               'alter table "test" add column "sid" bigint constraint "test_sid_pkey" primary key');
//           expect(await DB.execute(sql), isNotNull);
//         });

//         test(
//             'table.bigInteger(id).primary(name) adds a primary column with custom name',
//             () async {
//           var sql = Schema.updateSql('test', (table) {
//             table.bigInteger('sid').primary('custom_name');
//           });
//           expect(sql,
//               'alter table "test" add column "sid" bigint constraint "custom_name" primary key');
//           expect(await DB.execute(sql), isNotNull);
//         });

//         test('table.bigInteger(id).primary().change()', () async {
//           var sql = Schema.updateSql('test', (table) {
//             table.bigInteger('id').primary().change();
//           });
//           expect(
//             sql,
//             'alter table "test" alter column "id" type bigint using ("id"::bigint); '
//             'alter table "test" add constraint "test_id_pkey" primary key ("id")',
//           );
//           expect(await DB.execute(sql), isNotNull);
//         });
//         test('table.bigInteger(id).primary(name).change()', () async {
//           var sql = Schema.updateSql('test', (table) {
//             table.bigInteger('id').primary('custom_name').change();
//           });
//           expect(
//             sql,
//             'alter table "test" alter column "id" type bigint using ("id"::bigint); '
//             'alter table "test" add constraint "custom_name" primary key ("id")',
//           );
//           expect(await DB.execute(sql), isNotNull);
//         });
//       });

//       group('In Table', () {
//         test('table.primary(columns) with one column', () async {
//           var sql = Schema.updateSql('test', (table) {
//             table.primary(['id']);
//           });
//           expect(sql,
//               'alter table "test" add constraint "test_id_pkey" primary key ("id")');
//           expect(await DB.execute(sql), isNotNull);
//         });

//         test('table.primary(columns) with multiple columns', () async {
//           var sql = Schema.updateSql('test', (table) {
//             table.primary(['id', 'email']);
//           });
//           expect(sql,
//               'alter table "test" add constraint "test_id_email_pkey" primary key ("id", "email")');
//           expect(await DB.execute(sql), isNotNull);
//         });

//         test('table.primary(columns, name) with custom name', () async {
//           var sql = Schema.updateSql('test', (table) {
//             table.primary(['id', 'email'], name: 'custom_pkey_name');
//           });
//           expect(sql,
//               'alter table "test" add constraint "custom_pkey_name" primary key ("id", "email")');
//           expect(await DB.execute(sql), isNotNull);
//         });
//       });
//     });

//     group('Drop in table only: ', () {
//       setUp(() async {
//         await Schema.create('test', (table) {
//           table.integer('id').primary();
//         });
//       });

//       test('table.dropPrimary(column) using column', () async {
//         var sql = Schema.updateSql('test', (table) {
//           table.dropPrimary(columns: ['id']);
//         });
//         expect(sql, 'alter table "test" drop constraint "test_id_pkey"');
//         expect(await DB.execute(sql), isNotNull);
//       });
//       test('table.dropPrimary(name) using name', () async {
//         await Schema.update('test', (table) {
//           table.dropPrimary(columns: ['id']);
//           table.primary(['id'], name: 'custom_pkey');
//         });
//         var sql = Schema.updateSql('test', (table) {
//           table.dropPrimary(name: 'custom_pkey');
//         });
//         expect(sql, 'alter table "test" drop constraint "custom_pkey"');
//         expect(await DB.execute(sql), isNotNull);
//       });
//     });

//     group('Rename', () {
//       setUp(() => Schema.create('test', (table) {
//             table.id();
//           }));

//       test('table.renamePrimary(from, to)', () async {
//         var sql = Schema.updateSql('test', (table) {
//           table.renamePrimary('test_id_pkey', 'custom_pkey');
//         });
//         expect(sql,
//             'alter table "test" rename constraint "test_id_pkey" to "custom_pkey"');
//         expect(await DB.execute(sql), isNotNull);
//       });
//     });

//     group('Integrations: ', () {
//       setUp(() async {
//         await Schema.create('test', (table) {
//           table.string('name');
//         });
//       });

//       test(
//           'table.id() -> same as bigInteger(name).primary().notNullable().autoIncrement()',
//           () async {
//         var sql = Schema.updateSql('test', (table) => table.id());
//         expect(sql,
//             'alter table "test" add column "id" bigserial constraint "test_id_pkey" primary key not null');
//         expect(await DB.execute(sql), isNotNull);
//       });
//     });
//   });
}
