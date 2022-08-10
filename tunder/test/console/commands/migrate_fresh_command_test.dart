import 'package:test/test.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/console/commands/db/wipe_command.dart';
import 'package:tunder/src/console/commands/migrations/migrate_command.dart';
import 'package:tunder/src/console/commands/migrations/migrate_fresh_command.dart';
import 'package:tunder/test.dart';

import '../contexts/sky_command_context_for_migrations.dart';

main() {
  useDatabaseTransactions();

  group('MigrateFreshCommand', () {
    test('responds to migrate:fresh command', () {
      expect(MigrateFreshCommand().name, 'migrate:fresh');
    });

    test('has a description', () {
      expect(MigrateFreshCommand().description,
          'Drops all tables from database and re-runs all migrations');
    });

    test('has migrations category', () {
      expect(MigrateFreshCommand().category, 'migrations');
    });

    test('drops all tables from database calling db:wipe command', () async {
      // Arrange
      final migration3 = MigrationWithTable();
      final wipeCommand = WipeCommand();
      final migrateCommand =
          MigrateCommand([Migration1(), Migration2(), migration3]);

      final test = await SkyCommandContextForMigrations(
          forCommand: MigrateFreshCommand())
        ..mockProgressCall()
        ..sky.addTunderCommand(wipeCommand)
        ..sky.addTunderCommand(migrateCommand);

      await test.createMigrationsTable();
      final strangeTable = await test.createRandomTable();

      // Act
      final exitCode = await test.sky.run(['migrate:fresh']);

      // Assert
      expect(exitCode, 0);
      expect(await DB.tableExists(strangeTable), false);
      expect(await DB.tableExists('migrations'), true);
      expect(await DB.tableExists(migration3.table), true);
      expect(await Query('migrations').count(), 3);
    });
  });
}

class MigrationWithTable extends Migration {
  final id = '3';
  final name = 'MigrationWithTable';
  final table = 'migrate_fresh_table';

  @override
  Future up() async {
    await Schema.create(table, (table) {
      table
        ..id()
        ..string('name');
    });
  }

  @override
  Future down() async {}
}
