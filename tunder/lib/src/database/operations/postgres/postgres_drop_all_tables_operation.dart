import 'package:tunder/database.dart';

class PostgresDropAllTablesOperation {
  Future<int> execute() async {
    final connection = DB.connection;
    final dropSql =
        'select "table_name" from information_schema.tables where table_schema = \'public\'';
    final rows = await connection.query(dropSql);
    final tables = rows.map((row) => row['table_name']).toList().join(', ');

    return await connection.execute('drop table $tables cascade');
  }
}
