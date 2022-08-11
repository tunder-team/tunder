import 'package:mason_logger/mason_logger.dart';
import 'package:tunder/src/console/sky_command.dart';
import 'package:tunder/tunder.dart';

class CommandServiceProvider extends ServiceProvider {
  @override
  boot(app) {
    app.bind(SkyCommand, (_) => SkyCommand(app, Logger()));
  }
}
