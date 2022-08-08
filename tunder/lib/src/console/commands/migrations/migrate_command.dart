import 'package:tunder/console.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/console/commands/migrations/contracts/migration_command.dart';
import 'package:tunder/src/console/commands/migrations/mixins/manage_migrations.dart';

class MigrateCommand extends Command
    with ManageMigrations
    implements MigrationCommand {
  final name = 'migrate';
  final description = 'Runs migrations';
  final List<Migration> migrations;

  MigrateCommand(this.migrations) {
    this.migrations.sort((a, b) => a.version.compareTo(b.version));
  }

  Future run() async {
    if (!await DB.tableExists('migrations')) await createMigrationsTable();
    ranMigrations = await getRanMigrations();

    for (final migration in pendingMigrations) {
      final migrating =
          progress('Migrating: ${migration.version} ${migration.name}');

      try {
        await migration.up();
        await insertMigration(migration);

        migrating.complete('Migrated: ${migration.version} ${migration.name}');
      } catch (err) {
        migrating.fail('Failed: ${migration.version} ${migration.name}');
        error(err.toString());
        break;
      }
    }
  }
}
