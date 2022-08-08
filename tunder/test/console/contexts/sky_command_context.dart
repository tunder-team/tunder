import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tunder/console.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/console/commands/migrations/contracts/migration_command.dart';

class SkyCommandContext {
  late final SkyCommand sky;
  late final MigrationCommand command;
  final logger = LoggerMock();
  final progress = ProgressMock();
  late final migrationsDir;

  SkyCommandContext({required MigrationCommand forCommand}) {
    command = forCommand;
    sky = SkyCommand(logger, silent: true)..addTunderCommand(command);
  }

  Future<void> createMigrationsTable() => command.createMigrationsTable();

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
  final name = 'Migration1';
  final version = 1;

  @override
  Future down() async {}

  @override
  Future up() async {}
}

class Migration2 extends Migration {
  final name = 'Migration2';
  final version = 2;

  @override
  Future down() async {}

  @override
  Future up() async {}
}

class MigrationWithError extends Migration {
  final name = 'MigrationWithError';
  final version = 3;

  @override
  Future down() async {
    throw Exception('Some error on down');
  }

  @override
  Future up() async {
    throw Exception('Some error');
  }
}
