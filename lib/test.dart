import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/providers/database_service_provider.dart';
import 'package:tunder/utils.dart';

void useDatabaseTransaction() {
  setUpAll(() => DatabaseServiceProvider().boot(app()));
  setUp(() => DB.begin());
  tearDown(() => DB.rollback());
}

void useDatabaseTransactionAll({bool debug = false}) {
  setUpAll(() {
    DatabaseServiceProvider().boot(app());
    if (debug) print('>> using database transaction');
    DB.begin();
  });

  tearDownAll(() {
    DB.rollback();
    if (debug) print('>> database transaction rolled back');
  });
}
