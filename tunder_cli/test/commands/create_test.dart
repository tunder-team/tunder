import 'package:mason/mason.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:tunder_cli/src/tunder_command_runner.dart';

main() {
  group('CreateCommand:', () {
    late TunderCommandRunner runner;
    late MasonGenerator generator;
    late Logger logger;
    late Progress progress;

    setUpAll(() {
      registerFallbackValue(GeneratorTargetMock());
    });

    setUp(() {
      generator = MasonGeneratorMock();
      logger = LoggerMock();
      progress = ProgressMock();
      runner = TunderCommandRunner((_) async => generator, logger);
      when(() => logger.progress(any())).thenReturn(progress);
    });

    test('it prompts for the project name if not provided', () async {
      when(() => generator.generate(any(), vars: any(named: 'vars')))
          .thenAnswer((_) async => []);

      when(() => logger.prompt(any())).thenReturn('project_name');

      await runner.run(['create']);

      verify(() => logger.prompt('What is the name of your project?'))
          .called(1);
      verify(() => logger.progress('Creating project...')).called(1);
      verify(
        () => generator.generate(
          any(),
          vars: {
            'name': 'project_name',
          },
        ),
      ).called(1);
    });

    test('it prompts for the name while response is empty', () async {
      when(() => generator.generate(any(), vars: any(named: 'vars')))
          .thenAnswer((_) async => []);

      var responses = ['', '', 'project_name'];
      when(() => logger.prompt(any())).thenAnswer((_) => responses.removeAt(0));

      await runner.run(['create']);

      verify(() => logger.prompt('What is the name of your project?'))
          .called(3);
      verify(() => logger.progress('Creating project...')).called(1);
      verify(
        () => generator.generate(
          any(),
          vars: {
            'name': 'project_name',
          },
        ),
      ).called(1);
    });

    test('it accepts the project name as an argument', () async {
      when(() => generator.generate(any(), vars: any(named: 'vars')))
          .thenAnswer((_) async => []);

      await runner.run(['create', 'project_name']);

      verify(() => logger.progress('Creating project...')).called(1);
      verify(
        () => generator.generate(
          any(),
          vars: {
            'name': 'project_name',
          },
        ),
      ).called(1);
    });

    test('it converts the project name to snake_case', () async {
      when(() => generator.generate(any(), vars: any(named: 'vars')))
          .thenAnswer((_) async => []);

      await runner.run(['create', 'ProjectName']);

      verify(() => logger.progress('Creating project...')).called(1);
      verify(
        () => generator.generate(
          any(),
          vars: {
            'name': 'project_name',
          },
        ),
      ).called(1);
    });
  });
}

class MasonGeneratorMock extends Mock implements MasonGenerator {}

class LoggerMock extends Mock implements Logger {}

class GeneratorTargetMock extends Mock implements GeneratorTarget {}

class ProgressMock extends Mock implements Progress {}
