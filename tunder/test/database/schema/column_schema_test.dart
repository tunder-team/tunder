import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/database/schema/column_schema.dart';
import 'package:tunder/src/database/schema/data_type.dart';
import 'package:tunder/src/database/schema/table_schema.dart';
import 'package:tunder/test.dart';

main() {
  useDatabaseTransactions();

  group('ColumnSchema', () {
    late TableSchema table;

    setUp(() => table = TableSchema('test', DB.connection));

    test('update() changes property updating to true', () {
      final column = ColumnSchema('name', DataType.string, table)..update();
      expect(column.isUpdating, isTrue);
    });
  });
}
