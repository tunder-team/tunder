class UnknownDataTypeException extends UnsupportedError implements Exception {
  final String datatype;
  final String driver;

  UnknownDataTypeException(this.datatype, this.driver)
      : super('Unknown datatype [$datatype] for [$driver]');
}
