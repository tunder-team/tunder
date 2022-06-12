import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/database/schema/column_schema.dart';
import 'package:tunder/src/database/schema/data_type.dart';
import 'package:tunder/src/database/schema/table_schema.dart';
import 'package:tunder/src/exceptions/unknown_data_type_exception.dart';
import 'package:tunder/test.dart';

main() {
  useDatabaseTransactions();

  group('ColumnSchema', () {
    late TableSchema table;

    setUp(() => table = TableSchema('test', DB.connection));

    test('toString() returns a SQL line for creating a column', () {
      final column = ColumnSchema('name', DataType.string, table);
      expect(column.toString(), '"name" VARCHAR(255) NOT NULL');
    });

    test('nullable property sets to NULL', () {
      final column = ColumnSchema('name', DataType.string, table);
      expect(column.nullable.toString(), '"name" VARCHAR(255) NULL');
    });

    test('update() changes property updating to true', () {
      final column = ColumnSchema('name', DataType.string, table).update;
      expect(column.isUpdating, isTrue);
    });

    test('if unknown datatype is given an exception is thrown', () {
      final column = ColumnSchema('name', 'unknown', table);
      expect(() => column.toString(), throwsA(isA<UnknownDataTypeException>()));
    });

    group('changes', () {
      late TableSchema table;

      setUp(() {
        table = TableSchema('test', DB.connection);
      });

      test('getter returns a List of SQL changes for that column', () {
        final column = table.string('email', 123).changeTo.notNull.unique;
        expect(column.changes, [
          'ALTER COLUMN "email" SET NOT NULL',
          'ALTER COLUMN "email" TYPE VARCHAR(123)',
          'ADD CONSTRAINT "test_email_unique" UNIQUE ("email")'
        ]);
      });
    });
  });
}
