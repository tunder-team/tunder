import 'package:tunder/console.dart';
import 'package:tunder/src/console/commands/migrations/mixins/manage_migrations.dart';

abstract class MigrationCommand extends Command<int> with ManageMigrations {
  final category = 'migrations';
}
