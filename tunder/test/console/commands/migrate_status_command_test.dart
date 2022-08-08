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
              .info(' $pending ${migration1.version} ${migration1.name}'))
          .called(1);
      verify(() => test.logger
              .info(' $pending ${migration2.version} ${migration2.name}'))
          .called(1);
      await assertDatabaseDoesntHave('migrations', {
        'id': migration1.version,
      });
      await assertDatabaseDoesntHave('migrations', {
        'id': migration2.version,
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
              .info(' $checked ${migration1.version} ${migration1.name}'))
          .called(1);
      verify(() => test.logger
              .info(' $pending ${migration2.version} ${migration2.name}'))
          .called(1);
      await assertDatabaseHas('migrations', {'id': migration1.version});
      await assertDatabaseDoesntHave('migrations', {'id': migration2.version});
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
      expect(sortedMigrations.first.version, migration1.version);
      expect(sortedMigrations.last.version, migration2.version);
    });
  });
}
