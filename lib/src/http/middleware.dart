import 'dart:async';

import 'package:tunder/src/http/request.dart';
import 'package:tunder/src/http/response.dart';

abstract class Middleware {
  FutureOr<Response> handle(Request request, next);
}
