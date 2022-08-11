import 'dart:io';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';
import 'package:tunder/console.dart';
import 'package:tunder/src/console/commands/migrations/make_migration_command.dart';
import 'package:tunder/tunder.dart';
import 'package:clock/clock.dart';
import 'package:tunder/utils.dart';

main() {
  group('MakeMigrationCommand', () {
    const testStubsDir = 'test/stubs';

    test('responds to migrate command', () {
      expect(MakeMigrationCommand().name, 'make:migration');
    });

    test('has a description', () {
      expect(MakeMigrationCommand().description, 'Creates a migration file');
    });

    test('has migrations category', () {
      expect(MakeMigrationCommand().category, 'migrations');
    });

    test('has one argument', () {
      const testDestinationDir = 'tmp/migrations1';
      final sky = SkyCommand<int>(app(), Logger(), silent: true);
      final command = MakeMigrationCommand(
        stubsDir: testStubsDir,
        destinationDir: testDestinationDir,
      );
      sky.addTunderCommand(command);
      expect(command.invocation, 'sky make:migration [arguments]');
    });

    test('real migration file', () async {
      // Arrange
      final sky = SkyCommand<int>(app(), Logger(), silent: true);
      final command = MakeMigrationCommand();
      sky.addTunderCommand(command);
      final currentTime = DateTime.now();
      final id = DateFormat('yyyy_MM_dd_HHmmss').format(currentTime);
      var name = 'Some migration name';
      var expectedContent = '''
import 'package:tunder/database.dart';

class Migration_$id extends Migration {
  final id = '$id';
  final name = '$name';

  up() async {
    // TODO: Add your migration logic here.
  }

  down() async {
    // TODO: Add your migration logic here.
  }
}\n''';

      // Act
      int? exitCode;
      await withClock(Clock.fixed(currentTime), () async {
        exitCode = await sky.run(['make:migration', name]);
      });
      var file = File(join(
          '${ConsoleConfig.migrationDestination}/${id}_${name.snakeCase}.dart'));

      // Assert
      expect(file.existsSync(), true);
      expect(file.readAsStringSync(), expectedContent);
      cleanUpDir('database');
      expect(exitCode, 0);
    });

    test('creates a migration file from stub', () async {
      // Arrange
      const testDestinationDir = 'tmp/migrations2';
      final sky = SkyCommand<int>(app(), Logger(), silent: true);
      final command = MakeMigrationCommand(
        stubsDir: testStubsDir,
        destinationDir: testDestinationDir,
      );
      sky.addTunderCommand(command);
      final currentTime = DateTime.now();
      final id = DateFormat('yyyy_MM_dd_HHmmss').format(currentTime);
      final expectedContent = 'class Migration_${id} {}\n';
      final name = 'A migration';

      // Act
      withClock(Clock.fixed(currentTime), () async {
        await sky.run(['make:migration', name]);
      });

      // Assert
      var file = File('$testDestinationDir/${id}_${name.snakeCase}.dart');
      expect(file.existsSync(), true);
      expect(file.readAsStringSync(), expectedContent);
      Directory(testDestinationDir).deleteSync(recursive: true);
    });

    test(
        'calls progress method from logger on success when silent is false (the default behaviour)',
        () async {
      // Arrange
      const testDestinationDir = 'tmp/migrations3';
      final command = MakeMigrationCommand(
        stubsDir: testStubsDir,
        destinationDir: testDestinationDir,
      );
      final currentTime = DateTime.now();
      final id = DateFormat('yyyy_MM_dd_HHmmss').format(currentTime);
      final logger = LoggerMock();
      final progress = ProgressMock();
      final name = 'some migration';
      final filename = '${id}_${name.snakeCase}.dart';
      final sky = SkyCommand<int>(app(), logger, silent: false);
      sky.addTunderCommand(command);

      when(() => logger.progress(any())).thenReturn(progress);
      when(() => progress.complete(any())).thenReturn(null);

      // Act
      withClock(Clock.fixed(currentTime), () async {
        await sky.run(['make:migration', name]);
      });

      // Assert
      final file = File(join('$testDestinationDir/$filename'));
      expect(file.existsSync(), true);
      verify(() => logger.progress('Creating migration')).called(1);
      verify(() => progress.complete(
          'Migration created: $testDestinationDir/$filename')).called(1);
      cleanUpDir(testDestinationDir);
    });

    test('throws an exception if cant find the stub file', () {
      const testDestinationDir = 'tmp/migrations';
      final sky = SkyCommand<int>(app(), Logger(), silent: true);
      final command = MakeMigrationCommand(
        stubsDir: 'wrong/path',
        destinationDir: testDestinationDir,
      );
      sky.addTunderCommand(command);

      expect(
        () => sky.run(['make:migration', 'some migration']),
        throwsException,
      );
    });

    test('creates an index.dart file which exports the migration class',
        () async {
      // Arrange
      final sky = SkyCommand<int>(app(), Logger(), silent: true);
      final command = MakeMigrationCommand();
      final currentTime = DateTime(2020);
      final id = DateFormat('yyyy_MM_dd_HHmmss').format(currentTime);
      final name = 'Some migration name';
      sky.addTunderCommand(command);

      // Act
      withClock(Clock.fixed(currentTime), () async {
        await sky.run(['make:migration', name]);
      });
      final indexFile =
          File(join('${ConsoleConfig.migrationDestination}/index.dart'));

      // Assert
      expect(indexFile.existsSync(), true);
      expect(indexFile.readAsStringSync(), '''
export '${id}_${name.snakeCase}.dart';
// end
''');
      cleanUpDir();
    });

    test(
        'appends an export to index.dart file which exports the migration class',
        () async {
      // Arrange
      final sky = SkyCommand<int>(app(), Logger(), silent: true);
      final destinationDir = randomDir();
      final command = MakeMigrationCommand(
        destinationDir: destinationDir,
      );
      final indexFile = File(absolute('$destinationDir/index.dart'))
        ..createSync(recursive: true);
      indexFile.writeAsStringSync('''
export 'something.dart';
// end
''');
      sky.addTunderCommand(command);
      final name = 'Some migration name';
      final currentTime = DateTime(2019);
      final id = DateFormat('yyyy_MM_dd_HHmmss').format(currentTime);

      // Act
      withClock(Clock.fixed(currentTime), () async {
        await sky.run(['make:migration', name]);
      });

      // Assert
      expect(indexFile.readAsStringSync(), '''
export 'something.dart';
export '${id}_${name.snakeCase}.dart';
// end
''');
      cleanUpDir(destinationDir);
    });

    test(
        'creates a list.dart file which creates a list of Instances of migration classes',
        () async {
      // Arrange
      final sky = SkyCommand<int>(app(), Logger(), silent: true);
      final command = MakeMigrationCommand();
      final currentTime = DateTime(2018);
      final id = DateFormat('yyyy_MM_dd_HHmmss').format(currentTime);
      final name = 'Some migration name';
      sky.addTunderCommand(command);

      // Act
      await withClock(Clock.fixed(currentTime), () async {
        await sky.run(['make:migration', name]);
      });
      var listFile =
          File(join('${ConsoleConfig.migrationDestination}/list.dart'));

      // Assert
      expect(listFile.existsSync(), true);
      expect(listFile.readAsStringSync(), '''
import 'package:tunder/database.dart';

import 'index.dart';

final List<Migration> migrations = [
  Migration_$id(),
];

''');
      cleanUpDir();
    });

    test('adds a new item to migration list in list.dart file', () async {
      // Arrange
      final sky = SkyCommand<int>(app(), Logger(), silent: true);
      final command = MakeMigrationCommand();
      final listFile =
          File(absolute('${ConsoleConfig.migrationDestination}/list.dart'))
            ..createSync(recursive: true);
      listFile.writeAsStringSync('''
import 'package:tunder/database.dart';

import 'index.dart';

final List<Migration> migrations = [
  Migration1(),
];

''');
      sky.addTunderCommand(command);
      final currentTime = randomDate();
      final id = DateFormat('yyyy_MM_dd_HHmmss').format(currentTime);
      final name = 'Some migration name';

      // Act
      await withClock(Clock.fixed(currentTime), () async {
        await sky.run(['make:migration', name]);
      });

      // Assert
      expect(listFile.readAsStringSync(), '''
import 'package:tunder/database.dart';

import 'index.dart';

final List<Migration> migrations = [
  Migration1(),
  Migration_$id(),
];

''');
      cleanUpDir();
    });
  });
}

void cleanUpDir(
        [String testDestinationDir = ConsoleConfig.migrationDestination]) =>
    Directory(testDestinationDir).deleteSync(recursive: true);

String randomDir() {
  int randomNumber = Random().nextInt(100000);
  return 'tmp/migrations$randomNumber';
}

DateTime randomDate() {
  final year = 1970 + Random().nextInt(60);
  final month = Random().nextInt(12);
  final day = Random().nextInt(28);
  final hour = Random().nextInt(24);
  final minute = Random().nextInt(60);
  final second = Random().nextInt(60);
  return DateTime(year, month, day, hour, minute, second);
}

class LoggerMock extends Mock implements Logger {}

class ProgressMock extends Mock implements Progress {}
