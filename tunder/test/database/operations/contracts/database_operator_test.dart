import 'package:test/test.dart';
import 'package:tunder/src/database/operations/contracts/database_operator.dart';
import 'package:tunder/extensions.dart';

import '../../../feature.dart';

main() {
  group('DatabaseOperator', () {
    test('throws exception if not implemented for the provided driver', () {
      final driver = #unknown;
      expect(
          () => DatabaseOperator.forDriver(driver),
          toThrow(
              UnsupportedError, 'Driver [${driver.name}] is not supported'));
    });
  });
}
