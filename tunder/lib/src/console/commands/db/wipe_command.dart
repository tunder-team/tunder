import 'package:tunder/console.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/database/operations/contracts/database_operator.dart';

class WipeCommand extends Command<int> {
  final name = 'db:wipe';
  final description = 'Drops all tables from database';

  Future<int> run() async {
    final wiping = progress('Dropping all tables from database');
    await DatabaseOperator.forDriver(DB.driver).dropAllTables();
    wiping.complete('Dropped all tables successfully');

    return 0;
  }
}
