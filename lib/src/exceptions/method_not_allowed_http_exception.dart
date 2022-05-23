import 'package:tunder/http.dart';
import 'package:tunder/src/exceptions/http_exception.dart';

class MethodNotAllowedHttpException extends HttpException {
  MethodNotAllowedHttpException()
      : super(
            statusCode: Response.HTTP_METHOD_NOT_ALLOWED,
            message: 'Method not allowed.');
}
