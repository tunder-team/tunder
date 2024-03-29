import 'package:args/command_runner.dart' as args;
import 'package:mason_logger/mason_logger.dart';
import 'package:tunder/console.dart';

abstract class Command<int> extends args.Command<int> {
  late final String name;
  late final String description;
  late Logger logger;
  SkyCommand<int> get sky => runner as SkyCommand<int>;
  bool get silent => sky.silent;

  void info(String message) => logger.info(message);
  void alert(String message) => logger.alert(message);
  String prompt(String message) => logger.prompt(message);
  Progress progress(String message) => logger.progress(message);
  bool confirm(String message) => logger.confirm(message);
  void error(String message) => logger.err(message);
  void warning(String message) => logger.warn(message);
}
