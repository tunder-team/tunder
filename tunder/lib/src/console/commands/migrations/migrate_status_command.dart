import 'package:colorx/colorx.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/console/commands/migrations/contracts/migration_command.dart';
import 'package:tunder/src/console/commands/migrations/mixins/manage_migrations.dart';

class MigrateStatusCommand extends MigrationCommand with ManageMigrations {
  final name = 'migrate:status';
  final description = 'Get the status of each migration';
  final List<Migration> migrations;

  MigrateStatusCommand(this.migrations) {
    this.migrations.sort((a, b) => a.id.compareTo(b.id));
  }

  Future<int> run() async {
    if (!await DB.tableExists('migrations')) await createMigrationsTable();
    ranMigrations = await getRanMigrations();

    for (final migration in migrations) {
      String status = isPending(migration)
          ? 'pending'.bold.brightYellow
          : '✔'.bold.brightGreen;

      info(' $status ${migration.id}_${migration.name.snakeCase}');
    }

    return 0;
  }

  bool isPending(Migration migration) => pendingMigrations.contains(migration);
}
