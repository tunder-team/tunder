import 'package:test/test.dart';
import 'package:tunder/src/database/operations/contracts/count_operation.dart';
import 'package:tunder/src/database/operations/contracts/insert_operation.dart';
import 'package:tunder/src/database/operations/contracts/query_operation.dart';

import '../../feature.dart';

main() {
  group('Operation Exceptions', () {
    test('CountOperation throws exception for unknown driver', () {
      expect(
        () => CountOperation.forDatabase(#unknown),
        toThrow(UnsupportedError,
            'Count operation not implemented for driver [unknown]'),
      );
    });

    test('InsertOperation throws exception for unknown driver', () {
      expect(
        () => InsertOperation.forDatabase(#unknown),
        toThrow(UnsupportedError,
            'Insert operation not implemented for driver [unknown]'),
      );
    });

    test('QueryOperation throws exception for unknown driver', () {
      expect(
        () => QueryOperation.forDatabase(#unknown),
        toThrow(UnsupportedError,
            'Query operation not implemented for driver [unknown]'),
      );
    });
  });
}