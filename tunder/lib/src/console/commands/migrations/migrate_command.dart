import 'package:clock/clock.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:tunder/console.dart';
import 'package:tunder/database.dart';

class MigrateCommand extends Command {
  final name = 'migrate';
  final description = 'Runs migrations';
  final List<Migration> migrations;
  late final List ranMigrations;

  MigrateCommand(this.migrations);

  List<Migration> get remainingMigrations => migrations
      .where((migration) =>
          !ranMigrations.any((existing) => existing['id'] == migration.version))
      .toList();

  Future run() async {
    if (!await DB.tableExists('migrations')) await createMigrationsTable();
    ranMigrations = await getRanMigrations();

    for (final migration in remainingMigrations) {
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

  Future<int> insertMigration(Migration migration) {
    return Query('migrations').insert({
      'id': migration.version,
      'name': migration.name,
      'executed_at': clock.now(),
    });
  }

  Future<void> createMigrationsTable() async {
    Progress creation = progress('Creating migrations table');
    await Schema.create('migrations', (table) {
      table
        ..bigInteger('id').notNullable().primary()
        ..string('name').notNullable()
        ..dateTime('executed_at').notNullable();
    });
    creation.complete('Migrations table created');
  }

  Future<List> getRanMigrations() async {
    return Query('migrations').all();
  }
}
