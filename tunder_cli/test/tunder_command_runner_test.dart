import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:tunder_cli/tunder_cli.dart';

import 'helpers.dart';

class MockStdout extends Mock implements Stdout {
  @override
  void write(object) {
    logs.add(object);
  }
}

main() {
  group('TunderCommandRunner', () {
    late TunderCommandRunner runner;

    setUp(() {
      runner = TunderCommandRunner();
    });

    test('it displays usage if no subcommand is invoked',
        withOverrides(() async {
      await runner.run([]);
      expect(logs, [
        'Tunder CLI\n'
            '\n'
            'Usage: tunder <command> [arguments]\n'
            '\n'
            'Global options:\n'
            '-h, --help    Print this usage information.\n'
            '\n'
            'Available commands:\n'
            '  create   Create your Tunder project.\n'
            '\n'
            'Run "tunder help <command>" for more information about a command.'
      ]);
    }));
  });
}
