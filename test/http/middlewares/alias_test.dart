import 'package:tunder/http.dart';
import 'package:tunder/utils.dart';
import 'package:test/test.dart';

import '../../feature.dart';
import '../../helpers.dart' as http;

main() {
  feature();

  setUp(() {
    app(Router).flush();
    Kernel kernel = app(Kernel);
    kernel.routeMiddlewares['auth'] = Authenticate;
    kernel.syncMiddlewaresToRouter();
  });

  group('Middleware with alias', () {
    test('can be defined in the route', () async {
      Route.get('/something', () => 'it worked').middleware('auth');

      var response = await http.get('/something');

      expect(response.statusCode, 200);
      expect(response.body, 'it worked');
      expect(response.headers['auth'], 'worked');
    });

    test('can be defined in a route group', () async {
      Route.middlewares('auth').group(() {
        Route.get('/something', () => 'it worked').name('something');
      });

      var response = await http.get(route('something'));
      expect(response.statusCode, 200);
      expect(response.body, 'it worked');
      expect(response.headers['auth'], 'worked');
    });
  });
}

class Authenticate implements Middleware {
  handle(Request request, next) async {
    Response response = await next(request);
    response.headers['auth'] = 'worked';

    return response;
  }
}
