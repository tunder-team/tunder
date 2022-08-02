// import 'package:test/test.dart';
// import 'package:tunder/database.dart';
// import 'package:tunder/test.dart';

main() {
//   group('Unique Constraint', () {
//     useDatabaseTransactions();

//     group('Creation', () {
//       group('In Column: ', () {
//         test('table.string(name).unique()', () async {
//           var sql = Schema.createSql('test', (table) {
//             table.string('name').unique();
//           });

//           expect(sql,
//               'create table "test" ("name" varchar(255) constraint "test_name_unique" unique)');
//           expect(await DB.execute(sql), isNotNull);
//         });

//         test(
//             'table.string(name).unique(custom_name) for create creates with custom name for the constraint',
//             () async {
//           var sql = Schema.createSql('test', (table) {
//             table.string('name').unique('custom_name');
//           });
//           expect(sql,
//               'create table "test" ("name" varchar(255) constraint "custom_name" unique)');
//           expect(await DB.execute(sql), isNotNull);
//         });
//       });

//       group('In Table', () {
//         test('table.unique(columns) with one column', () async {
//           var sql = Schema.createSql('test', (table) {
//             table.id();
//             table.string('name');
//             table.unique(['name']);
//           });
//           expect(sql,
//               'create table "test" ("id" bigserial constraint "test_id_pkey" primary key not null, "name" varchar(255), constraint "test_name_unique" unique ("name"))');
//           expect(await DB.execute(sql), isNotNull);
//         });
//         test('table.unique(columns) with multiple columns', () async {
//           var sql = Schema.createSql('test', (table) {
//             table.id();
//             table.string('name');
//             table.unique(['id', 'name']);
//           });
//           expect(sql,
//               'create table "test" ("id" bigserial constraint "test_id_pkey" primary key not null, "name" varchar(255), constraint "test_id_name_unique" unique ("id", "name"))');
//           expect(await DB.execute(sql), isNotNull);
//         });
//       });
//     });

//     group('Update: ', () {
//       setUp(() async {
//         await Schema.create('test', (table) {
//           table.id();
//           table.string('name');
//         });
//       });

//       group('In Column', () {
//         test('table.string(name).unique().change()', () async {
//           var sql = Schema.updateSql('test', (table) {
//             table.string('name').unique().change();
//           });
//           expect(
//             sql,
//             'alter table "test" alter column "name" type varchar(255); '
//             'alter table "test" add constraint "test_name_unique" unique ("name")',
//           );
//           expect(await DB.execute(sql), isNotNull);
//         });
//         test('table.string(name).unique(name).change()', () async {
//           var sql = Schema.updateSql('test', (table) {
//             table.string('name').unique('custom_name').change();
//           });
//           expect(
//             sql,
//             'alter table "test" alter column "name" type varchar(255); '
//             'alter table "test" add constraint "custom_name" unique ("name")',
//           );
//           expect(await DB.execute(sql), isNotNull);
//         });
//       });

//       group('In Table', () {
//         test('table.unique(columns) with one column', () async {
//           var sql = Schema.updateSql('test', (table) {
//             table.unique(['name']);
//           });
//           expect(sql,
//               'alter table "test" add constraint "test_name_unique" unique ("name")');
//           expect(await DB.execute(sql), isNotNull);
//         });

//         test('table.unique(columns) with multiple columns', () async {
//           var sql = Schema.updateSql('test', (table) {
//             table.unique(['id', 'name']);
//           });
//           expect(sql,
//               'alter table "test" add constraint "test_id_name_unique" unique ("id", "name")');
//           expect(await DB.execute(sql), isNotNull);
//         });
//       });
//     });

//     group('Drop in table only: ', () {
//       setUp(() async {
//         await Schema.create('test', (table) {
//           table.id();
//           table.string('name').unique();
//           table.string('email').unique('custom_email_unique');
//         });
//       });

//       test('table.dropUnique(column) using column', () async {
//         var sql = Schema.updateSql('test', (table) {
//           table.dropUnique(column: 'name');
//         });
//         expect(sql, 'alter table "test" drop constraint "test_name_unique"');
//         expect(await DB.execute(sql), isNotNull);
//       });
//       test('table.dropUnique(name) using name', () async {
//         var sql = Schema.updateSql('test', (table) {
//           table.dropUnique(name: 'custom_email_unique');
//         });
//         expect(sql, 'alter table "test" drop constraint "custom_email_unique"');
//         expect(await DB.execute(sql), isNotNull);
//       });
//     });

//     group('Integrations: ', () {
//       setUp(() async {
//         await Schema.create('test', (table) {
//           table.id();
//           table.string('name');
//         });
//       });

//       test('table.string(email).unique().notNullable().change()', () async {
//         var sql = Schema.updateSql('test', (table) {
//           table.string('name').unique().notNullable().change();
//         });
//         expect(
//           sql,
//           'alter table "test" alter column "name" type varchar(255); '
//           'alter table "test" alter column "name" set not null; '
//           'alter table "test" add constraint "test_name_unique" unique ("name")',
//         );
//         expect(await DB.execute(sql), isNotNull);
//       });

//       test('table.string(email).unique().notNullable()', () async {
//         var sql = Schema.updateSql('test', (table) {
//           table.string('email').unique().notNullable();
//         });
//         expect(sql,
//             'alter table "test" add column "email" varchar(255) not null constraint "test_email_unique" unique');
//         expect(await DB.execute(sql), isNotNull);
//       });
//     });
//   });
}
