import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:tunder/console.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/console/commands/migrations/migrate_command.dart';
import 'package:tunder/test.dart';

import '../../helpers.dart';

main() {
  useDatabaseTransactions();

  group('MigrateCommand', () {
    test('creates table "migrations" if doesnt exist', () async {
      // Arrange
      final test = SkyCommandContext()..mockProgressCall();

      // Act
      expect(await DB.tableExists('migrations'), false);
      await test.sky.run(['migrate']);
      expect(await DB.tableExists('migrations'), true);
    });

    test('runs each migration and insert them in migrations table', () async {
      // Arrange
      final migration1 = Migration1();
      final test = SkyCommandContext()
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
      final test = await SkyCommandContext()
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
      final test = await SkyCommandContext()
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
      final test = await SkyCommandContext()
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

class SkyCommandContext {
  late final SkyCommand sky;
  final command = MigrateCommand([]);
  final logger = LoggerMock();
  final progress = ProgressMock();
  late final migrationsDir;

  SkyCommandContext() {
    sky = SkyCommand(logger, silent: true);
    sky.addTunderCommand(command);
  }

  Future<void> createMigrationsTable() {
    return command.createMigrationsTable();
  }

  void mockProgressCall() {
    when(() => logger.progress(any())).thenReturn(progress);
  }

  Future<void> addMigrations(List<Migration> migrations) async {
    command.migrations..addAll(migrations);
  }

  Future<void> addExistingMigrations(List<Migration> migrations) async {
    migrations.forEach((migration) => command.insertMigration(migration));
    command.migrations..addAll(migrations);
  }
}

class LoggerMock extends Mock implements Logger {}

class ProgressMock extends Mock implements Progress {}

class Migration1 extends Migration {
  final name = 'Migration1';
  final version = 1;

  @override
  Future down() async {
    //
  }

  @override
  Future up() async {
    //
  }
}

class Migration2 extends Migration {
  final name = 'Migration2';
  final version = 2;

  @override
  Future down() async {
    //
  }

  @override
  Future up() async {
    //
  }
}

class MigrationWithError extends Migration {
  final name = 'MigrationWithError';
  final version = 3;

  @override
  Future down() async {
    //
  }

  @override
  Future up() async {
    throw Exception('Some error');
  }
}
