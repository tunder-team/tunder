import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tunder/console.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/console/commands/migrations/contracts/migration_command.dart';
import 'package:tunder/utils.dart';

class SkyCommandContextForMigrations {
  late final SkyCommand sky;
  late final MigrationCommand command;
  final logger = LoggerMock();
  final progress = ProgressMock();
  late final migrationsDir;

  SkyCommandContextForMigrations({required MigrationCommand forCommand}) {
    command = forCommand;
    sky = SkyCommand<int>(logger, silent: true)..addTunderCommand(command);
  }

  Future<void> createMigrationsTable() => command.createMigrationsTable();

  Future<String> createRandomTable() async {
    final table = 'test_table_${Generate.id()}';
    await Schema.create(table, (table) => table..id());

    return table;
  }

  void mockProgressCall() =>
      when(() => logger.progress(any())).thenReturn(progress);
  void mockInfoCall() => when(() => logger.info(any())).thenReturn(null);

  void addMigrations(List<Migration> migrations) =>
      command.migrations..addAll(migrations);

  Future<void> addExistingMigrations(List<Migration> migrations) async {
    migrations.forEach((migration) => command.insertMigration(migration));
    command.migrations..addAll(migrations);
  }
}

class LoggerMock extends Mock implements Logger {}

class ProgressMock extends Mock implements Progress {}

class Migration1 extends Migration {
  final id = '1';
  final name = 'Migration1';

  @override
  Future down() async {}

  @override
  Future up() async {}
}

class Migration2 extends Migration {
  final id = '2';
  final name = 'Migration2';

  @override
  Future down() async {}

  @override
  Future up() async {}
}

class MigrationWithError extends Migration {
  final id = '3';
  final name = 'MigrationWithError';

  @override
  Future down() async {
    throw Exception('Some error on down');
  }

  @override
  Future up() async {
    throw Exception('Some error');
  }
}
