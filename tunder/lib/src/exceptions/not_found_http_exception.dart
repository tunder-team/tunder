import 'package:tunder/http.dart';
import 'package:tunder/src/exceptions/http_exception.dart';

class NotFoundHttpException extends HttpException {
  const NotFoundHttpException()
      : super(
          statusCode: Response.HTTP_NOT_FOUND,
          message: 'Resource not found.',
        );
}
