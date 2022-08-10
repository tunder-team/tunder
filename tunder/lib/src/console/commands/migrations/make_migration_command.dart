import 'dart:io';

import 'package:clock/clock.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:tunder/console.dart';
import 'package:tunder/src/console/commands/migrations/contracts/migration_command.dart';
import 'package:tunder/tunder.dart';

class MakeMigrationCommand extends MigrationCommand {
  final name = 'make:migration';
  final description = 'Creates a migration file';
  final String stubsDir;
  final String destinationDir;

  String? _migrationName;
  String get migrationName => _migrationName ??= argResults!.rest.join(' ');

  String? _id;
  String get id {
    if (_id != null) return _id!;

    return _id = DateFormat('yyyy_MM_dd_HHmmss').format(clock.now());
  }

  MakeMigrationCommand({
    this.destinationDir = ConsoleConfig.migrationDestination,
    this.stubsDir = ConsoleConfig.stubsDirectory,
  });

  Future<int> run() async {
    var file = File('$stubsDir/migrations/migration.stub');

    if (!file.existsSync())
      throw Exception('Stub file not found: ${file.path}');

    var logging = silent ? null : progress('Creating migration');
    File createdFile = generateMigrationFile(file);
    registerMigrationInIndexFile(createdFile);
    registerMigrationInListFile(createdFile);

    logging?.complete('Migration created: ${createdFile.path}');

    return 0;
  }

  File generateMigrationFile(File file) {
    var contents = file.readAsStringSync();

    contents = contents
        .replaceAll('{{ id }}', id)
        .replaceAll('{{ name }}', migrationName);

    var fileName = '${id}_${migrationName.snakeCase}.dart';
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
import 'package:tunder/database.dart';

import 'index.dart';

final List<Migration> migrations = [
];

''';
    var listContents = listFile.existsSync()
        ? listFile.readAsStringSync()
        : defaultListContents;
    var migrationInstance = "  Migration_$id(),\n];";

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
