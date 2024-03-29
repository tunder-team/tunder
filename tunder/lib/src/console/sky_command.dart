import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:tunder/console.dart' as tunder;
import 'package:tunder/tunder.dart';

class SkyCommand<int> extends CommandRunner<int> {
  late final Logger logger;
  bool silent;
  final Application app;

  SkyCommand(this.app, this.logger, {this.silent = false})
      : super('sky', 'Tunder Framework $tunderVersion');

  void addTunderCommand(tunder.Command<int> command) =>
      super.addCommand(command..logger = logger);
}
