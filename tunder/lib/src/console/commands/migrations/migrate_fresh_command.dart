import 'package:tunder/src/console/commands/migrations/contracts/migration_command.dart';
import 'package:tunder/src/console/commands/migrations/mixins/manage_migrations.dart';

class MigrateFreshCommand extends MigrationCommand with ManageMigrations {
  final name = 'migrate:fresh';
  final description =
      'Drops all tables from database and re-runs all migrations';

  Future<int> run() async {
    await sky.run(['db:wipe']);
    await sky.run(['migrate']);

    return 0;
  }
}
