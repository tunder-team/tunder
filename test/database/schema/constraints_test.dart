import 'package:test/test.dart';
import 'package:tunder/src/database/schema/constraints.dart';

import '../../feature.dart';

main() {
  group('Constraints', () {
    test('it throw an error if column and name is not provided', () {
      expect(
          () => Constraint('unique', table: 'test'),
          toThrow(ArgumentError,
              '[name] or [column] should be specified but both are null.'));
    });
  });
}
