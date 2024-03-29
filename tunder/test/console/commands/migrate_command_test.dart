import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/console/commands/migrations/migrate_command.dart';
import 'package:tunder/test.dart';

import '../../helpers.dart';
import '../contexts/sky_command_context_for_migrations.dart';

main() {
  useDatabaseTransactions();

  group('MigrateCommand', () {
    test('responds to migrate command', () {
      expect(MigrateCommand([]).name, 'migrate');
    });

    test('has a description', () {
      expect(MigrateCommand([]).description, 'Runs migrations');
    });

    test('has migrations category', () {
      expect(MigrateCommand([]).category, 'migrations');
    });

    test('creates table "migrations" if doesnt exist', () async {
      // Arrange
      final test =
          SkyCommandContextForMigrations(forCommand: MigrateCommand([]))
            ..mockProgressCall();

      // Act
      expect(await DB.tableExists('migrations'), false);
      final exitCode = await test.sky.run(['migrate']);
      expect(await DB.tableExists('migrations'), true);
      expect(exitCode, 0);
    });

    test('runs each migration and insert them in migrations table', () async {
      // Arrange
      final migration1 = Migration1();
      final test =
          SkyCommandContextForMigrations(forCommand: MigrateCommand([]))
            ..mockProgressCall()
            ..addMigrations([
              migration1,
            ]);

      // Act
      await test.sky.run(['migrate']);

      // Assert
      await assertDatabaseHas('migrations', {
        'id': migration1.id,
      });
    });

    test('runs remaining migrations based on table', () async {
      // Arrange
      final migration1 = Migration1();
      final migration2 = Migration2();
      final test =
          await SkyCommandContextForMigrations(forCommand: MigrateCommand([]))
            ..mockProgressCall()
            ..createMigrationsTable()
            ..addExistingMigrations([
              migration1,
            ])
            ..addMigrations([
              migration2,
            ]);

      // Act
      await test.sky.run(['migrate']);

      // Assert
      await assertDatabaseHas('migrations', {'id': migration1.id});
      await assertDatabaseHas('migrations', {'id': migration2.id});
    });

    test('dont insert a migration on failure', () async {
      // Arrange
      final migration1 = Migration1();
      final migration2 = Migration2();
      final migrationWithError = MigrationWithError();
      final test =
          await SkyCommandContextForMigrations(forCommand: MigrateCommand([]))
            ..mockProgressCall()
            ..createMigrationsTable()
            ..addExistingMigrations([
              migration1,
            ])
            ..addMigrations([migration2, migrationWithError]);

      // Act
      final exitCode = await test.sky.run(['migrate']);

      // Assert
      expect(exitCode, 1);
      await assertDatabaseHas('migrations', {'id': migration1.id});
      await assertDatabaseHas('migrations', {'id': migration2.id});
      await assertDatabaseDoesntHave(
          'migrations', {'id': migrationWithError.id});
      verify(() => test.logger.err(any())).called(1);
    });

    test('doesnt continue to run migrations if one fails', () async {
      // Arrange
      final migration1 = Migration1();
      final migration2 = Migration2();
      final migrationWithError = MigrationWithError();
      final test =
          await SkyCommandContextForMigrations(forCommand: MigrateCommand([]))
            ..mockProgressCall()
            ..createMigrationsTable()
            ..addExistingMigrations([
              migration1,
            ])
            ..addMigrations([migrationWithError, migration2]);

      // Act
      final exitCode = await test.sky.run(['migrate']);

      // Assert
      expect(exitCode, 1);
      await assertDatabaseHas('migrations', {'id': migration1.id});
      await assertDatabaseDoesntHave(
          'migrations', {'id': migrationWithError.id});
      await assertDatabaseDoesntHave('migrations', {'id': migration2.id});
      verify(() => test.logger.err(any())).called(1);
    });

    test('prints "No pending migrations" if all migrations migrated', () async {
      // Arrange
      final migration1 = Migration1();
      final migration2 = Migration2();
      final test =
          await SkyCommandContextForMigrations(forCommand: MigrateCommand([]))
            ..mockProgressCall()
            ..createMigrationsTable()
            ..addExistingMigrations([
              migration1,
              migration2,
            ]);

      // Act
      final exitCode = await test.sky.run(['migrate']);

      // Assert
      expect(exitCode, 0);
      await assertDatabaseHas('migrations', {'id': migration1.id});
      await assertDatabaseHas('migrations', {'id': migration2.id});
      verify(() => test.logger.info('No pending migrations')).called(1);
    });
  });
}
