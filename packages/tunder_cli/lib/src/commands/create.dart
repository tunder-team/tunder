import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:recase/recase.dart';
import 'package:collection/collection.dart';
import 'package:tunder_cli/src/templates/project_bundle.dart';

typedef GeneratorBuilder = Future<MasonGenerator> Function(MasonBundle);

class CreateCommand extends Command<int> {
  @override
  String get description => 'Create your Tunder project.';

  @override
  String get name => 'create';
  late final Logger logger;
  late final GeneratorBuilder builder;

  CreateCommand(this.builder, this.logger) {
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'The name of the project to create.',
    );
  }

  @override
  run() async {
    var folderName = _getFolderNameOrAsk();

    final progress = logger.progress('Creating project...');
    final generator = await builder(projectBundle);

    await generator.generate(
      DirectoryGeneratorTarget(Directory.current),
      vars: {
        'name': folderName,
      },
    );

    progress.complete('Tunder project successfully created!');

    return 0;
  }

  String _getFolderNameOrAsk() {
    var name = argResults?.rest.firstOrNull ??
        logger.prompt('What is the name of your project?');

    while (name == '') {
      logger.alert('You must provide a name for your project');
      name = logger.prompt('What is the name of your project?');
    }

    return name.snakeCase;
  }
}
