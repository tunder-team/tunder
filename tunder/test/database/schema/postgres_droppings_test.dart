import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/test.dart';

main() {
  group('Postgres Dropping', () {
    useDatabaseTransactions();

    setUp(() async {
      Schema.create('test', (table) {
        table.string('name');
      });
    });

    group('Constraints ->', () {
      var testCases = {
        "Nullable: table.string('name').nullable().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.string('name').nullable().change()),
          'result': 'alter table "test" alter column "name" type varchar(255); '
              'alter table "test" alter column "name" drop not null',
        },
        "Not Nullable: table.string('name').notNull().change()": {
          'action': () => Schema.updateSql(
              'test', (t) => t.string('name').notNullable().change()),
          'result': 'alter table "test" alter column "name" type varchar(255); '
              'alter table "test" alter column "name" set not null',
        },
      };

      testCases.forEach(
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
