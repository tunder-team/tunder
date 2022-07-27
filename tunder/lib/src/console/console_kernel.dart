import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:tunder/tunder.dart';

import '../contracts/console_kernel_contract.dart';

class ConsoleKernel implements ConsoleKernelContract {
  final Application app;
  final Set<Type> commands = {};

  ConsoleKernel(this.app);

  @override
  Future<int> handle(List<String> arguments) async {
    var runner = CommandRunner('tunder', 'Tunder Framework $TunderVersion');

    commands.forEach((command) => runner.addCommand(app.get(command)));

    runner.run(arguments);

    return exitCode;
  }
}
