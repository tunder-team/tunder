class HttpException implements Exception {
  late int statusCode;
  late String message;

  HttpException({
    required this.statusCode,
    required this.message,
  });
}
