import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:tunder/console.dart';
import 'package:tunder/database.dart';
import 'package:tunder/src/console/commands/db/wipe_command.dart';
import 'package:tunder/test.dart';
import 'package:tunder/utils.dart';

import '../contexts/sky_command_context_for_migrations.dart';

main() {
  useDatabaseTransactions();

  group('WipeCommand', () {
    test('it responds to db:wipe command', () {
      final command = WipeCommand();
      expect(command.name, 'db:wipe');
    });

    test('has description', () {
      final command = WipeCommand();
      expect(command.description, 'Drops all tables from database');
    });

    test('drops all databases from database', () async {
      // Arrange
      final table1 = 'test_wipe_command_table';
      final table2 = 'test_wipe_command_table2';
      await Schema.create(table1, (table) {
        table
          ..id()
          ..string('name')
          ..timestamps();
      });
      await Schema.create(table2, (table) {
        table
          ..id()
          ..string('name')
          ..timestamps();
      });
      expect(await DB.tableExists(table1), true);
      expect(await DB.tableExists(table2), true);
      final test = SkyCommandContext(WipeCommand());

      // Act
      await test.sky.run(['db:wipe']);

      // Assert
      expect(await DB.tableExists(table1), false);
      expect(await DB.tableExists(table2), false);
      verify(() => test.logger.progress('Dropping all tables from database'))
          .called(1);
      verify(() => test.progress.complete('Dropped all tables successfully'))
          .called(1);
    });
  });
}

class SkyCommandContext {
  late final Command<int> command;
  late final SkyCommand sky;
  late final logger = LoggerMock();
  late final progress = ProgressMock();

  SkyCommandContext(this.command) {
    sky = SkyCommand<int>(app(), logger, silent: true)
      ..addTunderCommand(command);
    mockProgressCall();
  }

  void mockProgressCall() =>
      when(() => logger.progress(any())).thenReturn(progress);
}
