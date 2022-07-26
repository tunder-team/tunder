import 'package:tunder/extensions.dart';

class UnknownDatabaseDriverException extends ArgumentError
    implements Exception {
  final Symbol driver;

  UnknownDatabaseDriverException(this.driver)
      : super('Unknown driver [${driver.name}]');
}
