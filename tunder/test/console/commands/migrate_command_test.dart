import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/console/commands/migrations/migrate_command.dart';
import 'package:tunder/test.dart';

import '../../helpers.dart';
import '../contexts/sky_command_context.dart';

main() {
  useDatabaseTransactions();

  group('MigrateCommand', () {
    test('creates table "migrations" if doesnt exist', () async {
      // Arrange
      final test = SkyCommandContext(forCommand: MigrateCommand([]))
        ..mockProgressCall();

      // Act
      expect(await DB.tableExists('migrations'), false);
      await test.sky.run(['migrate']);
      expect(await DB.tableExists('migrations'), true);
    });

    test('runs each migration and insert them in migrations table', () async {
      // Arrange
      final migration1 = Migration1();
      final test = SkyCommandContext(forCommand: MigrateCommand([]))
        ..mockProgressCall()
        ..addMigrations([
          migration1,
        ]);

      // Act
      await test.sky.run(['migrate']);

      // Assert
      await assertDatabaseHas('migrations', {
        'id': migration1.version,
      });
    });

    test('runs remaining migrations based on table', () async {
      // Arrange
      final migration1 = Migration1();
      final migration2 = Migration2();
      final test = await SkyCommandContext(forCommand: MigrateCommand([]))
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
      await assertDatabaseHas('migrations', {'id': migration1.version});
      await assertDatabaseHas('migrations', {'id': migration2.version});
    });

    test('dont insert a migration on failure', () async {
      // Arrange
      final migration1 = Migration1();
      final migration2 = Migration2();
      final migrationWithError = MigrationWithError();
      final test = await SkyCommandContext(forCommand: MigrateCommand([]))
        ..mockProgressCall()
        ..createMigrationsTable()
        ..addExistingMigrations([
          migration1,
        ])
        ..addMigrations([migration2, migrationWithError]);

      // Act
      await test.sky.run(['migrate']);

      // Assert
      await assertDatabaseHas('migrations', {'id': migration1.version});
      await assertDatabaseHas('migrations', {'id': migration2.version});
      await assertDatabaseDoesntHave(
          'migrations', {'id': migrationWithError.version});
      verify(() => test.logger.err(any())).called(1);
    });

    test('doesnt continue to run migrations if one fails', () async {
      // Arrange
      final migration1 = Migration1();
      final migration2 = Migration2();
      final migrationWithError = MigrationWithError();
      final test = await SkyCommandContext(forCommand: MigrateCommand([]))
        ..mockProgressCall()
        ..createMigrationsTable()
        ..addExistingMigrations([
          migration1,
        ])
        ..addMigrations([migrationWithError, migration2]);

      // Act
      await test.sky.run(['migrate']);

      // Assert
      await assertDatabaseHas('migrations', {'id': migration1.version});
      await assertDatabaseDoesntHave(
          'migrations', {'id': migrationWithError.version});
      await assertDatabaseDoesntHave('migrations', {'id': migration2.version});
      verify(() => test.logger.err(any())).called(1);
    });
  });
}
