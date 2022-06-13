class UnknownDataTypeException extends UnsupportedError implements Exception {
  final String datatype;
  final Symbol driver;

  UnknownDataTypeException(this.datatype, this.driver)
      : super('Unknown datatype [$datatype] for [$driver]');
}
