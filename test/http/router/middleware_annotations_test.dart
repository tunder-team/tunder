import 'dart:async';

import 'package:tunder/http.dart';
import 'package:tunder/utils.dart';
import 'package:test/test.dart';

import '../../feature.dart';
import '../../helpers.dart' as http;

main() {
  feature();

  group('Route(middlewares) annotation', () {
    setUp(() {
      Route.discovery(ExampleController);
    });

    test('it adds middleware to methods and class', () async {
      var response = await http.post(route('example.some-action'));
      expect(response.statusCode, 200);
      expect(response.body, 'someAction worked');
      expect(response.headers['my-middleware'], 'worked');
      expect(response.headers['my-class-middleware'], 'worked');
    });
  });
}

class MyMiddleware extends Middleware {
  FutureOr<Response> handle(Request request, next) async {
    Response response = await next(request);
    response.headers['my-middleware'] = 'worked';

    return response;
  }
}

class MyClassMiddleware extends Middleware {
  FutureOr<Response> handle(Request request, next) async {
    Response response = await next(request);
    response.headers['my-class-middleware'] = 'worked';

    return response;
  }
}

@Controller(middleware: MyClassMiddleware)
class ExampleController extends Controller {
  @Route(method: 'post', middleware: MyMiddleware)
  someAction() {
    return 'someAction worked';
  }
}
