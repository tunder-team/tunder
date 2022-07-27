import 'package:test/test.dart' as t;
import 'package:tunder/database.dart';
import 'package:tunder/test.dart';
import 'package:test/test.dart';

main() {
  t.group('Aggregate functions', () {
    useDatabaseTransactions();

    setUp(() async {
      await Schema.create('users', (table) {
        table
          ..id()
          ..string('name').notNullable();
      });
      await DB.execute("INSERT INTO users (name) VALUES ('Marco')");
    });

    t.test('count', () async {
      int count = await Query('users')
          .add(Where('name').contains('marco').insensitive)
          .count();

      t.expect(count, 1);
    });
  });
}
