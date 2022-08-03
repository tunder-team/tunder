import 'package:postgres/postgres.dart';
import 'package:tunder/database.dart';

class PostgresConnection implements DatabaseConnection {
  String host;
  int port;
  String database;
  String username;
  String password;
  Symbol driver;
  int _transactionLevel = 0;
  late PostgreSQLConnection _connection;

  String get url => 'postgres://$username:$password@$host:$port/$database';
  String get _name => 'sp_$_transactionLevel';
  bool _isOpen = false;

  PostgresConnection({
    this.host = 'localhost',
    this.port = 5432,
    required this.database,
    required this.username,
    required this.password,
  }) : driver = DatabaseDriver.postgres {
    _connection = _createNewConnection();
  }

  PostgreSQLConnection _createNewConnection() => PostgreSQLConnection(
        host,
        port,
        database,
        username: username,
        password: password,
      );

  @override
  Future<int> execute(String query) async {
    await open();

    return _connection.execute(query);
  }

  @override
  Future<void> open() async {
    if (_isOpen) return;
    if (_connection.isClosed) _connection = _createNewConnection();

    await _connection.open();

    _isOpen = true;
  }

  @override
  void close() async {
    await _connection.close();
    _isOpen = false;
  }

  @override
  Future<List<MappedRow>> query(String query) async {
    await open();
    List<Map> rows = (await _connection.mappedResultsQuery(query)).toList();

    return _transformedRows(rows);
  }

  Future<bool> tableExists(String table) async {
    await open();

    var res = await query(
        "SELECT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = '$table' )");

    return res.first['exists'];
  }

  @override
  Future<T> transaction<T>(Future<T> Function() operation) async {
    await open();

    try {
      await begin();
      var result = await operation();
      await commit();

      return result;
    } catch (_) {
      await rollback();
      rethrow;
    }
  }

  List<MappedRow> _transformedRows(List rows) =>
      rows.map((row) => row.values.single as MappedRow).toList();

  @override
  Future begin() async {
    var begin = _alreadyInTransaction ? 'savepoint $_name' : 'begin';
    ++_transactionLevel;
    return execute(begin);
  }

  bool get _alreadyInTransaction => _transactionLevel > 0;

  @override
  Future commit() {
    --_transactionLevel;
    var commit = _alreadyInTransaction ? 'release savepoint $_name' : 'commit';

    return execute(commit);
  }

  @override
  Future rollback() {
    --_transactionLevel;
    var rollback =
        _alreadyInTransaction ? 'rollback to savepoint $_name' : 'rollback';

    return execute(rollback);
  }
}
