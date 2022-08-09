import 'package:mason_logger/mason_logger.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/console/commands/migrations/contracts/migration_command.dart';
import 'package:tunder/src/console/commands/migrations/mixins/manage_migrations.dart';

class MigrateCommand extends MigrationCommand with ManageMigrations {
  final name = 'migrate';
  final description = 'Runs migrations';
  final List<Migration> migrations;

  MigrateCommand(this.migrations) {
    this.migrations.sort((a, b) => a.id.compareTo(b.id));
  }

  Future<int> run() async {
    if (!await DB.tableExists('migrations')) await createMigrationsTable();
    ranMigrations = await getRanMigrations();

    late Progress migrating;
    late Migration migration;
    try {
      for (migration in pendingMigrations) {
        migrating = progress('Migrating: ${migration.id} ${migration.name}');

        await migration.up();
        await insertMigration(migration);

        migrating.complete('Migrated: ${migration.id} ${migration.name}');
      }

      return 0;
    } catch (err) {
      migrating.fail('Failed: ${migration.id} ${migration.name}');
      error(err.toString());
      return 1;
    }
  }
}
