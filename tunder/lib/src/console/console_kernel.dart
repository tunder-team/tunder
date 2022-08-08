import 'dart:io';

import 'package:tunder/database.dart';
import 'package:tunder/src/console/command.dart';
import 'package:tunder/src/console/commands/migrations/make_migration_command.dart';
import 'package:tunder/src/console/commands/migrations/migrate_command.dart';
import 'package:tunder/src/console/commands/migrations/migrate_status_command.dart';
import 'package:tunder/src/console/sky_command.dart';
import 'package:tunder/tunder.dart';

import '../contracts/console_kernel_contract.dart';

class ConsoleKernel implements ConsoleKernelContract {
  final Application app;

  ConsoleKernel(this.app);

  @override
  Future<int> handle(List<String> arguments) async {
    SkyCommand runner = app.get(SkyCommand);

    (baseCommands() + _commands)
        .forEach((command) => runner.addTunderCommand(command));

    await runner.run(arguments);

    return exitCode;
  }

  List<Command> baseCommands() {
    final appMigrations = migrations();
    return [
      MakeMigrationCommand(),
      MigrateCommand(appMigrations),
      MigrateStatusCommand(appMigrations),
    ];
  }

  @override
  List<Type> commands() => [];
  List<Migration> migrations() => [];

  List<Command> get _commands =>
      commands().map((command) => app.get<Command>(command)).toList();
}
