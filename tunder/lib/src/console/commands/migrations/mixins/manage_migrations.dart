import 'package:clock/clock.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:tunder/console.dart';
import 'package:tunder/database.dart';

mixin ManageMigrations on Command {
  List<Migration> migrations = [];
  late final List ranMigrations;
  List<Migration> get pendingMigrations => migrations
      .where((migration) =>
          !ranMigrations.any((existing) => existing['id'] == migration.version))
      .toList();

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
    return Query('migrations').orderBy('id', 'desc').all();
  }

  Future<int> insertMigration(Migration migration) {
    return Query('migrations').insert({
      'id': migration.version,
      'name': migration.name,
      'executed_at': clock.now(),
    });
  }
}
