import 'package:tunder/database.dart';
import 'package:tunder/src/console/commands/migrations/contracts/migration_command.dart';
import 'package:tunder/src/console/commands/migrations/mixins/manage_migrations.dart';

class MigrateRollbackCommand extends MigrationCommand with ManageMigrations {
  final name = 'migrate:rollback';
  final description = 'Rollback the last database migration';
  final List<Migration> migrations;

  MigrateRollbackCommand(this.migrations) {
    this.migrations.sort((a, b) => a.id.compareTo(b.id));
  }

  Future<int> run() async {
    final ranMigrations = await getRanMigrations() as List<MappedRow>;
    if (ranMigrations.isEmpty) {
      info('No migrations to rollback');
      return 0;
    }

    final migrationId = ranMigrations.last['id'] as String;
    final migration = migrations.where((mig) => mig.id == migrationId).first;
    final rollingback =
        progress('Rolling back: ${migration.id}_${migration.name.snakeCase}');

    try {
      await migration.down();
      await deleteMigration(migration);
      rollingback
          .complete('Rolled back: ${migration.id}_${migration.name.snakeCase}');

      return 0;
    } catch (err) {
      rollingback.fail(
          'Failed to rollback: ${migration.id}_${migration.name.snakeCase}');
      error(err.toString());

      return 1;
    }
  }
}
