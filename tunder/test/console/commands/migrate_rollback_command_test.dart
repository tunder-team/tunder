import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/console/commands/migrations/migrate_rollback_command.dart';
import 'package:tunder/test.dart';

import '../../helpers.dart';
import '../contexts/sky_command_context_for_migrations.dart';

main() {
  useDatabaseTransactions();

  group('MigrateRollbackCommand', () {
    test('responds to migrate:rollback command', () {
      expect(MigrateRollbackCommand([]).name, 'migrate:rollback');
    });

    test('has description', () {
      expect(MigrateRollbackCommand([]).description,
          'Rollback the last database migration');
    });

    test('has migrations category', () {
      expect(MigrateRollbackCommand([]).category, 'migrations');
    });

    test('displays "no migrations to rollback" if theres no migration ran',
        () async {
      // Arrange
      final migration1 = Migration1();
      final migration2 = Migration2();
      final test = await SkyCommandContextForMigrations(
          forCommand: MigrateRollbackCommand([
        migration1,
        migration2,
      ]))
        ..mockProgressCall()
        ..createMigrationsTable();

      // Act
      final exitCode = await test.sky.run(['migrate:rollback']);
      expect(exitCode, 0);

      // Assert
      verify(() => test.logger.info('No migrations to rollback')).called(1);
      await assertDatabaseDoesntHave('migrations', {'id': migration1.id});
      await assertDatabaseDoesntHave('migrations', {'id': migration2.id});
    });

    test('rollbacks latest migration', () async {
      // Arrange
      final migration1 = Migration1();
      final migration2 = Migration2();
      final test =
          SkyCommandContextForMigrations(forCommand: MigrateRollbackCommand([]))
            ..mockProgressCall()
            ..createMigrationsTable()
            ..addExistingMigrations([
              migration1,
              migration2,
            ]);

      // Act and Assert
      await assertDatabaseHas('migrations', {'id': migration1.id});
      await assertDatabaseHas('migrations', {'id': migration2.id});
      int exitCode = await test.sky.run(['migrate:rollback']);
      expect(exitCode, 0);
      await assertDatabaseHas('migrations', {'id': migration1.id});
      await assertDatabaseDoesntHave('migrations', {'id': migration2.id});
      verifyNever(() => test.logger.progress(
          'Rolled back: ${migration1.id}_${migration1.name.snakeCase}'));
      verifyNever(() => test.progress.complete(
          'Rolled back: ${migration1.id}_${migration1.name.snakeCase}'));

      verify(() => test.logger.progress(
              'Rolling back: ${migration2.id}_${migration2.name.snakeCase}'))
          .called(1);
      verify(() => test.progress.complete(
              'Rolled back: ${migration2.id}_${migration2.name.snakeCase}'))
          .called(1);
    });

    test('dont remove migration from database if rollback fail', () async {
      // Arrange
      final migration1 = Migration1();
      final migration2 = Migration2();
      final migrationWithError = MigrationWithError();
      final test = await SkyCommandContextForMigrations(
          forCommand: MigrateRollbackCommand([]))
        ..mockProgressCall()
        ..createMigrationsTable()
        ..addExistingMigrations([
          migration1,
          migration2,
          migrationWithError,
        ]);

      // Act and Assert
      int exitCode = await test.sky.run(['migrate:rollback']);
      await assertDatabaseHas('migrations', {'id': migration1.id});
      await assertDatabaseHas('migrations', {'id': migration2.id});
      await assertDatabaseHas('migrations', {'id': migrationWithError.id});
      expect(exitCode, 1);
      verify(() =>
          test.progress.fail('Failed to rollback: 3_migration_with_error'));
      verify(() => test.logger.err('Exception: Some error on down')).called(1);
    });
  });
}
