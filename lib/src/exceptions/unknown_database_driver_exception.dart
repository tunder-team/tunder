class UnknownDatabaseDriverException extends ArgumentError
    implements Exception {
  final String driver;

  UnknownDatabaseDriverException(this.driver)
      : super('Unknown driver [$driver]');
}
