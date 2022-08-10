import 'package:tunder/database.dart';
import 'package:tunder/src/database/operations/postgres/mixins/value_transformer.dart';

class PostgresDropAllTablesOperation with PostgresTransformers {
  Future<int> execute() async {
    final connection = DB.connection;
    final dropSql =
        'select "tablename" from pg_tables where schemaname = \'public\'';

    final rows = await connection.query(dropSql);
    final tables =
        rows.map(toField('tablename')).map(toIdentity).toList().join(', ');

    return await connection.execute('drop table if exists $tables cascade');
  }
}
