import 'package:tunder/database.dart';

class PostgresDropTableOperation {
  Future<int> drop(String table) => DB.execute('drop table "$table"');
  Future<int> dropIfExists(String table) =>
      DB.execute('drop table if exists "$table"');
}
