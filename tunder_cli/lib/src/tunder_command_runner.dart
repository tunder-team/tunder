import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:tunder_cli/src/commands/create.dart';

class TunderCommandRunner extends CommandRunner<int> {
  late final GeneratorBuilder builder;
  late final Logger logger;

  TunderCommandRunner([GeneratorBuilder? builder, Logger? logger])
      : super('tunder', 'Tunder CLI') {
    this.builder = builder ?? MasonGenerator.fromBundle;
    this.logger = logger ?? Logger();

    addCommand(CreateCommand(this.builder, this.logger));
  }
}
