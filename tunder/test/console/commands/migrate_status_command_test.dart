import 'package:colorize/colorize.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/console/commands/migrations/migrate_status_command.dart';
import 'package:tunder/test.dart';

import '../../helpers.dart';
import '../contexts/sky_command_context.dart';

main() {
  useDatabaseTransactions();
  final pending = Colorize('pending')
    ..bold()
    ..lightYellow();
  final checked = Colorize('✔')
    ..bold()
    ..lightGreen();

  group('MigrateStatusCommand', () {
    test('creates table "migrations" if doesnt exist', () async {
      // Arrange
      final test = SkyCommandContext(forCommand: MigrateStatusCommand([]))
        ..mockProgressCall();

      // Act
      expect(await DB.tableExists('migrations'), false);
      await test.sky.run(['migrate:status']);
      expect(await DB.tableExists('migrations'), true);
    });

    test('lists all pending migrations', () async {
      // Arrange
      final migration1 = Migration1();
      final migration2 = Migration2();
      final test = SkyCommandContext(forCommand: MigrateStatusCommand([]))
        ..mockProgressCall()
        ..mockInfoCall()
        ..addMigrations([
          migration1,
          migration2,
        ]);

      // Act
      await test.sky.run(['migrate:status']);

      // Assert
      verify(() => test.logger
              .info(' $pending ${migration1.id}_${migration1.name.snakeCase}'))
          .called(1);
      verify(() => test.logger
              .info(' $pending ${migration2.id}_${migration2.name.snakeCase}'))
          .called(1);
      await assertDatabaseDoesntHave('migrations', {
        'id': migration1.id,
      });
      await assertDatabaseDoesntHave('migrations', {
        'id': migration2.id,
      });
    });

    test(
        'list ran migrations with "$checked" icon in logs and "$pending" keyword for pending migrations',
        () async {
      // Arrange
      final migration1 = Migration1();
      final migration2 = Migration2();
      final test = await SkyCommandContext(forCommand: MigrateStatusCommand([]))
        ..mockProgressCall()
        ..createMigrationsTable()
        ..addExistingMigrations([
          migration1,
        ])
        ..addMigrations([
          migration2,
        ]);

      // Act
      await test.sky.run(['migrate:status']);

      // Assert
      verify(() => test.logger
              .info(' $checked ${migration1.id}_${migration1.name.snakeCase}'))
          .called(1);
      verify(() => test.logger
              .info(' $pending ${migration2.id}_${migration2.name.snakeCase}'))
          .called(1);
      await assertDatabaseHas('migrations', {'id': migration1.id});
      await assertDatabaseDoesntHave('migrations', {'id': migration2.id});
    });

    test('list migrations in order of version', () async {
      // Arrange
      final migration1 = Migration1();
      final migration2 = Migration2();
      final test = await SkyCommandContext(
          forCommand: MigrateStatusCommand([
        migration2,
        migration1,
      ]))
        ..mockProgressCall()
        ..createMigrationsTable();

      // Act
      final sortedMigrations = test.command.migrations;
      expect(sortedMigrations.length, 2);
      expect(sortedMigrations.first.id, migration1.id);
      expect(sortedMigrations.last.id, migration2.id);
    });
  });
}
