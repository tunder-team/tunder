import 'dart:io';

import 'package:tunder/src/console/command.dart';
import 'package:tunder/src/console/commands/migrations/make_migration_command.dart';
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
    return [
      MakeMigrationCommand(),
    ];
  }

  @override
  List<Type> commands() => [];

  List<Command> get _commands =>
      commands().map((command) => app.get<Command>(command)).toList();
}
