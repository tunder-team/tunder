import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/test.dart';

main() {
  group('Aggregate functions', () {
    useDatabaseTransactions();

    setUp(() async {
      await Schema.create('users', (table) {
        table
          ..id()
          ..string('name').notNullable();
      });
      await DB.execute("INSERT INTO users (name) VALUES ('Marco')");
    });

    test('count', () async {
      int count = await Query('users')
          .add(Where('name').contains('marco').insensitive)
          .count();

      expect(count, 1);
    });
  });
}
