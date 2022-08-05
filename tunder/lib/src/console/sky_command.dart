import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:tunder/console.dart' as tunder;
import 'package:tunder/tunder.dart';

class SkyCommand<T> extends CommandRunner<T> {
  late final Logger logger;
  bool silent;

  SkyCommand(this.logger, {this.silent = false})
      : super('sky', 'Tunder Framework $tunderVersion');

  void addTunderCommand(tunder.Command<T> command) {
    super.addCommand(
      command
        ..logger = logger
        ..silent = silent,
    );
  }
}
