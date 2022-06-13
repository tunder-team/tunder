import 'package:postgresql2/postgresql.dart';
import 'package:tunder/database.dart';

class PostgresConnection implements DatabaseConnection {
  late String host;
  late int port;
  late String database;
  late String username;
  late String password;
  late final Symbol driver;
  Connection? _connection;

  String get url => 'postgres://$username:$password@$host:$port/$database';

  PostgresConnection({
    this.host = 'localhost',
    this.port = 5432,
    required this.database,
    required this.username,
    required this.password,
  }) : driver = DatabaseDriver.postgres;

  @override
  Future<int> execute(String query) async {
    await open();

    return _connection!.execute(query);
  }

  @override
  Future<void> open() async {
    _connection ??= await connect(url);
  }

  @override
  void close() {
    _connection?.close();
    _connection = null;
  }

  @override
  Future<List<MappedRow>> query(String query) async {
    await open();
    List<Row> rows = await _connection!.query(query).toList();

    return _transformedRows(rows);
  }

  Future<bool> tableExists(String table) async {
    await open();

    var res = await query(
        "SELECT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = '$table' )");

    return res.first['exists'];
  }

  @override
  Future<T> transaction<T>(Future<T> Function() function) async {
    await open();

    return _connection!.runInTransaction<T>(function);
  }

  List<MappedRow> _transformedRows(List<Row> rows) {
    return rows.map((row) {
      return row.toMap() as MappedRow;
    }).toList();
  }

  @override
  Future begin() async {
    return execute('BEGIN');
  }

  @override
  Future commit() {
    return execute('COMMIT');
  }

  @override
  Future rollback() {
    return execute('ROLLBACK');
  }
}
