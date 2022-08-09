import 'package:test/test.dart';
import 'package:tunder/src/database/operations/contracts/count_operation.dart';
import 'package:tunder/src/database/operations/contracts/delete_operation.dart';
import 'package:tunder/src/database/operations/contracts/insert_operation.dart';
import 'package:tunder/src/database/operations/contracts/query_operation.dart';
import 'package:tunder/src/database/operations/contracts/update_operation.dart';

import '../../feature.dart';

main() {
  group('Operation Exceptions', () {
    test('CountOperation throws exception for unknown driver', () {
      expect(
        () => CountOperation.forDriver(#unknown),
        toThrow(UnsupportedError,
            'Count operation not implemented for driver [unknown]'),
      );
    });

    test('InsertOperation throws exception for unknown driver', () {
      expect(
        () => InsertOperation.forDriver(#unknown),
        toThrow(UnsupportedError,
            'Insert operation not implemented for driver [unknown]'),
      );
    });

    test('QueryOperation throws exception for unknown driver', () {
      expect(
        () => QueryOperation.forDriver(#unknown),
        toThrow(UnsupportedError,
            'Query operation not implemented for driver [unknown]'),
      );
    });

    test('UpdateOperation throws exception for unknown driver', () {
      expect(
        () => UpdateOperation.forDriver(#unknown),
        toThrow(UnsupportedError,
            'Update operation not implemented for driver [unknown]'),
      );
    });

    test('DeleteOperation throws exception for unknown driver', () {
      expect(
        () => DeleteOperation.forDriver(#unknown),
        toThrow(UnsupportedError,
            'Delete operation not implemented for driver [unknown]'),
      );
    });
  });
}
