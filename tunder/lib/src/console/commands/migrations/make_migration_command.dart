import 'dart:io';

import 'package:clock/clock.dart';
import 'package:path/path.dart' as path;
import 'package:tunder/console.dart';
import 'package:tunder/tunder.dart';

class MakeMigrationCommand extends Command {
  final name = 'make:migration';
  final description = 'Create a migration file';
  final String stubsDir;
  final String destinationDir;

  String? _migrationName;
  String get migrationName => _migrationName ??= argResults!.rest.join(' ');
  int? _timestamp;
  int get timestamp => _timestamp ??= clock.now().millisecondsSinceEpoch;

  MakeMigrationCommand({
    this.destinationDir = ConsoleConfig.migrationDestination,
    this.stubsDir = ConsoleConfig.stubsDirectory,
  });

  run() async {
    var file = File('$stubsDir/migrations/migration.stub');

    if (!file.existsSync())
      throw Exception('Stub file not found: ${file.path}');

    var logging = silent ? null : progress('Creating migration');
    File createdFile = generateMigrationFile(file);
    registerMigrationInIndexFile(createdFile);
    registerMigrationInListFile(createdFile);

    if (logging != null)
      logging.complete('Migration created: ${createdFile.path}');
  }

  File generateMigrationFile(File file) {
    var contents = file.readAsStringSync();

    contents = contents
        .replaceAll('{{ version }}', timestamp.toString())
        .replaceAll('{{ name }}', migrationName);

    var fileName = '${timestamp}_${migrationName.snakeCase}.dart';
    var createdFile = _generateFile(fileName, contents);

    return createdFile;
  }

  void registerMigrationInIndexFile(File generated) {
    var indexFile = File(path.join(destinationDir, 'index.dart'));
    var indexContents =
        indexFile.existsSync() ? indexFile.readAsStringSync() : '// end\n';
    var migrationExport = "export '${path.basename(generated.path)}';\n// end";

    indexContents = indexContents.replaceAll('// end', migrationExport);
    indexFile
      ..createSync()
      ..writeAsStringSync(indexContents);
  }

  void registerMigrationInListFile(File generated) {
    var listFile = File(path.join(destinationDir, 'list.dart'));
    var defaultListContents = '''
import 'index.dart';

var migrations = [
];

''';
    var listContents = listFile.existsSync()
        ? listFile.readAsStringSync()
        : defaultListContents;
    var migrationInstance = "  Migration$timestamp(),\n];";

    listContents = listContents.replaceAll('];', migrationInstance);
    listFile
      ..createSync()
      ..writeAsStringSync(listContents);
  }

  File _generateFile(String fileName, String contents) =>
      File(path.join(destinationDir, fileName))
        ..createSync(recursive: true)
        ..writeAsStringSync(contents);
}
