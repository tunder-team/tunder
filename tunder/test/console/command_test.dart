import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:tunder/console.dart';

main() {
  group('Command logging method', () {
    late Logger logger;
    late SomeCommand command;

    setUp(() {
      logger = LoggerMock();
      command = SomeCommand(logger);
    });

    test('info(message)', () {
      // Act
      command.info('message');
      verify(() => logger.info('message')).called(1);
    });

    test('alert(message)', () {
      command.alert('message');
      verify(() => logger.alert('message')).called(1);
    });

    test('prompt(message)', () {
      when(() => logger.prompt(any())).thenReturn('something');
      command.prompt('message');
      verify(() => logger.prompt('message')).called(1);
    });

    test('progress(message)', () {
      when(() => logger.progress(any())).thenReturn(ProgressMock());
      command.progress('message');
      verify(() => logger.progress('message')).called(1);
    });

    test('confirm(message)', () {
      when(() => logger.confirm(any())).thenReturn(true);
      command.confirm('message');
      verify(() => logger.confirm('message')).called(1);
    });

    test('error(message)', () {
      command.error('message');
      verify(() => logger.err('message')).called(1);
    });

    test('warning(message)', () {
      command.warning('message');
      verify(() => logger.warn('message')).called(1);
    });
  });
}

class SomeCommand extends Command {
  final name = 'some:command';
  final description = 'Some command';
  final Logger logger;

  SomeCommand(this.logger);
}

class LoggerMock extends Mock implements Logger {}

class ProgressMock extends Mock implements Progress {}
