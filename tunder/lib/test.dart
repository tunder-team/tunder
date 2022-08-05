// coverage:ignore-file
import 'package:tunder/database.dart';
import 'package:tunder/utils.dart';
import 'package:test/test.dart';

void useDatabaseTransactions({bool debug = false}) {
  setUpAll(() => DatabaseServiceProvider().boot(app()));
  late DatabaseConnection connection;

  setUp(() async {
    if (debug) print('>> using database transaction');
    connection = DB.newConnection;
    await connection.begin();
  });

  tearDown(() async {
    await connection.rollback();
    connection.close();
    if (debug) print('>> database transaction rolled back');
  });
}

void useDatabaseTransactionsAll({bool debug = false}) {
  setUpAll(() async {
    DatabaseServiceProvider().boot(app());
    if (debug) print('>> using database transaction');
    await DB.begin();
  });

  tearDownAll(() async {
    await DB.rollback();
    if (debug) print('>> database transaction rolled back');
  });
}
