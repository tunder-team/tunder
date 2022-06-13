typedef MappedRow = Map<String, dynamic>;

abstract class DatabaseConnection {
  late String host;
  late int port;
  late String database;
  late String username;
  late String password;
  late Symbol driver;

  Future<void> open();
  void close();
  Future<int> execute(String query);
  Future<List<MappedRow>> query(String query);
  Future<bool> tableExists(String table);
  Future<T> transaction<T>(Future<T> Function() function);
  Future begin();
  Future commit();
  Future rollback();
}
