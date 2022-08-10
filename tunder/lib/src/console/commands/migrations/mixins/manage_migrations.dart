import 'package:clock/clock.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:tunder/console.dart';
import 'package:tunder/database.dart';

mixin ManageMigrations on Command<int> {
  List<Migration> migrations = [];
  late final List ranMigrations;
  List<Migration> get pendingMigrations => migrations
      .where((migration) =>
          !ranMigrations.any((existing) => existing['id'] == migration.id))
      .toList();

  Future<void> createMigrationsTable() async {
    Progress creation = progress('Creating migrations table');
    await Schema.create('migrations', (table) {
      table
        ..string('id').notNullable().primary()
        ..string('name').notNullable()
        ..dateTime('executed_at').notNullable();
    });
    creation.complete('Migrations table created');
  }

  Future<List> getRanMigrations() => Query('migrations').orderBy('id').all();

  Future insertMigration(Migration migration) => Query('migrations').insert({
        'id': migration.id,
        'name': migration.name,
        'executed_at': clock.now(),
      });

  Future<int> deleteMigration(Migration migration) =>
      Query('migrations').whereMap({'id': migration.id}).delete();
}
