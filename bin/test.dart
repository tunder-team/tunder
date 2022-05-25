import 'dart:convert';
import 'dart:io';

import 'package:colorize/colorize.dart';

main(List<String> arguments) async {
  arguments.any((option) => ['--coverage'].contains(option))
      ? coverage()
      : runTests(arguments);
}

runTests(List<String> arguments) async {
  var output = CommandOutput(stdout);

  var isPretty = arguments.any((option) => ['--pretty', '-p'].contains(option));
  var outputHandler = isPretty ? output.pretty : output.simple;
  var concurrency = isPretty ? '--concurrency=1' : '';

  await execute(
    'dart run test -r expanded --chain-stack-traces $concurrency'.trim(),
    eachLine: outputHandler,
  );
}

coverage() async {
  await execute('dart run coverage:test_with_coverage');
  await execute('genhtml coverage/lcov.info -o coverage');
  await execute('open coverage/index.html');
}

Future<void> execute(String cmd, {void Function(String)? eachLine}) async {
  var args = cmd.split(' ');
  var command = args.first;
  var options = args.length > 1
      ? args.getRange(1, args.length).toList()
      : [] as List<String>;

  var process = await Process.start(
    command,
    options,
  );

  process.stdout.transform(utf8.decoder).forEach(eachLine ?? stdout.write);

  var exitCode = await process.exitCode;

  if (exitCode != 0) {
    print(Colorize('ExitCode: $exitCode.')..red());
  }
}

class CommandOutput {
  final Stdout stdout;
  Map<String, List<Line>> results = {};
  String? currentTestFile;

  CommandOutput(this.stdout);

  simple(String input) {
    Line line = Line(input);

    if (line.isResult) {
      results.containsKey(line.filename)
          ? results[line.filename]!.add(line)
          : results[line.filename] = [line];

      return line.filename == '' ? print("\n${line.input}") : printSimple(line);
    }

    print(line.input);
  }

  pretty(String input) {
    Line line = Line(input);

    if (line.isResult) {
      if (currentTestFile != line.filename) {
        currentTestFile = line.filename;
        printTestFile(line.filename);
      }

      results.containsKey(line.filename)
          ? results[line.filename]!.add(line)
          : results[line.filename] = [line];

      return printPretty(line);
    }

    print(line.input);
  }

  String extractFileFrom(String line) {
    return line
        .split(' ')
        .firstWhere((s) => s.endsWith('.dart:'), orElse: () => '');
  }

  printTestFile(String filename) {
    print(Colorize('\n$filename\n')..bold());
  }

  printPretty(Line line) {
    var icon = line.hasError
        ? (Colorize("⨯ ")
          ..red()
          ..bold().toString())
        : (Colorize("✓ ")
          ..green()
          ..bold().toString());

    print(icon);
    print(Colorize(line.description)..darkGray());
  }

  printSimple(Line line) {
    var result =
        line.hasError ? (Colorize('F\n')..red()) : (Colorize('.')..green());

    print(result);
  }

  printTest(String name) {
    print(
      Colorize(' $name ')
        ..bgGreen()
        ..black()
        ..bold(),
    );
  }

  print(line) {
    stdout.write(line);
    stdout.write(Colorize()..reverse());
  }

  warn(line) {
    print(Colorize(line)..yellow());
  }
}

class Line {
  final String input;
  late final String filename;
  late final String description;

  Line(this.input) {
    _parse(input);
  }

  bool get isResult => input.startsWith(RegExp(r'\d{2}:\d{2}'));
  bool get hasError => input.contains('[E]');

  _parse(String input) {
    List<String> parts = _sanitize(input).split(' ');
    _setFilenameFrom(parts);
    _setDescriptionFrom(parts);
  }

  String _sanitize(String input) {
    var codesRegex = RegExp('\u001b\\[[0-9;]+m');

    return input.replaceAll(codesRegex, '');
  }

  _setFilenameFrom(List<String> parts) => filename =
      parts.firstWhere((s) => s.endsWith('.dart:'), orElse: () => '');

  _setDescriptionFrom(List<String> parts) {
    if (!isResult) return;

    if (filename == '') {
      return description = input;
    }

    var filenameIndex = parts.indexOf(filename);
    description = parts.sublist(filenameIndex + 1).join(' ');
  }
}
