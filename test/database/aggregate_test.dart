import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/providers/database_service_provider.dart';
import 'package:tunder/utils.dart';

main() {
  group('Aggregate functions', () {
    setUpAll(() => DatabaseServiceProvider().boot(app()));
    test('count', () async {
      int count = await Query('users')
          .add(Where('name').contains('marco').insensitive)
          .count();

      expect(count, 1);
    });
  });
}
