class HttpException implements Exception {
  final int statusCode;
  final String message;

  const HttpException({
    required this.statusCode,
    required this.message,
  });
}
