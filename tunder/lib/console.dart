export 'src/console/console_kernel.dart';
export 'src/console/command.dart';
export 'src/console/sky_command.dart';

abstract class ConsoleConfig {
  static const migrationDestination = 'database/migrations';
  static const stubsDirectory = 'templates/stubs';
}
