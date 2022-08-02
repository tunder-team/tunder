import 'dart:io';

import 'package:tunder/src/exceptions/not_found_http_exception.dart';
import 'package:tunder/src/http/request.dart';

class Response {
  static const HTTP_NOT_FOUND = 404;
  static const HTTP_METHOD_NOT_ALLOWED = 405;

  late HttpResponse original;
  late Request request;
  Map<String, String?> headers;
  String? body;

  void set statusCode(statusCode) {
    original.statusCode = statusCode;
  }

  Response({
    required this.original,
    required this.request,
    this.headers = const {},
  }) {
    headers = {};
  }

  Response.from(Request request)
      : this(
          request: request,
          original: request.response,
        );

  static Never notFound() {
    throw NotFoundHttpException();
  }

  void write([String? overwrite]) {
    body = overwrite ?? body;
    headers.forEach((key, value) => original.headers.add(key, value!));
    original.write(body.toString());
  }

  void close(Request request) async {
    await original.flush();
    await original.close();
  }
}
