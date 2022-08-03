import 'dart:async';

import 'package:tunder/http.dart';
import 'package:tunder/utils.dart';
import 'package:test/test.dart';

import '../../feature.dart';
import '../../helpers.dart' as http;

main() {
  feature();

  group('Group function:', () {
    setUp(() {
      Route.prefix('prefix').name('crazy.').group(() {
        Route.get('get', TestController, 'index').name('get');
      });
    });

    test('it works with prefix', () async {
      var response = await http.get('prefix/get');
      expect(response.statusCode, 200);
      expect(response.body, 'index worked');
    });

    test('it works with name', () {
      expect(route('crazy.get'), '/prefix/get');
    });

    test('it works with middleware function', () async {
      Route.middlewares([MyMiddleware])
          .prefix('with-middleware')
          .name('mid.')
          .group(() {
        Route.get('route', () => 'it worked').name('route');
      });

      var response = await http.get(route('mid.route'));

      expect(route('mid.route'), '/with-middleware/route');
      expect(response.statusCode, 200);
      expect(response.body, 'it worked');
      expect(response.headers.keys.contains('my-middleware'), true);
    });
  });
}

class TestController extends Controller {
  index() => 'index worked';
}

class MyMiddleware extends Middleware {
  FutureOr<Response> handle(Request request, next) async {
    Response response = await next(request);

    response.headers.addAll({'my-middleware': 'worked'});

    return response;
  }
}
